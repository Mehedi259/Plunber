import 'dart:io';
import 'package:get/get.dart';
import '../../service/profile/employee_profile_service.dart';

class EmployeeProfileController extends GetxController {
  final EmployeeProfileService _profileService = EmployeeProfileService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<EmployeeProfile?> profile = Rx<EmployeeProfile?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _profileService.getProfile();

      if (response.success && response.profile != null) {
        profile.value = response.profile;
        isLoading.value = false;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? profession,
    String? employeeId,
    File? profilePicture,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _profileService.updateProfile(
        fullName: fullName,
        phone: phone,
        profession: profession,
        employeeId: employeeId,
        profilePicture: profilePicture,
      );

      if (response.success && response.profile != null) {
        profile.value = response.profile;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _profileService.deleteAccount();

      if (response.success) {
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> logout() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _profileService.logout();

      if (response.success) {
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<void> refreshProfile() async {
    await fetchProfile();
  }
}
