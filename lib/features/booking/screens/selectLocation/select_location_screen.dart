import 'package:flutter/material.dart';
import 'package:liftapp2/features/booking/screens/selectLocation/widgets/quick_links_widget.dart';
import '../../../../../common/widgets/drawer/drawer.dart';
import 'widgets/location_form_widget.dart';
import 'widgets/appbar.dart';
import 'package:flutter/material.dart';
// Note: Adjusted imports for a single file structure.
// In your project, keep your original import structure.
import 'widgets/location_form_widget.dart';
import 'widgets/appbar.dart';

class SelectLocation extends StatelessWidget {
  const SelectLocation({super.key});

  // Helper widget to build the Quick Select Chips
  Widget _buildQuickSelectChip(BuildContext context, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      label: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onPressed: () {
        // --- Add your navigation or form pre-fill logic here ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $label')),
        );
      },
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Variables
    final txtTheme = Theme.of(context).textTheme;
    const double padding = 16.0;

    return SafeArea(
      child: Scaffold(
        appBar: const DashboardAppBar(),
        drawer: const TDrawer(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title/Instruction Header
              Padding(
                padding: const EdgeInsets.fromLTRB(padding, padding, padding, 8.0),
                child: Text(
                  '📍 Where are you headed?',
                  style: txtTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),


              // 2. Location Input Form (Original Widget)
              const LocationFormWidget(),
              const QuickSelectWidget(),
            ],
          ),
        ),
      ),
    );
  }
}