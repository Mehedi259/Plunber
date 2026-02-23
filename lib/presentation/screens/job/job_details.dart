import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_path.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    
    // Create 7 animation controllers for different sections
    _controllers = List.generate(
      7,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Start animations with stagger effect
    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 100));
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Header
              _buildAnimatedSection(
                0,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job ${widget.jobId}',
                      style: const TextStyle(
                        color: Color(0xFF1E40AF),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Leak Repair',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF323232),
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Safety Check Required Banner
              _buildAnimatedSection(
                1,
                GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      RoutePath.safetyCheck,
                      queryParameters: {
                        'jobId': widget.jobId,
                        'address': '45 Maple Street',
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Safety Check Required',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Job Info Section
              _buildAnimatedSection(
                2,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Info',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xCC323232),
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Address',
                        '123 Elm St, Downtown',
                        const Color(0xFF2563EB),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.access_time,
                        'Scheduled Time',
                        '8:00 AM',
                        const Color(0xFF2563EB),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.local_shipping_outlined,
                        'Vehicle: Truck 12',
                        'Vehicle no: ABC-1234',
                        const Color(0xFF2563EB),
                      ),
                      const Divider(height: 24),
                      _buildStatusRow(),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Job Info Description
              _buildAnimatedSection(
                3,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Info',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xCC323232),
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0x66323232),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Customer reported a leak under the kitchen sink. Water is pooling on the floor. Inspect and repair the leak.',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: Color(0xCC323232),
                          height: 1.30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Information
              _buildAnimatedSection(
                4,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xCC323232),
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0x66323232),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/scott.png',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scott Thompson',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF323232),
                                    height: 1.05,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Homeowner',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xCC323232),
                                    height: 1.05,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 16, color: Color(0xFF105DBE)),
                                    SizedBox(width: 2),
                                    Text(
                                      '+1 555-123-4567',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF105DBE),
                                        height: 1.05,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.phone, size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Phone',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    height: 1.05,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Attachments
              _buildAnimatedSection(
                5,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attachments',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xCC323232),
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0x66323232),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/pdf.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Leak_Repair_Agreement.pdf',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF323232),
                                    height: 1.05,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '2 days ago',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xCC323232),
                                    height: 1.05,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.download,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Start Job Button
              _buildAnimatedSection(
                6,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushNamed(
                        RoutePath.startJob,
                        queryParameters: {
                          'jobId': widget.jobId,
                          'address': '45 Maple Street',
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Start Job',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x66323232),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF323232),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF323232),
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF2563EB), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                  height: 1.05,
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Text(
                'Not Started',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4BB485),
                  height: 1.05,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
