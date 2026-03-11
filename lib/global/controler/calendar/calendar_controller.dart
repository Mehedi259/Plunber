import 'package:get/get.dart';
import '../../service/calendar/calendar_service.dart';
import '../../service/job/job_service.dart';

class CalendarController extends GetxController {
  final CalendarService _calendarService = CalendarService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<JobData> todayJobs = <JobData>[].obs;
  final RxList<JobData> tomorrowJobs = <JobData>[].obs;
  final Rx<Map<String, List<JobData>>> thisWeekJobs = Rx<Map<String, List<JobData>>>({});

  @override
  void onInit() {
    super.onInit();
    fetchCalendarJobs();
  }

  Future<void> fetchCalendarJobs() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _calendarService.getCalendarJobs();

      if (response.success) {
        todayJobs.value = response.todayJobs;
        tomorrowJobs.value = response.tomorrowJobs;
        thisWeekJobs.value = response.thisWeekJobs;
        isLoading.value = false;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      isLoading.value = false;
    }
  }

  Future<void> refreshCalendar() async {
    await fetchCalendarJobs();
  }

  List<JobData> getWeekJobsForDay(String day) {
    return thisWeekJobs.value[day.toLowerCase()] ?? [];
  }

  List<JobData> getAllWeekJobs() {
    final allJobs = <JobData>[];
    thisWeekJobs.value.forEach((day, jobs) {
      allJobs.addAll(jobs);
    });
    return allJobs;
  }
}
