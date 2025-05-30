import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:Motion_AI/managers/userManager.dart';
import 'package:Motion_AI/src/features/core/Screens/Paymentpage.dart';
import 'package:Motion_AI/src/features/core/Screens/Text2VideoUI.dart';
import 'package:Motion_AI/src/features/core/Screens/Image2Video.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AppDrawer extends StatefulWidget {
  final void Function(BuildContext) showLoginDialog;
  const AppDrawer({required this.showLoginDialog});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String androidId = "Loading...";

  @override
  void initState() {
    super.initState();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        androidId = androidInfo.id; // This is the Android ID
      });
    } else {
      setState(() {
        androidId = "Not an Android device";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Motion AI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "AI Video Generator",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 20),
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
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.upgrade, color: Colors.black),
                        title: Text(
                          "Upgrade your plan",
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          "More Credits & Premium Features",
                          style: TextStyle(color: Colors.black54),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PaymentPage(
                                    onClose: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
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
                          Text("166.00", style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),
                    buildTile("Manage your plan"),
                  ]),
                  buildCard([
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
                  ]),
                  buildCard([
                    buildTile("About Us"),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),

                    // Show User ID tile above About Us
                    buildTile("User ID: $androidId"),
                  ]),
                  ClerkAuthBuilder(
                    signedInBuilder: (context, authState) {
                      return Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: SizedBox(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                await authState.signOut();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Signed out')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Sign out",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    signedOutBuilder: (context, authState) {
                      return Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: TextButton(
                            onPressed: () => showLoginDialog(context),
                            child: Text(
                              "Login",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateUsBottomSheet() {
    int selectedStars = 0;

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

  ListTile buildTile(String title, {Widget? trailing}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: trailing,
    );
  }
}

void showLoginDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (_) => Dialog(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth < 400 ? constraints.maxWidth : 400,
                height: 500,
                child: const ClerkAuthentication(),
              );
            },
          ),
        ),
  );
}
