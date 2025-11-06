import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/active_lifts_controller.dart';

// Define a dark color palette
const Color primaryDark = Color(0xFF121212); // Deep background
const Color surfaceDark = Color(0xFF1E1E1E); // Card/List tile background
const Color accentColor = Color(0xFFFFFFFF); // Vibrant accent purple
const Color onPrimaryDark = Color(0xFFFFFFFF); // Primary text color
const Color onSurfaceDark = Color(0xFFB3B3B3); // Secondary text/subtitle color

class ActiveLifts extends StatelessWidget {
  const ActiveLifts({super.key});

  @override
  Widget build(BuildContext context) {
    print("opened lifts - Dark UI");
    // Ensure the controller instance is correct
    final controller = ActiveLiftsController.instance;

    // Apply a dark theme to the Scaffold
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primaryColor: accentColor,
        scaffoldBackgroundColor: primaryDark,
        appBarTheme: const AppBarTheme(
          color: surfaceDark, // AppBar surface slightly lighter
          foregroundColor: onPrimaryDark,
          iconTheme: IconThemeData(color: accentColor),
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: surfaceDark,
          textColor: onPrimaryDark,
          iconColor: accentColor,
          subtitleTextStyle: TextStyle(color: onSurfaceDark),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: accentColor, // The loading spinner color
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Active Lifts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.fetchUserLifts(fetchLatest: true),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.lifts.isEmpty) {
            return const Center(
              child: Text(
                'No active lifts.',
                style: TextStyle(color: onSurfaceDark),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.lifts.length,
            itemBuilder: (context, index) {
              final lift = controller.lifts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Card( // Use a Card for elevation/separation
                  color: surfaceDark,
                  elevation: 2, // Slight lift for the Card
                  child: ListTile(
                    leading: const Icon(Icons.directions_car, size: 30),
                    title: Text(
                      'Lift to ${lift.destinationName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Distance: ${lift.distanceKm} km'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2), // Light background for status
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        lift.status,
                        style: const TextStyle(
                          color: accentColor, // Accent color for status text
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}