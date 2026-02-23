import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_path.dart';

class StartJobScreen extends StatelessWidget {
  final String jobId;

  const StartJobScreen({Key? key, required this.jobId}) : super(key: key);

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
              Text(
                'Job #$jobId',
                style: const TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Leak Repair',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 24),

              // Job Info Section
              const Text(
                'Job Info',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xCC323232),
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

              const SizedBox(height: 24),

              // Job Description
              const Text(
                'Job Info',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xCC323232),
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

              const SizedBox(height: 24),

              // Contact Information
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xCC323232),
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
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Homeowner',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              color: Color(0xCC323232),
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16, color: Color(0xFF105DBE)),
                              SizedBox(width: 4),
                              Text(
                                '+1 555-123-4567',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF105DBE),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
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
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xCC323232),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF323232),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '2 days ago',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              color: Color(0xCC323232),
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

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.pushNamed(
                          RoutePath.problemSubmit,
                          queryParameters: {'jobId': jobId},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Problem',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to home/job screen
                        context.goNamed(RoutePath.home);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Complete Job',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF323232),
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
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF2563EB), size: 24),
              SizedBox(width: 8),
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                'Not Started',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4BB485),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]),
            ],
          ),
        ],
      ),
    );
  }
}
