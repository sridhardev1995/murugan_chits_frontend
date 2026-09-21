import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/master/emi_scheme/emi_scheme_controller.dart';



class EmiSchemeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmiSchemeController>(
      () => EmiSchemeController(),
      fenix: true,
    );
  }
}