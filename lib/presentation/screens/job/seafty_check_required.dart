import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_path.dart';

class SafetyCheckRequiredScreen extends StatefulWidget {
  final String jobId;
  final String address;

  const SafetyCheckRequiredScreen({
    Key? key,
    required this.jobId,
    required this.address,
  }) : super(key: key);

  @override
  State<SafetyCheckRequiredScreen> createState() => _SafetyCheckRequiredScreenState();
}

class _SafetyCheckRequiredScreenState extends State<SafetyCheckRequiredScreen> {
  final List<String> _checklistItems = [
    'PPE Worn ( Gloves, Goggles )',
    'Water supply isolated',
    'Electrical hazards checked',
    'Work area secured',
    'Tools inspected',
  ];

  final Map<int, bool> _checkedItems = {};
  bool _confirmationChecked = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _checklistItems.length; i++) {
      _checkedItems[i] = false;
    }
  }

  bool get _allItemsChecked {
    return _checkedItems.values.every((checked) => checked) && _confirmationChecked;
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safety Checklist',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF323232),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Job #${widget.jobId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '•',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF323232),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.address,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF323232),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Safety checks must be completed before starting the job',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _checklistItems.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    value: _checkedItems[index],
                    onChanged: (value) {
                      setState(() {
                        _checkedItems[index] = value ?? false;
                      });
                    },
                    title: Text(
                      _checklistItems[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF323232),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF2563EB),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _confirmationChecked,
              onChanged: (value) {
                setState(() {
                  _confirmationChecked = value ?? false;
                });
              },
              title: const Text(
                'I confirm all safety measures have been completed.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _allItemsChecked
                    ? () {
                        context.pushNamed(
                          RoutePath.jobDetails,
                          queryParameters: {'jobId': widget.jobId},
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Safety Check',
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
    );
  }
}
