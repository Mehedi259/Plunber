import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';

class InspectionService {
  Future<InspectionHistoryResponse> getInspectionHistory(String vehicleId) async {
    try {
      final token = StorageHelper.getString(ApiConstants.accessTokenKey);
      if (token == null) {
        return InspectionHistoryResponse(
          success: false,
          message: 'Authentication token not found',
          inspections: [],
        );
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.inspectionHistory(vehicleId)}');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return InspectionHistoryResponse(
          success: true,
          message: 'Inspection history fetched successfully',
          inspections: data.map((item) => InspectionHistoryItem.fromJson(item)).toList(),
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

  Future<InspectionDetailResponse> getInspectionDetails(String inspectionId) async {
    try {
      final token = StorageHelper.getString(ApiConstants.accessTokenKey);
      if (token == null) {
        return InspectionDetailResponse(
          success: false,
          message: 'Authentication token not found',
        );
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.inspectionDetails(inspectionId)}');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InspectionDetailResponse(
          success: true,
          message: 'Inspection details fetched successfully',
          inspection: InspectionDetail.fromJson(data),
        );
      } else {
        final error = jsonDecode(response.body);
        return InspectionDetailResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch inspection details',
        );
      }
    } catch (e) {
      return InspectionDetailResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<SubmitInspectionResponse> submitInspection({
    required String vehicleId,
    required String notes,
    required List<InspectionCheckItem> items,
    required Map<String, List<InspectionPhoto>> photos,
  }) async {
    try {
      final token = StorageHelper.getString(ApiConstants.accessTokenKey);
      if (token == null) {
        return SubmitInspectionResponse(
          success: false,
          message: 'Authentication token not found',
        );
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.submitInspection(vehicleId)}');
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add notes
      request.fields['notes'] = notes;

      // Add items as JSON string
      final itemsJson = items.map((item) => item.toJson()).toList();
      request.fields['items'] = jsonEncode(itemsJson);

      // Add photos
      for (var entry in photos.entries) {
        final category = entry.key;
        final photoList = entry.value;

        for (int i = 0; i < photoList.length; i++) {
          final photo = photoList[i];
          
          // Add photo file
          if (photo.file != null) {
            final fileStream = http.ByteStream(photo.file!.openRead());
            final fileLength = await photo.file!.length();
            final multipartFile = http.MultipartFile(
              'photos_${category}_$i',
              fileStream,
              fileLength,
              filename: photo.file!.path.split('/').last,
            );
            request.files.add(multipartFile);
          }

          // Add caption
          if (photo.caption != null && photo.caption!.isNotEmpty) {
            request.fields['captions_${category}_$i'] = photo.caption!;
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubmitInspectionResponse(
          success: true,
          message: data['message'] ?? 'Inspection submitted successfully',
          hasOpenIssue: data['has_open_issue'] ?? false,
          inspection: data['data'] != null ? InspectionDetail.fromJson(data['data']) : null,
        );
      } else {
        final error = jsonDecode(response.body);
        return SubmitInspectionResponse(
          success: false,
          message: error['error'] ?? error['message'] ?? 'Failed to submit inspection',
        );
      }
    } catch (e) {
      return SubmitInspectionResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

class InspectionHistoryResponse {
  final bool success;
  final String message;
  final List<InspectionHistoryItem> inspections;

  InspectionHistoryResponse({
    required this.success,
    required this.message,
    required this.inspections,
  });
}

class InspectionHistoryItem {
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

  InspectionHistoryItem({
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

  factory InspectionHistoryItem.fromJson(Map<String, dynamic> json) {
    return InspectionHistoryItem(
      id: json['id'],
      vehicle: json['vehicle'],
      vehicleName: json['vehicle_name'],
      vehiclePlate: json['vehicle_plate'],
      inspectedBy: json['inspected_by'],
      inspectedByName: json['inspected_by_name'],
      hasOpenIssue: json['has_open_issue'] ?? false,
      issueCount: json['issue_count'] ?? 0,
      completedItemsCount: json['completed_items_count'] ?? 0,
      notes: json['notes'] ?? '',
      inspectedAt: json['inspected_at'],
    );
  }

  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(inspectedAt);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return inspectedAt;
    }
  }
}

class InspectionDetailResponse {
  final bool success;
  final String message;
  final InspectionDetail? inspection;

  InspectionDetailResponse({
    required this.success,
    required this.message,
    this.inspection,
  });
}

class InspectionDetail {
  final String id;
  final String vehicle;
  final String vehicleName;
  final String vehiclePlate;
  final String inspectedBy;
  final String inspectedByName;
  final bool hasOpenIssue;
  final String notes;
  final List<CheckItem> checkItems;
  final int issueCount;
  final int completedItemsCount;
  final String inspectedAt;
  final String updatedAt;

  InspectionDetail({
    required this.id,
    required this.vehicle,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.inspectedBy,
    required this.inspectedByName,
    required this.hasOpenIssue,
    required this.notes,
    required this.checkItems,
    required this.issueCount,
    required this.completedItemsCount,
    required this.inspectedAt,
    required this.updatedAt,
  });

  factory InspectionDetail.fromJson(Map<String, dynamic> json) {
    return InspectionDetail(
      id: json['id'],
      vehicle: json['vehicle'],
      vehicleName: json['vehicle_name'],
      vehiclePlate: json['vehicle_plate'],
      inspectedBy: json['inspected_by'],
      inspectedByName: json['inspected_by_name'],
      hasOpenIssue: json['has_open_issue'] ?? false,
      notes: json['notes'] ?? '',
      checkItems: (json['check_items'] as List)
          .map((item) => CheckItem.fromJson(item))
          .toList(),
      issueCount: json['issue_count'] ?? 0,
      completedItemsCount: json['completed_items_count'] ?? 0,
      inspectedAt: json['inspected_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class CheckItem {
  final String id;
  final String category;
  final bool isOk;
  final String issueDetail;
  final List<PhotoItem> photos;
  final String createdAt;

  CheckItem({
    required this.id,
    required this.category,
    required this.isOk,
    required this.issueDetail,
    required this.photos,
    required this.createdAt,
  });

  factory CheckItem.fromJson(Map<String, dynamic> json) {
    return CheckItem(
      id: json['id'],
      category: json['category'],
      isOk: json['is_ok'] ?? false,
      issueDetail: json['issue_detail'] ?? '',
      photos: (json['photos'] as List?)
          ?.map((photo) => PhotoItem.fromJson(photo))
          .toList() ?? [],
      createdAt: json['created_at'],
    );
  }

  String getCategoryDisplayName() {
    switch (category) {
      case 'lights':
        return 'Lights';
      case 'tires':
        return 'Tires';
      case 'brakes':
        return 'Brakes';
      case 'fluid_levels':
        return 'Fluid Levels';
      case 'mirrors':
        return 'Mirrors';
      case 'horn':
        return 'Horn';
      case 'windshield_wipers':
        return 'Windshield & Wipers';
      case 'dashboard_warning_lights':
        return 'Dashboard Warning Lights';
      case 'body_exterior':
        return 'Body Exterior';
      default:
        return category;
    }
  }
}

class PhotoItem {
  final String id;
  final String photo;
  final String uploadedAt;

  PhotoItem({
    required this.id,
    required this.photo,
    required this.uploadedAt,
  });

  factory PhotoItem.fromJson(Map<String, dynamic> json) {
    return PhotoItem(
      id: json['id'],
      photo: json['photo'],
      uploadedAt: json['uploaded_at'],
    );
  }
}

class SubmitInspectionResponse {
  final bool success;
  final String message;
  final bool? hasOpenIssue;
  final InspectionDetail? inspection;

  SubmitInspectionResponse({
    required this.success,
    required this.message,
    this.hasOpenIssue,
    this.inspection,
  });
}

class InspectionCheckItem {
  final String category;
  final bool isOk;
  final String? issueDetail;

  InspectionCheckItem({
    required this.category,
    required this.isOk,
    this.issueDetail,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'category': category,
      'is_ok': isOk,
    };
    
    if (issueDetail != null && issueDetail!.isNotEmpty) {
      json['issue_detail'] = issueDetail!;
    }
    
    return json;
  }
}

class InspectionPhoto {
  final File? file;
  final String? caption;

  InspectionPhoto({
    this.file,
    this.caption,
  });
}
