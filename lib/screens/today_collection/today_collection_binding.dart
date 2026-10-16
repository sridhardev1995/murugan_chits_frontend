import 'package:get/get.dart';

import 'package:sri_murugan_chits/services/api/api_servies.dart';

import 'package:sri_murugan_chits/services/repositary/today_collection/today_collection_repository.dart';

import 'today_collection_controller.dart';

class TodayCollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(
      () => ApiService(),
    );

    Get.lazyPut<TodayCollectionRepository>(
      () => TodayCollectionRepository(
        Get.find<ApiService>(),
      ),
    );

    Get.lazyPut<TodayCollectionController>(
      () => TodayCollectionController(
        Get.find<TodayCollectionRepository>(),
      ),
    );
  }
}