import 'package:get/get.dart';
import '../../service/job/job_service.dart';
import '../../service/notification/notification_service.dart';

class JobController extends GetxController {
  final JobService _jobService = JobService();
  final NotificationService _notificationService = NotificationService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<JobData> todayJobs = <JobData>[].obs;
  final RxList<JobData> upcomingJobs = <JobData>[].obs;
  final RxList<JobData> completedJobs = <JobData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _jobService.getMyJobs();

      if (response.success) {
        todayJobs.value = response.todayJobs;
        upcomingJobs.value = response.upcomingJobs;
        completedJobs.value = response.completedJobs;
        
        // Check for new jobs and create notifications
        final totalJobs = todayJobs.length + upcomingJobs.length;
        await _notificationService.checkForNewJobs(totalJobs);
        
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

  Future<void> refreshJobs() async {
    await fetchJobs();
  }
}
