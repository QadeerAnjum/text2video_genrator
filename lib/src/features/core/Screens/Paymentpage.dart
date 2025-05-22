import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final VoidCallback onClose;

  const PaymentPage({required this.onClose, Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int selectedPlanIndex = 0; // 0 = Weekly, 1 = Yearly, 2 = Monthly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header Section
          Container(
  width: double.infinity,
  height: 200, // Set a specific height for background visibility
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).padding.top + 1,
    bottom: 1
  ),
  child: Stack(
    fit: StackFit.expand,
    children: [
      // Background Image
      Image.asset(
        'assets/image.png',
        fit: BoxFit.cover,
      ),
       // Close button
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
          // Bottom Scrollable Content
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
                    Text("AI Text to Video PRO",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    _buildFeature("Unlimited Text to Video Generations"),
                    _buildFeature("Unlimited HD Exports"),
                    _buildFeature("No Watermarks"),
                    _buildFeature("Ads - Free"),
                    SizedBox(height: 30),
                    _buildPlanCard(
                      index: 0,
                      title: "Weekly Plan",
                      price: "Rs 1,950.00/Weekly",
                      oldPrice: "Rs2632",
                      discount: "Save 35%",
                      isPopular: true,
                      trial: true,
                    ),
                    _buildPlanCard(
                      index: 1,
                      title: "Yearly Plan",
                      price: "Rs 12,700.00/Yearly",
                      oldPrice: "Rs22225",
                      discount: "Save 75%",
                    ),
                    _buildPlanCard(
                      index: 2,
                      title: "Monthly Plan",
                      price: "Rs 2,950.00/Month",
                      oldPrice: "Rs4572",
                      discount: "Save 55%",
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Start trial
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 183, 0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text("3 Days Free Trial",
                            style: TextStyle(color:Colors.white,fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "After 3-days free trial period you'll be charged Rs 1,950.00/Weekly unless you cancel before the trial expired. This Subscription is Auto-Renewable. Secured by PlayStore",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Term & Conditions",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(width: 20),
                        Text("Privacy Policy",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    )
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

  Widget _buildPlanCard(
    {
    required int index,
    required String title,
    required String price,
    required String oldPrice,
    required String discount,
    bool isPopular = false,
    bool trial = false,
  }) {
    final bool isSelected = selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFDAA520)])
              : null,
          color: isSelected ? null : Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.cyan, borderRadius: BorderRadius.circular(8)),
                child: Text("Popular",
                    style: TextStyle(fontSize: 12, color: Colors.black)),
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                Text(price,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(oldPrice,
                    style: TextStyle(
                        color: Colors.white60,
                        decoration: TextDecoration.lineThrough)),
                SizedBox(width: 8),
                Text(discount, style: TextStyle(color: Colors.greenAccent)),
                if (trial) ...[
                  SizedBox(width: 8),
                  Text("3 Days Free Trial",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
