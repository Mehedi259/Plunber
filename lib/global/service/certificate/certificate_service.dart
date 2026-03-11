import 'dart:convert';
import '../../constant/api_constant.dart';
import '../api_services.dart';

class CertificateService {
  Future<CertificatesResponse> getCertificates() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.certificates,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return CertificatesResponse(
          success: true,
          message: 'Certificates fetched successfully',
          certificates: data.map((cert) => Certificate.fromJson(cert)).toList(),
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
