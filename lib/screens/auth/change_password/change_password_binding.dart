import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/auth/change_password/change_password_controller.dart';

import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/repositary/auth/auth_repositary.dart';


class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(
      () => ApiService(),
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        Get.find<ApiService>(),
      ),
    );

    Get.lazyPut<ChangePasswordController>(
      () => ChangePasswordController(
        Get.find<AuthRepository>(),
      ),
    );
  }
}