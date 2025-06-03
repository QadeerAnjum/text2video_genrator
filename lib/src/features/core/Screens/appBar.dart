import 'package:Motion_AI/src/features/core/Screens/creditButton.dart';
import 'package:Motion_AI/src/features/core/Screens/creditsPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int credits;
  final VoidCallback? onCreditsTap; // Add this to handle tap

  const CustomAppBar({
    Key? key,
    required this.title,
    this.credits = 200,
    this.onCreditsTap, // Accept tap handler
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CreditsButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreditsPage()),
              );
            },
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(color: Colors.green, height: 1, thickness: 1),
      ),
    );
  }
}
