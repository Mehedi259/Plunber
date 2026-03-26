import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../constant/api_constant.dart';
import '../../models/report_model.dart';
import '../api_services.dart';

class ReportService {
  Future<ReportFormResponse> getReportFormFields(String jobReportId) async {
    try {
      log('Fetching report form fields for: $jobReportId');

      final response = await ApiService.get(
        endpoint: ApiConstants.reportFormFields(jobReportId),
        includeAuth: true,
      );

      log('Report form fields API response status: ${response.statusCode}');
      log('Report form fields API response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final reportForm = ReportFormData.fromJson(data);

          return ReportFormResponse(
            success: true,
            message: 'Report form fields fetched successfully',
            data: reportForm,
          );
        } catch (e) {
          log('Failed to parse report form fields: $e');
          return ReportFormResponse(
            success: false,
            message: 'Failed to parse server response',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return ReportFormResponse(
            success: false,
            message: error['message'] ?? 'Failed to fetch report form fields',
          );
        } catch (e) {
          return ReportFormResponse(
            success: false,
            message: 'Server error (${response.statusCode}): Unable to process response',
          );
        }
      }
    } catch (e) {
      log('Report form fields API error: $e');
      return ReportFormResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ReportSubmitResponse> submitReport(
    String jobReportId,
    String reportType,
    Map<String, dynamic> formData,
    Map<String, List<XFile>>? imageFiles,
  ) async {
    try {
      log('Submitting report: $jobReportId, type: $reportType');
      log('Form data: $formData');

      // Prepare multipart files from XFile objects
      Map<String, List<http.MultipartFile>>? files;
      if (imageFiles != null && imageFiles.isNotEmpty) {
        files = {};
        for (var entry in imageFiles.entries) {
          final fieldName = entry.key;
          final xFiles = entry.value;
          files[fieldName] = [];
          
          for (var xFile in xFiles) {
            final bytes = await xFile.readAsBytes();
            final multipartFile = http.MultipartFile.fromBytes(
              fieldName,
              bytes,
              filename: xFile.name,
            );
            files[fieldName]!.add(multipartFile);
          }
        }
      }

      final response = await ApiService.postMultipart(
        endpoint: ApiConstants.submitReport(jobReportId, reportType),
        fields: formData,
        files: files,
        includeAuth: true,
      );

      log('Submit report API response status: ${response.statusCode}');
      log('Submit report API response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return ReportSubmitResponse(
            success: true,
            message: data['message'] ?? 'Report submitted successfully',
          );
        } catch (e) {
          // Handle non-JSON success response
          return ReportSubmitResponse(
            success: true,
            message: 'Report submitted successfully',
          );
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return ReportSubmitResponse(
            success: false,
            message: error['message'] ?? 'Failed to submit report',
          );
        } catch (e) {
          // Handle non-JSON error response (e.g., HTML error page)
          return ReportSubmitResponse(
            success: false,
            message: 'Server error (${response.statusCode}): Unable to process response',
          );
        }
      }
    } catch (e) {
      log('Submit report API error: $e');
      return ReportSubmitResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
