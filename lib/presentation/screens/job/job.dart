import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../core/routes/route_path.dart';
import '../../widgets/custom_navigation/custom_navbar.dart';
import '../../widgets/animated_section.dart';
import '../../../global/controler/job/job_controller.dart';
import '../../../global/service/job/job_service.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key}) : super(key: key);

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _jobController = Get.put(JobController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            AnimatedSection(
              index: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/app_banner.png',
                      height: 45,
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FA),
                        border: Border.all(
                          color: const Color(0x0C323232),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 24),
                        onPressed: () {
                          context.pushNamed(RoutePath.notification);
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tabs
            AnimatedSection(
              index: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF2563EB),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF2563EB),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
            // Safety Check Banner
            AnimatedSection(
              index: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Safety Check Required',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.80),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Job List
            Expanded(
              child: Obx(() {
                if (_jobController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  );
                }

                if (_jobController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _jobController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _jobController.fetchJobs(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildJobList(_jobController.todayJobs),
                    _buildJobList(_jobController.upcomingJobs),
                    _buildJobList(_jobController.completedJobs),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(List<JobData> jobs) {
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'No jobs available',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _jobController.refreshJobs(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AnimatedSection(
              index: index + 3,
              child: _buildJobCard(job),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(JobData job) {
    final statusText = job.getStatusText();
    final isCompleted = job.isCompleted();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: job.getCardColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Number and Status/Complete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job ${job.jobId}',
                style: const TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                ),
              ),
              if (statusText != null && statusText == 'In Progress')
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1DEC5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                    ),
                  ),
                ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF105DBE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Complete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Address
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF323232)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.client.address,
                  style: const TextStyle(
                    color: Color(0xFF323232),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Job Type
          Text(
            job.jobName,
            style: const TextStyle(
              color: Color(0xFF323232),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          // Time, Vehicle, Vehicle No
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 16, color: Color(0xB2323232)),
                  const SizedBox(width: 4),
                  Text(
                    job.getFormattedTime(),
                    style: const TextStyle(
                      color: Color(0xB2323232),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      height: 1.05,
                      letterSpacing: -0.30,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xB2323232)),
                  const SizedBox(width: 4),
                  Text(
                    job.vehicle.name,
                    style: const TextStyle(
                      color: Color(0xB2323232),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      height: 1.05,
                      letterSpacing: -0.30,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 16, color: Color(0xB2323232)),
                  const SizedBox(width: 4),
                  Text(
                    'Vehicle no: ${job.vehicle.vehicleNumber}',
                    style: const TextStyle(
                      color: Color(0xB2323232),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      height: 1.05,
                      letterSpacing: -0.30,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // See Details Button
          GestureDetector(
            onTap: () {
              context.pushNamed(
                RoutePath.jobDetails,
                queryParameters: {'jobId': job.jobId},
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'See details',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      height: 1.05,
                      letterSpacing: -0.30,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
