import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/dues/dues_model.dart';
import 'package:sri_murugan_chits/services/repositary/dues/dues_repository.dart';



class DuesController extends GetxController {
  final DuesRepository _repository =
      DuesRepository();

  // ============================================================
  // LIST
  // ============================================================

  final RxList<DuesModel> todayDueList =
      <DuesModel>[].obs;

  final RxList<DuesModel> overdueList =
      <DuesModel>[].obs;

  // ============================================================
  // SEARCH
  // ============================================================

  final RxString searchText = ''.obs;

  // ============================================================
  // TAB
  // ============================================================

  final RxInt selectedTab = 0.obs;

  // 0 = All
  // 1 = Today
  // 2 = Overdue

  // ============================================================
  // LOADING
  // ============================================================

  final RxBool isLoading = false.obs;

  final RxBool isTodayLoading = false.obs;

  final RxBool isOverdueLoading = false.obs;

  final RxString errorMessage = ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadDues();
  }

  // ============================================================
  // LOAD ALL
  // ============================================================

  Future<void> loadDues() async {
    errorMessage.value = '';

    isLoading.value = true;

    try {
      await Future.wait([
        _loadToday(),
        _loadOverdue(),
      ]);
    } catch (e, st) {
      debugPrint(
        'Dues loading error: $e\n$st',
      );

      errorMessage.value =
          'Unable to load dues';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD TODAY
  // ============================================================

  Future<void> _loadToday() async {
    isTodayLoading.value = true;

    try {
      final results =
          await Future.wait([
        _repository.getDiwaliTodayDue(),
        _repository.getEmiTodayDue(),
      ]);

      final diwali =
          results[0];

      final emi =
          results[1];

      final combined = [
        ...diwali,
        ...emi,
      ];

      _sortByBalance(combined);

      todayDueList.assignAll(
        combined,
      );
    } catch (e, st) {
      debugPrint(
        'Today dues error: $e\n$st',
      );

      rethrow;
    } finally {
      isTodayLoading.value = false;
    }
  }

  // ============================================================
  // LOAD OVERDUE
  // ============================================================

  Future<void> _loadOverdue() async {
    isOverdueLoading.value = true;

    try {
      final results =
          await Future.wait([
        _repository.getDiwaliOverdue(),
        _repository.getEmiOverdue(),
      ]);

      final diwali =
          results[0];

      final emi =
          results[1];

      final combined = [
        ...diwali,
        ...emi,
      ];

      _sortByBalance(combined);

      overdueList.assignAll(
        combined,
      );
    } catch (e, st) {
      debugPrint(
        'Overdue dues error: $e\n$st',
      );

      rethrow;
    } finally {
      isOverdueLoading.value = false;
    }
  }

  // ============================================================
  // SORT
  // ============================================================

  void _sortByBalance(
    List<DuesModel> list,
  ) {
    list.sort(
      (a, b) => b.balanceAmount.compareTo(
        a.balanceAmount,
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void updateSearch(String value) {
    searchText.value = value;
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

  List<DuesModel> get currentList {
    List<DuesModel> source;

    switch (selectedTab.value) {
      case 1:
        source = todayDueList.toList();
        break;

      case 2:
        source = overdueList.toList();
        break;

      default:
        source = [
          ...todayDueList,
          ...overdueList,
        ];
        break;
    }

    final query =
        searchText.value.trim().toLowerCase();

    if (query.isEmpty) {
      _sortByBalance(source);
      return source;
    }

    final filtered = source.where((item) {
      final name =
          item.customerName.toLowerCase();

      final phone =
          item.customerPhone.toLowerCase();

      final type =
          item.type.toLowerCase();

      final scheme =
          (item.schemeName ?? '')
              .toLowerCase();

      return name.contains(query) ||
          phone.contains(query) ||
          type.contains(query) ||
          scheme.contains(query);
    }).toList();

    _sortByBalance(filtered);

    return filtered;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  double get todayTotal {
    return todayDueList.fold(
      0,
      (sum, item) =>
          sum + item.balanceAmount,
    );
  }

  double get overdueTotal {
    return overdueList.fold(
      0,
      (sum, item) =>
          sum + item.balanceAmount,
    );
  }

  double get totalDue {
    return todayTotal + overdueTotal;
  }

  int get todayCount =>
      todayDueList.length;

  int get overdueCount =>
      overdueList.length;

  int get totalCount =>
      todayCount + overdueCount;

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshDues() async {
    await loadDues();
  }

  // ============================================================
  // CURRENT LOADING
  // ============================================================

  bool get isCurrentTabLoading {
    switch (selectedTab.value) {
      case 1:
        return isTodayLoading.value;

      case 2:
        return isOverdueLoading.value;

      default:
        return isLoading.value;
    }
  }
}