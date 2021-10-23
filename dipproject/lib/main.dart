import 'package:dipproject/profile.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' show radians;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import './utilities.dart';
import './login.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './splashscreen.dart';

// Flutter radial menu staggered

void main() {
  runApp(Splash(next: 'homefirst'));
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  
} 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
  
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext buildContext) {
    return HomePage();
    
  }
}

class HomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
  
                
}

class _MyHomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext buildContext) {
    return  MaterialApp(
      title: 'U-Swift',
      
      routes: {
        '/Profiles': (context) => ProfileScreen(),
        '/Login': (context) => LoginScreen(),
        '/Utilities': (context) => UtilitiesScreen()
      },
      home: Scaffold(
              body: Stack(
                children:[
                  // new Container(
                  //   decoration: new BoxDecoration(
                  //     image: new DecorationImage(image: new AssetImage("lib/images/naturebackground.jpg"), fit: BoxFit.cover,),
                  //   ),
                  // ),
                  Column(
                    children:[
                      Container(height:180),
                      Text("U-Swift", 
                        style:  GoogleFonts.lato(
                          fontSize:50,
                          fontStyle: FontStyle.italic,
                        )
                      ),
                      Container(height:120),
                      RadialMenu(),
                      Container(height:50),
                      
                    ]
                  )
                ]
              )
      )
    );
  }

  
}

class RadialMenu extends StatefulWidget {
  createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with SingleTickerProviderStateMixin {
  
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: 900), vsync: this);
                  // ..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return RadialAnimation(controller: controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


class RadialAnimation extends StatefulWidget {
  final AnimationController controller;
  final Animation<double> rotation;
  final Animation<double> translation;
  final Animation<double> scale;

  RadialAnimation({ Key key, this.controller }) :

    translation = Tween<double>(
      begin: 0.0,
      end: 90.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut
      ),
    ),

    scale = Tween<double>(
      begin: 1.5,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn
      ),
    ),

    rotation = Tween<double>(
      begin: 0.0,
      end: 360.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0, 0.7,
          curve: Curves.decelerate,
        ),
      ),
    ),
    
  super(key: key);

  @override
  RadialAnimationState createState() => RadialAnimationState();  
    
}

void navigate(BuildContext context, String target) {
  Navigator.pushNamed(context, target);
}

class RadialAnimationState extends State<RadialAnimation> {
  AnimationController controller;
  Animation<double> rotation;
  Animation<double> translation;
  Animation<double> scale;

  static const platform = const MethodChannel('HceService');
  String canId;

  Future<Null> startHceService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  
    String email = prefs.getString("email");
    try {
      final String result = await platform.invokeMethod('HceService',{"email": email}); 
    } on PlatformException catch (e) {
    }
  }

  bool nfcVisibility = true;
  @override
  Widget build(BuildContext context) {
    controller = widget.controller;
    rotation = widget.rotation;
    translation = widget.translation;
    scale = widget.scale;
    print(scale.value);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, widget) { 
        return Transform.rotate(
          angle: radians(rotation.value),
          child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildButton('profile',29, 'Profile', "/Profiles", context, color:Color.fromARGB(255, 255, 51, 51), icon: FontAwesomeIcons.idCard),
            _buildButton('utilities',149, 'Utilities', "/Utilities", context, color: Color.fromARGB(255, 160, 160, 160), icon:FontAwesomeIcons.qrcode),
            _buildButton('login', 269, 'Login', "/Login", context, color: Color.fromARGB(255, 52, 31, 188), icon: FontAwesomeIcons.tools),
         
            Transform.scale(
              scale: scale.value - 1,
              child: FloatingActionButton(heroTag: 'cross', child: Icon(FontAwesomeIcons.timesCircle), onPressed: _close, backgroundColor: Colors.green),
            ),
            Transform.scale(
              scale: scale.value,
              child: Column(
                children: [
                  Container(
                    height:40
                  ),
                  Container(
                    height:135,
                    width:135,
                    child: InkWell(
                      onLongPress: () {
                        print("started");
                        startHceService();
                      },
                      child: FloatingActionButton(
                        heroTag: 'main',
                        child: Icon(FontAwesomeIcons.solidDotCircle, size: 40), 
                        backgroundColor: Color.fromARGB(255, 52, 31, 188),
                        onPressed: _open
                      ),
                    ),
                    
                  ),
                  Container(
                    height:20
                  ),
                  Visibility(
                    child: Text("Long Hold to Activate NFC",
                    style: new TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 52, 31, 188),
                      fontWeight: FontWeight.w500)
                    ),
                    visible: nfcVisibility,
                  ),
                ]
              )
            ),
           
        ])
      );
    });
  }

  void setNfcVisibility(bool flag) {
    setState(() {
      nfcVisibility = flag;

    });
  }

  _open() {
    controller.forward();
    setNfcVisibility(false);
  }

  _close() {
    controller.reverse();
    setNfcVisibility(true);
  }

  _buildButton(String tag, double angle, String text, String target, BuildContext context, { Color color, IconData icon }) {
    final double rad = radians(angle);
    return Transform(
      transform: Matrix4.identity()..translate(
        (translation.value) * cos(rad), 
        (translation.value) * sin(rad)
      ),
           
      child: Container(
        width: 180,
        height: 180,
        child: FloatingActionButton(
          heroTag: tag,
          child: Column(children: [
            Container(height: 50),
            Icon(icon, size: 50),
            Container(height: 10),
            Text(text,
              style: new TextStyle(
                fontSize: 20.0,
              )
            )
          ],), 
          backgroundColor: color, 
          onPressed: () => navigate(context, target), 
          elevation: 0)
        )
    );
  }
  
}


