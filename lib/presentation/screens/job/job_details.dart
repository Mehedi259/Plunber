import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routes/route_path.dart';
import '../../../global/service/job/job_service.dart';
import '../../../global/models/job_detail_model.dart';
import '../../widgets/animated_section.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final JobService _jobService = JobService();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<JobDetailModel?> jobDetail = Rx<JobDetailModel?>(null);

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }

  Future<void> _fetchJobDetails() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _jobService.getJobDetails(widget.jobId);

      if (response.success && response.data != null) {
        jobDetail.value = response.data;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2563EB),
            ),
          );
        }

        if (errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchJobDetails,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final job = jobDetail.value;
        if (job == null) {
          return const Center(
            child: Text('No job data available'),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchJobDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Header
                  AnimatedSection(
                    index: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobId,
                          style: const TextStyle(
                            color: Color(0xFF1E40AF),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.jobName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF323232),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Safety Check Banner (if needed)
                  if (job.status.toLowerCase() == 'pending' && job.safetyFormIds.isNotEmpty)
                    AnimatedSection(
                      index: 1,
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            RoutePath.safetyCheck,
                            queryParameters: {
                              'jobId': job.id,
                              'address': job.client.address,
                              'templateId': job.safetyFormIds.first,
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.info_outline, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Safety Check Required',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (job.status.toLowerCase() == 'pending' && job.safetyFormIds.isNotEmpty) const SizedBox(height: 24),

                  // Job Info Section
                  AnimatedSection(
                    index: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            job.client.address,
                            const Color(0xFF2563EB),
                            onTap: job.client.mapsUrl != null
                                ? () => _launchUrl(job.client.mapsUrl!)
                                : null,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.access_time,
                            'Scheduled Time',
                            job.getFormattedTime(),
                            const Color(0xFF2563EB),
                          ),
                          if (job.vehicle != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.local_shipping_outlined,
                              'Vehicle: ${job.vehicle!.name}',
                              'Vehicle no: ${job.vehicle!.plate}',
                              const Color(0xFF2563EB),
                            ),
                          ],
                          const Divider(height: 24),
                          _buildStatusRow(job.status),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Job Details Description
                  AnimatedSection(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            job.jobDetails,
                            style: const TextStyle(
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
                  AnimatedSection(
                    index: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        // Client Contact
                        _buildContactCard(
                          name: job.client.name,
                          role: 'client',
                          email: job.client.email,
                          phone: job.client.phone,
                          profilePicture: job.client.profilePicture,
                        ),
                        if (job.assignedTo != null) ...[
                          const SizedBox(height: 12),
                          // Employee Contact
                          _buildContactCard(
                            name: job.assignedTo!.fullName,
                            role: 'employee',
                            email: job.assignedTo!.email,
                            phone: job.assignedTo!.phone,
                            profilePicture: job.assignedTo!.profilePicture,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Attachments
                  if (job.attachments.isNotEmpty)
                    AnimatedSection(
                      index: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          ...job.attachments.map((attachment) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildAttachmentCard(attachment),
                              )),
                        ],
                      ),
                    ),

                  if (job.attachments.isNotEmpty) const SizedBox(height: 24),

                  // Action Buttons
                  AnimatedSection(
                    index: 6,
                    child: Column(
                      children: [
                        // Start Job Button
                        if (job.status.toLowerCase() != 'completed')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pushNamed(
                                  RoutePath.startJob,
                                  queryParameters: {
                                    'jobId': job.id,
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Start Job',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Reports & Notes button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushNamed(
                                RoutePath.reportsList,
                                extra: {
                                  'jobId': job.id,
                                  'reports': job.reports,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Reports & Notes',
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
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
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
            color: Colors.black.withValues(alpha: 0.08),
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

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
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
        if (onTap != null)
          const Icon(Icons.open_in_new, size: 16, color: Color(0xFF6B7280)),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }

  Widget _buildStatusRow(String status) {
    String statusText;
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'pending':
        statusText = 'pending';
        statusColor = const Color(0xFFEAB308);
        break;
      case 'in_progress':
        statusText = 'in progress';
        statusColor = const Color(0xFF2563EB);
        break;
      case 'completed':
        statusText = 'completed';
        statusColor = const Color(0xFF10B981);
        break;
      default:
        statusText = status;
        statusColor = const Color(0xFF6B7280);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF2563EB), size: 24),
            SizedBox(width: 12),
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
            Text(
              statusText,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required String name,
    required String role,
    required String email,
    required String phone,
    String? profilePicture,
  }) {
    return Container(
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
            color: Colors.black.withValues(alpha: 0.08),
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
              color: Color(0xFFE5E7EB),
            ),
            child: ClipOval(
              child: profilePicture != null
                  ? Image.network(
                      profilePicture,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 32, color: Color(0xFF6B7280));
                      },
                    )
                  : const Icon(Icons.person, size: 32, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF323232),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Color(0xCC323232),
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _sendEmail(email),
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: Color(0xFF105DBE)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF105DBE),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _makePhoneCall(phone),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Color(0xFF105DBE)),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF105DBE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () => _sendEmail(email),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.email, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _makePhoneCall(phone),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(AttachmentInfo attachment) {
    return Container(
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
            color: Colors.black.withValues(alpha: 0.08),
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
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.insert_drive_file, size: 36, color: Color(0xFF6B7280));
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF323232),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  attachment.getFormattedDate(),
                  style: const TextStyle(
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
            onPressed: () => _launchUrl(attachment.file),
            icon: const Icon(
              Icons.download,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
