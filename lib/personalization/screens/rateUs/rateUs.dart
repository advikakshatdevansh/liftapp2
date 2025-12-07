import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';

class RateUsScreen extends StatelessWidget {
  const RateUsScreen({super.key});

  // --- Configuration ---
  // Replace these with your actual App Store and Play Store IDs/URLs
  static const String androidAppId = 'com.example.yourappname';
  static const String iOSAppId = '1234567890'; // Use your 10-digit Apple ID

  // Get a direct link to the store page based on platform
  String get _storeUrl {
    if (GetPlatform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=$androidAppId';
    } else if (GetPlatform.isIOS) {
      return 'https://apps.apple.com/app/id$iOSAppId';
    }
    return ''; // Default fallback
  }

  // 1. Attempts to use the native in-app rating dialog
  Future<void> _requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      // Show the native, non-intrusive rating dialog
      inAppReview.requestReview();
    } else {
      // Fallback: If native dialog is not available (e.g., on web or device limitations),
      // launch the store page manually.
      _launchStorePage();
    }
  }

  // 2. Launches the app store page externally
  Future<void> _launchStorePage() async {
    final Uri url = Uri.parse(_storeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open app store link.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Our App'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rate_rounded,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              Text(
                'Enjoying Your App Name?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your honest review helps us grow and improve the app for everyone!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Primary Action Button (In-App Review) ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _requestReview,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Tap to Rate Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Secondary Action Button (External Store Link) ---
              TextButton(
                onPressed: _launchStorePage,
                child: const Text('Or Leave a Review on the App Store/Play Store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}