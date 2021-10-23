import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyHomePage());

}

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Virtual Matric Card',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.yellow,
//         // This makes the visual density adapt to the platform that you run
//         // the app on. For desktop platforms, the controls will be smaller and
//         // closer together (more dense) than on mobile platforms.
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Virtual Matric Card'),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

// NFC Functionality
  static const platform = const MethodChannel('readNFC');

  String nfcText ="Nothing";
  bool supportsNFC = false;
  String status = "Ready to receive";
  bool tapstatus = false;
  Timer timer;
  String message = "";
  bool alreadyRegistered = false;
  bool loggedin;

  @override
  void initState() {
    super.initState();
    asyncMethod();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) => checkIfTapped());
  }

   void asyncMethod() async {
    await initFirebase();
    // ....
  }

  void checkIfTapped() async{
    message = await platform.invokeMethod('readNFC');
    FirebaseAuth.instance
    .authStateChanges()
    .listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
        loggedin = false;
      } else {
        print('User is signed in!');
        loggedin = true;
      }
    });
    if (loggedin == false) {
      await initFirebase();
    }
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc("EE3002")
        .collection("01")
        .doc("week01")
        .get()
        .then((DocumentSnapshot documentSnapshot) {
          print(documentSnapshot.data());
          if (documentSnapshot.exists) {
            if (documentSnapshot.data()[message] == "YES") {
              setState(() {
                status = "Ready to receive, previous tap is registered";
                tapstatus = false;
                alreadyRegistered = true;
              });
            } else {
              alreadyRegistered = false;
            }
          }
        });
      if (alreadyRegistered == false) {
        setState(() {
          nfcText = message;
          print("THE MESSAGE IS: " + message);
          if (nfcText != "" && nfcText != "transceive") {
            status = "Tap button to register attendance for " + nfcText + "@e.ntu.edu.sg";
            tapstatus = true;
          } else {
            status = "Ready to receive";
            tapstatus = false;
          }
        });
      }
      
  }

  void initFirebase() async {
    await Firebase.initializeApp();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "dfdf@example.com",
        password: "fdff"
      );
      print("here");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {   
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      print("failed");
    }
  }
  
  Future<void> updateAttendance() async {
    FirebaseAuth.instance
    .authStateChanges()
    .listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
        loggedin = false;
      } else {
        print('User is signed in!');
        loggedin = true;
      }
    });
    if (loggedin == false) {
      await initFirebase();
    }
    print('HHHH');
    String m = await platform.invokeMethod('readNFC');
    setState(() {
      nfcText = m;
      print("THE MESSAGE IS: " + m);
    });
    CollectionReference users = FirebaseFirestore.instance.collection('attendance');
    return users
      .doc("EE3002")
      .collection('01')
      .doc('week01')
      .update({nfcText: "YES"})
      .then((value) => print("User Updated"))
      .catchError((error) => print("Failed to update user: $error"));

  }

  // void bookFacilities() async {
  //   await initFirebase();
  //   String message = await platform.invokeMethod('readNFC');
  //   setState(() {
  //     nfcText = message;
  //     print("THE MESSAGE IS: " + message);
  //   });
  //   CollectionReference users = FirebaseFirestore.instance.collection('staff');
  //   return users
  //     .doc('faeyz100@e.ntu.edu.sg')
  //     .collection('EE3002')
  //     .doc('week1')
  //     .update({nfcText: "Attended"})
  //     .then((value) => print("User Updated"))
  //     .catchError((error) => print("Failed to update user: $error"));

  // }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MaterialApp(
        home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("NFC Reader"),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                minWidth: 150.0,
                height: 50.0,
                child: RaisedButton(
                  onPressed: () {
                    if (tapstatus == true) {
                      
                      updateAttendance();
                    }
                  },
                  child: Text("Attendance taking"),
                ),
              ),
              SizedBox(width: 5,
              height: 20),
              Text(status, textAlign: TextAlign.center,)
              
            ],
          ),
        ),
        
      )
    );
  }
}
