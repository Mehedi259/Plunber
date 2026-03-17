import 'dart:convert';
import 'dart:developer';
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';
import 'token_manager.dart';

class AuthService {
  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      log('Login response status: ${response.statusCode}');
      log('Login response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        log('JSON decode error: $e');
        return {
          'success': false,
          'message': 'Invalid JSON response from server',
        };
      }

      if (responseData == null) {
        return {
          'success': false,
          'message': 'Null response from server',
        };
      }

      if (responseData is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'Invalid response format from server',
        };
      }

      log('Parsed response data: $responseData');

      if (response.statusCode == 200) {
        // Handle different response structures
        String? accessToken;
        String? refreshToken;
        Map<String, dynamic>? userData;

        // Check for different token structures
        if (responseData['access_token'] != null) {
          accessToken = responseData['access_token'];
          refreshToken = responseData['refresh_token'];
        } else if (responseData['access'] != null) {
          accessToken = responseData['access'];
          refreshToken = responseData['refresh'];
        } else if (responseData['tokens'] != null && responseData['tokens'] is Map) {
          final tokens = responseData['tokens'] as Map<String, dynamic>;
          accessToken = tokens['access'];
          refreshToken = tokens['refresh'];
        }

        // Check for user data
        if (responseData['user'] != null && responseData['user'] is Map) {
          userData = responseData['user'] as Map<String, dynamic>;
        }

        log('Extracted tokens - Access: ${accessToken != null}, Refresh: ${refreshToken != null}');
        log('User data: $userData');

        if (accessToken == null || refreshToken == null) {
          return {
            'success': false,
            'message': 'Invalid response format: missing tokens. Response: $responseData',
          };
        }

        // Save tokens with remember me preference
        await TokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          rememberMe: rememberMe,
        );

        // Save user data if provided
        if (userData != null) {
          await StorageHelper.saveString(
            ApiConstants.userDataKey,
            jsonEncode(userData),
          );
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'user': userData,
          'access_token': accessToken,
          'refresh_token': refreshToken,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      log('Login error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      // Call logout endpoint if refresh token exists
      final refreshToken = TokenManager.refreshToken;
      if (refreshToken != null) {
        await ApiService.post(
          endpoint: ApiConstants.logout,
          body: {'refresh': refreshToken},
        );
      }
    } catch (e) {
      // Continue with logout even if API call fails
    }

    // Clear all tokens and user data
    await TokenManager.clearTokens();

    return {
      'success': true,
      'message': 'Logged out successfully',
    };
  }

  // Check authentication status
  static Future<bool> checkAuthStatus() async {
    if (!TokenManager.isLoggedIn) {
      return false;
    }

    // If remember me is disabled, clear tokens and require fresh login
    if (!TokenManager.isRememberMeEnabled) {
      log('Remember me disabled, clearing tokens for fresh login');
      await TokenManager.clearTokens();
      return false;
    }

    // Try to get a valid access token (will refresh if needed)
    final validToken = await TokenManager.getValidAccessToken();
    return validToken != null;
  }

  // Get current user data
  static Map<String, dynamic>? getCurrentUser() {
    try {
      final userDataString = StorageHelper.getString(ApiConstants.userDataKey);
      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = jsonDecode(userDataString);
        if (userData is Map<String, dynamic>) {
          return userData;
        }
      }
    } catch (e) {
      log('Error getting current user: $e');
      // Clear corrupted user data
      StorageHelper.remove(ApiConstants.userDataKey);
    }
    return null;
  }

  // Fetch latest user profile from API
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.employeeProfile,
        includeAuth: true,
      );

      log('User profile response status: ${response.statusCode}');
      log('User profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Extract user data from response
        Map<String, dynamic>? userData;
        if (responseData['user'] != null) {
          userData = responseData['user'];
        } else if (responseData['data'] != null) {
          userData = responseData['data'];
        } else {
          userData = responseData;
        }

        // Save updated user data
        if (userData != null) {
          await StorageHelper.saveString(
            ApiConstants.userDataKey,
            jsonEncode(userData),
          );
          log('User profile updated in storage');
        }

        return {
          'success': true,
          'user': userData,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch user profile',
        };
      }
    } catch (e) {
      log('Error fetching user profile: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  // Initiate user registration - sends OTP to email
  static Future<Map<String, dynamic>> initiateRegistration({
    required String email,
    required String username,
    required String password,
    required String birthDate, // Format: YYYY-MM-DD
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.registerInitiate,
        body: {
          'email': email,
          'username': username,
          'password': password,
          'birth_date': birthDate,
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'email': responseData['email'],
          'expires_in_seconds': responseData['expires_in_seconds'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration initiation failed',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify OTP and complete registration
  static Future<Map<String, dynamic>> verifyRegistration({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.registerVerify,
        body: {
          'email': email,
          'otp': otp,
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save tokens with remember me enabled by default for registration
        await TokenManager.saveTokens(
          accessToken: responseData['access_token'],
          refreshToken: responseData['refresh_token'],
          rememberMe: true,
        );
        
        // Save user data
        await StorageHelper.saveString(
          ApiConstants.userDataKey,
          jsonEncode(responseData['user']),
        );

        return {
          'success': true,
          'message': responseData['message'],
          'user': responseData['user'],
          'access_token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'OTP verification failed',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}