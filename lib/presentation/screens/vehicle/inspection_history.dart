import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../global/service/vehicle/vehicle_service.dart';

class InspectionHistoryScreen extends StatefulWidget {
  final String vehicleId;
  final String vehicleName;
  final String vehiclePlate;

  const InspectionHistoryScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehiclePlate,
  });

  @override
  State<InspectionHistoryScreen> createState() => _InspectionHistoryScreenState();
}

class _InspectionHistoryScreenState extends State<InspectionHistoryScreen> {
  final VehicleService _vehicleService = VehicleService();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<InspectionHistoryData> inspections = <InspectionHistoryData>[].obs;

  @override
  void initState() {
    super.initState();
    _fetchInspectionHistory();
  }

  Future<void> _fetchInspectionHistory() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _vehicleService.getInspectionHistory(widget.vehicleId);

      if (response.success) {
        inspections.value = response.inspections;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
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
        title: const Text(
          'Inspection History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
                  onPressed: _fetchInspectionHistory,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (inspections.isEmpty) {
          return const Center(
            child: Text(
              'No inspection history available',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchInspectionHistory,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final inspection = inspections[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHistoryItem(
                  context,
                  inspection,
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    InspectionHistoryData inspection,
  ) {
    return InkWell(
      onTap: () {
        _showInspectionDetails(context, inspection);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Text(
                inspection.getFormattedDate(),
                style: const TextStyle(
                  color: Color(0xFF323232),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Status with Icon
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: inspection.isComplete() ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      inspection.getStatusText(),
                      style: TextStyle(
                        color: inspection.isComplete() ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInspectionDetails(
    BuildContext context,
    InspectionHistoryData inspection,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inspection - ${inspection.getFormattedDate()}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: inspection.isComplete() 
                                ? const Color(0xFFD1FAE5) 
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: inspection.isComplete() 
                                      ? const Color(0xFF10B981) 
                                      : const Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                inspection.getStatusText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: inspection.isComplete() 
                                      ? const Color(0xFF10B981) 
                                      : const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Details
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Vehicle Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Vehicle', inspection.vehicleName),
                          const SizedBox(height: 12),
                          _buildDetailRow('Number Plate', inspection.vehiclePlate),
                          const SizedBox(height: 12),
                          _buildDetailRow('Inspector', inspection.inspectedByName),
                          const SizedBox(height: 12),
                          _buildDetailRow('Time', inspection.getFormattedDateTime()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Inspection Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Completed Items', '${inspection.completedItemsCount}'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Issues Reported', '${inspection.issueCount}'),
                          if (inspection.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow('Notes', inspection.notes),
                          ],
                        ],
                      ),
                    ),
                    if (!inspection.isComplete()) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Issues Reported',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFECACA),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${inspection.issueCount} issue(s) found during inspection',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF991B1B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color(0xFF323232),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
