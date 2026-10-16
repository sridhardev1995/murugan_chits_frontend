
import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/report/profit/emi_profit_report_controller.dart';


import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/repositary/report/emi_profit_report_repository.dart';


class EmiProfitReportBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }

    Get.lazyPut<EmiProfitReportRepository>(
      () => EmiProfitReportRepository(),
    );

    Get.lazyPut<EmiProfitReportController>(
      () => EmiProfitReportController(),
    );
  }
}
