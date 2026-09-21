import 'package:get/get.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/repositary/customer/customer_repositary.dart';
import 'customer_controller.dart';


class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // ApiService is likely shared across features — register once,
    // keep it alive (fenix: true) so it survives controller disposal.
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }

    Get.lazyPut<CustomerRepository>(
      () => CustomerRepository(Get.find<ApiService>()),
    );

    Get.lazyPut<CustomerController>(
      () => CustomerController(Get.find<CustomerRepository>()),
    );
  }
}