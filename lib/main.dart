import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:text2video_app/managers/userManager.dart';
import 'package:text2video_app/src/features/core/Screens/Text2VideoUI.dart';

void main() {
  runApp(Text2VideoApp());
}

class Text2VideoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: 'pk_test_ZmlybS1mb3dsLTcxLmNsZXJrLmFjY291bnRzLmRldiQ',
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Text To Video Generator',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.blueAccent,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    UserManager.getUserID().then((userId) {
      print("Backend User ID: $userId");

      Timer(Duration(seconds: 3), () {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => TextToVideoUI()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Text To Video Generation',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
