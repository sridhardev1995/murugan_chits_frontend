import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_installment_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_payment_model.dart';
import 'package:sri_murugan_chits/models/emi_scheme/emi_scheme_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';

import 'package:sri_murugan_chits/services/repositary/emi_entroll/emi_enrollment_repository.dart';

import 'package:sri_murugan_chits/utils/global/payment_receipt_widget.dart';

class EmiEnrollmentController extends GetxController {
  final EnrollmentRepository repository =
      EnrollmentRepository();

  // ============================================================
  // CREATE ENROLLMENT
  // ============================================================

  final Rxn<CustomerModel> selectedCustomer =
      Rxn<CustomerModel>();

  final Rxn<EmiSchemeModel> selectedScheme =
      Rxn<EmiSchemeModel>();

  final amountController =
      TextEditingController();

  final weeksController =
      TextEditingController();

  final commissionValueController =
      TextEditingController();

  final RxString selectedCommissionType =
      'percent'.obs;

  final Rx<DateTime> startDate =
      DateTime.now().obs;

  final RxBool isSaving =
      false.obs;

  // ============================================================
  // EMI ENROLLMENT LIST
  // ============================================================

  final RxList<EnrollmentModel> enrollments =
      <EnrollmentModel>[].obs;

  final RxBool isLoading =
      false.obs;

  final RxBool isLoadingMore =
      false.obs;

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController searchController =
      TextEditingController();

  final RxString searchText =
      ''.obs;

  // ============================================================
  // STATUS FILTER
  // ============================================================

  final RxString selectedStatus =
      'Active'.obs;

  // ============================================================
  // PAGINATION
  // ============================================================

  int currentPage = 1;

  int totalPages = 1;

  int totalRecords = 0;

  final int pageLimit = 20;

  // ============================================================
  // DETAIL
  // ============================================================

  final Rxn<EnrollmentModel> selectedEnrollment =
      Rxn<EnrollmentModel>();

  final RxBool isDetailLoading =
      false.obs;

  // ============================================================
  // EMI SCHEDULE
  // ============================================================

  final RxList<EmiInstallmentModel> installments =
      <EmiInstallmentModel>[].obs;

  final RxMap<String, dynamic> emiSummary =
      <String, dynamic>{}.obs;

  final RxMap<String, dynamic> emiPaymentSummary =
      <String, dynamic>{}.obs;

  final RxBool isScheduleLoading =
      false.obs;

  // ============================================================
  // PAYMENT
  // ============================================================

  final RxBool isPaymentLoading =
      false.obs;

  final RxList<EmiPaymentModel> paymentHistory =
      <EmiPaymentModel>[].obs;

  final RxDouble paymentTotal =
      0.0.obs;

  final RxDouble cashTotal =
      0.0.obs;

  final RxDouble upiTotal =
      0.0.obs;

  final Rxn<EmiInstallmentModel>
      selectedInstallment =
      Rxn<EmiInstallmentModel>();

  // ============================================================
  // DEBUG LOG
  // ============================================================

