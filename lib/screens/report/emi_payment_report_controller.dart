import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/services/repositary/report/emi_payment_report_repository.dart';

class EmiPaymentReportController extends GetxController {
  final EmiPaymentReportRepository repository =
      EmiPaymentReportRepository();

  // ============================================================
  // LIST
  // ============================================================

  final RxList<Map<String, dynamic>> payments = <Map<String, dynamic>>[].obs;

  // ============================================================
  // LOADING
  // ============================================================

  final RxBool loading = false.obs;

  final RxBool loadingMore = false.obs;

  // ============================================================
  // FILTERS
  // ============================================================

  final RxString fromDate = ''.obs;

  final RxString toDate = ''.obs;

  final RxString selectedCustomerId = ''.obs;

  final RxString selectedSchemeId = ''.obs;

  final RxString paymentMode = ''.obs;

  final RxString status = ''.obs;

  // ============================================================
  // PAGINATION
  // ============================================================

  final RxInt currentPage = 1.obs;

  final RxInt totalPages = 1.obs;

  final RxInt totalRecords = 0.obs;

  final int pageLimit = 20;

  // ============================================================
  // SUMMARY
  // ============================================================

  final RxDouble totalCollection = 0.0.obs;

  final RxDouble cashTotal = 0.0.obs;

  final RxDouble upiTotal = 0.0.obs;

  final RxDouble reversedTotal = 0.0.obs;

  final RxInt transactionCount = 0.obs;

  // ============================================================
  // DEBUG
  // ============================================================

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadReport();
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> loadReport({
    bool refresh = true,
  }) async {
    try {
      if (refresh) {
        loading.value = true;
        currentPage.value = 1;
      } else {
        loadingMore.value = true;
      }

      _log(
        '🔵 [EMI REPORT] '
        'page=${currentPage.value} '
        'limit=$pageLimit '
        'from=${fromDate.value} '
        'to=${toDate.value} '
        'customer=${selectedCustomerId.value} '
        'scheme=${selectedSchemeId.value} '
        'mode=${paymentMode.value} '
        'status=${status.value}',
      );

      final result = await repository.getPaymentReport(
        page: currentPage.value,
        limit: pageLimit,
        fromDate: fromDate.value,
        toDate: toDate.value,
        customerId: selectedCustomerId.value,
        schemeId: selectedSchemeId.value,
        paymentMode: paymentMode.value,
        status: status.value,
      );

      // ========================================================
      // DATA
      // ========================================================

      final rawData = result['data'];

      final newItems = <Map<String, dynamic>>[];

      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map) {
            newItems.add(Map<String, dynamic>.from(item));
          }
        }
      }

      if (refresh) {
        payments.assignAll(newItems);
      } else {
        payments.addAll(newItems);
      }

      // ========================================================
      // SUMMARY
      // ========================================================

      final summary = result['summary'];

      if (summary is Map) {
        totalCollection.value = _toDouble(summary['totalCollection']);

        cashTotal.value = _toDouble(summary['cashTotal']);

        upiTotal.value = _toDouble(summary['upiTotal']);

        reversedTotal.value = _toDouble(summary['reversedTotal']);

        transactionCount.value = _toInt(summary['transactionCount']);
      } else {
        clearSummary();
      }

      // ========================================================
      // PAGINATION
      // ========================================================

      final pagination = result['pagination'];

      if (pagination is Map) {
        totalRecords.value = _toInt(pagination['total']);

        totalPages.value = _toInt(pagination['totalPages']);

        currentPage.value = _toInt(pagination['page']);
      } else {
        totalRecords.value = payments.length;

        totalPages.value = 1;
      }

      _log(
        '🟢 [EMI REPORT] '
        'loaded=${newItems.length} '
        'total=${payments.length} '
        'pages=${totalPages.value}',
      );
    } catch (e, st) {
      _log('🔴 [EMI REPORT] ERROR: $e\n$st');

      Get.snackbar(
        'Error',
        'Unable to load EMI payment report',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
      loadingMore.value = false;
    }
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Future<void> loadMore() async {
    if (loading.value || loadingMore.value) {
      return;
    }

    if (currentPage.value >= totalPages.value) {
      return;
    }

    currentPage.value++;

    await loadReport(refresh: false);
  }

  // ============================================================
  // APPLY FILTERS
  // ============================================================

  Future<void> applyFilters() async {
    await loadReport(refresh: true);
  }

  // ============================================================
  // DATE
  // ============================================================

  void setFromDate(DateTime date) {
    fromDate.value = _formatDate(date);
  }

  void setToDate(DateTime date) {
    toDate.value = _formatDate(date);
  }

  // ============================================================
  // CUSTOMER
  // ============================================================

  void setCustomer(String? id) {
    selectedCustomerId.value = id ?? '';
  }

  // ============================================================
  // SCHEME
  // ============================================================

  void setScheme(String? id) {
    selectedSchemeId.value = id ?? '';
  }

  // ============================================================
  // PAYMENT MODE
  // ============================================================

  void setPaymentMode(String? mode) {
    paymentMode.value = mode ?? '';
  }

  // ============================================================
  // STATUS
  // ============================================================

  void setStatus(String? newStatus) {
    status.value = newStatus ?? '';
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void> resetFilters() async {
    fromDate.value = '';
    toDate.value = '';

    selectedCustomerId.value = '';

    selectedSchemeId.value = '';

    paymentMode.value = '';

    status.value = '';

    await loadReport(refresh: true);
  }

  // ============================================================
  // CLEAR SUMMARY
  // ============================================================

  void clearSummary() {
    totalCollection.value = 0;
    cashTotal.value = 0;
    upiTotal.value = 0;
    reversedTotal.value = 0;
    transactionCount.value = 0;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}