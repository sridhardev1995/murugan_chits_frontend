import 'package:get/get.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/repositary/customer/customer_repositary.dart';
import 'package:sri_murugan_chits/services/repositary/diwali_enrollment/diwali_enrollment_repositary.dart';
import 'package:sri_murugan_chits/services/repositary/diwali_scheme/diwali_scheme_repo.dart';


import 'diwali_enrollment_controller.dart';

class DiwaliEnrollmentBinding extends Bindings {
  @override
  void dependencies() {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : Get.put(ApiService(), permanent: true);

    Get.lazyPut<DiwaliEnrollmentRepository>(() => DiwaliEnrollmentRepository(api));

    // Reuse Customer / Scheme repositories if already registered elsewhere,
    // otherwise create them here so the enrollment form's pickers work standalone.
    final customerRepo = Get.isRegistered<CustomerRepository>()
        ? Get.find<CustomerRepository>()
        : Get.put(CustomerRepository(api), permanent: true);

    final schemeRepo = Get.isRegistered<DiwaliSchemeRepository>()
        ? Get.find<DiwaliSchemeRepository>()
        : Get.put(DiwaliSchemeRepository(api), permanent: true);

    Get.lazyPut<DiwaliEnrollmentController>(
      () => DiwaliEnrollmentController(
        Get.find<DiwaliEnrollmentRepository>(),
        customerRepo,
        schemeRepo,
      ),
    );
  }
}