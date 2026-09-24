import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/models/diwali_enrollment/diwali_enrollment_model.dart';
import 'package:sri_murugan_chits/models/diwali_scheme.dart/diwali_scheme_model.dart';

import 'package:sri_murugan_chits/services/repositary/customer/customer_repositary.dart';
import 'package:sri_murugan_chits/services/repositary/diwali_enrollment/diwali_enrollment_repositary.dart';
import 'package:sri_murugan_chits/services/repositary/diwali_scheme/diwali_scheme_repo.dart';

class DiwaliEnrollmentController extends GetxController {
  final DiwaliEnrollmentRepository _repository;
  final CustomerRepository _customerRepository;
  final DiwaliSchemeRepository _schemeRepository;

  DiwaliEnrollmentController(
    this._repository,
    this._customerRepository,
    this._schemeRepository,
  );

  // ============================================================
  // DEBUG LOG HELPER
  // 🔵 start | 🟢 success | 🔴 error | ⚪ info
  // ============================================================

  void _log(String msg) {
    if (kDebugMode) debugPrint(msg);
  }

  // ============================================================
  // LIST STATE
  // ============================================================

  final enrollments = <DiwaliEnrollmentModel>[].obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  final page = 1.obs;
  final totalPages = 1.obs;

  static const int _limit = 20;

  final scrollController = ScrollController();

  // ============================================================
  // SEARCH
  // ============================================================

  final searchController = TextEditingController();
  final hasSearchText = false.obs;

  Timer? _debounce;

  // ============================================================
  // FILTER
  // ============================================================

  final selectedStatus = ''.obs;

  // ============================================================
  // CREATE ENROLLMENT
  // ============================================================

  final isSaving = false.obs;

  final selectedCustomer = Rxn<CustomerModel>();
  final selectedScheme = Rxn<DiwaliSchemeModel>();

  // ============================================================
  // DETAIL
  // ============================================================

  final isDetailLoading = false.obs;

  final currentEnrollment = Rxn<DiwaliEnrollmentModel>();

  final weeks = <DiwaliEnrollmentWeekModel>[].obs;

  final summary = Rxn<EnrollmentSummary>();

  // ============================================================
  // PAYMENT
  // ============================================================

  final isPaying = false.obs;
  final isBulkPaying = false.obs;

  // ============================================================
  // MODIFY CHITS
  // ============================================================

  final isModifyingChits = false.obs;

  // ============================================================
  // PAYMENT HISTORY
  // ============================================================

  final paymentHistory = <Map<String, dynamic>>[].obs;

  final isPaymentHistoryLoading = false.obs;

  // ============================================================
  // REVERT PAYMENT
  // ============================================================

  final isRevertingPayment = false.obs;
  final isRevertingPaymentGroup = false.obs;

  // ============================================================
  // ADJUSTMENT LOGS
  // ============================================================

  final adjustmentLogs = <AdjustmentLogModel>[].obs;

  final isAdjustmentLogsLoading = false.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _log('⚪ [onInit] controller initialised');

    fetchEnrollments(reset: true);

    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _log('⚪ [onClose] controller disposed');

    _debounce?.cancel();

    scrollController.removeListener(_onScroll);
    scrollController.dispose();

    searchController.removeListener(_onSearchChanged);
    searchController.dispose();

    super.onClose();
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    final nearBottom = position.pixels >= position.maxScrollExtent - 250;

