import 'package:get/get.dart';
import '../../service/vehicle/vehicle_service.dart';

class VehicleController extends GetxController {
  final VehicleService _vehicleService = VehicleService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<VehicleData?> vehicle = Rx<VehicleData?>(null);
  final RxList<VehicleData> vehicles = <VehicleData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyVehicles();
  }

  Future<void> fetchMyVehicles() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _vehicleService.getMyVehicles();

      if (response.success && response.vehicles.isNotEmpty) {
        vehicles.value = response.vehicles;
        vehicle.value = response.vehicles.first;
        isLoading.value = false;
      } else if (response.success && response.vehicles.isEmpty) {
        errorMessage.value = 'No vehicles assigned to your account';
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

  Future<void> fetchVehicleDetails(String vehicleId) async {
    // Handle empty or invalid vehicle ID
    if (vehicleId.isEmpty || vehicleId == 'default-vehicle-id') {
      isLoading.value = false;
      errorMessage.value = 'No vehicle assigned to your account';
      return;
    }

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
    await fetchMyVehicles();
  }
}
