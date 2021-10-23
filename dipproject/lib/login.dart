import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './splashscreen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
 
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  

  String statusMessage = "...";
  bool userExists;


  void getStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int status = prefs.getInt("status");  
    bool invalid = prefs.getBool("invalid");
    if (status ==1) {
      print("status");
      if (invalid == true) {
        print('invalid');
        setState(() {
          statusMessage = "Please re-enter credentials.";
        });
      } else {
        setState(() {
          statusMessage = "You are signed in as " +  prefs.getString("email");

        });
      }
      
    } else {
      setState(() {
        statusMessage = "You are not signed in yet.";
      });
    
    }
   
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 52, 31, 188),
        title: Text("NTU Credentials"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height:60
            ),
            Text("U-Swift", 
              style:  GoogleFonts.lato(
                fontSize:50,
                fontStyle: FontStyle.italic
              )
            ),
            Container(
              height:30
            ),
            Text(statusMessage),
            Container(height: 40),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: controller1,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your email as in the format',
                    hintText: 'E.g. jackson@e.ntu.edu.sg'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: controller2,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter password'),
              ),
            ),
         
            Container(height: 40),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 52, 31, 188), borderRadius: BorderRadius.circular(20)),
              child: FlatButton(
                onPressed: () {
                  if (controller1.text != "" && controller2.text != "") {
                    setData(controller1.text, controller2.text, context);
                    
                  } else {
                    showToast();
                  }
                  
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }

  showToast() {
    Fluttertoast.showToast(
        msg: "Please enter valid credentials!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void setData(email, password, context) async {
    await Firebase.initializeApp();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "dfdf@example.com",
        password: "dfdf"
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Splash(next: "home")));
      storeData(email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {   
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<bool> storeData(email) async {
    String name;
    String matric;
    String birthdate;
    String gradyear;
    String yos;
    String course;
    bool success;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await FirebaseFirestore.instance
        .collection('students')
        .doc(controller1.text)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
          print(documentSnapshot.data());
          if (documentSnapshot.exists) {
            if (documentSnapshot.data()["password"] == controller2.text) {
              name = documentSnapshot.data()['name'];
              matric = documentSnapshot.data()['matric'];
              birthdate = documentSnapshot.data()['birthdate'];
              gradyear = documentSnapshot.data()['gradyear'];
              yos = documentSnapshot.data()['yos'];
              course = documentSnapshot.data()['course'];

              success = true;
              prefs.setBool("invalid", false);

            } else {
              prefs.setBool("invalid", true);
              success = false;

            }
          } else {
            prefs.setBool("invalid", true);
            success = false;
          }
        });

    prefs.setString("email", email);
    prefs.setString("name", name);
    prefs.setString("birthdate", birthdate);
    prefs.setString("yos", yos);
    prefs.setString("matric", matric);
    prefs.setString("gradyear", gradyear);
    prefs.setString("course", course);
    prefs.setInt("status", 1);

    return success;
  }
}