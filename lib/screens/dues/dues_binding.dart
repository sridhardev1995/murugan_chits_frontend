import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/dues/dues_controller.dart';

class DuesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DuesController>(
      () => DuesController(),
      fenix: true,
    );
  }
}