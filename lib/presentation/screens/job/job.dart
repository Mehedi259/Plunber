import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_path.dart';
import '../../widgets/custom_navigation/custom_navbar.dart';
import '../../widgets/animated_section.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key}) : super(key: key);

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobList(),
                  _buildJobList(),
                  _buildJobList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        AnimatedSection(
          index: 3,
          child: _buildJobCard(
            jobNumber: '#1023',
            address: '123 Elm St, Downtown',
            jobType: 'Leak Repair',
            time: '8:00 AM',
            vehicle: 'Truck 12',
            vehicleNo: 'ABC-1234',
            color: const Color(0xFFFFE5E5),
            status: 'Safety Check Required',
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSection(
          index: 4,
          child: _buildJobCard(
            jobNumber: '#1022',
            address: '892 Maple Ave, Westfield',
            jobType: 'Not Mentioned',
            time: '9:30 AM',
            vehicle: 'Van 9',
            vehicleNo: 'XYZ-5678',
            color: const Color(0xFFE5F5E5),
            status: 'In Progress',
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSection(
          index: 5,
          child: _buildJobCard(
            jobNumber: '#1021',
            address: '55 Pine Rd, Lakeside',
            jobType: 'Not Mentioned',
            time: '4:00 AM',
            vehicle: 'Van 7',
            vehicleNo: 'XYZ-0025',
            color: const Color(0xFFFFF9E5),
            status: null,
            showComplete: true,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildJobCard({
    required String jobNumber,
    required String address,
    required String jobType,
    required String time,
    required String vehicle,
    required String vehicleNo,
    required Color color,
    String? status,
    bool showComplete = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
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
                'Job $jobNumber',
                style: const TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                ),
              ),
              if (status != null && status == 'In Progress')
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1DEC5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                    ),
                  ),
                ),
              if (showComplete)
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
              Text(
                address,
                style: const TextStyle(
                  color: Color(0xFF323232),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.05,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Job Type
          Text(
            jobType,
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
                    time,
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
                    vehicle,
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
                    'Vehicle no: $vehicleNo',
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
                queryParameters: {'jobId': jobNumber},
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
