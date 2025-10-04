import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController with WidgetsBindingObserver {
  static ThemeController get instance => Get.find();

  final GetStorage _box = GetStorage();
  final RxBool isDark = false.obs;
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Load saved mode or default to system
    final savedMode = _box.read('themeMode');
    themeMode.value = _getThemeModeFromString(savedMode);
    Get.changeThemeMode(themeMode.value);

    // Initialize isDark based on current system or saved preference
    _updateIsDarkFromSystem();
  }

  @override
  void didChangePlatformBrightness() {
    // When system theme changes, update if we're following system mode
    if (themeMode.value == ThemeMode.system) {
      _updateIsDarkFromSystem();
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  void toggleTheme() {
    // Toggle between light/dark manually
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
    } else if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }

    _box.write('themeMode', themeMode.value.toString().split('.').last);
    isDark.value = themeMode.value == ThemeMode.dark;
    Get.changeThemeMode(themeMode.value);
  }

  void useSystemTheme() {
    themeMode.value = ThemeMode.system;
    _box.remove('themeMode');
    _updateIsDarkFromSystem();
    Get.changeThemeMode(ThemeMode.system);
  }

  void _updateIsDarkFromSystem() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    isDark.value = brightness == Brightness.dark;
  }

  ThemeMode _getThemeModeFromString(String? mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
