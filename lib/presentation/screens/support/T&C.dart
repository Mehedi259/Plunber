import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

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
          'Terms & Condition',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Effective Date: [Insert Date]',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'By using this app, you agree to the following terms:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Authorized Use',
              'This app is for approved employees and contractors only. Login credentials must not be shared.',
            ),
            _buildSection(
              '2. Accurate Reporting',
              'All job updates, inspections, and safety checks must be completed honestly and accurately. False reporting may result in disciplinary action.',
            ),
            _buildSection(
              '3. Account Responsibility',
              'You are responsible for maintaining the security of your account and reporting unauthorized access.',
            ),
            _buildSection(
              '4. Monitoring & Tracking',
              'The app may collect GPS location, timestamps, and activity logs for working hours for operational and safety purposes.',
            ),
            _buildSection(
              '5. Acceptable Use',
              'Users must not misuse the app, upload inappropriate content, attempt system interference, or use it for personal purposes.',
            ),
            _buildSection(
              '6. Data Ownership',
              'All job reports, inspection data, and uploaded content remain the property of the company.',
            ),
            _buildSection(
              '7. Termination',
              'Access may be suspended or revoked if these terms are violated or employment ends.',
            ),
            _buildSection(
              '8. Updates',
              'We may update these terms at any time. Continued use means you accept the changes.',
            ),
            const SizedBox(height: 24),

            const Text(
              'For questions, contact:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _buildContactButton(
              icon: Icons.email,
              label: '[Support Email]',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildContactButton(
              icon: Icons.phone,
              label: '[Phone Number]',
              onTap: () {},
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2563EB)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
