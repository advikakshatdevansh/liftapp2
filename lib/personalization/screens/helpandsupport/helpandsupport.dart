import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart'; // Assuming GetX for navigation/context

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  // --- Configuration ---
  // Replace these placeholders with your actual URLs and email
  static const String faqUrl = 'https://www.yourwebsite.com/faq';
  static const String supportEmail = 'support@yourappname.com';
  static const String termsUrl = 'https://www.yourwebsite.com/terms';

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open link.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {'subject': 'Support Request from App User'},
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Get.snackbar('Error', 'Could not launch email app.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- FAQs Section ---
            ListTile(
              leading: const Icon(Icons.forum_outlined, color: Colors.blue),
              title: const Text('Frequently Asked Questions (FAQ)'),
              subtitle: const Text('Find answers to common questions instantly.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _launchUrl(faqUrl), // Opens external FAQ link
            ),
            const Divider(),

            // --- Contact Support Section ---
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Colors.green),
              title: const Text('Contact Support'),
              subtitle: Text('Email us at $supportEmail'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _launchEmail, // Opens device's email client
            ),
            const Divider(),

            // --- App Information Section ---
            ListTile(
              leading: const Icon(Icons.policy_outlined, color: Colors.grey),
              title: const Text('Terms of Service'),
              onTap: () => _launchUrl(termsUrl), // Opens external Terms link
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('App Version'),
              // You might fetch this version dynamically in a real app
              subtitle: const Text('Version 1.0.0 (Build 42)'),
            ),
          ],
        ),
      ),
    );
  }
}