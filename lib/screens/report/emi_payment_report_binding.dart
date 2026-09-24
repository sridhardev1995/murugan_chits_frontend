import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/report/emi_payment_report_controller.dart';

import 'package:sri_murugan_chits/services/api/api_servies.dart';

import 'package:sri_murugan_chits/services/repositary/customer/customer_repositary.dart';
import 'package:sri_murugan_chits/services/repositary/emi_scheme/emi_scheme_repository.dart';
import 'package:sri_murugan_chits/services/repositary/report/emi_payment_report_repository.dart';



class EmiPaymentReportBinding extends Bindings {
  @override
  void dependencies() {
    // ==========================================================
    // API SERVICE
    // ==========================================================

    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(
        () => ApiService(),
        fenix: true,
      );
    }

    // ==========================================================
    // CUSTOMER REPOSITORY
    // ==========================================================

    if (!Get.isRegistered<CustomerRepository>()) {
      Get.lazyPut<CustomerRepository>(
        () => CustomerRepository(
          Get.find<ApiService>(),
        ),
      );
    }

    // ==========================================================
    // EMI SCHEME REPOSITORY
    // ==========================================================

    if (!Get.isRegistered<EmiSchemeRepository>()) {
      Get.lazyPut<EmiSchemeRepository>(
        () => EmiSchemeRepository(),
      );
    }

    // ==========================================================
    // PAYMENT REPORT REPOSITORY
    // ==========================================================

    Get.lazyPut<EmiPaymentReportRepository>(
      () => EmiPaymentReportRepository(),
    );

    // ==========================================================
    // PAYMENT REPORT CONTROLLER
    // ==========================================================

    Get.lazyPut<EmiPaymentReportController>(
      () => EmiPaymentReportController(
        Get.find<EmiPaymentReportRepository>(),
        Get.find<CustomerRepository>(),
        Get.find<EmiSchemeRepository>(),
      ),
    );
  }
}