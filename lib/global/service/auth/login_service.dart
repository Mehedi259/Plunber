import 'dart:convert';
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';

class LoginService {
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save tokens
        await StorageHelper.saveString(
          ApiConstants.accessTokenKey,
          data['tokens']['access'],
        );
        await StorageHelper.saveString(
          ApiConstants.refreshTokenKey,
          data['tokens']['refresh'],
        );
        
        // Save user data
        await StorageHelper.saveJson(
          ApiConstants.userDataKey,
          data['user'],
        );

        return LoginResponse(
          success: true,
          message: data['message'],
          user: UserData.fromJson(data['user']),
          tokens: TokenData.fromJson(data['tokens']),
        );
      } else {
        final error = jsonDecode(response.body);
        return LoginResponse(
          success: false,
          message: error['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    await StorageHelper.remove(ApiConstants.accessTokenKey);
    await StorageHelper.remove(ApiConstants.refreshTokenKey);
    await StorageHelper.remove(ApiConstants.userDataKey);
  }

  bool isLoggedIn() {
    return StorageHelper.containsKey(ApiConstants.accessTokenKey);
  }

  UserData? getCurrentUser() {
    final userData = StorageHelper.getJson(ApiConstants.userDataKey);
    if (userData == null) return null;
    return UserData.fromJson(userData);
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final UserData? user;
  final TokenData? tokens;

  LoginResponse({
    required this.success,
    required this.message,
    this.user,
    this.tokens,
  });
}

class UserData {
  final String id;
  final String fullName;
  final String email;
  final String? profilePicture;
  final bool isActive;
  final String? phone;
  final String provider;
  final String createdAt;
  final String updatedAt;

  UserData({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.isActive,
    this.phone,
    required this.provider,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'],
      profilePicture: json['profile_picture'],
      isActive: json['is_active'] ?? true,
      phone: json['phone'],
      provider: json['provider'] ?? 'self',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'profile_picture': profilePicture,
      'is_active': isActive,
      'phone': phone,
      'provider': provider,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TokenData {
  final String access;
  final String refresh;

  TokenData({
    required this.access,
    required this.refresh,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      access: json['access'],
      refresh: json['refresh'],
    );
  }
}
