import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:text2video_app/src/features/core/Screens/Text2VideoUI.dart';

void main() {
  runApp(Text2VideoApp());
}

class Text2VideoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: 'pk_test_ZmlybS1mb3dsLTcxLmNsZXJrLmFjY291bnRzLmRldiQ'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Text To Video Generator',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.blueAccent,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: TextToVideoUI(),
      ),
    );
  }
}
