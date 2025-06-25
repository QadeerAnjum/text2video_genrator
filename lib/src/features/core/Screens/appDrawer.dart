import 'package:Motion_AI/src/features/core/Screens/AssetScreen.dart';
import 'package:Motion_AI/src/features/core/Screens/CreditsProvider.dart';
import 'package:Motion_AI/src/features/core/Screens/feedback.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:Motion_AI/managers/userManager.dart';
import 'package:Motion_AI/src/features/core/Screens/Paymentpage.dart';
import 'package:Motion_AI/src/features/core/Screens/Text2VideoUI.dart';
import 'package:Motion_AI/src/features/core/Screens/Image2Video.dart';

import 'package:provider/provider.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer();

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int selectedStars = 0;

  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initUserId();
  }

  void _initUserId() async {
    String id = await UserManager.getUserID();
    print("📦 AppDrawer User ID: $id");
    setState(() {
      userId = id;
      isLoading = false;
    });
  }

  void _submitRating() {
    if (selectedStars <= 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FeedbackPage()),
      );
    } else {
      _launchPlayStore();
    }
  }

  Future<void> _launchPlayStore() async {
    final Uri url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.bg.logomaker',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Play Store';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access credits from provider here:
    final credits = context.watch<CreditsProvider>().credits;

    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/trasns-videoapp.png', // replace with your actual asset path
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Motion AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "AI Video Generator",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  buildCard([
                    buildTile(
                      "Credits Details",
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.green,
                          ),
                          SizedBox(width: 5),
                          Text(
                            credits.toString(),
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  buildCard([
                    ListTile(
                      title: Text(
                        "Assets",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AssetScreen()),
                        );
                      },
                    ),
                    ListTile(
                      title: Text(
                        "Text To Video",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TextToVideoUI()),
                        );
                      },
                    ),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),

                    ListTile(
                      title: Text(
                        "Image To Video",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageToVideoScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),

                    ListTile(
                      title: Text(
                        "Rate Us",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.star, color: Colors.amber),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          backgroundColor: Colors.grey[900],
                          builder: (_) => _buildRateUsBottomSheet(),
                        );
                      },
                    ),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),
                    ListTile(
                      title: Text(
                        "FeedBack",
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FeedbackPage()),
                        );
                      },
                    ),
                  ]),
                  buildCard([
                    buildTile(
                      "About Us",
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://truesofts.com/portfolio/',
                        );
                        final canLaunch = await canLaunchUrl(url);

                        final success = await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );

                        if (!success) {
                          print("Launch failed");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Could not open About Us link"),
                            ),
                          );
                        }
                      },
                    ),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),

                    // Show User ID tile above About Us
                    buildTile("User ID: ${isLoading ? "Loading..." : userId}"),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateUsBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rate Us",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setModalState(() => selectedStars = index + 1);
                    },
                  );
                }),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitRating(); // <-- actually call the function
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Thanks for rating us $selectedStars stars!',
                      ),
                    ),
                  );
                },
                child: Text("Submit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      ),
    );
  }

  ListTile buildTile(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
