import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoService {
  static const String baseUrl =
      'https://motionai-backend-production.up.railway.app'; // Replace with your backend IP for mobile

  static Future<String> generateVideo(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['task_id'];
    } else {
      throw Exception('Failed to submit video task');
    }
  }

  static Future<Map<String, dynamic>> checkStatus(String taskId) async {
    final response = await http.get(Uri.parse('$baseUrl/status/$taskId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check status');
    }
  }

  static Future<String> getDownloadUrl(String fileId) async {
    final response = await http.get(Uri.parse('$baseUrl/download/$fileId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['download_url'];
    } else {
      throw Exception('Failed to get download URL');
    }
  }
}
