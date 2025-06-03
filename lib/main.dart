import 'package:Motion_AI/src/features/core/Screens/CreditsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Motion_AI/managers/userManager.dart';
import 'package:Motion_AI/src/features/core/Screens/WelcomeScreen.dart';
import 'package:Motion_AI/src/features/core/Screens/Text2VideoUI.dart';
import 'package:Motion_AI/src/features/core/Screens/paymentPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CreditsProvider(),
      child: Text2VideoApp(),
    ),
  );
}

class Text2VideoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

    // Run heavy logic AFTER first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    // Show splash UI instantly while doing heavy work in background
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
    final hasSeenPayment = prefs.getBool('hasSeenPayment') ?? false;

    // Small delay only if really needed
    await Future.delayed(Duration(milliseconds: 3000));

    if (!hasSeenWelcome) {
      await prefs.setBool('hasSeenWelcome', true);
      _navigateTo(WelcomeScreen());
    } else if (!hasSeenPayment) {
      await prefs.setBool('hasSeenPayment', true);
      _navigateTo(
        PaymentPage(
          onClose: () {
            _navigateTo(TextToVideoUI());
          },
        ),
      );
    } else {
      _navigateTo(TextToVideoUI());
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tip: Replace large asset with small or compressed one if needed
            Image.asset(
              'assets/trasns-videoapp.png',
              width: 100,
              height: 100,
              filterQuality: FilterQuality.low, // Optimize image rendering
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                minHeight: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
