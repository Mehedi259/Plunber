import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../global/models/job_detail_model.dart';
import '../../../core/routes/route_path.dart';

class ReportsListScreen extends StatelessWidget {
  final String jobId;
  final List<ReportInfo> reports;

  const ReportsListScreen({
    super.key,
    required this.jobId,
    required this.reports,
  });

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
        title: const Text(
          'Reports & Notes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(context, report);
        },
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportInfo report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RoutePath.reportForm,
            queryParameters: {
              'jobReportId': report.jobReportId,
              'reportType': report.reportType,
              'reportTypeDisplay': report.reportTypeDisplay,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: report.isSubmitted
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFDEEBFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  report.isSubmitted ? Icons.check_circle : Icons.description,
                  color: report.isSubmitted
                      ? const Color(0xFF10B981)
                      : const Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.reportTypeDisplay,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF323232),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.isSubmitted
                          ? 'Submitted'
                          : 'Not submitted',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: report.isSubmitted
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
