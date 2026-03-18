import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';

class SupportService {
  Future<FAQsResponse> getFAQs() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.faqs,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return FAQsResponse(
          success: true,
          message: 'FAQs fetched successfully',
          faqs: results.map((faq) => FAQ.fromJson(faq)).toList(),
        );
      } else {
        return FAQsResponse(
          success: false,
          message: 'Failed to fetch FAQs',
          faqs: [],
        );
      }
    } catch (e) {
      return FAQsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        faqs: [],
      );
    }
  }

  Future<ContentResponse> getAboutUs() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.aboutUs,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ContentResponse(
          success: true,
          message: 'About Us fetched successfully',
          content: data['content'],
        );
      } else {
        return ContentResponse(
          success: false,
          message: 'Failed to fetch About Us',
        );
      }
    } catch (e) {
      return ContentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ContentResponse> getTerms() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.terms,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ContentResponse(
          success: true,
          message: 'Terms fetched successfully',
          content: data['content'],
        );
      } else {
        return ContentResponse(
          success: false,
          message: 'Failed to fetch Terms',
        );
      }
    } catch (e) {
      return ContentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ContentResponse> getPrivacy() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.privacy,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ContentResponse(
          success: true,
          message: 'Privacy Policy fetched successfully',
          content: data['content'],
        );
      } else {
        return ContentResponse(
          success: false,
          message: 'Failed to fetch Privacy Policy',
        );
      }
    } catch (e) {
      return ContentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<IssueResponse> submitIssue({
    required String title,
    required String description,
    File? photo1,
    File? photo2,
    File? photo3,
    File? photo4,
    File? photo5,
  }) async {
    try {
      final token = StorageHelper.getString(ApiConstants.accessTokenKey);
      if (token == null) {
        return IssueResponse(
          success: false,
          message: 'Authentication token not found',
        );
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.submitIssue}');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['title'] = title;
      request.fields['description'] = description;

      if (photo1 != null) {
        final file = await http.MultipartFile.fromPath('photo_1', photo1.path);
        request.files.add(file);
      }
      if (photo2 != null) {
        final file = await http.MultipartFile.fromPath('photo_2', photo2.path);
        request.files.add(file);
      }
      if (photo3 != null) {
        final file = await http.MultipartFile.fromPath('photo_3', photo3.path);
        request.files.add(file);
      }
      if (photo4 != null) {
        final file = await http.MultipartFile.fromPath('photo_4', photo4.path);
        request.files.add(file);
      }
      if (photo5 != null) {
        final file = await http.MultipartFile.fromPath('photo_5', photo5.path);
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return IssueResponse(
          success: true,
          message: data['message'] ?? 'Issue submitted successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return IssueResponse(
          success: false,
          message: error['message'] ?? 'Failed to submit issue',
        );
      }
    } catch (e) {
      return IssueResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<FeedbackResponse> submitFeedback({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String country,
    required String language,
    required String message,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.submitFeedback,
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'country': country,
          'language': language,
          'message': message,
        },
        includeAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FeedbackResponse(
          success: true,
          message: data['message'] ?? 'Feedback submitted successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return FeedbackResponse(
          success: false,
          message: error['message'] ?? 'Failed to submit feedback',
        );
      }
    } catch (e) {
      return FeedbackResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

class FAQsResponse {
  final bool success;
  final String message;
  final List<FAQ> faqs;

  FAQsResponse({
    required this.success,
    required this.message,
    required this.faqs,
  });
}

class FAQ {
  final String id;
  final String question;
  final String answer;
  final String createdAt;
  final String updatedAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ContentResponse {
  final bool success;
  final String message;
  final String? content;

  ContentResponse({
    required this.success,
    required this.message,
    this.content,
  });
}

class IssueResponse {
  final bool success;
  final String message;

  IssueResponse({
    required this.success,
    required this.message,
  });
}

class FeedbackResponse {
  final bool success;
  final String message;

  FeedbackResponse({
    required this.success,
    required this.message,
  });
}
