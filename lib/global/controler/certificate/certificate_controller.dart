import 'dart:io';
import 'package:get/get.dart';
import '../../service/certificate/certificate_service.dart';

class CertificateController extends GetxController {
  final CertificateService _certificateService = CertificateService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Certificate> certificates = <Certificate>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _certificateService.getCertificates();

      if (response.success) {
        certificates.value = response.certificates;
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

  Future<void> refreshCertificates() async {
    await fetchCertificates();
  }

  Future<bool> addCertificate({
    required String name,
    required String issuingOrganization,
    required String description,
    required String issueDate,
    required String expirationDate,
    required File media,
  }) async {
    if (name.isEmpty || issuingOrganization.isEmpty) {
      errorMessage.value = 'Name and issuing organization are required';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _certificateService.addCertificate(
        name: name,
        issuingOrganization: issuingOrganization,
        description: description,
        issueDate: issueDate,
        expirationDate: expirationDate,
        media: media,
      );

      if (response.success) {
        isLoading.value = false;
        await fetchCertificates(); // Refresh the list
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
