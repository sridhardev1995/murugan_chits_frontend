import 'package:get/get.dart';

import 'emi_payment_report_controller.dart';

class EmiPaymentReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmiPaymentReportController>(
      () => EmiPaymentReportController(),
      fenix: true,
    );
  }
}