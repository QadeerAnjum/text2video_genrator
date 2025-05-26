import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text2video_app/main.dart';
import 'package:text2video_app/src/features/core/Screens/Paymentpage.dart';
import 'package:text2video_app/managers/userManager.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: TextToVideoUI()),
  );
}

class TextToVideoUI extends StatefulWidget {
  const TextToVideoUI({super.key});

  @override
  State<TextToVideoUI> createState() => _TextToVideoUIState();
}

class _TextToVideoUIState extends State<TextToVideoUI> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool showDropUp = false;
  String selectedDuration = '5s';

  String selectedtRatio = '16:9';
  bool isLoading = false;
  bool _showPaymentPage = true; // Shown on app start

  void generateVideo() {
    setState(() => isLoading = true);
    Future.delayed(Duration(seconds: 3), () {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video generated!')));
    });
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width:
                      constraints.maxWidth < 400 ? constraints.maxWidth : 400,
                  height: 500,
                  child: ClerkAuthentication(),
                );
              },
            ),
          ),
    );
  }

  void _closePaymentPage() {
    setState(() => _showPaymentPage = false);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Text to Video',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: 'MINIMAX v1',
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              items:
                  ['MINIMAX v1', 'MINIMAX v2']
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              onChanged: (_) {},
            ),
          ),
        ],
      ),
      drawer: AppDrawer(showLoginDialog: _showLoginDialog),

      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Main Content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prompt',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _promptController,
                              maxLines: 6,
                              maxLength: 2000,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(16),
                                hintText:
                                    'Describe the scene and the action...',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                counterStyle: GoogleFonts.poppins(
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Negative Prompt',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '⚠ It is prohibited to use AI generated content for illegal activities',
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Drop-up Overlay
            if (showDropUp)
              Positioned(
                bottom: 130,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        "Duration:",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: [
                          GestureDetector(
                            onTap:
                                () => setState(() => selectedDuration = "5s"),
                            child: _dropOption(
                              "5s",
                              selected: selectedDuration == "5s",
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                () => setState(() => selectedDuration = "10s"),
                            child: _dropOption(
                              "10s",
                              selected: selectedDuration == "10s",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Aspect Ratio:",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          GestureDetector(
                            onTap:
                                () => setState(() => selectedtRatio = "16:9"),
                            child: _dropOptionWithIcon(
                              "16:9",
                              selected: selectedtRatio == "16:9",
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                () => setState(() => selectedtRatio = "9:16"),
                            child: _dropOptionWithIcon(
                              "9:16",
                              selected: selectedtRatio == "9:16",
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => selectedtRatio = "1:1"),
                            child: _dropOptionWithIcon(
                              "1:1",
                              selected: selectedtRatio == "1:1",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Section (Fixed)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDropUp = !showDropUp;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white30, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  _dropOption("Duration", selected: true),
                                  _dropOption("Aspect Ratio"),
                                ],
                              ),
                            ),
                            Icon(
                              showDropUp
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: Colors.white,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: generateVideo,
                        icon: const Icon(
                          Icons.local_fire_department,
                          color: Colors.black,
                          size: 18,
                        ),
                        label: Text(
                          'Generate',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topTab(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _dropOption(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: selected ? Colors.white : Colors.white30,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _dropOptionWithIcon(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: selected ? Colors.white : Colors.white30,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
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
                    buildTile(
                      "User ID: ${UserManager.currentUserId ?? 'Loading...'}",
                    ),
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
