import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_path.dart';
import '../../widgets/custom_navigation/custom_navbar.dart';

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PlumberS',
                    style: TextStyle(
                      color: Color(0xFFF63C00),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFF63C00),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFF63C00),
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            // Safety Check Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF63C00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Safety Check Required',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
        _buildJobCard(
          jobNumber: '#1023',
          address: '123 Elm St, Downtown',
          jobType: 'Leak Repair',
          time: '8:00 AM',
          vehicle: 'Truck 12',
          vehicleNo: 'ABC-1234',
          color: const Color(0xFFFFE5E5),
          status: 'Safety Check Required',
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          jobNumber: '#1022',
          address: '892 Maple Ave, Westfield',
          jobType: 'Not Mentioned',
          time: '9:30 AM',
          vehicle: 'Van 9',
          vehicleNo: 'XYZ-5678',
          color: const Color(0xFFE5F5E5),
          status: 'In Progress',
        ),
        const SizedBox(height: 12),
        _buildJobCard(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job $jobNumber',
                style: const TextStyle(
                  color: Color(0xFFF63C00),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              if (showComplete)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Complete'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(address, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            jobType,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(time, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(vehicle, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.directions_car_outlined, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text('Vehicle no: $vehicleNo', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              context.pushNamed(
                RoutePath.jobDetails,
                queryParameters: {'jobId': jobNumber},
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'See details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
