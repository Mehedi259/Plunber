import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
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
                    'Calendar',
                    style: TextStyle(
                      color: Colors.black,
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
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFF63C00),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFF63C00),
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Tomorrow'),
                Tab(text: 'This Week'),
              ],
            ),
            // Timeline
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTimeline(),
                  _buildTimeline(),
                  _buildTimeline(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTimelineItem(
          time: '8:00\nAM',
          jobNumber: '#1023',
          address: '123 Elm St, Downtown',
          startTime: '8:00 AM',
          vehicle: 'Truck 12',
          vehicleNo: 'ABC-1234',
          color: const Color(0xFFFFE5E5),
        ),
        _buildTimelineItem(
          time: '9:30\nAM',
          jobNumber: '#1022',
          address: '892 Maple Ave, Westfield',
          startTime: '9:30 AM',
          vehicle: 'Van 9',
          vehicleNo: 'XYZ-5678',
          color: const Color(0xFFE5F5E5),
        ),
        _buildTimelineItem(
          time: '4:00\nPM',
          jobNumber: '#1021',
          address: '55 Pine Rd, Lakeside',
          startTime: '4:00 AM',
          vehicle: 'Van 7',
          vehicleNo: 'XYZ-0025',
          color: const Color(0xFFE5E5FF),
        ),
        _buildTimelineItem(
          time: '8:30\nPM',
          jobNumber: '#1020',
          address: '60 Park Rd, Lakeside',
          startTime: '8:30 PM',
          vehicle: 'Van 5',
          vehicleNo: 'XYZ-0725',
          color: const Color(0xFFFFF9E5),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String jobNumber,
    required String address,
    required String startTime,
    required String vehicle,
    required String vehicleNo,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time
        SizedBox(
          width: 50,
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF63C00),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 140,
              color: const Color(0xFFF63C00),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Job Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job $jobNumber',
                  style: const TextStyle(
                    color: Color(0xFFF63C00),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(startTime, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(vehicle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.directions_car_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('Vehicle no: $vehicleNo', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
