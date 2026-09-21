import 'package:get/get.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/repositary/diwali_scheme/diwali_scheme_repo.dart';


import 'diwali_scheme_controller.dart';

class DiwaliSchemeBinding extends Bindings {
  @override
  void dependencies() {
    // Reuses the global ApiService if it's already registered (e.g. in main.dart);
    // falls back to creating one so this binding also works standalone.
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : Get.put(ApiService(), permanent: true);

    Get.lazyPut<DiwaliSchemeRepository>(() => DiwaliSchemeRepository(api));
    Get.lazyPut<DiwaliSchemeController>(
      () => DiwaliSchemeController(Get.find<DiwaliSchemeRepository>()),
    );
  }
}