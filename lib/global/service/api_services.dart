import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant/api_constant.dart';
import '../storage/storage_helper.dart';
import 'auth/token_manager.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await TokenManager.getValidAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> post({
    required String endpoint,
    required Map<String, dynamic> body,
    bool includeAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get({
    required String endpoint,
    bool includeAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    return await http.get(
      url,
      headers: headers,
    );
  }

  static Future<http.Response> patch({
    required String endpoint,
    required Map<String, dynamic> body,
    bool includeAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    return await http.patch(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete({
    required String endpoint,
    bool includeAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    return await http.delete(
      url,
      headers: headers,
    );
  }
}
