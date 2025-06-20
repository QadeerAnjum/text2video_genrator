import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Motion_AI/src/features/core/Screens/CreditsProvider.dart';
import 'package:Motion_AI/src/features/core/Screens/WelcomeScreen.dart';
import 'package:Motion_AI/src/features/core/Screens/Text2VideoUI.dart';
import 'package:Motion_AI/src/features/core/Screens/paymentPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CreditsProvider())],
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
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Show native splash for at least 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

    bool isSubscribed = await _checkSubscription();

    if (!hasSeenWelcome) {
      prefs.setBool('hasSeenWelcome', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
    } else if (isSubscribed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TextToVideoUI()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaymentPage(
                onClose: () async {
                  bool newSub = await _checkSubscription();
                  if (newSub) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => TextToVideoUI()),
                    );
                  }
                },
              ),
        ),
      );
    }
  }

  Future<bool> _checkSubscription() async {
    // Query past purchases to verify active subscription
    final Stream<List<PurchaseDetails>> purchaseStream =
        _inAppPurchase.purchaseStream;
    final Completer<bool> completer = Completer();

    final sub = purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if ((purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored) &&
            (purchase.productID == 'weekly_plan_id' ||
                purchase.productID == 'yearly_plan_id')) {
          completer.complete(true);
          return;
        }
      }
      completer.complete(false);
    });

    // Restore purchases to trigger purchaseStream
    await _inAppPurchase.restorePurchases();

    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        sub.cancel();
        return false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo
            Image.asset(
              'assets/trasns-videoapp.png', // Replace with your actual logo path
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),

            // Horizontal loading bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                backgroundColor: Colors.white24,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
