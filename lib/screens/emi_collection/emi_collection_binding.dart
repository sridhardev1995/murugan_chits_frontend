
import 'package:get/get.dart';

import 'package:sri_murugan_chits/screens/emi_collection/emi_collection_controller.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';

class EmiCollectionBinding extends Bindings {
  @override
  void dependencies() {
    // EMI Enrollment Controller
    Get.lazyPut<EmiEnrollmentController>(
      () => EmiEnrollmentController(),
      fenix: true,
    );

    // EMI Collection Controller
    Get.lazyPut<EmiCollectionController>(
      () => EmiCollectionController(),
      fenix: true,
    );
  }
}
