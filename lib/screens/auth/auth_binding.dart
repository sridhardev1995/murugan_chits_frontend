import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/auth/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
