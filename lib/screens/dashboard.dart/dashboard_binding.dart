import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/dashboard.dart/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
      fenix: true,
    );
  }
}