import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../service/profile/profile_setup_service.dart';

class ProfileSetupController extends GetxController {
  final ProfileSetupService _profileSetupService = ProfileSetupService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> updateProfileStep1({
    required String fullName,
    required String phone,
    required String primarySkill,
    required String profession,
    String? employeeId,
    EmergencyContact? emergencyContact,
  }) async {
    if (fullName.isEmpty || phone.isEmpty || primarySkill.isEmpty || profession.isEmpty) {
      errorMessage.value = 'Please fill all required fields';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _profileSetupService.updateProfileStep1(
        fullName: fullName,
        phone: phone,
        primarySkill: primarySkill,
        profession: profession,
        employeeId: employeeId,
        emergencyContact: emergencyContact,
      );

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

  Future<bool> updateProfileStep2({
    required bool usesCompanyVehicle,
    required String driversLicenseNumber,
    required String licenseExpiryDate,
    PlatformFile? driversLicenseFile,
  }) async {
    if (driversLicenseNumber.isEmpty || licenseExpiryDate.isEmpty) {
      errorMessage.value = 'Please fill all required fields';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _profileSetupService.updateProfileStep2(
        usesCompanyVehicle: usesCompanyVehicle,
        driversLicenseNumber: driversLicenseNumber,
        licenseExpiryDate: licenseExpiryDate,
        driversLicenseFile: driversLicenseFile,
      );

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
}
