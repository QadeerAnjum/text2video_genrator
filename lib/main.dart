import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:text2video_app/managers/userManager.dart';
import 'package:text2video_app/src/features/core/Screens/Text2VideoUI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text2video_app/src/features/core/Screens/paymentPage.dart';

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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _handleFirstLaunch();
  }

  Future<void> _handleFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPayment = prefs.getBool('hasSeenPayment') ?? false;

    // Fetch user ID in background
    final userId = await UserManager.getUserID();
    print("Backend User ID: $userId");

    // Wait for 3 seconds before navigating
    await Future.delayed(Duration(seconds: 3));
    _animationController.stop();

    if (!hasSeenPayment) {
      // Set the flag so payment screen only shows once
      await prefs.setBool('hasSeenPayment', true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => PaymentPage(
                onClose: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => TextToVideoUI()),
                  );
                },
              ),
        ),
      );
    } else {
      // Go directly to main UI
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => TextToVideoUI()));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _animationController.value,
                    minHeight: 5,
                    backgroundColor: Colors.green.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.greenAccent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
