import 'dart:async';

import 'package:get/get.dart';
import 'package:sri_murugan_chits/services/repositary/today_collection/today_collection_repository.dart';


class TodayCollectionController extends GetxController {
final TodayCollectionRepository _repository;

TodayCollectionController(
  this._repository,
);

  // ============================================================
  // LOADING
  // ============================================================

  final isLoading = false.obs;
  final isRefreshing = false.obs;

  final errorMessage = ''.obs;

  // ============================================================
  // TAB
  // 0 = Diwali
  // 1 = EMI
  // ============================================================

  final selectedTab = 0.obs;

  // ============================================================
  // COLLECTION LISTS
  // ============================================================

  final diwaliCollections =
      <Map<String, dynamic>>[].obs;

  final emiCollections =
      <Map<String, dynamic>>[].obs;

  // ============================================================
  // SUMMARY
  // ============================================================

  final totalAmount = 0.0.obs;
  final cashAmount = 0.0.obs;
  final upiAmount = 0.0.obs;
  final transactionCount = 0.obs;

  // ============================================================
  // AUTO REFRESH
  // ============================================================

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();

    loadTodayCollections();

    _startAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  // ============================================================
  // LOAD ALL DATA
  // ============================================================

  Future<void> loadTodayCollections({
    bool showLoader = true,
  }) async {
    try {
      errorMessage.value = '';

      if (showLoader) {
        isLoading.value = true;
      }

      final results = await Future.wait([
        _repository.getTodayCollections(),
        _repository.getTodayCollectionSummary(),
      ]);

      // ========================================================
      // COLLECTION DATA
      // ========================================================

      final collectionData =
          results[0];

      final diwaliData =
          collectionData['diwali'];

      final emiData =
          collectionData['emi'];

      if (diwaliData is List) {
        diwaliCollections.assignAll(
          diwaliData
              .map(
                (item) => Map<String, dynamic>.from(
                  item as Map,
                ),
              )
              .toList(),
        );
      } else {
        diwaliCollections.clear();
      }

      if (emiData is List) {
        emiCollections.assignAll(
          emiData
              .map(
                (item) => Map<String, dynamic>.from(
                  item as Map,
                ),
              )
              .toList(),
        );
      } else {
        emiCollections.clear();
      }

      // ========================================================
      // SUMMARY DATA
      // ========================================================

      final summaryData =
          results[1];

      totalAmount.value =
          _toDouble(
        summaryData['totalAmount'],
      );

      cashAmount.value =
          _toDouble(
        summaryData['cashAmount'],
      );

      upiAmount.value =
          _toDouble(
        summaryData['upiAmount'],
      );

      transactionCount.value =
          _toInt(
        summaryData['transactionCount'],
      );

    } catch (e) {
      errorMessage.value =
          e.toString().replaceFirst(
                'Exception: ',
                '',
              );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ============================================================
  // MANUAL REFRESH
  // ============================================================

  Future<void> refreshCollections() async {
    isRefreshing.value = true;

    await loadTodayCollections(
      showLoader: false,
    );
  }

  // ============================================================
  // CHANGE TAB
  // ============================================================

  void changeTab(int index) {
    selectedTab.value = index;
  }

  // ============================================================
  // CURRENT COLLECTIONS
  // ============================================================

  List<Map<String, dynamic>> get currentCollections {
    if (selectedTab.value == 0) {
      return diwaliCollections;
    }

    return emiCollections;
  }

  // ============================================================
  // CURRENT TAB TOTAL
  // ============================================================

  double get currentTabTotal {
    return currentCollections.fold(
      0.0,
      (sum, item) =>
          sum + _toDouble(
            item['amount'],
          ),
    );
  }

  // ============================================================
  // CURRENT TAB CASH
  // ============================================================

  double get currentTabCash {
    return currentCollections.fold(
      0.0,
      (sum, item) {
        if ((item['payment_mode'] ?? '')
                .toString()
                .toLowerCase() ==
            'cash') {
          return sum +
              _toDouble(
                item['amount'],
              );
        }

        return sum;
      },
    );
  }

  // ============================================================
  // CURRENT TAB UPI
  // ============================================================

  double get currentTabUpi {
    return currentCollections.fold(
      0.0,
      (sum, item) {
        if ((item['payment_mode'] ?? '')
                .toString()
                .toLowerCase() ==
            'upi') {
          return sum +
              _toDouble(
                item['amount'],
              );
        }

        return sum;
      },
    );
  }

  // ============================================================
  // CURRENT TAB COUNT
  // ============================================================

  int get currentTabCount {
    return currentCollections.length;
  }

  // ============================================================
  // AUTO REFRESH EVERY 20 SECONDS
  // ============================================================

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) {
        loadTodayCollections(
          showLoader: false,
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }
}