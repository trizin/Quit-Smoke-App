import 'package:flutter/material.dart';
import 'package:quitsmoke/screens/home_screen.dart';
import 'package:quitsmoke/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  _donavigate() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString("startTime") != null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => WelcomeScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    _donavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(""),
    );
  }
}
