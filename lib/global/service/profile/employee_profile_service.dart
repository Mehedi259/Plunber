import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';

class EmployeeProfileService {
  Future<ProfileResponse> getProfile() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.employeeProfile,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResponse(
          success: true,
          message: 'Profile fetched successfully',
          profile: EmployeeProfile.fromJson(data),
        );
      } else {
        final error = jsonDecode(response.body);
        return ProfileResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch profile',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ProfileResponse> updateProfile({
    String? fullName,
    String? phone,
    String? profession,
    String? employeeId,
    File? profilePicture,
  }) async {
    try {
      final token = StorageHelper.getString(ApiConstants.accessTokenKey);
      if (token == null) {
        return ProfileResponse(
          success: false,
          message: 'Authentication token not found',
        );
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateProfile}');
      final request = http.MultipartRequest('PATCH', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (fullName != null) request.fields['full_name'] = fullName;
      if (phone != null) request.fields['phone'] = phone;
      if (profession != null) request.fields['profession'] = profession;
      if (employeeId != null) request.fields['employee_id'] = employeeId;

      if (profilePicture != null) {
        final fileStream = http.ByteStream(profilePicture.openRead());
        final fileLength = await profilePicture.length();
        final multipartFile = http.MultipartFile(
          'profile_picture',
          fileStream,
          fileLength,
          filename: profilePicture.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResponse(
          success: true,
          message: data['message'] ?? 'Profile updated successfully',
          profile: EmployeeProfile.fromJson(data['data']),
        );
      } else {
        final error = jsonDecode(response.body);
        return ProfileResponse(
          success: false,
          message: error['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse> deleteAccount() async {
    try {
      final response = await ApiService.delete(
        endpoint: ApiConstants.updateProfile,
        includeAuth: true,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        // Clear local storage
        await StorageHelper.clear();
        
        return BaseResponse(
          success: true,
          message: 'Account deleted successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return BaseResponse(
          success: false,
          message: error['message'] ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      return BaseResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse> logout() async {
    try {
      final refreshToken = StorageHelper.getString(ApiConstants.refreshTokenKey);
      
      final response = await ApiService.post(
        endpoint: ApiConstants.logout,
        body: {'refresh': refreshToken ?? ''},
        includeAuth: true,
      );

      // Clear storage regardless of response
      await StorageHelper.remove(ApiConstants.accessTokenKey);
      await StorageHelper.remove(ApiConstants.refreshTokenKey);
      await StorageHelper.remove(ApiConstants.userDataKey);

      if (response.statusCode == 205 || response.statusCode == 200) {
        return BaseResponse(
          success: true,
          message: 'Successfully logged out',
        );
      } else {
        return BaseResponse(
          success: true,
          message: 'Logged out locally',
        );
      }
    } catch (e) {
      // Clear storage even on error
      await StorageHelper.remove(ApiConstants.accessTokenKey);
      await StorageHelper.remove(ApiConstants.refreshTokenKey);
      await StorageHelper.remove(ApiConstants.userDataKey);
      
      return BaseResponse(
        success: true,
        message: 'Logged out locally',
      );
    }
  }
}

class ProfileResponse {
  final bool success;
  final String message;
  final EmployeeProfile? profile;

  ProfileResponse({
    required this.success,
    required this.message,
    this.profile,
  });
}

class BaseResponse {
  final bool success;
  final String message;

  BaseResponse({
    required this.success,
    required this.message,
  });
}

class EmployeeProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePicture;
  final String role;
  final String primarySkill;
  final String employeeId;
  final String profession;
  final EmergencyContactData? emergencyContact;
  final bool usesCompanyVehicle;
  final String driversLicenseNumber;
  final String licenseExpiryDate;
  final String? driversLicenseFile;
  final bool onboardingComplete;
  final String createdAt;
  final String updatedAt;

  EmployeeProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePicture,
    required this.role,
    required this.primarySkill,
    required this.employeeId,
    required this.profession,
    this.emergencyContact,
    required this.usesCompanyVehicle,
    required this.driversLicenseNumber,
    required this.licenseExpiryDate,
    this.driversLicenseFile,
    required this.onboardingComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'],
      role: json['role'] ?? 'employee',
      primarySkill: json['primary_skill'] ?? '',
      employeeId: json['employee_id'] ?? '',
      profession: json['profession'] ?? '',
      emergencyContact: json['emergency_contact'] != null
          ? EmergencyContactData.fromJson(json['emergency_contact'])
          : null,
      usesCompanyVehicle: json['uses_company_vehicle'] ?? false,
      driversLicenseNumber: json['drivers_license_number'] ?? '',
      licenseExpiryDate: json['license_expiry_date'] ?? '',
      driversLicenseFile: json['drivers_license_file'],
      onboardingComplete: json['onboarding_complete'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class EmergencyContactData {
  final String id;
  final String name;
  final String mobile;
  final String relation;

  EmergencyContactData({
    required this.id,
    required this.name,
    required this.mobile,
    required this.relation,
  });

  factory EmergencyContactData.fromJson(Map<String, dynamic> json) {
    return EmergencyContactData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      relation: json['relation'] ?? '',
    );
  }
}
