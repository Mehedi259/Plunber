import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';
import '../auth/token_manager.dart';

class ProfileSetupService {
  Future<ProfileSetupResponse> updateProfileStep1({
    required String fullName,
    required String phone,
    required String primarySkill,
    required String profession,
    String? employeeId,
    EmergencyContact? emergencyContact,
  }) async {
    try {
      final body = {
        'full_name': fullName,
        'phone': phone,
        'primary_skill': primarySkill,
        'profession': profession,
        if (employeeId != null && employeeId.isNotEmpty) 'employee_id': employeeId,
        if (emergencyContact != null) 'emergency_contact': emergencyContact.toJson(),
      };

      log('Profile update request body: $body');

      final response = await ApiService.patch(
        endpoint: ApiConstants.onboardingStep1,
        body: body,
        includeAuth: true,
      );

      log('Profile update response status: ${response.statusCode}');
      log('Profile update response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Update user data in storage with onboarding status
        await _updateUserDataInStorage(data['data']);
        
        return ProfileSetupResponse(
          success: true,
          message: 'Profile updated successfully',
          data: data,
        );
      } else {
        final error = jsonDecode(response.body);
        return ProfileSetupResponse(
          success: false,
          message: error['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      log('Profile update error: $e');
      return ProfileSetupResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ProfileSetupResponse> updateProfileStep2({
    required bool usesCompanyVehicle,
    required String driversLicenseNumber,
    required String licenseExpiryDate,
    PlatformFile? driversLicenseFile,
  }) async {
    try {
      final token = await TokenManager.getValidAccessToken();
      if (token == null) {
        return ProfileSetupResponse(
          success: false,
          message: 'Authentication token not found',
        );
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.onboardingStep2}');
      final request = http.MultipartRequest('PATCH', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['uses_company_vehicle'] = usesCompanyVehicle.toString();
      request.fields['drivers_license_number'] = driversLicenseNumber;
      request.fields['license_expiry_date'] = licenseExpiryDate;

      // Add file if provided
      if (driversLicenseFile != null) {
        if (kIsWeb) {
          // Web: use bytes directly
          if (driversLicenseFile.bytes != null) {
            final multipartFile = http.MultipartFile.fromBytes(
              'drivers_license_file',
              driversLicenseFile.bytes!,
              filename: driversLicenseFile.name,
            );
            request.files.add(multipartFile);
          }
        } else {
          // Mobile/Desktop: use file path
          if (driversLicenseFile.path != null) {
            final multipartFile = await http.MultipartFile.fromPath(
              'drivers_license_file',
              driversLicenseFile.path!,
              filename: driversLicenseFile.name,
            );
            request.files.add(multipartFile);
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Update user data in storage with onboarding status
        await _updateUserDataInStorage(data['data']);
        
        return ProfileSetupResponse(
          success: true,
          message: 'Work details updated successfully',
          data: data,
        );
      } else {
        final error = jsonDecode(response.body);
        return ProfileSetupResponse(
          success: false,
          message: error['message'] ?? 'Failed to update work details',
        );
      }
    } catch (e) {
      return ProfileSetupResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Helper method to update user data in storage
  Future<void> _updateUserDataInStorage(Map<String, dynamic>? profileData) async {
    if (profileData == null) return;

    try {
      // Get current user data
      final currentUserDataString = StorageHelper.getString(ApiConstants.userDataKey);
      if (currentUserDataString != null) {
        final currentUserData = jsonDecode(currentUserDataString) as Map<String, dynamic>;
        
        // Update with new profile data
        if (profileData['onboarding_complete'] != null) {
          currentUserData['onboarding_complete'] = profileData['onboarding_complete'];
          log('Updated onboarding_complete to: ${profileData['onboarding_complete']}');
        }
        
        // Save updated user data
        await StorageHelper.saveString(
          ApiConstants.userDataKey,
          jsonEncode(currentUserData),
        );
        
        log('User data updated in storage');
      }
    } catch (e) {
      log('Error updating user data in storage: $e');
    }
  }
}

class ProfileSetupResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ProfileSetupResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class EmergencyContact {
  final String name;
  final String mobile;
  final String relation;

  EmergencyContact({
    required this.name,
    required this.mobile,
    required this.relation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'relation': relation,
    };
  }
}
