import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';

class EmiEnrollmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmiEnrollmentController>(
      () => EmiEnrollmentController(),
      fenix: true,
    );
  }
}