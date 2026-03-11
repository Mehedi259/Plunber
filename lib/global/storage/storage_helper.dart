import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageHelper not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Save string
  static Future<bool> saveString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  // Get string
  static String? getString(String key) {
    return prefs.getString(key);
  }

  // Save JSON object
  static Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    return await prefs.setString(key, jsonEncode(value));
  }

  // Get JSON object
  static Map<String, dynamic>? getJson(String key) {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Remove key
  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  // Clear all
  static Future<bool> clear() async {
    return await prefs.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }
}
