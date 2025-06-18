import 'package:Motion_AI/src/features/core/Screens/CreditsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreditsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CreditsButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creditsProvider = Provider.of<CreditsProvider>(context);

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.local_fire_department, color: Colors.green),
      label: Text(
        '${creditsProvider.credits}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.grey[850],
        side: const BorderSide(color: Colors.green, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
