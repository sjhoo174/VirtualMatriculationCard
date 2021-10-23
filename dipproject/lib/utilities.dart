import 'package:flutter/material.dart';
import 'generate.dart';
import 'scan.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UtilitiesScreen extends StatefulWidget {
  @override
  _UtilitiesScreenState createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  String qrCodeResult = "";
  String studentName = "";
  String lab = "";
  String week = "";
  String session = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateAttendance() async {
    await initFirebase();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    studentName = prefs.getString("email");
    studentName = studentName.substring(0, studentName.indexOf('@'));
    lab = qrCodeResult.substring(0, 6);
    session = qrCodeResult.substring(7, 9);
    week = qrCodeResult.substring(10,16);
    print(lab);
    print(session);
    print(week);
    print(studentName);
    CollectionReference users = FirebaseFirestore.instance.collection('attendance');
    return users
      .doc(lab)
      .collection(session)
      .doc(week)
      .update({studentName: "YES"})
      .then((value) => print("User Updated"))
      .catchError((error) => print("Failed to update user: $error"));
  }
  
  void initFirebase() async {
    await Firebase.initializeApp();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "dfdf@example.com",
        password: "dfdf"
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Utilities"),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Container(height:100),
            Image(image: NetworkImage("https://download.logo.wine/logo/Nanyang_Technological_University/Nanyang_Technological_University-Logo.wine.png")),
            // Text(
            //   "Hello \n Alvin Koh Jun Ming",
            //   style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: 30.0,),
            FlatButton(
              height: 45,
              minWidth: 300,
              onPressed: () async {
                String codeSanner = await BarcodeScanner.scan();    //barcode scnner
                qrCodeResult = codeSanner;
                updateAttendance();
              },
              child: Text('Scan Attendance', style: TextStyle(
                  color: Colors.blue
                )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                color: Colors.blue,
                
                width: 3,
                style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(50)),
            ),
            SizedBox(height: 20.0,),
            FlatButton(
              height: 45,
              minWidth: 300,
              onPressed: () async {
                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => GeneratePage()));
              },
              child: Text('Generate QR Code', style: TextStyle(
                  color: Colors.blue
                )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                color: Colors.blue,
                
                width: 3,
                style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(50)),
            ),
          ],
        ),
      ),
    );

  }
  // Widget flatButton(String text, Widget widget) {
  //   return FlatButton(
  //     padding: EdgeInsets.all(15.0),
  //     onPressed: () async {
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: (context) => widget));
  //     },
  //     child: Text(
  //       text,
  //       style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),
  //     ),
  //     shape: RoundedRectangleBorder(
  //         side: BorderSide(color: Colors.blue,width: 3.0),
  //         borderRadius: BorderRadius.circular(20.0)),
  //   );
  // }
}