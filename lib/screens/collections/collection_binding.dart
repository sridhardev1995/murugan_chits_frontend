import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/collections/collection_controller.dart';

class CollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CollectionController>(
      () => CollectionController(),
      fenix: true,
    );
  }
}