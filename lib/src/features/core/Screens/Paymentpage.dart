import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

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
  List<ProductDetails> _products = [];
  bool _purchasePending = false;

  final List<String> _productIds = ['weekly_plan_id', 'yearly_plan_id'];
  // Replace these with your actual product IDs from Play Store / App Store

  @override
  void initState() {
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // handle error here.
      },
    );
    _initStoreInfo();
    super.initState();
  }

  Future<void> _initStoreInfo() async {
    _available = await _inAppPurchase.isAvailable();
    if (!_available) {
      setState(() {
        _products = [];
      });
      return;
    }
    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
      _productIds.toSet(),
    );
    if (response.error != null) {
      // handle error
    }
    if (response.productDetails.isEmpty) {
      // no products found
    }
    setState(() {
      _products = response.productDetails;
    });
    print("Store available: $_available");
    print("Found ${response.productDetails.length} products");
    for (var product in response.productDetails) {
      print("Product: ${product.id} - ${product.title} - ${product.price}");
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails.error!);
      }
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _verifyPurchase(PurchaseDetails purchaseDetails) {
    // TODO: Verify purchase with your server or receipt validation
    setState(() {
      _purchasePending = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Purchase successful: ${purchaseDetails.productID}'),
      ),
    );
    widget.onClose(); // close payment page after success
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
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    setState(() {
      _purchasePending = true;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Store not available',
            style: TextStyle(color: Colors.white),
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
                    onTap: widget.onClose,
                    child: Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Text to Video PRO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildFeature("No Watermarks"),
                    _buildFeature("Ads - Free"),
                    SizedBox(height: 30),
                    ..._products.map((product) {
                      final bool isWeekly = product.id == 'weekly_plan_id';
                      return _buildPlanCard(
                        title: isWeekly ? "Weekly Plan" : "Yearly Plan",
                        price: product.price,
                        coins: isWeekly ? 500 : 5000,
                        discount: isWeekly ? null : "Save 70%",
                        isPopular: isWeekly,
                        onTap: () {
                          if (!_purchasePending) {
                            _buyProduct(product);
                          }
                        },
                      );
                    }).toList(),
                    if (_purchasePending)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    SizedBox(height: 20),
                    Text(
                      "Subscription is auto-renewable and you will be charged unless you cancel before the renewal date. Secured by PlayStore.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
          Icon(Icons.check, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.white)),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient:
              isPopular
                  ? LinearGradient(
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
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Popular",
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
            SizedBox(height: 8),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "$coins Coins",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(width: 12),
                if (discount != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      discount,
                      style: TextStyle(
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
