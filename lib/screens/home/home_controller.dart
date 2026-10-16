import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/dashboard/dashboard_model.dart';
import 'package:sri_murugan_chits/services/repositary/dashboard/dashboard_repository.dart';
import 'package:sri_murugan_chits/services/api/storage_service.dart';

class HomeController extends GetxController {
  final HomeRepository repository = HomeRepository();

  // ============================================================
  // STATE
  // ============================================================

  final Rxn<DashboardModel> dashboard =
      Rxn<DashboardModel>();

  final RxBool isLoading =
      false.obs;

  final RxString errorMessage =
      ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _initializeDashboard();
  }

  // ============================================================
  // INITIALIZE DASHBOARD
  // ============================================================

  Future<void> _initializeDashboard() async {
    try {
      final token = await StorageService.getToken();

      debugPrint(
        '🔐 [Dashboard] Token exists: '
        '${token != null && token.isNotEmpty}',
      );

      // ========================================================
      // NO TOKEN
      // ========================================================

      if (token == null || token.isEmpty) {
        debugPrint(
          '🟡 [Dashboard] No token. Dashboard API skipped.',
        );

        return;
      }

      // ========================================================
      // TOKEN EXISTS
      // ========================================================

      await fetchDashboard();
    } catch (e) {
      debugPrint(
        '🔴 [Dashboard] Initialization error: $e',
      );
    }
  }

  // ============================================================
  // FETCH DASHBOARD
  // ============================================================

  Future<void> fetchDashboard({
    bool showLoader = true,
  }) async {
    try {
      // ========================================================
      // TOKEN CHECK BEFORE API
      // ========================================================

      final token = await StorageService.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          '🟡 [Dashboard] Token missing. API call skipped.',
        );

        return;
      }

      // ========================================================
      // LOADER
      // ========================================================

      if (showLoader) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      debugPrint(
        '🔵 [Dashboard] Fetch started',
      );

      // ========================================================
      // API
      // ========================================================

      final result =
          await repository.getDashboardSummary();

      dashboard.value = result;

      debugPrint(
        '🟢 [Dashboard] Fetch success',
      );
    } catch (e) {
      debugPrint(
        '🔴 [Dashboard] Fetch error: $e',
      );

      errorMessage.value =
          e.toString().replaceFirst(
                'Exception: ',
                '',
              );

      // ========================================================
      // SHOW ERROR ONLY IF WE ACTUALLY HAVE A TOKEN
      // ========================================================

      if (errorMessage.value.isNotEmpty) {
        Get.snackbar(
          'Dashboard',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshDashboard() async {
    await fetchDashboard(
      showLoader: false,
    );
  }

  // ============================================================
  // GETTERS
  // ============================================================

  DashboardModel? get data =>
      dashboard.value;

  int get totalCustomers =>
      data?.customers.total ?? 0;

  int get totalDiwaliChits =>
      data?.diwali.totalChits ?? 0;

  double get diwaliTotalAmount =>
      data?.diwali.totalAmount ?? 0;

  double get diwaliReceivedAmount =>
      data?.diwali.receivedAmount ?? 0;

  double get diwaliPendingAmount =>
      data?.diwali.pendingAmount ?? 0;

  double get emiTotalAmount =>
      data?.emi.totalAmount ?? 0;

  double get emiCollectedAmount =>
      data?.emi.collectedAmount ?? 0;

  double get emiPendingCollection =>
      data?.emi.pendingCollection ?? 0;

  double get todayDiwaliCollection =>
      data?.today.diwaliCollection ?? 0;

  double get todayEmiCollection =>
      data?.today.emiCollection ?? 0;

  double get todayTotalCollection =>
      data?.today.totalCollection ?? 0;

  double get todayDue =>
      data?.due.todayDue ?? 0;

  double get overdueAmount =>
      data?.due.overdueAmount ?? 0;

  int get pendingCustomers =>
      data?.due.pendingCustomers ?? 0;
}