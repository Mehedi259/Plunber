import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';

class CertificateService {
  Future<CertificatesResponse> getCertificates() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.certificates,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return CertificatesResponse(
          success: true,
          message: 'Certificates fetched successfully',
          certificates: results.map((cert) => Certificate.fromJson(cert)).toList(),
        );
      } else {
        return CertificatesResponse(
          success: false,
          message: 'Failed to fetch certificates',
          certificates: [],
        );
      }
    } catch (e) {
      return CertificatesResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        certificates: [],
      );
    }
  }

  Future<AddCertificateResponse> addCertificate({
    required String name,
    required String issuingOrganization,
    required String description,
    required String issueDate,
    required String expirationDate,
    required File media,
  }) async {
    try {
      final token = StorageHelper.getString(ApiConstants.accessTokenKey);
      if (token == null) {
        return AddCertificateResponse(
          success: false,
          message: 'Authentication token not found',
        );
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.certificates}');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['issuing_organization'] = issuingOrganization;
      request.fields['description'] = description;
      request.fields['issue_date'] = issueDate;
      request.fields['expiration_date'] = expirationDate;

      final file = await http.MultipartFile.fromPath('media', media.path);
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Certificate API Status: ${response.statusCode}');
      print('Certificate API Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AddCertificateResponse(
          success: true,
          message: 'Certificate added successfully',
        );
      } else {
        try {
          final error = jsonDecode(response.body);
          return AddCertificateResponse(
            success: false,
            message: error['message'] ?? error.toString(),
          );
        } catch (e) {
          return AddCertificateResponse(
            success: false,
            message: 'Server error: ${response.body}',
          );
        }
      }
    } catch (e) {
      print('Certificate submission error: $e');
      return AddCertificateResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

class CertificatesResponse {
  final bool success;
  final String message;
  final List<Certificate> certificates;

  CertificatesResponse({
    required this.success,
    required this.message,
    required this.certificates,
  });
}

class AddCertificateResponse {
  final bool success;
  final String message;

  AddCertificateResponse({
    required this.success,
    required this.message,
  });
}

class Certificate {
  final String id;
  final String name;
  final String issuingOrganization;
  final String description;
  final String issueDate;
  final String expirationDate;
  final String media;
  final String createdAt;
  final String updatedAt;

  Certificate({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    required this.description,
    required this.issueDate,
    required this.expirationDate,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      name: json['name'],
      issuingOrganization: json['issuing_organization'],
      description: json['description'],
      issueDate: json['issue_date'],
      expirationDate: json['expiration_date'],
      media: json['media'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  String getFormattedIssueDate() {
    try {
      final dateTime = DateTime.parse(issueDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return issueDate;
    }
  }

  String getFormattedExpirationDate() {
    try {
      final dateTime = DateTime.parse(expirationDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return expirationDate;
    }
  }

  bool isExpired() {
    try {
      final expDate = DateTime.parse(expirationDate);
      return expDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}
