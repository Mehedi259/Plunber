import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/animated_section.dart';
import '../../../global/controler/calendar/calendar_controller.dart';
import '../../../global/service/calendar/calendar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _calendarController = Get.put(CalendarController());
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize with current date
    final now = DateTime.now();
    _selectedDay = now.day;
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<List<int>> _getMonthDays() {
    // Get all days in the selected month organized by weeks
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);
    
    // Get the weekday of the first day (0 = Sunday, 6 = Saturday)
    final firstWeekday = firstDayOfMonth.weekday % 7;
    
    List<List<int>> weeks = [];
    List<int> currentWeek = [];
    
    // Add empty spaces for days before the first day
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(0); // 0 means empty
    }
    
    // Add all days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      currentWeek.add(day);
      
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    
    // Add remaining days to complete the last week
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(0);
      }
      weeks.add(currentWeek);
    }
    
    return weeks;
  }

  List<CalendarJobData> _getJobsForSelectedDate() {
    final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    return _calendarController.thisWeekJobs.where((job) {
      try {
        final jobDate = DateTime.parse(job.scheduledDatetime);
        final jobDateOnly = DateTime(jobDate.year, jobDate.month, jobDate.day);
        return jobDateOnly.isAtSameMomentAs(selectedDateOnly);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  bool _hasJobsOnDate(int day) {
    if (day == 0) return false;
    
    final date = DateTime(_selectedYear, _selectedMonth, day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    return _calendarController.thisWeekJobs.any((job) {
      try {
        final jobDate = DateTime.parse(job.scheduledDatetime);
        final jobDateOnly = DateTime(jobDate.year, jobDate.month, jobDate.day);
        return jobDateOnly.isAtSameMomentAs(dateOnly);
      } catch (e) {
        return false;
      }
    });
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

  Widget _buildTimeline(List<CalendarJobData> jobs) {
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

  Widget _buildTimelineItem(CalendarJobData job) {
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
                        job.clientAddress,
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
                    if (job.vehicleName != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(job.vehicleName!, style: const TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
                if (job.vehiclePlate != null)
                  const SizedBox(height: 4),
                if (job.vehiclePlate != null)
                  Row(
                    children: [
                      const Icon(Icons.directions_car_outlined, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text('Vehicle no: ${job.vehiclePlate}', style: const TextStyle(fontSize: 12)),
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
    final monthDays = _getMonthDays();
    
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Month Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                      onPressed: () => _changeMonth(false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      '${_monthNames[_selectedMonth - 1]} $_selectedYear',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                      onPressed: () => _changeMonth(true),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Week Days Header
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
                const SizedBox(height: 8),
                // Month Days Grid
                ...monthDays.map((week) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: week.map((day) {
                        return _buildDayNumber(day, day == _selectedDay);
                      }).toList(),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Jobs for Selected Date
        Expanded(
          child: Obx(() {
            final selectedDateJobs = _getJobsForSelectedDate();
            
            if (selectedDateJobs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No jobs on ${_monthNames[_selectedMonth - 1]} $_selectedDay',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () => _calendarController.refreshCalendar(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: selectedDateJobs.length,
                itemBuilder: (context, index) {
                  final job = selectedDateJobs[index];
                  return AnimatedSection(
                    index: index + 3,
                    child: _buildTimelineItem(job),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWeekDayLabel(String day) {
    return SizedBox(
      width: 36,
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDayNumber(int day, bool isSelected) {
    if (day == 0) {
      // Empty day
      return const SizedBox(width: 36, height: 36);
    }
    
    final hasJobs = _hasJobsOnDate(day);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          border: hasJobs && !isSelected
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (hasJobs && !isSelected)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
