import 'package:get/get.dart';

class SettingsController extends GetxController {
  final List<Map<String, dynamic>> settingsMenus = [
    {
      "title": "Customer",
      "subtitle": "Manage customer details",
      "icon": "people",
      "route": "/customer",
    },
    {
      "title": "Diwali Scheme",
      "subtitle": "Manage Diwali schemes",
      "icon": "festival",
      "route": "/diwali-schemes",
    },
    {
      "title": "Enroller Diwali",
      "subtitle": "Manage Diwali enrollers",
      "icon": "person_add",
      "route": "/diwali-enrollments",
    },
    {
      "title": "Emi Scheme",
      "subtitle": "Manage EMI schemes",
      "icon": "person_add",
      "route": "/emi-schemes",
    },
    {
      "title": "Emi Enroll",
      "subtitle": "Manage EMI enrollments",
      "icon": "person_add",
      "route": "/emi-enrollments",
    },
    {
      "title": "Emi Enroll List",
      "subtitle": "View EMI enrollment list",
      "icon": "person_add",
      "route": "/emi-enrollments-list",
    },
    {
      "title": "Emi Report",
      "subtitle": "Report",
      "icon": "person_add",
      "route": "/emi-payment-report",
    },
  ];

  void onMenuTap(String route) {
    Get.toNamed(route);
  }
}