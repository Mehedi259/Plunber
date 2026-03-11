import 'dart:io';
import 'package:get/get.dart';
import '../../service/inspection/inspection_service.dart';

class InspectionController extends GetxController {
  final InspectionService _inspectionService = InspectionService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<InspectionHistoryItem> inspectionHistory = <InspectionHistoryItem>[].obs;
  final Rx<InspectionDetail?> inspectionDetail = Rx<InspectionDetail?>(null);

  Future<void> fetchInspectionHistory(String vehicleId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _inspectionService.getInspectionHistory(vehicleId);

      if (response.success) {
        inspectionHistory.value = response.inspections;
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

  Future<void> fetchInspectionDetails(String inspectionId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _inspectionService.getInspectionDetails(inspectionId);

      if (response.success && response.inspection != null) {
        inspectionDetail.value = response.inspection;
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

  Future<SubmitInspectionResponse> submitInspection({
    required String vehicleId,
    required String notes,
    required List<InspectionCheckItem> items,
    required Map<String, List<InspectionPhoto>> photos,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _inspectionService.submitInspection(
        vehicleId: vehicleId,
        notes: notes,
        items: items,
        photos: photos,
      );

      if (response.success) {
        isLoading.value = false;
        return response;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return response;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      isLoading.value = false;
      return SubmitInspectionResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<void> refreshHistory(String vehicleId) async {
    await fetchInspectionHistory(vehicleId);
  }
}
