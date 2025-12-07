import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../controllers/google_map_controller.dart';
import '../../nearbylifts/nearby_rides_screen.dart';

class PublishButton extends StatelessWidget {
  const PublishButton({
    super.key,
    required this.onTap,
    required this.source,
    required this.destination,
  });

  final LatLng source;
  final LatLng destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomMapController>();
    const petrolPricePerKm = 9.0;

    // Use the primary color from the theme for consistency
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Container(
        color: Colors.white, // Footer background
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Uniform padding
          child: Obx(() {
            final distance = controller.distance.value;
            final estimatedCost = (distance * petrolPricePerKm).toStringAsFixed(2);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Distance and Cost Metrics Row ---
                Row(
                  children: [
                    // DISTANCE (Primary Metric)
                    _TripMetricCard(
                      icon: Icons.route,
                      label: 'Distance',
                      value: '${distance.toStringAsFixed(2)} km',
                      color: primaryColor, // Use Primary Color
                    ),
                    const SizedBox(width: 12),

                    // ESTIMATED COST (Secondary Metric)
                    _TripMetricCard(
                      icon: Icons.currency_rupee,
                      label: 'Estimated Cost',
                      value: estimatedCost,
                      color: Colors.green, // Use Green for cost
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // --- 2. Action Button ---
                // The "Next" button logic is complex and should be prioritized.
                // If the list is ready, show a single, clear action button.
                SizedBox(
                  width: double.infinity,
                  height: 54, // Slightly taller button for better UX
                  child: ElevatedButton(
                    onPressed: controller.isListReady.value
                        ? () {
                      if (!controller.isRide.value) { // Assuming isRide is false for Get a Lift
                        Get.to(() => NearbyRidesScreen(source: source, destination: destination));
                      } else {
                        onTap(); // Use onTap for publishing a ride
                      }
                    }
                        : onTap, // Default action if list isn't ready
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0, // Flat design is modern
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      controller.isListReady.value
                          ? (controller.isRide.value ? "Publish Your Ride" : "View Available Lifts")
                          : "What are you planning to do?", // Loading/Default State
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// --- Custom Widget for Metric Display ---
class _TripMetricCard extends StatelessWidget {
  const _TripMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), // Light background tint
          borderRadius: BorderRadius.circular(10),
          // Use a subtle border instead of a shadow
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Label
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Value (The main number)
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}