import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CreditsProvider.dart';
import 'creditButton.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({Key? key}) : super(key: key);

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  int currentCredits = 0;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    super.initState();
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
    );
    _initializeStore();
    _loadCredits();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        final provider = Provider.of<CreditsProvider>(context, listen: false);

        switch (purchaseDetails.productID) {
          case 'credit_500':
            await provider.addCredits(500);
            break;
          case 'credits_5000':
            await provider.addCredits(5000);
            break;
          case 'credits_10000':
            await provider.addCredits(10000);
            break;
        }

        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _initializeStore() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    setState(() => _available = isAvailable);

    if (isAvailable) {
      const Set<String> _kIds = {'credit_500', 'credits_5000', 'credits_10000'};
      final response = await _inAppPurchase.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        print("Products not found: ${response.notFoundIDs}");
      }
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCredits = prefs.getInt('credits') ?? 0;
    setState(() {
      currentCredits = savedCredits;
    });
  }

  void _buyCredits(BuildContext context, String productId) async {
    final provider = Provider.of<CreditsProvider>(context, listen: false);

    if (!provider.hasSubscribed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to purchase a plan to get credits.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ProductDetails? product;
    try {
      product = _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      product = null;
    }

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  Widget _creditCard(
    BuildContext context,
    String productId,
    int amount,
    int credits,
    double cardWidth,
  ) {
    return GestureDetector(
      onTap: () => _buyCredits(context, productId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$credits Credits',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$$amount',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Buy',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const spacing = 8.0;
    const totalCards = 3;

    final creditsProvider = Provider.of<CreditsProvider>(context);
    final totalSpacing = spacing * (totalCards - 1) + 40;
    final cardWidth = ((screenWidth - totalSpacing) / totalCards).clamp(
      100.0,
      200.0,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Buy Credits',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CreditsButton(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Credits button tapped"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Colors.green, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buy More Points Here To Generate Videos',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 50),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: [
                _creditCard(context, 'credit_500', 5, 500, cardWidth),
                _creditCard(context, 'credits_5000', 50, 5000, cardWidth),
                _creditCard(context, 'credits_10000', 100, 10000, cardWidth),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
