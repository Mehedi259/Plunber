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

  Widget _buildVehicleCard(BuildContext context, vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vehicle Image
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: vehicle.image != null
                ? Image.network(
                    vehicle.image!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/Truck.png',
                        fit: BoxFit.contain,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/Truck.png',
                    fit: BoxFit.contain,
                  ),
          ),
          
          // Vehicle Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Vehicle Name
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                // Number Plate
                Text(
                  'Number Plate: ${vehicle.plate}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Status Badge
                if (vehicle.isInspectionRequired())
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: vehicle.status.toLowerCase() == 'issue_reported'
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF1E40AF),
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
                const SizedBox(height: 16),
                
                // Last Inspection
                Row(
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
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Next Service
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.build_outlined, size: 16, color: Color(0xFF323232)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Next Service: ${vehicle.kmUntilService.toStringAsFixed(0)} km',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF323232),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
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
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.pushNamed(
                            RoutePath.inspectionHistory,
                            queryParameters: {
                              'vehicleId': vehicle.id,
                              'vehicleName': vehicle.name,
                              'vehiclePlate': vehicle.plate,
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 1.5,
                          ),
                        ),
                        child: const Text(
                          'History',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

          final vehicles = _vehicleController.vehicles;
          if (vehicles.isEmpty) {
            return const Center(
              child: Text('No vehicles available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _vehicleController.fetchMyVehicles(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: AnimatedSection(
                    index: 0,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'My Vehicles',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Vehicle List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final vehicle = vehicles[index];
                        return AnimatedSection(
                          index: index + 1,
                          child: _buildVehicleCard(context, vehicle),
                        );
                      },
                      childCount: vehicles.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
