import 'dart:convert';
import '../../constant/api_constant.dart';
import '../api_services.dart';

class VehicleService {
  Future<VehicleResponse> getVehicleDetails(String vehicleId) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.vehicleDetails(vehicleId),
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return VehicleResponse(
          success: true,
          message: 'Vehicle details fetched successfully',
          vehicle: VehicleData.fromJson(data),
        );
      } else {
        final error = jsonDecode(response.body);
        return VehicleResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch vehicle details',
        );
      }
    } catch (e) {
      return VehicleResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

class VehicleResponse {
  final bool success;
  final String message;
  final VehicleData? vehicle;

  VehicleResponse({
    required this.success,
    required this.message,
    this.vehicle,
  });
}

class VehicleData {
  final String id;
  final String name;
  final String plate;
  final String status;
  final String make;
  final String modelName;
  final int year;
  final String? image;
  final int currentOdometerKm;
  final int nextServiceKm;
  final int kmUntilService;
  final String lastInspectionDate;
  final String? notes;
  final List<MaintenanceHistory> maintenanceHistory;

  VehicleData({
    required this.id,
    required this.name,
    required this.plate,
    required this.status,
    required this.make,
    required this.modelName,
    required this.year,
    this.image,
    required this.currentOdometerKm,
    required this.nextServiceKm,
    required this.kmUntilService,
    required this.lastInspectionDate,
    this.notes,
    required this.maintenanceHistory,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      id: json['id'],
      name: json['name'],
      plate: json['plate'],
      status: json['status'],
      make: json['make'],
      modelName: json['model_name'],
      year: json['year'],
      image: json['image'],
      currentOdometerKm: json['current_odometer_km'],
      nextServiceKm: json['next_service_km'],
      kmUntilService: json['km_until_service'],
      lastInspectionDate: json['last_inspection_date'],
      notes: json['notes'],
      maintenanceHistory: (json['maintenance_history'] as List?)
          ?.map((history) => MaintenanceHistory.fromJson(history))
          .toList() ?? [],
    );
  }

  String getFormattedLastInspection() {
    try {
      final dateTime = DateTime.parse(lastInspectionDate);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  bool isInspectionRequired() {
    return status.toLowerCase() == 'inspection_due';
  }

  String getStatusText() {
    switch (status.toLowerCase()) {
      case 'inspection_due':
        return 'Inspection Required';
      case 'active':
        return 'Active';
      case 'maintenance':
        return 'Under Maintenance';
      default:
        return status;
    }
  }
}

class MaintenanceHistory {
  final String id;
  final String scheduledDate;
  final String status;
  final String description;

  MaintenanceHistory({
    required this.id,
    required this.scheduledDate,
    required this.status,
    required this.description,
  });

  factory MaintenanceHistory.fromJson(Map<String, dynamic> json) {
    return MaintenanceHistory(
      id: json['id'],
      scheduledDate: json['scheduled_date'],
      status: json['status'],
      description: json['description'],
    );
  }

  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(scheduledDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    } catch (e) {
      return 'N/A';
    }
  }

  String getStatusText() {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Complete';
      case 'issue_reported':
        return 'Issue Reported';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  bool isComplete() {
    return status.toLowerCase() == 'completed';
  }
}
