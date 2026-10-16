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
import 'package:sri_murugan_chits/utils/global/payment_receipt_widget.dart';

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
  // ============================================================

  void _log(String msg) {
    if (kDebugMode) {
      debugPrint(msg);
    }
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

    final nearBottom =
        position.pixels >= position.maxScrollExtent - 250;

    if (nearBottom) {
      loadMore();
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    hasSearchText.value =
        searchController.text.trim().isNotEmpty;

    _log(
      '⌨️ [search] text="${searchController.text}"',
    );

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
    _log(
      '🎛️ [changeStatus] "$status"',
    );

    selectedStatus.value = status;

    fetchEnrollments(reset: true);
  }

  // ============================================================
  // FETCH ENROLLMENTS
  // ============================================================

  Future<void> fetchEnrollments({
    bool reset = false,
  }) async {
    _log(
      '🔵 [fetchEnrollments] '
      'reset=$reset '
      'page=${page.value} '
      'search="${searchController.text.trim()}" '
      'status="${selectedStatus.value}"',
    );

    if (reset) {
      page.value = 1;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final result =
          await _repository.getEnrollments(
        page: page.value,
        limit: _limit,
        search: searchController.text.trim(),
        status: selectedStatus.value,
      );

      _log(
        '🟢 [fetchEnrollments] '
        'raw keys=${result.keys}',
      );

      final fetched =
          result['enrollments']
              as List<DiwaliEnrollmentModel>;

      final pagination =
          result['pagination']
                  as Map<String, dynamic>? ??
              {};

      _log(
        '🟢 [fetchEnrollments] '
        'fetched=${fetched.length} '
        'pagination=$pagination',
      );

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
        (a, b) =>
            b.currentChits.compareTo(
          a.currentChits,
        ),
      );

      _log(
        '🟢 [fetchEnrollments] '
        'list total=${enrollments.length} '
        'totalPages=${totalPages.value}',
      );
    } catch (e, st) {
      _log(
        '🔴 [fetchEnrollments] '
        'ERROR: $e\n$st',
      );

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
    if (isLoading.value ||
        isLoadingMore.value) {
      return;
    }

    if (page.value >= totalPages.value) {
      _log(
        '⚪ [loadMore] '
        'last page reached '
        '${page.value}/${totalPages.value}',
      );

      return;
    }

    page.value++;

    _log(
      '🔵 [loadMore] '
      'loading page=${page.value}',
    );

    await fetchEnrollments();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshEnrollments() async {
    _log(
      '🔵 [refreshEnrollments]',
    );

    await fetchEnrollments(
      reset: true,
    );
  }

  // ============================================================
  // CUSTOMER SEARCH
  // ============================================================

  Future<List<CustomerModel>> searchCustomers(
    String query,
  ) async {
    _log(
      '🔵 [searchCustomers] '
      'query="$query"',
    );

    try {
      final result =
          await _customerRepository.getCustomers(
        page: 1,
        limit: 20,
        search: query.trim(),
        status: 'Active',
      );

      final list =
          result['customers']
              as List<CustomerModel>;

      _log(
        '🟢 [searchCustomers] '
        'count=${list.length}',
      );

      return list;
    } catch (e, st) {
      _log(
        '🔴 [searchCustomers] '
        'ERROR: $e\n$st',
      );

      _showError(e);

      return [];
    }
  }

  // ============================================================
  // SCHEME SEARCH
  // ============================================================

  Future<List<DiwaliSchemeModel>>
      searchActiveSchemes() async {
    _log(
      '🔵 [searchActiveSchemes]',
    );

    try {
      final result =
          await _schemeRepository.getSchemes(
        page: 1,
        limit: 50,
        status: 'Active',
      );

      final list =
          result['schemes']
              as List<DiwaliSchemeModel>;

      _log(
        '🟢 [searchActiveSchemes] '
        'count=${list.length}',
      );

      return list;
    } catch (e, st) {
      _log(
        '🔴 [searchActiveSchemes] '
        'ERROR: $e\n$st',
      );

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
    _log(
      '⚪ [pickCustomer] '
      'id=${customer.id}',
    );

    selectedCustomer.value = customer;
  }

  // ============================================================
  // PICK SCHEME
  // ============================================================

  void pickScheme(
    DiwaliSchemeModel scheme,
  ) {
    _log(
      '⚪ [pickScheme] '
      'id=${scheme.id}',
    );

    selectedScheme.value = scheme;
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearFormSelections() {
    _log(
      '⚪ [clearFormSelections]',
    );

    selectedCustomer.value = null;
    selectedScheme.value = null;
  }

  // ============================================================
  // CREATE ENROLLMENT
  // ============================================================

  Future<Map<String, dynamic>?>
      createEnrollment(
    int chits,
  ) async {
    final customer =
        selectedCustomer.value;

    final scheme =
        selectedScheme.value;

    _log(
      '🔵 [createEnrollment] '
      'customer=${customer?.id} '
      'scheme=${scheme?.id} '
      'chits=$chits',
    );

    if (customer == null) {
      _showError(
        Exception(
          'Please select a customer',
        ),
      );

      return null;
    }

    if (scheme == null) {
      _showError(
        Exception(
          'Please select a scheme',
        ),
      );

      return null;
    }

    if (chits <= 0) {
      _showError(
        Exception(
          'Enter a valid number of chits',
        ),
      );

      return null;
    }

    isSaving.value = true;

    try {
      final result =
          await _repository.createEnrollment(
        customerId: customer.id,
        schemeId: scheme.id,
        chits: chits,
      );

      _log(
        '🟢 [createEnrollment] '
        'result=$result',
      );

      clearFormSelections();

      await fetchEnrollments(
        reset: true,
      );

      return result;
    } catch (e, st) {
      _log(
        '🔴 [createEnrollment] '
        'ERROR: $e\n$st',
      );

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
    _log(
      '🔵 [loadEnrollmentDetail] '
      'id=$id',
    );

    isDetailLoading.value = true;

    try {
      final result =
          await _repository.getEnrollmentDetail(
        id,
      );

      _log(
        '🟢 [loadEnrollmentDetail] '
        'keys=${result.keys}',
      );

      currentEnrollment.value =
          result['enrollment']
              as DiwaliEnrollmentModel;

      weeks.assignAll(
        result['weeks']
            as List<DiwaliEnrollmentWeekModel>,
      );

      summary.value =
          result['summary']
              as EnrollmentSummary;

      _log(
        '🟢 [loadEnrollmentDetail] '
        'weeks=${weeks.length} '
        'totalPaid=${summary.value?.totalPaid} '
        'totalDue=${summary.value?.totalDue} '
        'balance=${summary.value?.balance}',
      );

      await loadPaymentHistory(id);

      await loadAdjustmentLogs(id);
    } catch (e, st) {
      _log(
        '🔴 [loadEnrollmentDetail] '
        'ERROR: $e\n$st',
      );

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
    _log(
      '🔵 [payWeek] '
      'enrollmentId=$enrollmentId '
      'week=$weekNumber '
      'payments=$payments '
      'date=$paymentDate',
    );

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
      // ==========================================================
      // 1. SAVE PAYMENT
      // ==========================================================

      final result =
          await _repository.payWeek(
        enrollmentId: enrollmentId,
        weekNumber: weekNumber,
        payments: payments,
        paymentDate: paymentDate,
      );

      _log(
        '🟢 [payWeek] '
        'result=$result',
      );

      final updatedWeek =
          result['week']
              as DiwaliEnrollmentWeekModel;

      final index =
          weeks.indexWhere(
        (w) =>
            w.weekNumber ==
            weekNumber,
      );

      if (index != -1) {
        weeks[index] = updatedWeek;
      }

      // ==========================================================
      // 2. CAPTURE RECEIPT DETAILS
      // ==========================================================

      final receiptNumber =
          result['receiptNumber']
                  ?.toString() ??
              result['receipt_number']
                  ?.toString();

      final paidAmount = _toDouble(
        result['paidAmount'] ??
            result['paid_amount'] ??
            _calculatePaymentTotal(
              payments,
            ),
      );

      final paymentMode =
          _extractPaymentMode(
        payments,
      );

      _log(
        '🧾 [payWeek] '
        'receipt=$receiptNumber '
        'paid=$paidAmount '
        'mode=$paymentMode',
      );

      // ==========================================================
      // 3. REFRESH ENROLLMENT
      // ==========================================================
      //
      // This is important.
      //
      // Backend detail API calculates:
      //
      // balance = totalDue - totalPaid
      //
      // So we MUST refresh before reading
      // summary.balance.
      //

      await loadEnrollmentDetail(
        enrollmentId,
      );

      // ==========================================================
      // 4. GET ACTUAL REMAINING BALANCE
      // ==========================================================

      final latestSummary =
          summary.value;

      final remainingBalance =
          latestSummary?.balance ?? 0;

      _log(
        '💰 [payWeek] '
        'latestTotalPaid='
        '${latestSummary?.totalPaid} '
        'latestTotalDue='
        '${latestSummary?.totalDue} '
        'remainingBalance='
        '$remainingBalance',
      );

      // ==========================================================
      // 5. STOP PAYMENT LOADING
      // ==========================================================

      isPaying.value = false;

      // ==========================================================
      // 6. SHOW RECEIPT
      // ==========================================================

      _showPaymentReceipt(
        receiptNumber: receiptNumber,
        customerName: _customerName(),
        customerCode: _customerCode(),
        schemeName: _schemeName(),
        installmentLabel:
            'Week $weekNumber',
        paidAmount:
            _formatAmount(
          paidAmount,
        ),
        paymentMode: paymentMode,
        paymentDate:
            paymentDate ??
            _formatDate(
              DateTime.now(),
            ),
        remainingBalance:
            _formatAmount(
          remainingBalance,
        ),
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [payWeek] '
        'ERROR: $e\n$st',
      );

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
    _log(
      '🔵 [bulkPay] '
      'enrollmentId=$enrollmentId '
      'amount=$totalAmount '
      'mode=$paymentMode '
      'date=$paymentDate',
    );

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
      // ==========================================================
      // 1. SAVE BULK PAYMENT
      // ==========================================================

      final result =
          await _repository.bulkPay(
        enrollmentId: enrollmentId,
        totalAmount: totalAmount,
        paymentMode: paymentMode,
        paymentDate: paymentDate,
      );

      _log(
        '🟢 [bulkPay] '
        'result=$result',
      );

      // ==========================================================
      // 2. CAPTURE RECEIPT DATA
      // ==========================================================

      final receiptNumber =
          result['receiptNumber']
                  ?.toString() ??
              result['receipt_number']
                  ?.toString();

      final applied = _toDouble(
        result['appliedAmount'] ??
            result['applied_amount'] ??
            0,
      );

      _log(
        '🧾 [bulkPay] '
        'receipt=$receiptNumber '
        'applied=$applied',
      );

      // ==========================================================
      // 3. REFRESH ENROLLMENT
      // ==========================================================
      //
      // IMPORTANT:
      // Do NOT read balance before this refresh.
      //
      // The old code was doing:
      //
      // remainingBalance =
      //     _extractBulkRemainingBalance(result);
      //
      // before refreshing.
      //
      // That caused ₹0.00.
      //

      await loadEnrollmentDetail(
        enrollmentId,
      );

      // ==========================================================
      // 4. GET LATEST BALANCE
      // ==========================================================

      final latestSummary =
          summary.value;

      final remainingBalance =
          latestSummary?.balance ?? 0;

      _log(
        '💰 [bulkPay] '
        'latestTotalPaid='
        '${latestSummary?.totalPaid} '
        'latestTotalDue='
        '${latestSummary?.totalDue} '
        'remainingBalance='
        '$remainingBalance',
      );

      // ==========================================================
      // 5. FIND COVERED WEEKS
      // ==========================================================
      //
      // Backend may not return coveredWeeks directly.
      // So we use the freshly loaded payment history.
      //

      final coveredWeeks =
          _extractCoveredWeeksFromHistory(
        receiptNumber,
      );

      _log(
        '📅 [bulkPay] '
        'coveredWeeks=$coveredWeeks',
      );

      // ==========================================================
      // 6. STOP LOADING
      // ==========================================================

      isBulkPaying.value = false;

      // ==========================================================
      // 7. SHOW RECEIPT
      // ==========================================================

      _showPaymentReceipt(
        receiptNumber: receiptNumber,
        customerName: _customerName(),
        customerCode: _customerCode(),
        schemeName: _schemeName(),
        installmentLabel:
            'Advance / Bulk Payment',
        paidAmount: _formatAmount(
          applied > 0
              ? applied
              : totalAmount,
        ),
        paymentMode: paymentMode,
        paymentDate:
            paymentDate ??
            _formatDate(
              DateTime.now(),
            ),
        remainingBalance:
            _formatAmount(
          remainingBalance,
        ),
        coveredWeeks:
            coveredWeeks,
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [bulkPay] '
        'ERROR: $e\n$st',
      );

      _showError(e);

      return false;
    } finally {
      isBulkPaying.value = false;
    }
  }

  // ============================================================
  // PAYMENT RECEIPT
  // ============================================================

  void _showPaymentReceipt({
    String? receiptNumber,
    String? customerName,
    String? customerCode,
    String? schemeName,
    String? installmentLabel,
    String? paidAmount,
    String? paymentMode,
    String? paymentDate,
    String? remainingBalance,
    List<String>? coveredWeeks,
  }) {
    _log(
      '🧾 [receipt] '
      'receiptNumber=$receiptNumber '
      'paidAmount=$paidAmount '
      'remainingBalance=$remainingBalance '
      'coveredWeeks=$coveredWeeks',
    );

    // ==========================================================
    // CLOSE PAYMENT CONFIRM DIALOG
    // ==========================================================
    //
    // The payment dialog is still open when this method is called.
    //
    // If we push receipt on top of it, the view's Navigator.pop()
    // can accidentally close the receipt instead.
    //
    // So close the current payment dialog first.
    //

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Small delay ensures the previous dialog is completely
    // removed before opening the receipt dialog.
    Future.delayed(
  const Duration(milliseconds: 80),
  () {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: PaymentReceiptWidget(
                receiptNumber: receiptNumber,
                customerName: customerName,
                customerCode: customerCode,
                schemeName: schemeName,
                installmentLabel: installmentLabel,
                paidAmount: paidAmount,
                paymentMode: paymentMode,
                paymentDate: paymentDate,
                remainingBalance: remainingBalance,
                coveredWeeks: coveredWeeks,
              ),
            ),

            Positioned(
              right: 8,
              top: 8,
              child: Material(
                color: Colors.black,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  },
);
  }

  // ============================================================
  // PAYMENT TOTAL
  // ============================================================

  double _calculatePaymentTotal(
    List<Map<String, dynamic>> payments,
  ) {
    double total = 0;

    for (final payment in payments) {
      total += _toDouble(
        payment['amount'] ??
            payment['amountPaid'] ??
            payment['amount_paid'],
      );
    }

    return total;
  }

  // ============================================================
  // PAYMENT MODE
  // ============================================================

  String? _extractPaymentMode(
    List<Map<String, dynamic>> payments,
  ) {
    if (payments.isEmpty) {
      return null;
    }

    final modes = <String>{};

    for (final payment in payments) {
      final mode =
          payment['paymentMode'] ??
              payment['payment_mode'];

      if (mode != null &&
          mode
              .toString()
              .trim()
              .isNotEmpty) {
        modes.add(
          mode.toString(),
        );
      }
    }

    if (modes.isEmpty) {
      return null;
    }

    if (modes.length == 1) {
      return modes.first;
    }

    return modes.join(' + ');
  }

  // ============================================================
  // REMAINING BALANCE
  // ============================================================
  //
  // This helper is kept for compatibility if another part of
  // the controller needs it.
  //
  // Overall enrollment balance MUST come from summary.balance.
  //

  double _extractRemainingBalance(
    Map<String, dynamic> result,
    DiwaliEnrollmentWeekModel updatedWeek,
  ) {
    final direct =
        result['remainingBalance'] ??
            result['remaining_balance'];

    if (direct != null) {
      return _toDouble(
        direct,
      );
    }

    final weekBalance =
        _readDynamicProperty(
      updatedWeek,
      const [
        'remainingBalance',
        'remaining_balance',
      ],
    );

    if (weekBalance != null) {
      return _toDouble(
        weekBalance,
      );
    }

    return 0;
  }

  // ============================================================
  // COVERED WEEKS FROM RESULT
  // ============================================================

  List<String> _extractCoveredWeeks(
    Map<String, dynamic> result,
  ) {
    final dynamic raw =
        result['coveredWeeks'] ??
            result['covered_weeks'] ??
            result['weeksCovered'] ??
            result['weeks_covered'];

    if (raw is! List) {
      return [];
    }

    return raw.map<String>((item) {
      if (item is Map) {
        final week =
            item['weekNumber'] ??
                item['week_number'] ??
                item['week'];

        if (week != null) {
          return 'Week $week';
        }

        return item.toString();
      }

      final value =
          item.toString();

      return value.startsWith(
        'Week',
      )
          ? value
          : 'Week $value';
    }).toList();
  }

  // ============================================================
  // COVERED WEEKS FROM PAYMENT HISTORY
  // ============================================================
  //
  // Bulk payment uses one receipt number for multiple weeks.
  //
  // Example:
  //
  // SMC-26-27-000010
  //
  // Week 1 -> ₹1000
  // Week 2 -> ₹1000
  // Week 3 -> ₹500
  //
  // All rows have the same receipt_number.
  //
  // We read payment history after refresh and collect those weeks.
  //

  List<String> _extractCoveredWeeksFromHistory(
    String? receiptNumber,
  ) {
    if (receiptNumber == null ||
        receiptNumber.trim().isEmpty) {
      return [];
    }

    final weekNumbers = <int>{};

    for (final payment
        in paymentHistory) {
      final paymentReceipt =
          payment['receipt_number'] ??
              payment['receiptNumber'];

      if (paymentReceipt
              ?.toString() !=
          receiptNumber) {
        continue;
      }

      final rawWeek =
          payment['week_number'] ??
              payment['weekNumber'] ??
              payment['week'];

      final week =
          _toInt(rawWeek);

      if (week > 0) {
        weekNumbers.add(
          week,
        );
      }
    }

    final sortedWeeks =
        weekNumbers.toList()
          ..sort();

    return sortedWeeks
        .map(
          (week) => 'Week $week',
        )
        .toList();
  }

  // ============================================================
  // CUSTOMER NAME
  // ============================================================

  String? _customerName() {
    final enrollment =
        currentEnrollment.value;

    if (enrollment == null) {
      return null;
    }

    final dynamic value =
        _readDynamicProperty(
      enrollment,
      const [
        'customerName',
        'customer_name',
        'name',
      ],
    );

    return value?.toString();
  }

  // ============================================================
  // CUSTOMER CODE
  // ============================================================

  String? _customerCode() {
    final enrollment =
        currentEnrollment.value;

    if (enrollment == null) {
      return null;
    }

    final dynamic value =
        _readDynamicProperty(
      enrollment,
      const [
        'customerCode',
        'customer_code',
        'code',
      ],
    );

    return value?.toString();
  }

  // ============================================================
  // SCHEME NAME
  // ============================================================

  String? _schemeName() {
    final enrollment =
        currentEnrollment.value;

    if (enrollment == null) {
      return null;
    }

    final dynamic value =
        _readDynamicProperty(
      enrollment,
      const [
        'schemeName',
        'scheme_name',
      ],
    );

    return value?.toString();
  }

  // ============================================================
  // SAFE DYNAMIC PROPERTY
  // ============================================================

  dynamic _readDynamicProperty(
    dynamic object,
    List<String> names,
  ) {
    if (object == null) {
      return null;
    }

    for (final name in names) {
      try {
        if (object is Map) {
          if (object.containsKey(
            name,
          )) {
            return object[name];
          }
        }

        if (name == 'customerName') {
          try {
            return object.customerName;
          } catch (_) {}
        }

        if (name == 'customer_name') {
          try {
            return object.customer_name;
          } catch (_) {}
        }

        if (name == 'customerCode') {
          try {
            return object.customerCode;
          } catch (_) {}
        }

        if (name == 'customer_code') {
          try {
            return object.customer_code;
          } catch (_) {}
        }

        if (name == 'schemeName') {
          try {
            return object.schemeName;
          } catch (_) {}
        }

        if (name == 'scheme_name') {
          try {
            return object.scheme_name;
          } catch (_) {}
        }

        if (name == 'remainingBalance') {
          try {
            return object.remainingBalance;
          } catch (_) {}
        }

        if (name == 'remaining_balance') {
          try {
            return object.remaining_balance;
          } catch (_) {}
        }

        if (name == 'balance') {
          try {
            return object.balance;
          } catch (_) {}
        }

        if (name == 'totalDue') {
          try {
            return object.totalDue;
          } catch (_) {}
        }

        if (name == 'total_due') {
          try {
            return object.total_due;
          } catch (_) {}
        }

        if (name == 'dueAmount') {
          try {
            return object.dueAmount;
          } catch (_) {}
        }

        if (name == 'due_amount') {
          try {
            return object.due_amount;
          } catch (_) {}
        }
      } catch (_) {
        // Ignore unavailable optional property.
      }
    }

    return null;
  }

  // ============================================================
  // FORMAT AMOUNT
  // ============================================================

  String _formatAmount(
    double amount,
  ) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    return '$day-$month-${date.year}';
  }

  // ============================================================
  // PAYMENT HISTORY
  // ============================================================

  Future<void> loadPaymentHistory(
    int enrollmentId,
  ) async {
    _log(
      '🔵 [paymentHistory] '
      'enrollmentId=$enrollmentId',
    );

    isPaymentHistoryLoading.value =
        true;

    try {
      final result =
          await _repository
              .getPaymentHistory(
        enrollmentId,
      );

      _log(
        '🟢 [paymentHistory] '
        'count=${result.length}',
      );

      paymentHistory.assignAll(
        result,
      );
    } catch (e, st) {
      _log(
        '🔴 [paymentHistory] '
        'ERROR: $e\n$st',
      );

      _showError(e);
    } finally {
      isPaymentHistoryLoading.value =
          false;
    }
  }

  // ============================================================
  // VIEW OLD PAYMENT RECEIPT
  // ============================================================

  void viewPaymentReceipt(Map<String, dynamic> payment) {
    final receiptNumber =
        (payment['receipt_number'] ?? payment['receiptNumber'])
            ?.toString();

    if (receiptNumber == null ||
        receiptNumber.trim().isEmpty ||
        receiptNumber == 'null') {
      Get.snackbar(
        'Receipt Not Available',
        'Receipt number is not available for this payment.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // A bulk receipt may cover multiple weeks. Use every history row
    // with the same receipt number to rebuild the original receipt total.
    final matchingPayments = paymentHistory.where((item) {
      final itemReceipt =
          (item['receipt_number'] ?? item['receiptNumber'])?.toString();
      return itemReceipt == receiptNumber;
    }).toList();

    final rows = matchingPayments.isEmpty
        ? <Map<String, dynamic>>[payment]
        : matchingPayments;

    final totalAmount = rows.fold<double>(
      0,
      (sum, item) => sum + _toDouble(item['amount']),
    );

    final modes = <String>{};
    for (final item in rows) {
      final rawMode = item['payment_mode'] ?? item['paymentMode'];
      final mode = rawMode?.toString().trim();
      if (mode != null && mode.isNotEmpty && mode != 'null') {
        modes.add(mode);
      }
    }

    final paymentMode = modes.isEmpty ? '-' : modes.join(' + ');
    final coveredWeeks = _extractCoveredWeeksFromHistory(receiptNumber);

    final rawWeek = payment['week_number'] ??
        payment['weekNumber'] ??
        payment['week'];

    final installmentLabel = coveredWeeks.length > 1
        ? 'Advance / Bulk Payment'
        : coveredWeeks.length == 1
            ? coveredWeeks.first
            : rawWeek != null
                ? 'Week $rawWeek'
                : 'Payment';

    final rawDate =
        (payment['payment_date'] ?? payment['paymentDate'])?.toString();

    // Do not show today's balance as if it were the historical balance.
    // This field is used only if the API saved it with the payment row.
    final historicalBalance =
        payment['remaining_balance'] ?? payment['remainingBalance'];

    _showPaymentReceipt(
      receiptNumber: receiptNumber,
      customerName: _customerName(),
      customerCode: _customerCode(),
      schemeName: _schemeName(),
      installmentLabel: installmentLabel,
      paidAmount: _formatAmount(totalAmount),
      paymentMode: paymentMode,
      paymentDate: rawDate == null ||
              rawDate.isEmpty ||
              rawDate == 'null'
          ? '-'
          : rawDate,
      remainingBalance: historicalBalance == null
          ? '-'
          : _formatAmount(_toDouble(historicalBalance)),
      coveredWeeks: coveredWeeks.isEmpty ? null : coveredWeeks,
    );
  }

  // ============================================================
  // REVERT SINGLE PAYMENT
  // ============================================================

  Future<bool> revertPayment({
    required int enrollmentId,
    required int transactionId,
    String? reason,
  }) async {
    _log(
      '🔵 [revertPayment] '
      'enrollmentId=$enrollmentId '
      'txnId=$transactionId '
      'reason=$reason',
    );

    isRevertingPayment.value =
        true;

    try {
      final result =
          await _repository.revertPayment(
        transactionId: transactionId,
        reason: reason,
      );

      _log(
        '🟢 [revertPayment] '
        'result=$result',
      );

      await loadEnrollmentDetail(
        enrollmentId,
      );

      final amount = _toDouble(
        result['reversedAmount'] ??
            result['reversed_amount'],
      );

      Get.snackbar(
        'Payment Reverted',
        '₹${amount.toStringAsFixed(0)} '
            'payment reverted',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [revertPayment] '
        'ERROR: $e\n$st',
      );

      _showError(e);

      return false;
    } finally {
      isRevertingPayment.value =
          false;
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
    _log(
      '🔵 [revertGroup] '
      'enrollmentId=$enrollmentId '
      'groupId=$paymentGroupId '
      'reason=$reason',
    );

    isRevertingPaymentGroup.value =
        true;

    try {
      final result =
          await _repository
              .revertPaymentGroup(
        paymentGroupId:
            paymentGroupId,
        reason: reason,
      );

      _log(
        '🟢 [revertGroup] '
        'result=$result',
      );

      await loadEnrollmentDetail(
        enrollmentId,
      );

      final amount = _toDouble(
        result['totalReversed'] ??
            result['total_reversed'],
      );

      final count = _toInt(
        result['transactionCount'] ??
            result['transaction_count'],
      );

      Get.snackbar(
        'Payment Group Reverted',
        '$count payment(s) reverted • '
            '₹${amount.toStringAsFixed(0)}',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [revertGroup] '
        'ERROR: $e\n$st',
      );

      _showError(e);

      return false;
    } finally {
      isRevertingPaymentGroup.value =
          false;
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
    _log(
      '🔵 [modifyChits] '
      'enrollmentId=$enrollmentId '
      'fromWeek=$fromWeekNumber '
      'newChits=$newChits',
    );

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

    isModifyingChits.value =
        true;

    try {
      final result =
          await _repository.modifyChits(
        enrollmentId: enrollmentId,
        fromWeekNumber:
            fromWeekNumber,
        newChits: newChits,
      );

      _log(
        '🟢 [modifyChits] '
        'result=$result',
      );

      final updatedWeeks =
          result['weeks']
              as List<
                  DiwaliEnrollmentWeekModel>?;

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
      _log(
        '🔴 [modifyChits] '
        'ERROR: $e\n$st',
      );

      _showError(e);

      return false;
    } finally {
      isModifyingChits.value =
          false;
    }
  }

  // ============================================================
  // ADJUSTMENT LOGS
  // ============================================================

  Future<void> loadAdjustmentLogs(
    int enrollmentId,
  ) async {
    _log(
      '🔵 [adjustmentLogs] '
      'enrollmentId=$enrollmentId',
    );

    isAdjustmentLogsLoading.value =
        true;

    try {
      final result =
          await _repository
              .getAdjustmentLogs(
        enrollmentId,
      );

      _log(
        '🟢 [adjustmentLogs] '
        'count=${result.length}',
      );

      adjustmentLogs.assignAll(
        result,
      );
    } catch (e, st) {
      _log(
        '🔴 [adjustmentLogs] '
        'ERROR: $e\n$st',
      );

      _showError(e);
    } finally {
      isAdjustmentLogsLoading.value =
          false;
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    Object error,
  ) {
    _log(
      '🔴 [_showError] $error',
    );

    final message =
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );

    Get.snackbar(
      'Error',
      message,
      snackPosition:
          SnackPosition.BOTTOM,
      duration:
          const Duration(seconds: 3),
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