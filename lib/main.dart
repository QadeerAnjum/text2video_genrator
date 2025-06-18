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
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

    bool isSubscribed = await _checkSubscription();

    if (!hasSeenWelcome) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
      prefs.setBool('hasSeenWelcome', true);
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
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
