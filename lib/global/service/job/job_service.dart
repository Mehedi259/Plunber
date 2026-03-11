import 'dart:convert';
import 'package:flutter/material.dart';
import '../../constant/api_constant.dart';
import '../api_services.dart';

class JobService {
  Future<JobsResponse> getMyJobs() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.myJobs,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return JobsResponse(
          success: true,
          message: 'Jobs fetched successfully',
          todayJobs: (data['today'] as List?)
              ?.map((job) => JobData.fromJson(job))
              .toList() ?? [],
          upcomingJobs: (data['upcoming'] as List?)
              ?.map((job) => JobData.fromJson(job))
              .toList() ?? [],
          completedJobs: (data['completed'] as List?)
              ?.map((job) => JobData.fromJson(job))
              .toList() ?? [],
        );
      } else {
        final error = jsonDecode(response.body);
        return JobsResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch jobs',
          todayJobs: [],
          upcomingJobs: [],
          completedJobs: [],
        );
      }
    } catch (e) {
      return JobsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        todayJobs: [],
        upcomingJobs: [],
        completedJobs: [],
      );
    }
  }
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
      id: json['id'],
      jobId: json['job_id'],
      jobName: json['job_name'] ?? 'Not Mentioned',
      client: ClientData.fromJson(json['client']),
      scheduledDatetime: json['scheduled_datetime'],
      status: json['status'],
      vehicle: VehicleData.fromJson(json['vehicle']),
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
      name: json['name'],
      address: json['address'],
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

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      vehicleNumber: json['vehicle_number'],
      name: json['name'],
    );
  }
}
