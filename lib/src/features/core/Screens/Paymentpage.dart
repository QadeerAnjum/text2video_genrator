import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final VoidCallback onClose;

  const PaymentPage({required this.onClose, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header Section
        // Header Section
Container(
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF7B61FF), Color(0xFF3D2C8D)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 20),
  child: Stack(
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/text2video.png'),
          ),
          SizedBox(height: 10),
          Text("Beach Video", style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
      Positioned(
        top: 0,
        right: 16,
        child: GestureDetector(
          onTap: onClose,
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
                    _buildPlanCard("Weekly Plan", "Rs 1,950.00/Weekly", "Rs2632", "Save 35%",
                        isPopular: true, trial: true),
                    _buildPlanCard("Yearly Plan", "Rs 12,700.00/Yearly", "Rs22225", "Save 75%"),
                    _buildPlanCard("Monthly Plan", "Rs 2,950.00/Month", "Rs4572", "Save 55%"),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Start trial
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B61FF),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text("3 Days Free Trial", style: TextStyle(fontSize: 16)),
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
                        Text("Term & Conditions", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(width: 20),
                        Text("Privacy Policy", style: TextStyle(color: Colors.white70, fontSize: 12)),
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

  Widget _buildPlanCard(String title, String price, String oldPrice, String discount,
      {bool isPopular = false, bool trial = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPopular
            ? LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF5D50FE)])
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
                  color: Colors.cyan, borderRadius: BorderRadius.circular(8)),
              child: Text("Popular", style: TextStyle(fontSize: 12, color: Colors.black)),
            ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(price,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(oldPrice,
                  style: TextStyle(color: Colors.white60, decoration: TextDecoration.lineThrough)),
              SizedBox(width: 8),
              Text(discount, style: TextStyle(color: Colors.greenAccent)),
              if (trial) ...[
                SizedBox(width: 8),
                Text("3 Days Free Trial", style: TextStyle(color: Colors.white, fontSize: 12)),
              ]
            ],
          )
        ],
      ),
    );
  }
}
