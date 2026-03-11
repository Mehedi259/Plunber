import 'package:get/get.dart';
import '../../service/vehicle/vehicle_service.dart';

class VehicleController extends GetxController {
  final VehicleService _vehicleService = VehicleService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<VehicleData?> vehicle = Rx<VehicleData?>(null);

  Future<void> fetchVehicleDetails(String vehicleId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _vehicleService.getVehicleDetails(vehicleId);

      if (response.success && response.vehicle != null) {
        vehicle.value = response.vehicle;
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

  Future<void> refreshVehicle(String vehicleId) async {
    await fetchVehicleDetails(vehicleId);
  }
}
