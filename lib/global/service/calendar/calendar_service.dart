import 'dart:convert';
import '../../constant/api_constant.dart';
import '../api_services.dart';
import '../job/job_service.dart';

class CalendarService {
  Future<CalendarResponse> getCalendarJobs() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.calendar,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return CalendarResponse(
          success: true,
          message: 'Calendar jobs fetched successfully',
          todayJobs: (data['today'] as List?)
              ?.map((job) => JobData.fromJson(job))
              .toList() ?? [],
          tomorrowJobs: (data['tomorrow'] as List?)
              ?.map((job) => JobData.fromJson(job))
              .toList() ?? [],
          thisWeekJobs: _parseWeekJobs(data['this_week']),
        );
      } else {
        final error = jsonDecode(response.body);
        return CalendarResponse(
          success: false,
          message: error['message'] ?? 'Failed to fetch calendar jobs',
          todayJobs: [],
          tomorrowJobs: [],
          thisWeekJobs: {},
        );
      }
    } catch (e) {
      return CalendarResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        todayJobs: [],
        tomorrowJobs: [],
        thisWeekJobs: {},
      );
    }
  }

  Map<String, List<JobData>> _parseWeekJobs(dynamic weekData) {
    if (weekData == null) return {};
    
    final Map<String, List<JobData>> weekJobs = {};
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    for (final day in days) {
      if (weekData[day] != null) {
        weekJobs[day] = (weekData[day] as List)
            .map((job) => JobData.fromJson(job))
            .toList();
      } else {
        weekJobs[day] = [];
      }
    }
    
    return weekJobs;
  }
}

class CalendarResponse {
  final bool success;
  final String message;
  final List<JobData> todayJobs;
  final List<JobData> tomorrowJobs;
  final Map<String, List<JobData>> thisWeekJobs;

  CalendarResponse({
    required this.success,
    required this.message,
    required this.todayJobs,
    required this.tomorrowJobs,
    required this.thisWeekJobs,
  });
}
