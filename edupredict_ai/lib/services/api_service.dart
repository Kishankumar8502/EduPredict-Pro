import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const bool isLocal = true;

  static String get apiUrl {
    if (isLocal) {
      return "http://127.0.0.1:5000/predict";
    } else {
      return "https://edupredict-pro.onrender.com/predict";
    }
  }

  static Future<Map<String, dynamic>> predictPerformance(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'score': (data['predicted_overall_score'] as num?)?.toDouble() ?? _getFallbackScore(payload),
          'level': data['level'],
          'improvement': data['improvement'],
        };
      } else {
        return {
          'success': false,
          'score': _getFallbackScore(payload),
          'error': 'Server error. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'score': _getFallbackScore(payload),
        'error': 'Server error. Please try again.',
      };
    }
  }

  static double _getFallbackScore(Map<String, dynamic> payload) {
    double studyHours = (payload['study_hours'] as num?)?.toDouble() ?? 4.0;
    double sleepHours = (payload['sleep_hours'] as num?)?.toDouble() ?? 7.0;
    // We add fallback entertainment hours in flutter just in case since it's not directly in home_screen UI payload but formula demands it
    double entertainmentHours = (payload['entertainment_hours'] as num?)?.toDouble() ?? 2.0;
    
    double score = (studyHours * 6) + (sleepHours * 4) - (entertainmentHours * 2);
    return score.clamp(0.0, 100.0);
  }
}