    if (nearBottom) {
      loadMore();
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    hasSearchText.value = searchController.text.trim().isNotEmpty;

    _log('⌨️ [search] text="${searchController.text}"');

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        fetchEnrollments(reset: true);
      },
    );
  }

  void clearSearch() {
    _log('⌨️ [clearSearch]');

    searchController.clear();

    hasSearchText.value = false;

    fetchEnrollments(reset: true);
  }

  // ============================================================
  // STATUS FILTER
  // ============================================================

  void changeStatus(String status) {
    _log('🎛️ [changeStatus] "$status"');

    selectedStatus.value = status;
    fetchEnrollments(reset: true);
  }

  // ============================================================
  // FETCH ENROLLMENTS
  // ============================================================

  Future<void> fetchEnrollments({
    bool reset = false,
  }) async {
    _log('🔵 [fetchEnrollments] reset=$reset page=${page.value} '
        'search="${searchController.text.trim()}" '
        'status="${selectedStatus.value}"');

    if (reset) {
      page.value = 1;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final result = await _repository.getEnrollments(
        page: page.value,
        limit: _limit,
        search: searchController.text.trim(),
        status: selectedStatus.value,
      );

      _log('🟢 [fetchEnrollments] raw keys=${result.keys}');

      final fetched = result['enrollments'] as List<DiwaliEnrollmentModel>;

      final pagination = result['pagination'] as Map<String, dynamic>? ?? {};

      _log('🟢 [fetchEnrollments] fetched=${fetched.length} '
          'pagination=$pagination');

      totalPages.value = _toInt(
        pagination['totalPages'],
        fallback: 1,
      );

      if (reset) {
        enrollments.assignAll(fetched);
      } else {
        enrollments.addAll(fetched);
      }
      enrollments.sort(
        (a, b) => b.currentChits.compareTo(a.currentChits),
      );

      _log('🟢 [fetchEnrollments] list total=${enrollments.length} '
          'totalPages=${totalPages.value}');
    } catch (e, st) {
      _log('🔴 [fetchEnrollments] ERROR: $e\n$st');
      _showError(e);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value) {
      return;
    }

    if (page.value >= totalPages.value) {
      _log('⚪ [loadMore] last page reached '
          '${page.value}/${totalPages.value}');
      return;
    }

    page.value++;

    _log('🔵 [loadMore] loading page=${page.value}');

    await fetchEnrollments();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshEnrollments() async {
    _log('🔵 [refreshEnrollments]');
    await fetchEnrollments(reset: true);
  }

  // ============================================================
  // CUSTOMER SEARCH
  // ============================================================

  Future<List<CustomerModel>> searchCustomers(
    String query,
  ) async {
    _log('🔵 [searchCustomers] query="$query"');

    try {
      final result = await _customerRepository.getCustomers(
        page: 1,
        limit: 20,
        search: query.trim(),
        status: 'Active',
      );

      final list = result['customers'] as List<CustomerModel>;

      _log('🟢 [searchCustomers] count=${list.length}');

      return list;
    } catch (e, st) {
      _log('🔴 [searchCustomers] ERROR: $e\n$st');
      _showError(e);
      return [];
    }
  }

  // ============================================================
  // SCHEME SEARCH
  // ============================================================

  Future<List<DiwaliSchemeModel>> searchActiveSchemes() async {
    _log('🔵 [searchActiveSchemes]');

    try {
      final result = await _schemeRepository.getSchemes(
        page: 1,
        limit: 50,
        status: 'Active',
      );

      final list = result['schemes'] as List<DiwaliSchemeModel>;

      _log('🟢 [searchActiveSchemes] count=${list.length}');

      return list;
    } catch (e, st) {
      _log('🔴 [searchActiveSchemes] ERROR: $e\n$st');
      _showError(e);
      return [];
    }
  }

  // ============================================================
  // PICK CUSTOMER
  // ============================================================

  void pickCustomer(
    CustomerModel customer,
  ) {
    _log('⚪ [pickCustomer] id=${customer.id}');
    selectedCustomer.value = customer;
  }

  // ============================================================
  // PICK SCHEME
  // ============================================================

  void pickScheme(
    DiwaliSchemeModel scheme,
  ) {
    _log('⚪ [pickScheme] id=${scheme.id}');
    selectedScheme.value = scheme;
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearFormSelections() {
    _log('⚪ [clearFormSelections]');
    selectedCustomer.value = null;
    selectedScheme.value = null;
  }

  // ============================================================
  // CREATE ENROLLMENT
  // ============================================================

  Future<Map<String, dynamic>?> createEnrollment(
    int chits,
  ) async {
    final customer = selectedCustomer.value;

    final scheme = selectedScheme.value;

    _log('🔵 [createEnrollment] customer=${customer?.id} '
        'scheme=${scheme?.id} chits=$chits');

    if (customer == null) {
      _showError(
        Exception('Please select a customer'),
      );
      return null;
    }

    if (scheme == null) {
      _showError(
        Exception('Please select a scheme'),
      );
      return null;
    }

    if (chits <= 0) {
      _showError(
        Exception('Enter a valid number of chits'),
      );
      return null;
    }

    isSaving.value = true;

    try {
      final result = await _repository.createEnrollment(
        customerId: customer.id,
        schemeId: scheme.id,
        chits: chits,
      );

      _log('🟢 [createEnrollment] result=$result');

      clearFormSelections();

      await fetchEnrollments(
        reset: true,
      );

      return result;
    } catch (e, st) {
      _log('🔴 [createEnrollment] ERROR: $e\n$st');
      _showError(e);
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // LOAD DETAIL
  // ============================================================

  Future<void> loadEnrollmentDetail(
    int id,
  ) async {
    _log('🔵 [loadEnrollmentDetail] id=$id');

    isDetailLoading.value = true;

    try {
      final result = await _repository.getEnrollmentDetail(id);

      _log('🟢 [loadEnrollmentDetail] keys=${result.keys}');

      currentEnrollment.value = result['enrollment'] as DiwaliEnrollmentModel;

      weeks.assignAll(
        result['weeks'] as List<DiwaliEnrollmentWeekModel>,
      );

      summary.value = result['summary'] as EnrollmentSummary;

      _log('🟢 [loadEnrollmentDetail] weeks=${weeks.length}');

      // Load payment history also.
      await loadPaymentHistory(id);

      // Load adjustment logs.
      await loadAdjustmentLogs(id);
    } catch (e, st) {
      _log('🔴 [loadEnrollmentDetail] ERROR: $e\n$st');
      _showError(e);
    } finally {
      isDetailLoading.value = false;
    }
  }

  // ============================================================
  // SINGLE WEEK PAYMENT
  // ============================================================

  Future<bool> payWeek({
    required int enrollmentId,
    required int weekNumber,
    required List<Map<String, dynamic>> payments,
    String? paymentDate,
  }) async {
    _log('🔵 [payWeek] enrollmentId=$enrollmentId week=$weekNumber '
        'payments=$payments date=$paymentDate');

    if (payments.isEmpty) {
      _showError(
        Exception(
          'Please enter at least one payment amount',
        ),
      );
      return false;
    }

    isPaying.value = true;

    try {
      final result = await _repository.payWeek(
        enrollmentId: enrollmentId,
        weekNumber: weekNumber,
        payments: payments,
        paymentDate: paymentDate,
      );

      _log('🟢 [payWeek] result=$result');

      final updatedWeek = result['week'] as DiwaliEnrollmentWeekModel;

      final index = weeks.indexWhere(
        (w) => w.weekNumber == weekNumber,
      );

      _log('🟢 [payWeek] week index in list=$index');

      if (index != -1) {
        weeks[index] = updatedWeek;
      }

      await loadEnrollmentDetail(
        enrollmentId,
      );

      return true;
    } catch (e, st) {
      _log('🔴 [payWeek] ERROR: $e\n$st');
      _showError(e);
      return false;
    } finally {
      isPaying.value = false;
    }
  }

  // ============================================================
  // BULK PAYMENT
  // ============================================================

  Future<bool> bulkPayEnrollment({
    required int enrollmentId,
    required double totalAmount,
    String? paymentMode,
    String? paymentDate,
  }) async {
    _log('🔵 [bulkPay] enrollmentId=$enrollmentId amount=$totalAmount '
        'mode=$paymentMode date=$paymentDate');

    if (totalAmount <= 0) {
      _showError(
        Exception(
          'Enter a valid payment amount',
        ),
      );
      return false;
    }

    isBulkPaying.value = true;

    try {
      final result = await _repository.bulkPay(
        enrollmentId: enrollmentId,
        totalAmount: totalAmount,
        paymentMode: paymentMode,
        paymentDate: paymentDate,
      );

      _log('🟢 [bulkPay] result=$result');

      await loadEnrollmentDetail(
        enrollmentId,
      );

      final applied = _toDouble(
        result['appliedAmount'],
      );

      Get.snackbar(
        'Payment Recorded',
        '₹${applied.toStringAsFixed(0)} applied successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log('🔴 [bulkPay] ERROR: $e\n$st');
      _showError(e);
      return false;
    } finally {
      isBulkPaying.value = false;
    }
  }

  // ============================================================
  // PAYMENT HISTORY
  // ============================================================

  Future<void> loadPaymentHistory(
    int enrollmentId,
  ) async {
    _log('🔵 [paymentHistory] enrollmentId=$enrollmentId');

    isPaymentHistoryLoading.value = true;

    try {
      final result = await _repository.getPaymentHistory(
        enrollmentId,
      );

      _log('🟢 [paymentHistory] count=${result.length}');

      paymentHistory.assignAll(
        result,
      );
    } catch (e, st) {
      _log('🔴 [paymentHistory] ERROR: $e\n$st');
      _showError(e);
    } finally {
      isPaymentHistoryLoading.value = false;
    }
  }

  // ============================================================
  // REVERT SINGLE PAYMENT
  // ============================================================

  Future<bool> revertPayment({
    required int enrollmentId,
    required int transactionId,
    String? reason,
  }) async {
    _log('🔵 [revertPayment] enrollmentId=$enrollmentId '
        'txnId=$transactionId reason=$reason');

    isRevertingPayment.value = true;

    try {
      final result = await _repository.revertPayment(
        transactionId: transactionId,
        reason: reason,
      );

      _log('🟢 [revertPayment] result=$result');

      await loadEnrollmentDetail(
        enrollmentId,
      );

      final amount = _toDouble(
        result['reversedAmount'],
      );

      Get.snackbar(
        'Payment Reverted',
        '₹${amount.toStringAsFixed(0)} payment reverted',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log('🔴 [revertPayment] ERROR: $e\n$st');
      _showError(e);
      return false;
    } finally {
      isRevertingPayment.value = false;
    }
  }

  // ============================================================
  // REVERT PAYMENT GROUP
  // ============================================================

  Future<bool> revertPaymentGroup({
    required int enrollmentId,
    required String paymentGroupId,
    String? reason,
  }) async {
    _log('🔵 [revertGroup] enrollmentId=$enrollmentId '
        'groupId=$paymentGroupId reason=$reason');

    isRevertingPaymentGroup.value = true;

    try {
      final result = await _repository.revertPaymentGroup(
        paymentGroupId: paymentGroupId,
        reason: reason,
      );

      _log('🟢 [revertGroup] result=$result');

      await loadEnrollmentDetail(
        enrollmentId,
      );

      final amount = _toDouble(
        result['totalReversed'],
      );

      final count = _toInt(
        result['transactionCount'],
      );

      Get.snackbar(
        'Payment Group Reverted',
        '$count payment(s) reverted • ₹${amount.toStringAsFixed(0)}',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log('🔴 [revertGroup] ERROR: $e\n$st');
      _showError(e);
      return false;
    } finally {
      isRevertingPaymentGroup.value = false;
    }
  }

  // ============================================================
  // MODIFY CHITS
  // ============================================================

  Future<bool> modifyChits({
    required int enrollmentId,
    required int fromWeekNumber,
    required int newChits,
  }) async {
    _log('🔵 [modifyChits] enrollmentId=$enrollmentId '
        'fromWeek=$fromWeekNumber newChits=$newChits');

    if (fromWeekNumber <= 0) {
      _showError(
        Exception(
          'Enter a valid week number',
        ),
      );
      return false;
    }

    if (newChits <= 0) {
      _showError(
        Exception(
          'Enter a valid chit count',
        ),
      );
      return false;
    }

    isModifyingChits.value = true;

    try {
      final result = await _repository.modifyChits(
        enrollmentId: enrollmentId,
        fromWeekNumber: fromWeekNumber,
        newChits: newChits,
      );

      _log('🟢 [modifyChits] result=$result');

      final updatedWeeks =
          result['weeks'] as List<DiwaliEnrollmentWeekModel>?;

      if (updatedWeeks != null) {
        weeks.assignAll(
          updatedWeeks,
        );
      }

      await loadEnrollmentDetail(
        enrollmentId,
      );

      return true;
    } catch (e, st) {
      _log('🔴 [modifyChits] ERROR: $e\n$st');
      _showError(e);
      return false;
    } finally {
      isModifyingChits.value = false;
    }
  }

  // ============================================================
  // ADJUSTMENT LOGS
  // ============================================================

  Future<void> loadAdjustmentLogs(
    int enrollmentId,
  ) async {
    _log('🔵 [adjustmentLogs] enrollmentId=$enrollmentId');

    isAdjustmentLogsLoading.value = true;

    try {
      final result = await _repository.getAdjustmentLogs(
        enrollmentId,
      );

      _log('🟢 [adjustmentLogs] count=${result.length}');

      adjustmentLogs.assignAll(
        result,
      );
    } catch (e, st) {
      _log('🔴 [adjustmentLogs] ERROR: $e\n$st');
      _showError(e);
    } finally {
      isAdjustmentLogsLoading.value = false;
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(Object error) {
    _log('🔴 [_showError] $error');

    final message = error.toString().replaceFirst(
          'Exception: ',
          '',
        );

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        fallback;
  }

  double _toDouble(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        fallback;
  }
}