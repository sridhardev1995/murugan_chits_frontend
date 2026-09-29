import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_installment_model.dart';
import 'package:sri_murugan_chits/services/repositary/emi_collections/emi_collection_repository.dart';



class EmiCollectionController extends GetxController {
  final EmiCollectionRepository _repository =
      EmiCollectionRepository();

  // ============================================================
  // LISTS
  // ============================================================

  final RxList<EmiInstallmentModel> todayDueList =
      <EmiInstallmentModel>[].obs;

  final RxList<EmiInstallmentModel> overdueList =
      <EmiInstallmentModel>[].obs;

  // ============================================================
  // STATE
  // ============================================================

  final RxBool isLoading = false.obs;

  final RxBool isTodayDueLoading = false.obs;

  final RxBool isOverdueLoading = false.obs;

  final RxInt selectedTab = 0.obs;

  final RxString errorMessage = ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadCollections();
  }

  // ============================================================
  // LOAD BOTH
  // ============================================================

  Future<void> loadCollections() async {
    errorMessage.value = '';

    await Future.wait([
      fetchTodayDue(),
      fetchOverdue(),
    ]);
  }

  // ============================================================
  // TODAY DUE
  // ============================================================

  Future<void> fetchTodayDue() async {
    try {
      isTodayDueLoading.value = true;

      final result =
          await _repository.getTodayDue();

      todayDueList.assignAll(result);
    } catch (e, st) {
      debugPrint(
        '🔴 [EMI Today Due] ERROR: $e\n$st',
      );

      errorMessage.value =
          'Unable to load EMI today due';
    } finally {
      isTodayDueLoading.value = false;
    }
  }

  // ============================================================
  // OVERDUE
  // ============================================================

  Future<void> fetchOverdue() async {
    try {
      isOverdueLoading.value = true;

      final result =
          await _repository.getOverdue();

      overdueList.assignAll(result);
    } catch (e, st) {
      debugPrint(
        '🔴 [EMI Overdue] ERROR: $e\n$st',
      );

      errorMessage.value =
          'Unable to load EMI overdue';
    } finally {
      isOverdueLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshCollections() async {
    await loadCollections();
  }

  // ============================================================
  // TAB
  // ============================================================

  void changeTab(int index) {
    selectedTab.value = index;
  }

  // ============================================================
  // CURRENT LIST
  // ============================================================

  List<EmiInstallmentModel> get currentList {
    if (selectedTab.value == 0) {
      return todayDueList;
    }

    return overdueList;
  }

  // ============================================================
  // TODAY DUE TOTAL
  // ============================================================

  double get todayDueAmount {
    return todayDueList.fold(
      0,
      (sum, item) => sum + item.balance,
    );
  }

  // ============================================================
  // OVERDUE TOTAL
  // ============================================================

  double get overdueAmount {
    return overdueList.fold(
      0,
      (sum, item) => sum + item.balance,
    );
  }

  // ============================================================
  // COUNTS
  // ============================================================

  int get todayDueCount {
    return todayDueList.length;
  }

  int get overdueCount {
    return overdueList.length;
  }

  // ============================================================
  // TOTAL BALANCE
  // ============================================================

  double get totalPendingAmount {
    return currentList.fold(
      0,
      (sum, item) => sum + item.balance,
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  bool get isCurrentTabLoading {
    if (selectedTab.value == 0) {
      return isTodayDueLoading.value;
    }

    return isOverdueLoading.value;
  }
}