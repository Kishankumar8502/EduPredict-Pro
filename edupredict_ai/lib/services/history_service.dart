import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String keyHistory = 'predictionHistory';

  // Save a new prediction to history
  static Future<void> savePrediction(Map<String, dynamic> predictionData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(keyHistory) ?? [];
    
    // Add current timestamp if not present
    predictionData['timestamp'] = DateTime.now().toIso8601String();
    
    historyList.insert(0, jsonEncode(predictionData)); // Add stringified json at top
    await prefs.setStringList(keyHistory, historyList);
  }

  // Load all prediction history
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(keyHistory) ?? [];
    
    return historyList.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  // Delete a specific prediction by exact match or timestamp
  static Future<void> deletePrediction(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(keyHistory) ?? [];
    
    historyList.removeWhere((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return decoded['timestamp'] == timestamp;
    });
    
    await prefs.setStringList(keyHistory, historyList);
  }

  // Clear all history
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyHistory);
  }
}
