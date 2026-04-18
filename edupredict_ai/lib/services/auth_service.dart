import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyStudentId = 'studentId';
  static const String keyStudentPassword = 'studentPassword';
  static const String keyStudentName = 'studentName';
  static const String keyStudentEmail = 'studentEmail';
  static const String keyStudentAge = 'studentAge';
  static const String keyStudentGender = 'studentGender';

  // Check if a user is currently logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // Register / Save credentials locally
  static Future<bool> registerUser(String studentId, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyStudentId, studentId);
    await prefs.setString(keyStudentPassword, password);
    await prefs.setString(keyStudentName, name);
    // Auto login after registration
    await prefs.setBool(keyIsLoggedIn, true);
    return true;
  }

  // Login locally
  static Future<bool> loginUser(String studentId, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(keyStudentId);
    final savedPassword = prefs.getString(keyStudentPassword);

    if (savedId == studentId && savedPassword == password) {
      await prefs.setBool(keyIsLoggedIn, true);
      return true;
    }
    return false;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, false);
  }

  // Get current user details
  static Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'studentId': prefs.getString(keyStudentId) ?? '',
      'name': prefs.getString(keyStudentName) ?? '',
      'email': prefs.getString(keyStudentEmail) ?? '',
      'age': prefs.getInt(keyStudentAge) ?? 0,
      'gender': prefs.getString(keyStudentGender) ?? '',
    };
  }

  // Update user details
  static Future<void> updateUserDetails({
    String? name,
    String? email,
    int? age,
    String? gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(keyStudentName, name);
    if (email != null) await prefs.setString(keyStudentEmail, email);
    if (age != null) await prefs.setInt(keyStudentAge, age);
    if (gender != null) await prefs.setString(keyStudentGender, gender);
  }
}
