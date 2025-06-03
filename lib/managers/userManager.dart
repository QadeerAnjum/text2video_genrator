import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserManager {
  static const _userIdKey = 'backend_user_id';
  static String? currentUserId;

  static Future<String> getUserID() async {
    if (currentUserId != null) return currentUserId!;

    final prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString(_userIdKey);

    if (storedUserId == null) {
      storedUserId = await _getDeviceId();
      await prefs.setString(_userIdKey, storedUserId);
      await createUserInDatabase(storedUserId);
    }

    currentUserId = storedUserId;
    return storedUserId;
  }

  static Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String? androidId = androidInfo.id; // Correct way
      return androidId ?? "unknown_device_id";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      String? iosId = iosInfo.identifierForVendor;
      return iosId ?? "unknown_device_id";
    } else {
      return "unsupported_platform";
    }
  }

  static Future<void> createUserInDatabase(String userId) async {
    const String backendBase = "http://192.168.100.123:8000";
    final Uri uri = Uri.parse('$backendBase/create_user');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ User created or exists: $userId');
      } else {
        print('❌ Error creating user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❗ Network error: $e');
    }
  }
}
