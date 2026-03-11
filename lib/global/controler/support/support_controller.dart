import 'dart:io';
import 'package:get/get.dart';
import '../../service/support/support_service.dart';

class SupportController extends GetxController {
  final SupportService _supportService = SupportService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<FAQ> faqs = <FAQ>[].obs;
  final RxString aboutUsContent = ''.obs;
  final RxString termsContent = ''.obs;
  final RxString privacyContent = ''.obs;

  Future<void> fetchFAQs() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supportService.getFAQs();

      if (response.success) {
        faqs.value = response.faqs;
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

  Future<void> fetchAboutUs() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supportService.getAboutUs();

      if (response.success && response.content != null) {
        aboutUsContent.value = response.content!;
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

  Future<void> fetchTerms() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supportService.getTerms();

      if (response.success && response.content != null) {
        termsContent.value = response.content!;
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

  Future<void> fetchPrivacy() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supportService.getPrivacy();

      if (response.success && response.content != null) {
        privacyContent.value = response.content!;
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

  Future<bool> submitIssue({
    required String title,
    required String description,
    File? photo1,
    File? photo2,
    File? photo3,
  }) async {
    if (title.isEmpty || description.isEmpty) {
      errorMessage.value = 'Title and description are required';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supportService.submitIssue(
        title: title,
        description: description,
        photo1: photo1,
        photo2: photo2,
        photo3: photo3,
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
