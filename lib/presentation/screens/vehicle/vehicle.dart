import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../core/routes/route_path.dart';
import '../../widgets/animated_section.dart';
import '../../../global/controler/vehicle/vehicle_controller.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _vehicleController = Get.put(VehicleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          if (_vehicleController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            );
          }

          if (_vehicleController.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _vehicleController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _vehicleController.fetchMyVehicles(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final vehicle = _vehicleController.vehicle.value;
          if (vehicle == null) {
            return const Center(
              child: Text('No vehicle data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _vehicleController.fetchMyVehicles(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  AnimatedSection(
                    index: 0,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Vehicle',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Vehicle Image
                  AnimatedSection(
                    index: 1,
                    child: Container(
                      height: 181,
                      margin: const EdgeInsets.symmetric(horizontal: 68),
                      child: vehicle.image != null
                          ? Image.network(
                              vehicle.image!,
                              width: 266,
                              height: 181,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/Truck.png',
                                  width: 266,
                                  height: 181,
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/Truck.png',
                              width: 266,
                              height: 181,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Vehicle Name
                  AnimatedSection(
                    index: 2,
                    child: Text(
                      vehicle.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Number Plate
                  AnimatedSection(
                    index: 3,
                    child: Text(
                      'Number Plate: ${vehicle.plate}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Inspection Required Badge
                  if (vehicle.isInspectionRequired())
                    AnimatedSection(
                      index: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E40AF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              vehicle.getStatusText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Last Inspection
                  AnimatedSection(
                    index: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF323232)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Last Inspection: ${vehicle.getFormattedLastInspection()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF323232),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Next Service
                  AnimatedSection(
                    index: 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.build_outlined, size: 16, color: Color(0xFF323232)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Next Service: ${vehicle.kmUntilService.toStringAsFixed(0)} km remaining',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF323232),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Start Inspection Button
                  AnimatedSection(
                    index: 7,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 47),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pushNamed(
                            RoutePath.inspection,
                            queryParameters: {
                              'vehicleId': vehicle.id,
                              'vehicleName': vehicle.name,
                              'vehiclePlate': vehicle.plate,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start Inspection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
