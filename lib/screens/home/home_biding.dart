import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/home/home_controller.dart';

class HomeBiding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,
    );
  }
}