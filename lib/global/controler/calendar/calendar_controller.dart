import 'package:get/get.dart';
import '../../service/calendar/calendar_service.dart';

class CalendarController extends GetxController {
  final CalendarService _calendarService = CalendarService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<CalendarJobData> todayJobs = <CalendarJobData>[].obs;
  final RxList<CalendarJobData> tomorrowJobs = <CalendarJobData>[].obs;
  final RxList<CalendarJobData> thisWeekJobs = <CalendarJobData>[].obs;

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

  List<CalendarJobData> getAllWeekJobs() {
    return thisWeekJobs;
  }
}
