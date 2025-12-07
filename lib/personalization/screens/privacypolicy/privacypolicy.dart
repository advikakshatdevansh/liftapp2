import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // --- 1. Define the Policy Content Directly in Dart ---
  final String _localPolicyContent = '''
Lift Share Mobile Application Privacy Policy

Effective Date: December 7, 2025

1. Introduction
Lift Share ("we," "us," or "our") operates the Lift Share mobile application. This Privacy Policy informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.

2. Information Collection and Use

We collect several different types of information for various purposes to provide and improve our Service to you.

A. Personal Data
While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). Personally identifiable information may include, but is not limited to:
* Email address
* First and last name
* Usage Data

B. Usage Data
We may also collect information about how the Service is accessed and used ("Usage Data"). This Usage Data may include information such as your device's Internet Protocol address (e.g., IP address), browser type, browser version, the pages of our Service that you visit, the time and date of your visit, the time spent on those pages, unique device identifiers, and other diagnostic data.

3. Use of Data
Lift Share uses the collected data for various purposes:
* To provide and maintain the Service
* To notify you about changes to our Service
* To allow you to participate in interactive features of our Service when you choose to do so
* To provide customer support

4. Security of Data
The security of your data is important to us, but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.

5. Changes to This Privacy Policy
We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Effective Date" at the top of this Privacy Policy.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localPolicyContent,
              // Apply basic styling for readability
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            // Optional: Add a button to close the screen or navigate away
          ],
        ),
      ),
    );
  }
}