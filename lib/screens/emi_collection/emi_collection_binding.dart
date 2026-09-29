import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/emi_collection/emi_collection_controller.dart';

class EmiCollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmiCollectionController>(
      () => EmiCollectionController(),
      fenix: true,
    );
  }
}
