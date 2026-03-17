import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';

class TokenManager {
  static bool _isRefreshing = false;
  static List<Function> _refreshCallbacks = [];

  // Check if user is logged in
  static bool get isLoggedIn {
    final accessToken = StorageHelper.getString(ApiConstants.accessTokenKey);
    final refreshToken = StorageHelper.getString(ApiConstants.refreshTokenKey);
    log('Checking login status - Access token: ${accessToken != null}, Refresh token: ${refreshToken != null}');
    return accessToken != null && refreshToken != null;
  }

  // Check if remember me is enabled
  static bool get isRememberMeEnabled {
    return StorageHelper.getString(ApiConstants.rememberMeKey) == 'true';
  }

  // Get current access token
  static String? get accessToken {
    return StorageHelper.getString(ApiConstants.accessTokenKey);
  }

  // Get current refresh token
  static String? get refreshToken {
    return StorageHelper.getString(ApiConstants.refreshTokenKey);
  }

  // Save tokens with remember me option
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required bool rememberMe,
  }) async {
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw Exception('Cannot save empty tokens');
    }

    log('Saving tokens - Remember me: $rememberMe');
    await StorageHelper.saveString(ApiConstants.accessTokenKey, accessToken);
    await StorageHelper.saveString(ApiConstants.refreshTokenKey, refreshToken);
    
    if (rememberMe) {
      await StorageHelper.saveString(ApiConstants.rememberMeKey, 'true');
      log('Tokens saved with remember me enabled');
    } else {
      await StorageHelper.saveString(ApiConstants.rememberMeKey, 'false');
      log('Tokens saved with remember me disabled');
    }
  }

  // Clear all tokens and user data
  static Future<void> clearTokens() async {
    await StorageHelper.remove(ApiConstants.accessTokenKey);
    await StorageHelper.remove(ApiConstants.refreshTokenKey);
    await StorageHelper.remove(ApiConstants.userDataKey);
    await StorageHelper.remove(ApiConstants.rememberMeKey);
  }

  // Refresh access token using refresh token
  static Future<Map<String, dynamic>> refreshAccessToken() async {
    if (_isRefreshing) {
      // If already refreshing, wait for it to complete
      return await _waitForRefresh();
    }

    final currentRefreshToken = refreshToken;
    if (currentRefreshToken == null) {
      return {
        'success': false,
        'message': 'No refresh token available',
        'shouldLogout': true,
      };
    }

    _isRefreshing = true;

    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.tokenRefresh,
        body: {
          'refresh': currentRefreshToken,
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save new tokens
        await StorageHelper.saveString(
          ApiConstants.accessTokenKey,
          responseData['access'],
        );
        
        // Update refresh token if provided
        if (responseData['refresh'] != null) {
          await StorageHelper.saveString(
            ApiConstants.refreshTokenKey,
            responseData['refresh'],
          );
        }

        _isRefreshing = false;
        _notifyRefreshCallbacks(true);

        return {
          'success': true,
          'access_token': responseData['access'],
          'refresh_token': responseData['refresh'],
        };
      } else {
        _isRefreshing = false;
        _notifyRefreshCallbacks(false);

        return {
          'success': false,
          'message': responseData['message'] ?? 'Token refresh failed',
          'shouldLogout': response.statusCode == 401,
        };
      }
    } catch (e) {
      _isRefreshing = false;
      _notifyRefreshCallbacks(false);

      log('Token refresh error: $e');
      return {
        'success': false,
        'message': 'Network error during token refresh',
        'shouldLogout': false,
      };
    }
  }

  // Wait for ongoing refresh to complete
  static Future<Map<String, dynamic>> _waitForRefresh() async {
    final completer = Completer<bool>();
    _refreshCallbacks.add((success) => completer.complete(success));
    
    final success = await completer.future;
    
    if (success) {
      return {
        'success': true,
        'access_token': accessToken,
      };
    } else {
      return {
        'success': false,
        'message': 'Token refresh failed',
      };
    }
  }

  // Notify all waiting callbacks
  static void _notifyRefreshCallbacks(bool success) {
    for (final callback in _refreshCallbacks) {
      callback(success);
    }
    _refreshCallbacks.clear();
  }

  // Check if access token is expired (basic check)
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded);

      final exp = payloadMap['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      // Consider token expired if it expires within next 5 minutes
      return expiryDate.isBefore(now.add(const Duration(minutes: 5)));
    } catch (e) {
      log('Error checking token expiry: $e');
      return true;
    }
  }

  // Auto-refresh token if needed
  static Future<String?> getValidAccessToken() async {
    final currentToken = accessToken;
    
    if (currentToken == null) {
      return null;
    }

    // Check if token is expired
    if (isTokenExpired(currentToken)) {
      log('Access token expired, attempting refresh...');
      final refreshResult = await refreshAccessToken();
      
      if (refreshResult['success']) {
        return refreshResult['access_token'];
      } else {
        log('Token refresh failed: ${refreshResult['message']}');
        if (refreshResult['shouldLogout'] == true) {
          await clearTokens();
        }
        return null;
      }
    }

    return currentToken;
  }
}