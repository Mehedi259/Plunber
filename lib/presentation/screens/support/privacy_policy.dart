import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Privacy Policy',
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
              'Plumber App Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: February 17, 2026',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Introduction',
              'This Privacy Policy explains how Plumber App ("we", "us", or "our") collects, uses, and protects your personal information when you use our mobile application.',
            ),
            _buildSection(
              '2. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n• Personal identification information (name, email, phone number)\n• Job-related data and work history\n• Vehicle inspection records\n• Location data for job assignments\n• Photos and documents you upload',
            ),
            _buildSection(
              '3. How We Use Your Information',
              'We use the information we collect to:\n\n• Provide and maintain our services\n• Assign and manage jobs\n• Track vehicle inspections\n• Communicate with you about jobs and updates\n• Improve our application and services',
            ),
            _buildSection(
              '4. Information Sharing',
              'We do not sell your personal information. We may share your information with:\n\n• Your employer or contracting company\n• Service providers who assist in our operations\n• Law enforcement when required by law',
            ),
            _buildSection(
              '5. Data Security',
              'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, or destruction.',
            ),
            _buildSection(
              '6. Your Rights',
              'You have the right to:\n\n• Access your personal data\n• Request correction of inaccurate data\n• Request deletion of your data\n• Opt-out of certain data collection',
            ),
            _buildSection(
              '7. Location Data',
              'We collect location data to:\n\n• Assign jobs based on your location\n• Track job completion\n• Provide navigation assistance\n\nYou can disable location services in your device settings.',
            ),
            _buildSection(
              '8. Data Retention',
              'We retain your personal information for as long as necessary to provide our services and comply with legal obligations.',
            ),
            _buildSection(
              '9. Children\'s Privacy',
              'Our service is not intended for users under 18 years of age. We do not knowingly collect information from children.',
            ),
            _buildSection(
              '10. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            _buildSection(
              '11. Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@plumberapp.com\nPhone: +1 (555) 123-4567',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
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
}
