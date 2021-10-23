import 'package:flutter/material.dart';
import './login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import './main.dart';

class Splash extends StatefulWidget {
  final String next;

  Splash({Key key, @required this.next});
  @override
  _SplashState createState() => new _SplashState(next: next);
}

class _SplashState extends State<Splash> {
  final String next;

  String text;

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  _SplashState({Key key, @required this.next});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5), () {
      proceed();
    });
    
       
  }

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        title: 'U-Swift',
        routes: {
          '/Login': (context) => LoginScreen(),
          '/Home' : (context) => HomeScreen()
        },
        home: Scaffold(
          body: Column(
            
            children: [
              Container(height:270),
              Container( 
                height:220,
                width:260,
                
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://download.logo.wine/logo/Nanyang_Technological_University/Nanyang_Technological_University-Logo.wine.png"),
                    fit: BoxFit.fill,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              Container(height:30),
              returnText(),
              Container(height:100),
              CircularProgressIndicator()
            ],
          )
        )
    );
  }
  

  Widget returnText() {
    if (next == 'home') {
      return new Text("Verifying your credentials...",
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0
        ));
    } else {
      return new Text("Loading your profile...",
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0
        ));
    }
  }

  void proceed() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
        int status = prefs.getInt("status");
        if (status == 1) {
          navigatorKey.currentState.pushReplacementNamed('/Home');

        } else {
          navigatorKey.currentState.pushReplacementNamed('/Login');

        }
      } on Exception catch(e) {
          navigatorKey.currentState.pushReplacementNamed('/Login');
      }
      
    }

  // Widget returnScreen() {
  //   switch (next) {
  //   case "login":
  //     return new LoginScreen();
  //   case "profile": 
  //     return new ProfileScreen();
  //   case "utilities":
  //     return new UtilitiesScreen();
  //   case "home":
  //     return new HomeScreen();
  // }
  // }
}