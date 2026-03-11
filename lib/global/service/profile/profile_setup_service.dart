import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';

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

      final response = await ApiService.patch(
        endpoint: ApiConstants.onboardingStep1,
        body: body,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    File? driversLicenseFile,
  }) async {
    try {
      final token = StorageHelper.getString(ApiConstants.accessTokenKey);
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
        final fileStream = http.ByteStream(driversLicenseFile.openRead());
        final fileLength = await driversLicenseFile.length();
        final multipartFile = http.MultipartFile(
          'drivers_license_file',
          fileStream,
          fileLength,
          filename: driversLicenseFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
