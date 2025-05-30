import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:text2video_app/managers/userManager.dart';
import 'package:text2video_app/src/features/core/Screens/Paymentpage.dart';
import 'package:text2video_app/src/features/core/Screens/Text2VideoUI.dart';
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
          ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              final user = authState.user;
              final userEmail =
                  (user?.emailAddresses != null &&
                          user!.emailAddresses!.isNotEmpty)
                      ? user.emailAddresses!.first.emailAddress
                      : "No Email";

              final userName =
                  user?.firstName != null && user!.firstName!.isNotEmpty
                      ? "${user.firstName} ${user.lastName ?? ''}".trim()
                      : user?.username ?? "No Name";

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF1E1E1E)),
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      user?.imageUrl != null
                          ? NetworkImage(user!.imageUrl!)
                          : null,
                  child:
                      user?.imageUrl == null
                          ? Icon(Icons.person, size: 40)
                          : null,
                ),
              );
            },
            signedOutBuilder: (context, authState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF1E1E1E)),
                    accountName: Text("Guest"),
                    accountEmail: Text("Please log in"),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person_outline, size: 40),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.login, color: Colors.white),
                      label: Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 233, 175, 3),
                      ),
                      onPressed: () => showLoginDialog(context),
                    ),
                  ),
                ],
              );
            },
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
                    buildTile("Messages"),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),
                    buildTile("Help Center"),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),
                    buildTile("Communities"),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),
                    buildTile("Contact Us"),
                  ]),
                  buildCard([
                    buildTile("Permission list"),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),
                    buildTile("Privacy Policy"),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),
                    buildTile("Terms of services"),
                    Divider(color: Colors.grey.shade800, thickness: 0.2),
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
