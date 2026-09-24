import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_installment_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_payment_model.dart';
import 'package:sri_murugan_chits/models/emi_scheme/emi_scheme_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';
import 'package:sri_murugan_chits/services/repositary/emi_entroll/emi_enrollment_repository.dart';

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

  /// Default status is Active.
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

  // Currently selected installment for payment UI
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

    // Load Active enrollments automatically.
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
        scheme.defaultWeeks.toString() ?? '';

    commissionValueController.text =
        scheme.defaultCommissionValue
                .toString() ??
            '';

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
      _log(
        '🔴 [EMI validate] customer not selected',
      );

      Get.snackbar(
        'Validation',
        'Please select a customer',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }

    if (selectedScheme.value == null) {
      _log(
        '🔴 [EMI validate] scheme not selected',
      );

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
      _log(
        '🔴 [EMI validate] invalid amount: $amount',
      );

      Get.snackbar(
        'Validation',
        'Enter a valid requested amount',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }

    _log(
      '🟢 [EMI validate] passed',
    );

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
        commissionValueController
            .text
            .trim(),
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

      _log(
        '🔵 [EMI createEnrollment] request => '
        'customerId=${selectedCustomer.value!.id} '
        'schemeId=${selectedScheme.value!.id} '
        'requestedAmount=$requestedAmount '
        'commissionType=${selectedCommissionType.value} '
        'commissionValue=$commissionValue '
        'weeks=$weeks '
        'startDate=$startDateStr',
      );

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

      _log(
        '⚪ [EMI createEnrollment] '
        'finished '
        'isSaving=${isSaving.value}',
      );
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearForm() {
    _log(
      '⚪ [EMI clearForm]',
    );

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

        status:
            selectedStatus.value,
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

      // ========================================================
      // PAGINATION
      // ========================================================

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

      // ========================================================
      // PAYMENT SUMMARY
      // ========================================================

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

      _log(
        '🔵 [EMI collect] '
        'installmentId=${installment.id} '
        'amount=$amount '
        'mode=$paymentMode '
        'status=$status',
      );

      final updated =
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
            paidDate ??
                DateTime.now()
                    .toIso8601String()
                    .split('T')
                    .first,
      );

      // --------------------------------------------------------
      // Update local schedule
      // --------------------------------------------------------

      _updateInstallment(
        updated,
      );

      // --------------------------------------------------------
      // Refresh payment summary
      // --------------------------------------------------------

      await loadPaymentHistory(
        installment.id!,
      );

      // --------------------------------------------------------
      // Refresh complete schedule
      // --------------------------------------------------------

      if (installment.enrollmentId !=
          null) {
        await loadEnrollmentSchedule(
          installment.enrollmentId!,
        );
      }

      Get.snackbar(
        'Success',
        'EMI payment collected successfully',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [EMI collect] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Payment Failed',
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
  // COLLECT SPLIT PAYMENT
  //
  // Example:
  //
  // Cash ₹400
  // UPI  ₹600
  //
  // payments:
  //
  // [
  //   {
  //     'amount': 400,
  //     'paymentMode': 'Cash',
  //   },
  //   {
  //     'amount': 600,
  //     'paymentMode': 'UPI',
  //   }
  // ]
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

      _log(
        '🔵 [EMI split payment] '
        'installmentId=${installment.id} '
        'payments=$payments '
        'status=$status',
      );

      final updated =
          await repository
              .collectSplitPayment(
        installmentId:
            installment.id!,
        status:
            status,
        payments:
            payments,
        paidDate:
            paidDate ??
                DateTime.now()
                    .toIso8601String()
                    .split('T')
                    .first,
      );

      // --------------------------------------------------------
      // Update local installment
      // --------------------------------------------------------

      _updateInstallment(
        updated,
      );

      // --------------------------------------------------------
      // Reload payment history
      // --------------------------------------------------------

      await loadPaymentHistory(
        installment.id!,
      );

      // --------------------------------------------------------
      // Reload complete schedule
      // --------------------------------------------------------

      if (installment.enrollmentId !=
          null) {
        await loadEnrollmentSchedule(
          installment.enrollmentId!,
        );
      }

      Get.snackbar(
        'Success',
        'Split payment collected successfully',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, st) {
      _log(
        '🔴 [EMI split payment] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Payment Failed',
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

      // --------------------------------------------------------
      // HISTORY
      // --------------------------------------------------------

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

      // --------------------------------------------------------
      // SUMMARY
      // --------------------------------------------------------

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
        paymentTotal.value =
            0;

        cashTotal.value =
            0;

        upiTotal.value =
            0;
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

      // --------------------------------------------------------
      // Reload history
      // --------------------------------------------------------

      await loadPaymentHistory(
        installmentId,
      );

      // --------------------------------------------------------
      // Reload schedule
      // --------------------------------------------------------

      final installment =
          installments.firstWhereOrNull(
        (item) =>
            item.id ==
            installmentId,
      );

      if (installment?.enrollmentId !=
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
  // CLEAR PAYMENT DATA
  // ============================================================

  void clearPaymentData() {
    paymentHistory.clear();

    paymentTotal.value =
        0;

    cashTotal.value =
        0;

    upiTotal.value =
        0;

    selectedInstallment.value =
        null;
  }

  // ============================================================
  // HELPER
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