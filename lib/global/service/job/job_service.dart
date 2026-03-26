import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../../constant/api_constant.dart';
import '../../models/job_detail_model.dart';
import '../api_services.dart';

class JobService {
  Future<JobsResponse> getMyJobs() async {
    try {
      log('Fetching jobs with server-side filtering');
      
      // Fetch jobs for each category using server-side filtering
      final todayJobsFuture = _fetchJobsByFilter('today');
      final upcomingJobsFuture = _fetchJobsByFilter('upcoming');
      final completedJobsFuture = _fetchJobsByFilter('completed');
      
      // Wait for all requests to complete
      final results = await Future.wait([
        todayJobsFuture,
        upcomingJobsFuture,
        completedJobsFuture,
      ]);
      
      final todayJobs = results[0];
      final upcomingJobs = results[1];
      final completedJobs = results[2];
      
      log('Final counts - Today: ${todayJobs.length}, Upcoming: ${upcomingJobs.length}, Completed: ${completedJobs.length}');
      
      return JobsResponse(
        success: true,
        message: 'Jobs fetched successfully',
        todayJobs: todayJobs,
        upcomingJobs: upcomingJobs,
        completedJobs: completedJobs,
      );
    } catch (e) {
      log('Jobs API error: $e');
      return JobsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        todayJobs: [],
        upcomingJobs: [],
        completedJobs: [],
      );
    }
  }

  Future<List<JobData>> _fetchJobsByFilter(String filter) async {
    try {
      log('Fetching jobs with filter: $filter');
      
      final response = await ApiService.get(
        endpoint: '${ApiConstants.myJobs}?filter=$filter',
        includeAuth: true,
      );

      log('Jobs API ($filter) response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse paginated response
        final results = (data['results'] as List?)
            ?.map((job) => JobData.fromJson(job))
            .toList() ?? [];
        
        log('Total $filter jobs from API: ${results.length}');
        return results;
      } else {
        log('Failed to fetch $filter jobs: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching $filter jobs: $e');
      return [];
    }
  }

  Future<JobDetailResponse> getJobDetails(String jobId) async {
    try {
      log('Fetching job details for: $jobId');
      
      final response = await ApiService.get(
        endpoint: ApiConstants.jobDetailsById(jobId),
        includeAuth: true,
      );

      log('Job details API response status: ${response.statusCode}');
      log('Job details API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jobDetail = JobDetailModel.fromJson(data);
        
        return JobDetailResponse(
          success: true,
          message: 'Job details fetched successfully',
          data: jobDetail,
        );
      } else {
        final error = jsonDecode(response.body);
        return JobDetailResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch job details',
        );
      }
    } catch (e) {
      log('Job details API error: $e');
      return JobDetailResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<JobActionResponse> startJob(String jobId) async {
    try {
      log('Starting job: $jobId');
      
      final response = await ApiService.post(
        endpoint: ApiConstants.startJob(jobId),
        body: {},
        includeAuth: true,
      );

      log('Start job API response status: ${response.statusCode}');
      log('Start job API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JobActionResponse(
          success: true,
          message: data['message'] ?? 'Job started successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return JobActionResponse(
          success: false,
          message: error['message'] ?? 'Failed to start job',
        );
      }
    } catch (e) {
      log('Start job API error: $e');
      return JobActionResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<JobActionResponse> completeJob(String jobId) async {
    try {
      log('Completing job: $jobId');
      
      final response = await ApiService.post(
        endpoint: ApiConstants.completeJob(jobId),
        body: {},
        includeAuth: true,
      );

      log('Complete job API response status: ${response.statusCode}');
      log('Complete job API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JobActionResponse(
          success: true,
          message: data['message'] ?? 'Job completed successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return JobActionResponse(
          success: false,
          message: error['message'] ?? 'Failed to complete job',
        );
      }
    } catch (e) {
      log('Complete job API error: $e');
      return JobActionResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

class JobDetailResponse {
  final bool success;
  final String message;
  final JobDetailModel? data;

  JobDetailResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class JobActionResponse {
  final bool success;
  final String message;

  JobActionResponse({
    required this.success,
    required this.message,
  });
}

class JobsResponse {
  final bool success;
  final String message;
  final List<JobData> todayJobs;
  final List<JobData> upcomingJobs;
  final List<JobData> completedJobs;

  JobsResponse({
    required this.success,
    required this.message,
    required this.todayJobs,
    required this.upcomingJobs,
    required this.completedJobs,
  });
}

class JobData {
  final String id;
  final String jobId;
  final String jobName;
  final ClientData client;
  final String scheduledDatetime;
  final String status;
  final VehicleData vehicle;

  JobData({
    required this.id,
    required this.jobId,
    required this.jobName,
    required this.client,
    required this.scheduledDatetime,
    required this.status,
    required this.vehicle,
  });

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(
      id: json['id'] ?? '',
      jobId: json['job_id'] ?? '',
      jobName: json['job_name'] ?? 'Not Mentioned',
      client: ClientData(
        name: json['client_name'] ?? 'Unknown',
        address: json['client_address'] ?? 'Unknown',
      ),
      scheduledDatetime: json['scheduled_datetime'] ?? '',
      status: json['status'] ?? 'pending',
      vehicle: VehicleData(
        vehicleNumber: json['vehicle_plate'] ?? 'N/A',
        name: json['vehicle_name'] ?? 'No Vehicle',
      ),
    );
  }

  String getFormattedTime() {
    try {
      final dateTime = DateTime.parse(scheduledDatetime);
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (e) {
      return 'N/A';
    }
  }

  Color getCardColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFE5E5);
      case 'in_progress':
        return const Color(0xFFE5F5E5);
      case 'completed':
        return const Color(0xFFFFF9E5);
      default:
        return const Color(0xFFE5E5E5);
    }
  }

  String? getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Safety Check Required';
      case 'in_progress':
        return 'In Progress';
      default:
        return null;
    }
  }

  bool isCompleted() {
    return status.toLowerCase() == 'completed';
  }
}

class ClientData {
  final String name;
  final String address;

  ClientData({
    required this.name,
    required this.address,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      name: json['name'] ?? 'Unknown',
      address: json['address'] ?? 'Unknown',
    );
  }
}

class VehicleData {
  final String vehicleNumber;
  final String name;

  VehicleData({
    required this.vehicleNumber,
    required this.name,
  });
}
