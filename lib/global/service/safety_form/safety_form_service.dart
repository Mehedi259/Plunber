import 'dart:convert';
import 'dart:developer';
import '../../constant/api_constant.dart';
import '../../models/safety_form_model.dart';
import '../api_services.dart';

class SafetyFormService {
  Future<SafetyFormTemplateResponse> getSafetyFormTemplate(
    String jobId,
    String templateId,
  ) async {
    try {
      log('Fetching safety form template for job: $jobId, template: $templateId');

      final response = await ApiService.get(
        endpoint: ApiConstants.safetyFormTemplate(jobId, templateId),
        includeAuth: true,
      );

      log('Safety form template API response status: ${response.statusCode}');
      log('Safety form template API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final template = SafetyFormTemplate.fromJson(data);

        return SafetyFormTemplateResponse(
          success: true,
          message: 'Safety form template fetched successfully',
          template: template,
        );
      } else {
        final error = jsonDecode(response.body);
        return SafetyFormTemplateResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch safety form template',
        );
      }
    } catch (e) {
      log('Safety form template API error: $e');
      return SafetyFormTemplateResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<SafetyFormSubmitResponse> submitSafetyForm(
    String jobId,
    String templateId,
    List<Map<String, String>> responses,
  ) async {
    try {
      log('Submitting safety form for job: $jobId, template: $templateId');
      log('Responses: $responses');

      final response = await ApiService.post(
        endpoint: ApiConstants.submitSafetyForm(jobId, templateId),
        body: {
          'responses': responses,
        },
        includeAuth: true,
      );

      log('Submit safety form API response status: ${response.statusCode}');
      log('Submit safety form API response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SafetyFormSubmitResponse(
          success: true,
          message: data['message'] ?? 'Safety form submitted successfully',
          data: data['data'] != null
              ? SubmittedFormData.fromJson(data['data'])
              : null,
        );
      } else {
        final error = jsonDecode(response.body);
        return SafetyFormSubmitResponse(
          success: false,
          message: error['message'] ?? 'Failed to submit safety form',
        );
      }
    } catch (e) {
      log('Submit safety form API error: $e');
      return SafetyFormSubmitResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
