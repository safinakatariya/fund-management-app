import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_app/Screens/dashboard_screen.dart';
import 'package:fund_app/Screens/signup_screen.dart';
// You need to create this screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  void checkAuthentication() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    if (user != null) {
      // User is signed in, navigate to Dashboard
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      });
    } else {
      // User is not signed in, navigate to Signup
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SignupScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipOval(
              child: Image.asset('assets/logo.jpg', height: 400),
            ),
            SizedBox(height: 24),
            Text('Ψ આઈ શ્રી ખોડિયાર માં Ψ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
