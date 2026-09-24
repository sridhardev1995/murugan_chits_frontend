import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/settings/settings_controller.dart';
import 'package:sri_murugan_chits/screens/master/diwali_entrollment/diwali_enrollment_binding.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<BottomNavigationBarItem> bottomItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shutter_speed_outlined),
      activeIcon: Icon(Icons.shutter_speed_outlined),
      label: 'EMI',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined),
      activeIcon: Icon(Icons.account_balance_wallet),
      label: 'Collections',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.card_giftcard_outlined),
      activeIcon: Icon(Icons.card_giftcard),
      label: 'Diwali',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: "Settings",
    ),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    Get.put(SettingsController());
    DiwaliEnrollmentBinding()
        .dependencies(); // 👈 sets up ApiService, repos & controller correctly
    debugPrint('DashboardController initialized');
  }

  @override
  void onClose() {
    debugPrint('DashboardController closed');
    super.onClose();
  }
}
