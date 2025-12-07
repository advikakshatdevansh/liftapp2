import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account Settings",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _SettingsMenuItem(
              title: "Profile Management",
              icon: LineAwesomeIcons.user_circle,
              onTap: () => Get.toNamed(TRoutes.profileScreen),
            ),

            _SettingsMenuItem(
              title: "Notifications",
              icon: LineAwesomeIcons.bell,
              onTap: () => Get.toNamed(TRoutes.notification),
            ),

            _SettingsToggleItem(
              title: "Dark Mode",
              icon: LineAwesomeIcons.moon,
              value: Get.isDarkMode,
              onChanged: (value) => Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),

            const Divider(height: 32),

            Text(
              "App Information & Support",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _SettingsMenuItem(
              title: "Privacy Policy",
              icon: LineAwesomeIcons.lock_solid,
              onTap: () => Get.toNamed(TRoutes.privacyPolicyScreen),
            ),

            _SettingsMenuItem(
              title: "Help & Support",
              icon: LineAwesomeIcons.question_circle,
              onTap: () => Get.toNamed(TRoutes.helpandsupportScreen),
            ),

            _SettingsMenuItem(
              title: "Rate Us",
              icon: LineAwesomeIcons.star,
              onTap: () => Get.toNamed(TRoutes.rateUsScreen),
            ),

            const Divider(height: 32),

            _SettingsMenuItem(
              title: "Delete Account",
              icon: LineAwesomeIcons.trash_solid,
              color: Colors.red,
              onTap: () => Get.defaultDialog(title: "Delete Account", middleText: "Are you sure?"),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  const _SettingsMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;
    // Determine the solid background color for the icon container
    final containerColor = color ?? Theme.of(context).primaryColor;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          // --- CHANGE 1: Use solid container color for contrast ---
          // Removed .withOpacity(0.1)
          color: containerColor,
        ),
        // --- CHANGE 2: Set icon color to white ---
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: TextStyle(color: effectiveColor)),
      trailing: color == null ? const Icon(LineAwesomeIcons.angle_right_solid, size: 18) : null,
      onTap: onTap,
    );
  }
}

// The _SettingsToggleItem remains correct from the previous step.

class _SettingsToggleItem extends StatelessWidget {
  const _SettingsToggleItem({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          // This is correctly set to solid color
          color: Theme.of(context).primaryColor,
        ),
        // This is correctly set to white
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
      onTap: () => onChanged(!value),
    );
  }
}