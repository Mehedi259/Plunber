import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant/api_constant.dart';
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

  static Future<http.Response> postMultipart({
    required String endpoint,
    required Map<String, dynamic> fields,
    Map<String, List<http.MultipartFile>>? files,
    bool includeAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', url);

    // Add authorization header
    if (includeAuth) {
      final token = await TokenManager.getValidAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Add form fields (non-file data)
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // Add files
    if (files != null) {
      files.forEach((fieldName, fileList) {
        for (var file in fileList) {
          request.files.add(file);
        }
      });
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
