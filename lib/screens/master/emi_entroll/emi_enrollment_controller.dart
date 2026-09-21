import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/models/emi_scheme/emi_scheme_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';
import 'package:sri_murugan_chits/services/repositary/emi_entroll/emi_enrollment_repository.dart';

class EmiEnrollmentController extends GetxController {
  final EnrollmentRepository repository = EnrollmentRepository();

  // ============================================================
  // CREATE ENROLLMENT
  // ============================================================

  final Rxn<CustomerModel> selectedCustomer =
      Rxn<CustomerModel>();

  final Rxn<EmiSchemeModel> selectedScheme =
      Rxn<EmiSchemeModel>();

  final amountController = TextEditingController();
  final weeksController = TextEditingController();
  final commissionValueController = TextEditingController();

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
      ''.obs;

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
      '⚪ [EMI onInit] controller initialised',
    );
  }

  // ============================================================
  // PICK CUSTOMER
  // ============================================================

  void pickCustomer(CustomerModel customer) {
    _log(
      '⚪ [EMI pickCustomer] id=${customer.id}',
    );

    selectedCustomer.value = customer;
  }

  // ============================================================
  // PICK SCHEME
  // ============================================================

  void pickScheme(EmiSchemeModel scheme) {
    _log(
      '⚪ [EMI pickScheme] '
      'id=${scheme.id} '
      'defaultWeeks=${scheme.defaultWeeks} '
      'defaultCommissionType=${scheme.defaultCommissionType} '
      'defaultCommissionValue=${scheme.defaultCommissionValue}',
    );

    selectedScheme.value = scheme;

    weeksController.text =
        scheme.defaultWeeks?.toString() ?? '';

    commissionValueController.text =
        scheme.defaultCommissionValue?.toString() ?? '';

    selectedCommissionType.value =
        scheme.defaultCommissionType ?? 'percent';
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
        snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    final amount =
        double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _log(
        '🔴 [EMI validate] invalid amount: $amount',
      );

      Get.snackbar(
        'Validation',
        'Enter a valid requested amount',
        snackPosition: SnackPosition.BOTTOM,
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
            selectedCustomer.value!.id!,
        schemeId:
            selectedScheme.value!.id!,
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
        '🟢 [EMI createEnrollment] response=$result',
      );

      // Refresh enrollment list
      await loadEnrollments();

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
        '🔴 [EMI createEnrollment] ERROR: $e\n$st',
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
        'finished isSaving=${isSaving.value}',
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

        // Repository expects String, not null
        customerId: '',
        schemeId: '',

        // Empty string means all statuses
        status: selectedStatus.value,
      );

      final rawEnrollments =
          result['enrollments'];

      List<EnrollmentModel> newItems =
          <EnrollmentModel>[];

      if (rawEnrollments
          is List<EnrollmentModel>) {
        newItems =
            rawEnrollments;
      } else if (rawEnrollments is List) {
        newItems = rawEnrollments
            .whereType<EnrollmentModel>()
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

      // --------------------------------------------------------
      // PAGINATION
      // --------------------------------------------------------

      final pagination =
          result['pagination'];

      if (pagination is Map) {
        totalRecords =
            _toInt(
                  pagination['total'],
                ) ??
                enrollments.length;

        totalPages =
            _toInt(
                  pagination['totalPages'],
                ) ??
                1;

        currentPage =
            _toInt(
                  pagination['page'],
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
        'totalPages=$totalPages',
      );
    } catch (e, st) {
      _log(
        '🔴 [EMI loadEnrollments] ERROR: $e\n$st',
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

    if (currentPage >= totalPages) {
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

  void onSearchChanged(String value) {
    searchText.value = value;
  }

  List<EnrollmentModel>
      get filteredEnrollments {
    final query =
        searchText.value
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return enrollments.toList();
    }

    return enrollments.where((item) {
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

      return customerName.contains(query) ||
          customerPhone.contains(query) ||
          schemeName.contains(query) ||
          enrollmentId.contains(query);
    }).toList();
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
    selectedStatus.value =
        status ?? '';

    await loadEnrollments();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshEnrollments() async {
    await loadEnrollments();
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
          await repository.getEnrollmentById(
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
        '🔴 [EMI detail] ERROR: $e\n$st',
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
  // CHANGE STATUS
  // ============================================================

  Future<bool> changeEnrollmentStatus({
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

      await loadEnrollments();

      if (selectedEnrollment.value?.id ==
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
        '🔴 [EMI status] ERROR: $e\n$st',
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
  // HELPERS
  // ============================================================

  int? _toInt(dynamic value) {
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
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _log(
      '⚪ [EMI onClose] controller disposed',
    );

    amountController.dispose();
    weeksController.dispose();
    commissionValueController.dispose();
    searchController.dispose();

    super.onClose();
  }
}