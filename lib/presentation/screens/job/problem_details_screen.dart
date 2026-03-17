import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProblemDetailsScreen extends StatefulWidget {
  final String jobId;
  final String jobReportId;
  final String reportType;
  final String reportTypeDisplay;

  const ProblemDetailsScreen({
    super.key,
    required this.jobId,
    required this.jobReportId,
    required this.reportType,
    required this.reportTypeDisplay,
  });

  @override
  State<ProblemDetailsScreen> createState() => _ProblemDetailsScreenState();
}

class _ProblemDetailsScreenState extends State<ProblemDetailsScreen> {
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _jobOrderController = TextEditingController();
  final TextEditingController _siteAddressController = TextEditingController();
  final TextEditingController _reportPurposeController = TextEditingController();
  final TextEditingController _propertyConditionController = TextEditingController();
  final TextEditingController _conclusionController = TextEditingController();

  String _selectedCondition = 'Good';
  final List<String> _selectedPreviousIssues = [];

  @override
  void dispose() {
    _dateTimeController.dispose();
    _jobOrderController.dispose();
    _siteAddressController.dispose();
    _reportPurposeController.dispose();
    _propertyConditionController.dispose();
    _conclusionController.dispose();
    super.dispose();
  }

  void _addPhoto() {
    // Implement image picker functionality
  }

  void _saveReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.reportTypeDisplay,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF323232),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Date / Time', _dateTimeController, 'Jan 24, 2025'),
              const SizedBox(height: 16),
              _buildTextField('Job / Order No.', _jobOrderController, ''),
              const SizedBox(height: 16),
              _buildTextField('Site Address', _siteAddressController, ''),
              const SizedBox(height: 16),
              _buildTextField('Report Purpose', _reportPurposeController, ''),
              const SizedBox(height: 16),
              _buildTextField('Property Condition', _propertyConditionController, ''),
              const SizedBox(height: 16),

              // Area of Inspection
              const Text(
                'Area of Inspection',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdownField('Choose Space', ['Kitchen', 'Bathroom', 'Basement']),
              const SizedBox(height: 16),

              // Condition of Pipe
              const Text(
                'Condition of Pipe',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildConditionChip('Fair'),
                  const SizedBox(width: 8),
                  _buildConditionChip('Average'),
                  const SizedBox(width: 8),
                  _buildConditionChip('Good'),
                  const SizedBox(width: 8),
                  _buildConditionChip('Satisfactory'),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField('Conclusion', _conclusionController, ''),
              const SizedBox(height: 16),

              // Pictures
              const Text(
                'Pictures',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                label: const Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2563EB),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Previous Issues
              const Text(
                'Previous Issues',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 8),
              _buildPreviousIssueItem('Jan 15', 'Jane Connor', 'Leak detected'),
              _buildPreviousIssueItem('Jan 20', 'Sara Smith', 'Leak detected'),
              _buildPreviousIssueItem('Jan 8', 'Usama Irshd', 'Leak detected'),
              _buildPreviousIssueItem('Jan 15', 'Bergin Smith', 'Leak detected'),
              _buildPreviousIssueItem('Jan 16', 'Sam Auditor', 'Leak detected'),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Color(0xFF323232),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String hint, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
            ),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {},
        ),
      ),
    );
  }

  Widget _buildConditionChip(String label) {
    final isSelected = _selectedCondition == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCondition = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF323232),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousIssueItem(String date, String name, String issue) {
    final isSelected = _selectedPreviousIssues.contains('$date-$name');
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPreviousIssues.remove('$date-$name');
          } else {
            _selectedPreviousIssues.add('$date-$name');
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF323232),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF323232),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      issue,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
