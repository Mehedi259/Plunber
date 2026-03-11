import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/animated_section.dart';
import '../../../global/controler/calendar/calendar_controller.dart';
import '../../../global/service/job/job_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _calendarController = Get.put(CalendarController());
  int _selectedDay = 19;
  int _selectedMonth = 1; // January = 1
  int _selectedYear = 2026;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

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

  List<int> _getWeekDays() {
    // Get the current week days based on selected day
    final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final weekday = selectedDate.weekday % 7; // 0 = Sunday, 6 = Saturday
    
    List<int> weekDays = [];
    for (int i = -weekday; i < 7 - weekday; i++) {
      final date = selectedDate.add(Duration(days: i));
      weekDays.add(date.day);
    }
    return weekDays;
  }

  void _changeMonth(bool next) {
    setState(() {
      if (next) {
        if (_selectedMonth == 12) {
          _selectedMonth = 1;
          _selectedYear++;
        } else {
          _selectedMonth++;
        }
      } else {
        if (_selectedMonth == 1) {
          _selectedMonth = 12;
          _selectedYear--;
        } else {
          _selectedMonth--;
        }
      }
      // Reset to first day of new month
      _selectedDay = 1;
    });
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
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Calendar',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    Tab(text: 'Tomorrow'),
                    Tab(text: 'This Week'),
                  ],
                ),
              ),
            ),
            // Timeline
            Expanded(
              child: Obx(() {
                if (_calendarController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  );
                }

                if (_calendarController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _calendarController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _calendarController.fetchCalendarJobs(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTimeline(_calendarController.todayJobs),
                    _buildTimeline(_calendarController.tomorrowJobs),
                    _buildWeekView(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(List<JobData> jobs) {
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'No jobs scheduled',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _calendarController.refreshCalendar(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return AnimatedSection(
            index: index + 2,
            child: _buildTimelineItem(job),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(JobData job) {
    final time = job.getFormattedTime();
    final timeLines = time.split(' ');
    final displayTime = timeLines.length > 1 
        ? '${timeLines[0]}\n${timeLines[1]}' 
        : time;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time
        SizedBox(
          width: 50,
          child: Text(
            displayTime,
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
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 140,
              color: const Color(0xFF2563EB),
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
              color: job.getCardColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job ${job.jobId}',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
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
                        job.client.address,
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
                    Text(job.getFormattedTime(), style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(job.vehicle.name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.directions_car_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('Vehicle no: ${job.vehicle.vehicleNumber}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final weekDays = _getWeekDays();
    
    return Column(
      children: [
        // Calendar Widget
        AnimatedSection(
          index: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCCBB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Month Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () => _changeMonth(false),
                    ),
                    Text(
                      '${_monthNames[_selectedMonth - 1]} $_selectedYear',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () => _changeMonth(true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Week Days
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeekDayLabel('Sun'),
                    _buildWeekDayLabel('Mon'),
                    _buildWeekDayLabel('Tue'),
                    _buildWeekDayLabel('Wed'),
                    _buildWeekDayLabel('Thu'),
                    _buildWeekDayLabel('Fri'),
                    _buildWeekDayLabel('Sat'),
                  ],
                ),
                const SizedBox(height: 12),
                // Week Days Numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((day) {
                    return _buildDayNumber(day, day == _selectedDay);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        // Timeline
        Expanded(
          child: Obx(() {
            final weekJobs = _calendarController.getAllWeekJobs();
            return _buildTimeline(weekJobs);
          }),
        ),
      ],
    );
  }

  Widget _buildWeekDayLabel(String day) {
    return SizedBox(
      width: 40,
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDayNumber(int day, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              color: isSelected ? const Color(0xFF2563EB) : Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