  void _log(String msg) {
    if (kDebugMode) {
      debugPrint(msg);
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _log(
      '⚪ [EMI onInit] controller initialised '
      'selectedStatus=${selectedStatus.value}',
    );

    loadEnrollments();
  }

  // ============================================================
  // PICK CUSTOMER
  // ============================================================

  void pickCustomer(
    CustomerModel customer,
  ) {
    _log(
      '⚪ [EMI pickCustomer] id=${customer.id}',
    );

    selectedCustomer.value =
        customer;
  }

  // ============================================================
  // PICK SCHEME
  // ============================================================

  void pickScheme(
    EmiSchemeModel scheme,
  ) {
    _log(
      '⚪ [EMI pickScheme] '
      'id=${scheme.id} '
      'defaultWeeks=${scheme.defaultWeeks} '
      'defaultCommissionType=${scheme.defaultCommissionType} '
      'defaultCommissionValue=${scheme.defaultCommissionValue}',
    );

    selectedScheme.value =
        scheme;

    weeksController.text =
        scheme.defaultWeeks.toString();

    commissionValueController.text =
        scheme.defaultCommissionValue.toString();

    selectedCommissionType.value =
        scheme.defaultCommissionType ??
            'percent';
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validate() {
    _log(
      '🔵 [EMI validate] '
      'customer=${selectedCustomer.value?.id} '
      'scheme=${selectedScheme.value?.id} '
      'amount="${amountController.text.trim()}"',
    );

    if (selectedCustomer.value == null) {
      Get.snackbar(
        'Validation',
        'Please select a customer',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }

    if (selectedScheme.value == null) {
      Get.snackbar(
        'Validation',
        'Please select a scheme',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }

    final amount =
        double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      Get.snackbar(
        'Validation',
        'Enter a valid requested amount',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }

    return true;
  }

  // ============================================================
  // CREATE ENROLLMENT
  // ============================================================

  Future<void> createEnrollment() async {
    _log(
      '🔵 [EMI createEnrollment] started',
    );

    if (!_validate()) {
      return;
    }

    try {
      isSaving.value = true;

      final requestedAmount =
          double.parse(
        amountController.text.trim(),
      );

      final commissionValue =
          double.tryParse(
        commissionValueController.text.trim(),
      );

      final weeks =
          int.tryParse(
        weeksController.text.trim(),
      );

      final startDateStr =
          startDate.value
              .toIso8601String()
              .split('T')
              .first;

      final result =
          await repository.createEnrollment(
        customerId:
            selectedCustomer.value!.id,
        schemeId:
            selectedScheme.value!.id,
        requestedAmount:
            requestedAmount,
        commissionType:
            selectedCommissionType.value,
        commissionValue:
            commissionValue,
        weeks:
            weeks,
        startDate:
            startDateStr,
      );

      _log(
        '🟢 [EMI createEnrollment] '
        'response=$result',
      );

      await loadEnrollments(
        refresh: true,
      );

      Get.back();

      clearForm();

      Get.snackbar(
        'Success',
        'Customer enrolled successfully',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      _log(
        '🔴 [EMI createEnrollment] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Error',
        'Unable to create enrollment',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearForm() {
    selectedCustomer.value = null;

    selectedScheme.value = null;

    amountController.clear();

    weeksController.clear();

    commissionValueController.clear();

    selectedCommissionType.value =
        'percent';

    startDate.value =
        DateTime.now();
  }

  // ============================================================
  // LOAD ENROLLMENTS
  // ============================================================

  Future<void> loadEnrollments({
    bool refresh = true,
  }) async {
    try {
      if (refresh) {
        isLoading.value = true;
        currentPage = 1;
      } else {
        isLoadingMore.value = true;
      }

      _log(
        '🔵 [EMI loadEnrollments] '
        'page=$currentPage '
        'limit=$pageLimit '
        'status=${selectedStatus.value}',
      );

      final result =
          await repository.getEnrollments(
        page: currentPage,
        limit: pageLimit,
        customerId: '',
        schemeId: '',
        status: selectedStatus.value,
      );

      final rawEnrollments =
          result['enrollments'];

      List<EnrollmentModel>
          newItems =
          <EnrollmentModel>[];

      if (rawEnrollments
          is List<EnrollmentModel>) {
        newItems =
            rawEnrollments;
      } else if (rawEnrollments
          is List) {
        newItems =
            rawEnrollments
                .whereType<
                    EnrollmentModel>()
                .toList();
      }

      if (refresh) {
        enrollments.assignAll(
          newItems,
        );
      } else {
        enrollments.addAll(
          newItems,
        );
      }

      final pagination =
          result['pagination'];

      if (pagination is Map) {
        totalRecords =
            _toInt(
                  pagination[
                      'total'],
                ) ??
                enrollments.length;

        totalPages =
            _toInt(
                  pagination[
                      'totalPages'],
                ) ??
                1;

        currentPage =
            _toInt(
                  pagination[
                      'page'],
                ) ??
                currentPage;
      } else {
        totalRecords =
            enrollments.length;

        totalPages = 1;
      }

      _log(
        '🟢 [EMI loadEnrollments] '
        'loaded=${newItems.length} '
        'total=${enrollments.length} '
        'totalRecords=$totalRecords '
        'currentPage=$currentPage '
        'totalPages=$totalPages '
        'status=${selectedStatus.value}',
      );
    } catch (e, st) {
      _log(
        '🔴 [EMI loadEnrollments] '
        'ERROR: $e\n$st',
      );

      if (refresh) {
        Get.snackbar(
          'Error',
          'Unable to load EMI enrollments',
          snackPosition:
              SnackPosition.BOTTOM,
        );
      }
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

    if (currentPage >=
        totalPages) {
      return;
    }

    currentPage++;

    await loadEnrollments(
      refresh: false,
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void onSearchChanged(
    String value,
  ) {
    searchText.value =
        value;
  }

  // ============================================================
  // FILTERED ENROLLMENTS
  // ============================================================

  List<EnrollmentModel>
      get filteredEnrollments {
    final query =
        searchText.value
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return enrollments.toList();
    }

    return enrollments.where(
      (item) {
        final customerName =
            item.customerName
                    ?.toLowerCase() ??
                '';

        final customerPhone =
            item.customerPhone
                    ?.toLowerCase() ??
                '';

        final schemeName =
            item.schemeName
                    ?.toLowerCase() ??
                '';

        final enrollmentId =
            item.id
                    ?.toString()
                    .toLowerCase() ??
                '';

        return customerName
                .contains(query) ||
            customerPhone
                .contains(query) ||
            schemeName
                .contains(query) ||
            enrollmentId
                .contains(query);
      },
    ).toList();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void clearSearch() {
    searchController.clear();

    searchText.value = '';
  }

  // ============================================================
  // STATUS FILTER
  // ============================================================

  Future<void> changeStatus(
    String? status,
  ) async {
    final newStatus =
        status ?? '';

    _log(
      '🔵 [EMI changeStatus] '
      'old=${selectedStatus.value} '
      'new=$newStatus',
    );

    selectedStatus.value =
        newStatus;

    await loadEnrollments(
      refresh: true,
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void>
      refreshEnrollments() async {
    await loadEnrollments(
      refresh: true,
    );
  }

  // ============================================================
  // LOAD SINGLE ENROLLMENT
  // ============================================================

  Future<EnrollmentModel?>
      loadEnrollmentDetail(
    int enrollmentId,
  ) async {
    try {
      isDetailLoading.value =
          true;

      _log(
        '🔵 [EMI detail] '
        'loading enrollmentId=$enrollmentId',
      );

      final enrollment =
          await repository
              .getEnrollmentById(
        enrollmentId,
      );

      selectedEnrollment.value =
          enrollment;

      _log(
        '🟢 [EMI detail] '
        'loaded enrollmentId=$enrollmentId',
      );

      return enrollment;
    } catch (e, st) {
      _log(
        '🔴 [EMI detail] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Error',
        'Unable to load enrollment details',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return null;
    } finally {
      isDetailLoading.value =
          false;
    }
  }

  // ============================================================
  // CHANGE ENROLLMENT STATUS
  // ============================================================

  Future<bool>
      changeEnrollmentStatus({
    required int enrollmentId,
    required String status,
  }) async {
    try {
      _log(
        '🔵 [EMI status] '
        'id=$enrollmentId '
        'status=$status',
      );

      await repository.changeStatus(
        id: enrollmentId,
        status: status,
      );

      await loadEnrollments(
        refresh: true,
      );

      if (selectedEnrollment
              .value
              ?.id ==
          enrollmentId) {
        await loadEnrollmentDetail(
          enrollmentId,
        );
      }

      Get.snackbar(
        'Success',
        'Enrollment marked as $status',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [EMI status] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Error',
        'Unable to update enrollment status',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }
  }

  // ============================================================
  // LOAD EMI SCHEDULE
  // ============================================================

  Future<void>
      loadEnrollmentSchedule(
    int enrollmentId,
  ) async {
    try {
      isScheduleLoading.value =
          true;

      final result =
          await repository
              .getEnrollmentSchedule(
        enrollmentId,
      );

      final schedule =
          result['schedule'];

      if (schedule
          is List<EmiInstallmentModel>) {
        installments.assignAll(
          schedule,
        );
      } else if (schedule
          is List) {
        installments.assignAll(
          schedule
              .whereType<
                  EmiInstallmentModel>()
              .toList(),
        );
      } else {
        installments.clear();
      }

      final summary =
          result['summary'];

      if (summary is Map) {
        emiSummary.assignAll(
          Map<String, dynamic>.from(
            summary,
          ),
        );
      } else {
        emiSummary.clear();
      }

      final paymentSummary =
          result['paymentSummary'];

      if (paymentSummary
          is Map) {
        emiPaymentSummary
            .assignAll(
          Map<String, dynamic>.from(
            paymentSummary,
          ),
        );
      } else {
        emiPaymentSummary.clear();
      }
    } catch (e, st) {
      _log(
        '🔴 [EMI schedule] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Error',
        'Unable to load EMI schedule',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    } finally {
      isScheduleLoading.value =
          false;
    }
  }

  // ============================================================
  // SELECT INSTALLMENT
  // ============================================================

  void selectInstallment(
    EmiInstallmentModel installment,
  ) {
    selectedInstallment.value =
        installment;

    _log(
      '⚪ [EMI payment] '
      'selected installment=${installment.id}',
    );
  }

  // ============================================================
  // COLLECT SINGLE EMI PAYMENT
  //
  // Supports:
  // - Cash
  // - UPI
  // - Partial
  // - Paid
  //
  // NEW:
  // - Receipt number
  // - Receipt popup
  // - Remaining balance
  // ============================================================

  Future<bool>
      collectInstallment({
    required EmiInstallmentModel
        installment,
    required double amount,
    required String status,
    required String paymentMode,
    String? paidDate,
  }) async {
    try {
      if (installment.id == null) {
        throw Exception(
          'Invalid EMI installment',
        );
      }

      if (amount <= 0) {
        throw Exception(
          'Enter a valid payment amount',
        );
      }

      if (![
        'Cash',
        'UPI',
      ].contains(paymentMode)) {
        throw Exception(
          'Payment mode must be Cash or UPI',
        );
      }

      isPaymentLoading.value =
          true;

      final actualPaymentDate =
          paidDate ??
              DateTime.now()
                  .toIso8601String()
                  .split('T')
                  .first;

      _log(
        '🔵 [EMI collect] '
        'installmentId=${installment.id} '
        'amount=$amount '
        'mode=$paymentMode '
        'status=$status',
      );

      // ========================================================
      // API PAYMENT
      // ========================================================

      final result =
          await repository
              .collectInstallment(
        installmentId:
            installment.id!,
        status:
            status,
        amount:
            amount,
        paymentMode:
            paymentMode,
        paidDate:
            actualPaymentDate,
      );

      _log(
        '🟢 [EMI collect] '
        'result=$result',
      );

      // ========================================================
      // GET UPDATED INSTALLMENT
      // ========================================================

      final updated =
          result['installment'];

      if (updated
          is EmiInstallmentModel) {
        _updateInstallment(
          updated,
        );
      }

      // ========================================================
      // RECEIPT NUMBER
      // ========================================================

      final receiptNumber =
          result['receiptNumber']
                  ?.toString() ??
              result['receipt_number']
                  ?.toString();

      _log(
        '🧾 [EMI collect] '
        'receiptNumber=$receiptNumber',
      );

      // ========================================================
      // PAID AMOUNT
      // ========================================================

      final paidAmount =
          _toDouble(
                result['paidAmount'] ??
                    result['paid_amount'],
              ) ??
              amount;

      // ========================================================
      // REFRESH PAYMENT HISTORY
      // ========================================================

      await loadPaymentHistory(
        installment.id!,
      );

      // ========================================================
      // REFRESH COMPLETE SCHEDULE
      // ========================================================

      if (installment.enrollmentId !=
          null) {
        await loadEnrollmentSchedule(
          installment.enrollmentId!,
        );

        // Refresh enrollment also.
        await loadEnrollmentDetail(
          installment.enrollmentId!,
        );
      }

      // ========================================================
      // GET LATEST REMAINING BALANCE
      // ========================================================

      final remainingBalance =
          _extractEnrollmentBalance();

      _log(
        '💰 [EMI collect] '
        'remainingBalance=$remainingBalance',
      );

      // ========================================================
      // RECEIPT
      // ========================================================

      _showPaymentReceipt(
        receiptNumber:
            receiptNumber,
        customerName:
            _customerName(),
        customerCode:
            _customerCode(),
        schemeName:
            _schemeName(),
        installmentLabel:
            'Week ${installment.weekNo ?? '-'}',
        paidAmount:
            _formatAmount(
          paidAmount,
        ),
        paymentMode:
            paymentMode,
        paymentDate:
            _formatPaymentDate(
          actualPaymentDate,
        ),
        remainingBalance:
            _formatAmount(
          remainingBalance,
        ),
        coveredWeeks: [
          'Week ${installment.weekNo ?? '-'}',
        ],
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [EMI collect] '
        'ERROR: $e\n$st',
      );

      _showPaymentError(e);

      return false;
    } finally {
      isPaymentLoading.value =
          false;
    }
  }

  // ============================================================
  // COLLECT SPLIT PAYMENT
  //
  // Example:
  //
  // Cash ₹400
  // UPI  ₹600
  //
  // One receipt number is generated
  // for the complete split payment.
  // ============================================================

  Future<bool>
      collectSplitPayment({
    required EmiInstallmentModel
        installment,
    required List<
            Map<String, dynamic>>
        payments,
    required String status,
    String? paidDate,
  }) async {
    try {
      if (installment.id == null) {
        throw Exception(
          'Invalid EMI installment',
        );
      }

      if (payments.isEmpty) {
        throw Exception(
          'At least one payment is required',
        );
      }

      for (final payment
          in payments) {
        final amount =
            double.tryParse(
                  payment['amount']
                          ?.toString() ??
                      '0',
                ) ??
                0;

        final mode =
            payment['paymentMode']
                ?.toString();

        if (amount <= 0) {
          throw Exception(
            'Payment amount must be greater than zero',
          );
        }

        if (![
          'Cash',
          'UPI',
        ].contains(mode)) {
          throw Exception(
            'Payment mode must be Cash or UPI',
          );
        }
      }

      isPaymentLoading.value =
          true;

      final actualPaymentDate =
          paidDate ??
              DateTime.now()
                  .toIso8601String()
                  .split('T')
                  .first;

      _log(
        '🔵 [EMI split payment] '
        'installmentId=${installment.id} '
        'payments=$payments '
        'status=$status',
      );

      // ========================================================
      // API PAYMENT
      // ========================================================

      final result =
          await repository
              .collectSplitPayment(
        installmentId:
            installment.id!,
        status:
            status,
        payments:
            payments,
        paidDate:
            actualPaymentDate,
      );

      _log(
        '🟢 [EMI split payment] '
        'result=$result',
      );

      // ========================================================
      // UPDATED INSTALLMENT
      // ========================================================

      final updated =
          result['installment'];

      if (updated
          is EmiInstallmentModel) {
        _updateInstallment(
          updated,
        );
      }

      // ========================================================
      // RECEIPT NUMBER
      // ========================================================

      final receiptNumber =
          result['receiptNumber']
                  ?.toString() ??
              result['receipt_number']
                  ?.toString();

      // ========================================================
      // PAID AMOUNT
      // ========================================================

      final paidAmount =
          _toDouble(
                result['paidAmount'] ??
                    result['paid_amount'],
              ) ??
              _calculatePaymentTotal(
                payments,
              );

      // ========================================================
      // PAYMENT MODE
      // ========================================================

      final displayPaymentMode =
          _extractPaymentMode(
        payments,
      );

      // ========================================================
      // REFRESH HISTORY
      // ========================================================

      await loadPaymentHistory(
        installment.id!,
      );

      // ========================================================
      // REFRESH SCHEDULE + ENROLLMENT
      // ========================================================

      if (installment.enrollmentId !=
          null) {
        await loadEnrollmentSchedule(
          installment.enrollmentId!,
        );

        await loadEnrollmentDetail(
          installment.enrollmentId!,
        );
      }

      // ========================================================
      // REMAINING BALANCE
      // ========================================================

      final remainingBalance =
          _extractEnrollmentBalance();

      // ========================================================
      // RECEIPT
      // ========================================================

      _showPaymentReceipt(
        receiptNumber:
            receiptNumber,
        customerName:
            _customerName(),
        customerCode:
            _customerCode(),
        schemeName:
            _schemeName(),
        installmentLabel:
            'Week ${installment.weekNo ?? '-'}',
        paidAmount:
            _formatAmount(
          paidAmount,
        ),
        paymentMode:
            displayPaymentMode,
        paymentDate:
            _formatPaymentDate(
          actualPaymentDate,
        ),
        remainingBalance:
            _formatAmount(
          remainingBalance,
        ),
        coveredWeeks: [
          'Week ${installment.weekNo ?? '-'}',
        ],
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [EMI split payment] '
        'ERROR: $e\n$st',
      );

      _showPaymentError(e);

      return false;
    } finally {
      isPaymentLoading.value =
          false;
    }
  }

  // ============================================================
  // UPDATE INSTALLMENT LOCALLY
  // ============================================================

  void _updateInstallment(
    EmiInstallmentModel updated,
  ) {
    final index =
        installments.indexWhere(
      (item) =>
          item.id == updated.id,
    );

    if (index != -1) {
      installments[index] =
          updated;

      installments.refresh();
    }
  }

  // ============================================================
  // LOAD PAYMENT HISTORY
  // ============================================================

  Future<void>
      loadPaymentHistory(
    int installmentId,
  ) async {
    try {
      isPaymentLoading.value =
          true;

      _log(
        '🔵 [EMI payment history] '
        'installmentId=$installmentId',
      );

      final result =
          await repository
              .getPaymentHistory(
        installmentId,
      );

      // ========================================================
      // HISTORY
      // ========================================================

      final history =
          result['history'];

      if (history is List) {
        paymentHistory.assignAll(
          history
              .map(
                (item) =>
                    EmiPaymentModel
                        .fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              )
              .toList(),
        );
      } else {
        paymentHistory.clear();
      }

      // ========================================================
      // SUMMARY
      // ========================================================

      final summary =
          result['summary'];

      if (summary is Map) {
        paymentTotal.value =
            _toDouble(
                  summary[
                      'totalPaid'],
                ) ??
                0;

        cashTotal.value =
            _toDouble(
                  summary[
                      'cashTotal'],
                ) ??
                0;

        upiTotal.value =
            _toDouble(
                  summary[
                      'upiTotal'],
                ) ??
                0;
      } else {
        paymentTotal.value = 0;
        cashTotal.value = 0;
        upiTotal.value = 0;
      }

      _log(
        '🟢 [EMI payment history] '
        'count=${paymentHistory.length} '
        'total=${paymentTotal.value} '
        'cash=${cashTotal.value} '
        'upi=${upiTotal.value}',
      );
    } catch (e, st) {
      _log(
        '🔴 [EMI payment history] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Error',
        'Unable to load payment history',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    } finally {
      isPaymentLoading.value =
          false;
    }
  }

  // ============================================================
  // REVERSE PAYMENT
  //
  // IMPORTANT:
  // paymentId = emi_payment_transactions.id
  //
  // NOT installmentId.
  // ============================================================

  Future<bool>
      reversePayment({
    required int paymentId,
    required int installmentId,
    String? reason,
  }) async {
    try {
      isPaymentLoading.value =
          true;

      _log(
        '🔵 [EMI reverse payment] '
        'paymentId=$paymentId '
        'installmentId=$installmentId',
      );

      await repository.reversePayment(
        paymentId:
            paymentId,
        reason:
            reason ??
                'Payment reversed by admin',
      );

      // ========================================================
      // RELOAD HISTORY
      // ========================================================

      await loadPaymentHistory(
        installmentId,
      );

      // ========================================================
      // RELOAD SCHEDULE
      // ========================================================

      EmiInstallmentModel?
          installment;

      for (final item
          in installments) {
        if (item.id ==
            installmentId) {
          installment = item;
          break;
        }
      }

      if (installment
              ?.enrollmentId !=
          null) {
        await loadEnrollmentSchedule(
          installment!
              .enrollmentId!,
        );
      }

      Get.snackbar(
        'Success',
        'Payment reversed successfully',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [EMI reverse payment] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Reverse Failed',
        e.toString(),
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isPaymentLoading.value =
          false;
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
    '🧾 [EMI receipt] '
    'receiptNumber=$receiptNumber '
    'paidAmount=$paidAmount '
    'remainingBalance=$remainingBalance',
  );

  // Close payment confirmation dialog
  if (Get.isDialogOpen ?? false) {
    Get.back();
  }

  Future.delayed(
    const Duration(milliseconds: 100),
    () {
      Get.dialog(
        Dialog(
          backgroundColor:
              Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: PaymentReceiptWidget(
                  receiptNumber:
                      receiptNumber,
                  customerName:
                      customerName,
                  customerCode:
                      customerCode,
                  schemeName:
                      schemeName,
                  installmentLabel:
                      installmentLabel,
                  paidAmount:
                      paidAmount,
                  paymentMode:
                      paymentMode,
                  paymentDate:
                      paymentDate,
                  remainingBalance:
                      remainingBalance,
                  coveredWeeks:
                      coveredWeeks,
                  companyName:
                      'Sri Murugan Chits',
                  logoAssetPath:
                      'assets/images/logo.png',
                ),
              ),

              Positioned(
                right: 8,
                top: 8,
                child: Material(
                  color: Colors.black,
                  shape:
                      const CircleBorder(),
                  child: InkWell(
                    customBorder:
                        const CircleBorder(),
                    onTap: () {
                      if (Get.isDialogOpen ??
                          false) {
                        Get.back();
                      }
                    },
                    child:
                        const Padding(
                      padding:
                          EdgeInsets.all(7),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color:
                            Colors.white,
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
    List<Map<String, dynamic>>
        payments,
  ) {
    double total = 0;

    for (final payment
        in payments) {
      total += _toDouble(
            payment['amount'] ??
                payment['amountPaid'] ??
                payment['amount_paid'],
          ) ??
          0;
    }

    return total;
  }

  // ============================================================
  // PAYMENT MODE
  // ============================================================

  String? _extractPaymentMode(
    List<Map<String, dynamic>>
        payments,
  ) {
    if (payments.isEmpty) {
      return null;
    }

    final modes =
        <String>{};

    for (final payment
        in payments) {
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
  // CUSTOMER NAME
  // ============================================================

  String? _customerName() {
    final enrollment =
        selectedEnrollment.value;

    if (enrollment == null) {
      return null;
    }

    return enrollment.customerName;
  }

  // ============================================================
  // CUSTOMER CODE
  // ============================================================
  //
  // EMI enrollment model currently exposes customerId.
  // We use that as the receipt customer reference.
  // ============================================================

  String? _customerCode() {
    final enrollment =
        selectedEnrollment.value;

    if (enrollment == null) {
      return null;
    }

    final customerId =
        enrollment.customerId;

    if (customerId == null) {
      return null;
    }

    return customerId.toString();
  }

  // ============================================================
  // SCHEME NAME
  // ============================================================

  String? _schemeName() {
    final enrollment =
        selectedEnrollment.value;

    if (enrollment == null) {
      return null;
    }

    return enrollment.schemeName;
  }

  // ============================================================
  // REMAINING ENROLLMENT BALANCE
  // ============================================================

  double _extractEnrollmentBalance() {
    // ----------------------------------------------------------
    // First preference:
    // summary.balance
    // ----------------------------------------------------------

    final directBalance =
        _toDouble(
      emiSummary['balance'],
    );

    if (directBalance !=
        null) {
      return directBalance;
    }

    // ----------------------------------------------------------
    // Alternative backend names
    // ----------------------------------------------------------

    final remainingBalance =
        _toDouble(
      emiSummary[
          'remainingBalance'],
    );

    if (remainingBalance !=
        null) {
      return remainingBalance;
    }

    final remainingBalanceSnake =
        _toDouble(
      emiSummary[
          'remaining_balance'],
    );

    if (remainingBalanceSnake !=
        null) {
      return remainingBalanceSnake;
    }

    final pendingAmount =
        _toDouble(
      emiSummary[
          'pendingAmount'],
    );

    if (pendingAmount !=
        null) {
      return pendingAmount;
    }

    final pendingAmountSnake =
        _toDouble(
      emiSummary[
          'pending_amount'],
    );

    if (pendingAmountSnake !=
        null) {
      return pendingAmountSnake;
    }

    // ----------------------------------------------------------
    // Fallback:
    // Sum remaining balance of schedule
    // ----------------------------------------------------------

    if (installments.isNotEmpty) {
      return installments.fold<double>(
        0,
        (sum, item) =>
            sum + item.balance,
      );
    }

    return 0;
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
  // FORMAT PAYMENT DATE
  // ============================================================

  String _formatPaymentDate(
    String date,
  ) {
    try {
      final parsed =
          DateTime.parse(date);

      final day =
          parsed.day
              .toString()
              .padLeft(
                2,
                '0',
              );

      final month =
          parsed.month
              .toString()
              .padLeft(
                2,
                '0',
              );

      return '$day-$month-${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // PAYMENT ERROR
  // ============================================================

  void _showPaymentError(
    dynamic error,
  ) {
    String message =
        error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      message =
          message.substring(
        'Exception: '.length,
      );
    }

    Get.snackbar(
      'Payment Failed',
      message,
      snackPosition:
          SnackPosition.BOTTOM,
    );
  }

  // ============================================================
  // CLEAR PAYMENT DATA
  // ============================================================

  void clearPaymentData() {
    paymentHistory.clear();

    paymentTotal.value = 0;

    cashTotal.value = 0;

    upiTotal.value = 0;

    selectedInstallment.value =
        null;
  }

  // ============================================================
  // INTEGER HELPER
  // ============================================================

  int? _toInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // DOUBLE HELPER
  // ============================================================

  double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _log(
      '⚪ [EMI onClose] '
      'controller disposed',
    );

    amountController.dispose();

    weeksController.dispose();

    commissionValueController.dispose();

    searchController.dispose();

    super.onClose();
  }
}