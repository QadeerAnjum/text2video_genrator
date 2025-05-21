import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:text2video_app/src/features/core/Screens/Paymentpage.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String _selectedAspectRatio = '16:9';
  bool isLoading = false;

  // Add this state for payment overlay
  bool _showPaymentPage = true; // show on app start

  void generateVideo() {
    setState(() => isLoading = true);
    Future.delayed(Duration(seconds: 3), () {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video generated!')),
      );
    });
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 400,
          height: 500,
          child: ClerkAuthentication(),
        ),
      ),
    );
  }

  void _closePaymentPage() {
    setState(() {
      _showPaymentPage = false;
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main InputScreen UI
        Scaffold(
          appBar: AppBar(
            title: Text('Create Your Video'),
            centerTitle: true,
          ),
          drawer: AppDrawer(showLoginDialog: _showLoginDialog),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ... your existing input screen widgets here ...
                        Text("Prompt:", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        TextField(
                          controller: _inputController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Describe the scene and action...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text("Video Duration (seconds):", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g. 10',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text("Aspect Ratio:", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedAspectRatio,
                          items: ['16:9', '4:3', '1:1'].map((ratio) {
                            return DropdownMenuItem(
                              value: ratio,
                              child: Text(ratio),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedAspectRatio = value!);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 30),
                        // Gradient Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : generateVideo,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF25AB77), Color(0xFF1976D2)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: isLoading
                                    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.video_call, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Generate Video',
                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        if (_inputController.text.isNotEmpty && !isLoading)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.video_library,
                                    size: 80,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _inputController.text,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Payment overlay if shown
        if (_showPaymentPage)
          PaymentPage(onClose: _closePaymentPage),
      ],
    );
  }
}



class AppDrawer extends StatelessWidget {
  final void Function(BuildContext) showLoginDialog;

  const AppDrawer({required this.showLoginDialog});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF1E1E1E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              final user = authState.user;
              final userEmail = (user?.emailAddresses != null && user!.emailAddresses!.isNotEmpty)
                  ? user.emailAddresses!.first.emailAddress
                  : "No Email";

              final userName = user?.firstName != null && user!.firstName!.isNotEmpty
                  ? "${user.firstName} ${user.lastName ?? ''}".trim()
                  : user?.username ?? "No Name";

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF1E1E1E)),
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: user?.imageUrl != null ? NetworkImage(user!.imageUrl!) : null,
                  child: user?.imageUrl == null ? Icon(Icons.person, size: 40) : null,
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
                      icon: Icon(Icons.login),
                      label: Text("Login"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
                        title: Text("Upgrade your plan", style: TextStyle(color: Colors.black)),
                        subtitle: Text("More Credits & Premium Features", style: TextStyle(color: Colors.black54)),
                        onTap: () {},
                      ),
                    ),
                  ),
                  buildCard([
                    buildTile("Credits Details",
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.green),
                            SizedBox(width: 5),
                            Text("166.00", style: TextStyle(color: Colors.green)),
                          ],
                        )),
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
                            child: Text("Login", style: TextStyle(color: Colors.green)),
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
