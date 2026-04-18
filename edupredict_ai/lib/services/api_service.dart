import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ YOUR REAL IP
  static const String apiUrl = 'http://10.239.70.55:5000/predict';

  static Future<Map<String, dynamic>> predictPerformance(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'score': (data['predicted_overall_score'] as num).toDouble(),
        };
      } else {
        return {
          'success': false,
          'error': 'Server Error (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed.\nCheck:\n1. Flask running\n2. Same WiFi\n3. Correct IP\n\nDetails: $e',
      };
    }
  }
}