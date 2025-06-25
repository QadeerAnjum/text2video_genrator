import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class UserManager {
  static const _userIdKey = 'backend_user_id';
  static const MethodChannel _deviceChannel = MethodChannel(
    'com.motionai/device',
  );
  static String? currentUserId;

  static Future<String> getUserID() async {
    if (currentUserId != null) return currentUserId!;

    final prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString(_userIdKey);

    if (storedUserId == null) {
      storedUserId = await _getStableDeviceId();
      await prefs.setString(_userIdKey, storedUserId);
      await createUserInDatabase(storedUserId);
    }

    currentUserId = storedUserId;
    return storedUserId;
  }

  static Future<String> _getStableDeviceId() async {
    try {
      final String deviceId = await _deviceChannel.invokeMethod('getDeviceId');
      return deviceId;
    } catch (e) {
      debugPrint("❗ Failed to get device ID: $e");
      return const Uuid().v4(); // fallback
    }
  }

  static Future<void> createUserInDatabase(String userId) async {
    const String backendBase =
        "https://motionai-backend-production.up.railway.app";
    final Uri uri = Uri.parse('$backendBase/create_user');

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "appVersion": packageInfo.version,
          "buildNumber": packageInfo.buildNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ User created or exists: $userId');
      } else {
        debugPrint(
          '❌ Error creating user: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❗ Network error: $e');
    }
  }
}
