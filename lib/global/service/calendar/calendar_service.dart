import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../../constant/api_constant.dart';
import '../api_services.dart';

class CalendarService {
  Future<CalendarResponse> getCalendarJobs() async {
    try {
      log('Fetching calendar jobs from: ${ApiConstants.jobsByDate}');
      
      final response = await ApiService.get(
        endpoint: ApiConstants.jobsByDate,
        includeAuth: true,
      );

      log('Calendar API response status: ${response.statusCode}');
      log('Calendar API response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        log('Parsed calendar data count: ${data.length}');
        
        final jobs = data.map((job) => CalendarJobData.fromJson(job)).toList();
        log('Total jobs parsed: ${jobs.length}');
        
        // Categorize jobs by date
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        
        final todayJobs = <CalendarJobData>[];
        final tomorrowJobs = <CalendarJobData>[];
        final allJobs = <CalendarJobData>[];
        
        for (var job in jobs) {
          try {
            final scheduledDate = DateTime.parse(job.scheduledDatetime);
            final jobDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
            
            log('Job ${job.jobId}: scheduled=$jobDate, today=$today, tomorrow=$tomorrow');
            
            if (jobDate.isAtSameMomentAs(today)) {
              todayJobs.add(job);
              log('Added to today: ${job.jobId}');
            } else if (jobDate.isAtSameMomentAs(tomorrow)) {
              tomorrowJobs.add(job);
              log('Added to tomorrow: ${job.jobId}');
            }
            
            // Add all jobs to thisWeekJobs for calendar view
            allJobs.add(job);
          } catch (e) {
            log('Date parse error for job ${job.jobId}: $e');
          }
        }
        
        log('Final counts - Today: ${todayJobs.length}, Tomorrow: ${tomorrowJobs.length}, All: ${allJobs.length}');
        
        return CalendarResponse(
          success: true,
          message: 'Calendar jobs fetched successfully',
          todayJobs: todayJobs,
          tomorrowJobs: tomorrowJobs,
          thisWeekJobs: allJobs,
        );
      } else {
        final error = jsonDecode(response.body);
        return CalendarResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch calendar jobs',
          todayJobs: [],
          tomorrowJobs: [],
          thisWeekJobs: [],
        );
      }
    } catch (e) {
      log('Calendar API error: $e');
      return CalendarResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        todayJobs: [],
        tomorrowJobs: [],
        thisWeekJobs: [],
      );
    }
  }
}

class CalendarResponse {
  final bool success;
  final String message;
  final List<CalendarJobData> todayJobs;
  final List<CalendarJobData> tomorrowJobs;
  final List<CalendarJobData> thisWeekJobs;

  CalendarResponse({
    required this.success,
    required this.message,
    required this.todayJobs,
    required this.tomorrowJobs,
    required this.thisWeekJobs,
  });
}

class CalendarJobData {
  final String id;
  final String jobId;
  final String jobName;
  final String clientAddress;
  final String scheduledDatetime;
  final String? vehicleName;
  final String? vehiclePlate;
  final String status;

  CalendarJobData({
    required this.id,
    required this.jobId,
    required this.jobName,
    required this.clientAddress,
    required this.scheduledDatetime,
    this.vehicleName,
    this.vehiclePlate,
    required this.status,
  });

  factory CalendarJobData.fromJson(Map<String, dynamic> json) {
    return CalendarJobData(
      id: json['id'] ?? '',
      jobId: json['job_id'] ?? '',
      jobName: json['job_name'] ?? 'Not Mentioned',
      clientAddress: json['client_address'] ?? 'Unknown',
      scheduledDatetime: json['scheduled_datetime'] ?? '',
      vehicleName: json['vehicle_name'],
      vehiclePlate: json['vehicle_plate'],
      status: json['status'] ?? 'pending',
    );
  }

  String getFormattedTime() {
    try {
      final dateTime = DateTime.parse(scheduledDatetime);
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
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
      case 'overdue':
        return const Color(0xFFFFE5E5);
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
      case 'overdue':
        return 'Overdue';
      default:
        return null;
    }
  }

  bool isCompleted() {
    return status.toLowerCase() == 'completed';
  }
}
