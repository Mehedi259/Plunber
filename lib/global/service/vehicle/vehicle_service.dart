import 'dart:convert';
import '../../constant/api_constant.dart';
import '../api_services.dart';

class VehicleService {
  Future<MyVehiclesResponse> getMyVehicles() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.myVehicles,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final vehicles = data.map((json) => VehicleData.fromJson(json)).toList();
        
        return MyVehiclesResponse(
          success: true,
          message: 'Vehicles fetched successfully',
          vehicles: vehicles,
        );
      } else {
        final error = jsonDecode(response.body);
        return MyVehiclesResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch vehicles',
          vehicles: [],
        );
      }
    } catch (e) {
      return MyVehiclesResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        vehicles: [],
      );
    }
  }

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

  Future<InspectionHistoryResponse> getInspectionHistory(String vehicleId) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.inspectionHistory(vehicleId),
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        final inspections = results.map((json) => InspectionHistoryData.fromJson(json)).toList();
        
        return InspectionHistoryResponse(
          success: true,
          message: 'Inspection history fetched successfully',
          inspections: inspections,
        );
      } else {
        final error = jsonDecode(response.body);
        return InspectionHistoryResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch inspection history',
          inspections: [],
        );
      }
    } catch (e) {
      return InspectionHistoryResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        inspections: [],
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
  final String? picture;
  final int nextService;
  final String lastInspectionDate;

  VehicleData({
    required this.id,
    required this.name,
    required this.plate,
    required this.status,
    this.picture,
    required this.nextService,
    required this.lastInspectionDate,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      plate: json['plate'] ?? '',
      status: json['status'] ?? '',
      picture: json['picture'],
      nextService: json['next_service'] ?? 0,
      lastInspectionDate: json['last_inspection_date'] ?? '',
    );
  }

  String? get image => picture;
  
  double get kmUntilService => nextService.toDouble();
  
  List<MaintenanceHistory> get maintenanceHistory => [];

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
    return status.toLowerCase() == 'inspection_due' || status.toLowerCase() == 'issue_reported';
  }

  String getStatusText() {
    switch (status.toLowerCase()) {
      case 'inspection_due':
        return 'Inspection Required';
      case 'issue_reported':
        return 'Issue Reported';
      case 'active':
        return 'Active';
      case 'maintenance':
        return 'Under Maintenance';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
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
      id: json['id'] ?? '',
      scheduledDate: json['scheduled_date'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
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

class MyVehiclesResponse {
  final bool success;
  final String message;
  final List<VehicleData> vehicles;

  MyVehiclesResponse({
    required this.success,
    required this.message,
    required this.vehicles,
  });
}

class InspectionHistoryResponse {
  final bool success;
  final String message;
  final List<InspectionHistoryData> inspections;

  InspectionHistoryResponse({
    required this.success,
    required this.message,
    required this.inspections,
  });
}

class InspectionHistoryData {
  final String id;
  final String vehicle;
  final String vehicleName;
  final String vehiclePlate;
  final String inspectedBy;
  final String inspectedByName;
  final bool hasOpenIssue;
  final int issueCount;
  final int completedItemsCount;
  final String notes;
  final String inspectedAt;

  InspectionHistoryData({
    required this.id,
    required this.vehicle,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.inspectedBy,
    required this.inspectedByName,
    required this.hasOpenIssue,
    required this.issueCount,
    required this.completedItemsCount,
    required this.notes,
    required this.inspectedAt,
  });

  factory InspectionHistoryData.fromJson(Map<String, dynamic> json) {
    return InspectionHistoryData(
      id: json['id'] ?? '',
      vehicle: json['vehicle'] ?? '',
      vehicleName: json['vehicle_name'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      inspectedBy: json['inspected_by'] ?? '',
      inspectedByName: json['inspected_by_name'] ?? '',
      hasOpenIssue: json['has_open_issue'] ?? false,
      issueCount: json['issue_count'] ?? 0,
      completedItemsCount: json['completed_items_count'] ?? 0,
      notes: json['notes'] ?? '',
      inspectedAt: json['inspected_at'] ?? '',
    );
  }

  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(inspectedAt);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    } catch (e) {
      return 'N/A';
    }
  }

  String getFormattedDateTime() {
    try {
      final dateTime = DateTime.parse(inspectedAt);
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return 'N/A';
    }
  }

  String getStatusText() {
    if (hasOpenIssue) {
      return 'Issue Reported';
    }
    return 'Complete';
  }

  bool isComplete() {
    return !hasOpenIssue;
  }
}
