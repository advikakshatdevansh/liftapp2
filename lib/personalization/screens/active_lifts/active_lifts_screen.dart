import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/active_lifts_controller.dart';

class ActiveLifts extends StatelessWidget {
  const ActiveLifts({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ActiveLiftsController.instance;

    controller.fetchUserLifts();

    return Scaffold(
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
          return const Center(child: Text('No active lifts.'));
        }

        return ListView.builder(
          itemCount: controller.lifts.length,
          itemBuilder: (context, index) {
            final lift = controller.lifts[index];
            return ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text('Lift to ${lift.destination}'),
              subtitle: Text('Distance: ${lift.distanceKm} km'),
              trailing: Text(lift.status),
            );
          },
        );
      }),
    );
  }
}
