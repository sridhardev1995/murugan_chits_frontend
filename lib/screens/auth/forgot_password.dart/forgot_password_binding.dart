import 'package:get/get.dart';

import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/repositary/auth/auth_repositary.dart';

import 'forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = ApiService();

    final repository =
        AuthRepository(apiService);

    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(repository),
    );
  }
}