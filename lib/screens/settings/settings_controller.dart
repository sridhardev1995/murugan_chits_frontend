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
      "subtitle": "Manage Diwali enrollers",
      "icon": "person_add",
      "route": "/emi-schemes",
    },

      {
      "title": "Emi Entroll",
      "subtitle": "Manage Diwali enrollers",
      "icon": "person_add",
      "route": "/emi-enrollments",
    },
    {
      "title": "Emi Entroll List",
      "subtitle": "Manage Diwali enrollers",
      "icon": "person_add",
      "route": "/emi-enrollments-list",
    },
  ];

  void onMenuTap(String route) {
    Get.toNamed(route);
  }
}