import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barcode_flutter/barcode_flutter.dart';


class Profile extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: ProfileScreen(),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

/// This is the stateless widget that the main application instantiates.
class _ProfileScreenState extends State<ProfileScreen> {

  String matricNumber = "---";
  String studentName = "---";
  String birthDate = "---";
  String course = "---";
  String gradyear = "---";
  String yos = "---";
  String imageURL = "https://developers.google.com/maps/documentation/streetview/images/error-image-generic.png";

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Matriculation Details"),
      ),
      body: Column(
        children: [
          Container(height:20),
          Card(
            child: Container(
              height: 250,
              width: 360,
                decoration: new BoxDecoration(
                      image: new DecorationImage(image: new AssetImage("lib/images/background.jpg"), fit: BoxFit.cover,),
                    ),
                child: Column(
                  children: [
                    Row(children: [
                      Container(
                        width:20,
                      ),
                    Column(
                      children: [
                        Container(
                          height:20,
                          width:150
                        ),
                        Container( 
                          height:60,
                          width:150,
                          
                          // decoration: BoxDecoration(
                          //   image: DecorationImage(
                          //     image: NetworkImage("https://www3.ntu.edu.sg/cits2/maintenance/img/logo/hires_logo_bw_school.jpg"),
                          //     fit: BoxFit.fitWidth,
                          //     alignment: Alignment.topCenter,
                          //   ),
                          // ),
                        ),
                        Container(
                          height:10,
                          width:150
                        ),
                        Container(
                          height:90,
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height:90,
                                child: Column(
                                  children:[Container( 
                                    height:80,
                                    width:70,
                                      
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(imageURL),
                                          fit: BoxFit.fill,
                                          alignment: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                              Container(
                                width:5
                              ),
                              Container(
                                height:80,
                                child: Column(
                                
                                  children: [
                                    Text(matricNumber, 
                                      style: new TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                    ),
                                    Text(studentName)
                                  ],
                                )
                              )
                              
                            ]
                          )
                        )
                                               
                      ]
                    ),
                    Column(
                      children: [
                        Container(
                          height:100,
                          width:70
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          height:140,
                          // child: Text("STUDENT", 
                          //   style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                          // ),
                        )
                      ]
                    ),
                    Container(
                      width:20
                    )
                    
                  ]
                ),
                BarCodeImage(
                  params: Code39BarCodeParams(
                    matricNumber,
                    lineWidth: 1.5,
                    barHeight: 40.0,
                    withText: false,
                  ),
                  onError: (error){
                    print('error= $error');
                  },
                )
                  ],
                )
                
                  
            )
          ),
          Container(height:20),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget> [
              const ListTile(
                title: const Text('Information', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              ),
              Align(
                alignment: Alignment(0, 0),
                child: Container(
                  child: Text("Birthdate: " + birthDate),
                ),
              ),
              Align(
                alignment: Alignment(0, 0),
                child: Container(
                  child: Text("Course: " + course),
                ),
              ),
              Align(
                alignment: Alignment(0, 0),
                child: Container(
                  child: Text("Graduation Year: " + gradyear),
                ),
              ),
              Align(
                alignment: Alignment(0, 0),
                child: Container(
                    child: Text("Matric Number: " + matricNumber),
                  ),
                ),
              Align(
                alignment: Alignment(0, 0),
                child: Container(
                  child: Text("Year of Study: " + yos),
                ),
              ),
            ]
          )
        ]
      )
    );
  }


  void getDetails() async{
    await Firebase.initializeApp();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "dfdf@example.com",
        password: "dfd"
      );
     
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {   
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    bool invalid = prefs.getBool("invalid");
    if (invalid == false) {
      String email = prefs.getString("email");
      print(email);

      imageURL = await firebase_storage.FirebaseStorage.instance
        .ref(email+'.PNG')
        .getDownloadURL();
      setState(() {
        studentName = prefs.getString("name");  
        matricNumber = prefs.getString("matric");
        course = prefs.getString("course");
        gradyear = prefs.getString("gradyear");
        yos = prefs.getString("yos");
        birthDate = prefs.getString("birthdate");

      });
    
    } else {
      setState(() {
        studentName = "---";  
        matricNumber = "---";
        course = "---";
        gradyear = "---";
        yos = "---";
        birthDate = "---";

      });
    }
   
  }
      

}
