import 'package:Motion_AI/src/features/core/Screens/CreditsProvider.dart';
import 'package:Motion_AI/src/features/core/Screens/Text2VideoUI.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  final VoidCallback onClose;

  const PaymentPage({required this.onClose, Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  bool _loading = true;
  List<ProductDetails> _products = [];
  bool _purchasePending = false;
  String? _queryProductError;

  final List<String> _productIds = ['weekly_plan_id', 'yearly_plan_id'];

  @override
  void initState() {
    super.initState();

    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        // Handle error here.
        debugPrint('Purchase Stream error: $error');
      },
    );

    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!mounted) return;

    setState(() {
      _available = isAvailable;
      _loading = false;
    });

    if (!_available) {
      setState(() {
        _products = [];
        _queryProductError = 'Store not available';
      });
      return;
    }

    final response = await _inAppPurchase.queryProductDetails(
      _productIds.toSet(),
    );
    if (!mounted) return;

    if (response.error != null) {
      setState(() {
        _queryProductError = response.error!.message;
        _products = [];
      });
      return;
    }

    if (response.productDetails.isEmpty) {
      setState(() {
        _queryProductError = 'No products found';
        _products = [];
      });
      return;
    }

    setState(() {
      _products = response.productDetails;
      _queryProductError = null;
    });

    // Debug logs
    debugPrint("Store available: $_available");
    debugPrint("Found ${_products.length} products");
    for (var product in _products) {
      debugPrint(
        "Product: ${product.id} - ${product.title} - ${product.price}",
      );
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          setState(() => _purchasePending = true);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          _handleError(purchaseDetails.error!);
          break;

        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
      debugPrint(
        "Received purchase update: ${purchaseDetails.productID}, status: ${purchaseDetails.status}",
      );
    }
  }

  void _verifyPurchase(PurchaseDetails purchaseDetails) async {
    setState(() {
      _purchasePending = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final creditsProvider = context.read<CreditsProvider>();

    // Add credits and update flags
    await creditsProvider.addCreditsForSubscription(purchaseDetails.productID);
    await prefs.setBool('hasSubscribed', true);
    await prefs.setInt('remainingCredits', creditsProvider.credits);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Purchased ${purchaseDetails.productID} - Credits Updated!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // ✅ Navigate on both purchased and restored
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TextToVideoUI()),
      );
    }
  }

  void _handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Purchase error: ${error.message}')));
  }

  void _buyProduct(ProductDetails productDetails) {
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    setState(() {
      _purchasePending = true;
    });

    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _restorePurchases() async {
    setState(() {
      _purchasePending = true;
    });

    await _inAppPurchase.restorePurchases();

    // Wait up to 5 seconds; remove loading if no restore happens
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _purchasePending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No previous purchases found or restored.')),
        );
      }
    });
  }

  String getPlanTitle(String productId) {
    switch (productId) {
      case 'weekly_plan_id':
        return "Weekly Plan";
      case 'yearly_plan_id':
        return "Yearly Plan";
      default:
        return "Premium Plan";
    }
  }

  int getPlanCoins(String productId) {
    switch (productId) {
      case 'weekly_plan_id':
        return 500;
      case 'yearly_plan_id':
        return 5000;
      default:
        return 1000;
    }
  }

  String? getDiscountText(String productId) {
    if (productId == 'yearly_plan_id') return "Save 70%";
    return null;
  }

  bool isPlanPopular(String productId) {
    return productId == 'weekly_plan_id';
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<bool> checkIfUserHasActiveSubscription() async {
    final Completer<bool> completer = Completer();
    final purchaseUpdated = InAppPurchase.instance.purchaseStream;

    final sub = purchaseUpdated.listen((purchaseDetailsList) async {
      for (final purchase in purchaseDetailsList) {
        if ((purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored) &&
            (purchase.productID == 'weekly_plan_id' ||
                purchase.productID == 'yearly_plan_id')) {
          completer.complete(true);
          return;
        }
      }

      // No valid purchases found
      completer.complete(false);
    });

    // Trigger restore
    await InAppPurchase.instance.restorePurchases();

    // Wait max 5 seconds for purchase stream to emit
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
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_available) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _queryProductError ?? 'Store not available',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            height: 200,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 1,
              bottom: 1,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/image.png', fit: BoxFit.cover),
                Positioned(
                  top: 0,
                  right: 16,
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => TextToVideoUI()),
                      );
                    },

                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AI Text to Video PRO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeature("No Watermarks"),
                    _buildFeature("Ads - Free"),
                    const SizedBox(height: 30),

                    if (_products.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          _queryProductError ?? 'No products available',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),

                    ..._products.map((product) {
                      return _buildPlanCard(
                        title: getPlanTitle(product.id),
                        price: product.price,
                        coins: getPlanCoins(product.id),
                        discount: getDiscountText(product.id),
                        isPopular: isPlanPopular(product.id),
                        onTap:
                            _purchasePending
                                ? null
                                : () => _buyProduct(product),
                      );
                    }).toList(),

                    if (_purchasePending)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    const SizedBox(height: 20),

                    Text(
                      "Subscription is auto-renewable and you will be charged unless you cancel before the renewal date. Secured by PlayStore.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed:
                              _purchasePending ? null : _restorePurchases,
                          child: const Text(
                            "Restore Purchases",
                            style: TextStyle(color: Colors.cyanAccent),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Terms & Conditions",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Privacy Policy",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required int coins,
    String? discount,
    bool isPopular = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient:
              isPopular
                  ? const LinearGradient(
                    colors: [Color(0xFFFF8C00), Color(0xFFDAA520)],
                  )
                  : null,
          color: isPopular ? null : Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: isPopular ? null : Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Popular",
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isPopular ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "$coins Coins",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(width: 12),
                if (discount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
