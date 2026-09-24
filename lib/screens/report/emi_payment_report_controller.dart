import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/models/emi_scheme/emi_scheme_model.dart';

import 'package:sri_murugan_chits/services/repositary/customer/customer_repositary.dart';
import 'package:sri_murugan_chits/services/repositary/emi_scheme/emi_scheme_repository.dart';
import 'package:sri_murugan_chits/services/repositary/report/emi_payment_report_repository.dart';

class EmiPaymentReportController extends GetxController {
  // ============================================================
  // REPOSITORIES
  // ============================================================

  final EmiPaymentReportRepository repository;

  final CustomerRepository customerRepository;

  final EmiSchemeRepository schemeRepository;

  EmiPaymentReportController(
    this.repository,
    this.customerRepository,
    this.schemeRepository,
  );

  // ============================================================
  // PAYMENT REPORT LIST
  // ============================================================

  final RxList<Map<String, dynamic>> payments =
      <Map<String, dynamic>>[].obs;

  // ============================================================
  // CUSTOMER LIST
  // ============================================================

  final RxList<CustomerModel> customers =
      <CustomerModel>[].obs;

  final RxBool customersLoading = false.obs;

  // ============================================================
  // SCHEME LIST
  // ============================================================

  final RxList<EmiSchemeModel> schemes =
      <EmiSchemeModel>[].obs;

  final RxBool schemesLoading = false.obs;

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

  final RxString status = 'Active'.obs;

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

    final today = _formatDate(
      DateTime.now(),
    );

    fromDate.value = today;

    toDate.value = today;

    // Load filters and report together.
    _initialize();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    await Future.wait([
      loadCustomers(),
      loadSchemes(),
    ]);

    await loadReport();
  }

  // ============================================================
  // LOAD CUSTOMERS
  // ============================================================

  Future<void> loadCustomers() async {
    try {
      customersLoading.value = true;

      _log(
        '🔵 [EMI REPORT] Loading customers...',
      );

      final result =
          await customerRepository.getCustomers(
        page: 1,
        limit: 100,
        search: '',
        status: 'Active',
      );

      final rawCustomers =
          result['customers'];

      final List<CustomerModel> loadedCustomers =
          <CustomerModel>[];

      if (rawCustomers is List) {
        for (final item in rawCustomers) {
          if (item is CustomerModel) {
            loadedCustomers.add(item);
          }
        }
      }

      customers.assignAll(
        loadedCustomers,
      );

      _log(
        '🟢 [EMI REPORT] '
        'Customers loaded: ${customers.length}',
      );
    } catch (e, st) {
      _log(
        '🔴 [EMI REPORT] '
        'Customer loading error: $e\n$st',
      );

      Get.snackbar(
        'Error',
        'Unable to load customers',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      customersLoading.value = false;
    }
  }

  // ============================================================
  // LOAD SCHEMES
  // ============================================================

  Future<void> loadSchemes() async {
    try {
      schemesLoading.value = true;

      _log(
        '🔵 [EMI REPORT] Loading schemes...',
      );

      final result =
          await schemeRepository.getSchemes(
        page: 1,
        limit: 100,
        search: '',
        status: 'Active',
      );

      final rawSchemes =
          result['schemes'];

      final List<EmiSchemeModel> loadedSchemes =
          <EmiSchemeModel>[];

      if (rawSchemes is List) {
        for (final item in rawSchemes) {
          if (item is EmiSchemeModel) {
            loadedSchemes.add(item);
          }
        }
      }

      schemes.assignAll(
        loadedSchemes,
      );

      _log(
        '🟢 [EMI REPORT] '
        'Schemes loaded: ${schemes.length}',
      );
    } catch (e, st) {
      _log(
        '🔴 [EMI REPORT] '
        'Scheme loading error: $e\n$st',
      );

      Get.snackbar(
        'Error',
        'Unable to load schemes',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      schemesLoading.value = false;
    }
  }

  // ============================================================
  // LOAD PAYMENT REPORT
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

      final result =
          await repository.getPaymentReport(
        page: currentPage.value,
        limit: pageLimit,
        fromDate: fromDate.value,
        toDate: toDate.value,
        customerId:
            selectedCustomerId.value,
        schemeId:
            selectedSchemeId.value,
        paymentMode:
            paymentMode.value,
        status:
            status.value,
      );

      // ========================================================
      // DATA
      // ========================================================

      final rawData =
          result['data'];

      final List<Map<String, dynamic>>
          newItems =
          <Map<String, dynamic>>[];

      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map) {
            newItems.add(
              Map<String, dynamic>.from(
                item,
              ),
            );
          }
        }
      }

      if (refresh) {
        payments.assignAll(
          newItems,
        );
      } else {
        payments.addAll(
          newItems,
        );
      }

      // ========================================================
      // SUMMARY
      // ========================================================

      final summary =
          result['summary'];

      if (summary is Map) {
        totalCollection.value =
            _toDouble(
          summary['totalCollection'],
        );

        cashTotal.value =
            _toDouble(
          summary['cashTotal'],
        );

        upiTotal.value =
            _toDouble(
          summary['upiTotal'],
        );

        reversedTotal.value =
            _toDouble(
          summary['reversedTotal'],
        );

        transactionCount.value =
            _toInt(
          summary['transactionCount'],
        );
      } else {
        clearSummary();
      }

      // ========================================================
      // PAGINATION
      // ========================================================

      final pagination =
          result['pagination'];

      if (pagination is Map) {
        totalRecords.value =
            _toInt(
          pagination['total'],
        );

        totalPages.value =
            _toInt(
          pagination['totalPages'],
        );

        currentPage.value =
            _toInt(
          pagination['page'],
        );
      } else {
        totalRecords.value =
            payments.length;

        totalPages.value = 1;
      }

      _log(
        '🟢 [EMI REPORT] '
        'loaded=${newItems.length} '
        'total=${payments.length} '
        'pages=${totalPages.value}',
      );
    } catch (e, st) {
      _log(
        '🔴 [EMI REPORT] '
        'ERROR: $e\n$st',
      );

      Get.snackbar(
        'Error',
        'Unable to load EMI payment report',
        snackPosition:
            SnackPosition.BOTTOM,
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
    if (loading.value ||
        loadingMore.value) {
      return;
    }

    if (currentPage.value >=
        totalPages.value) {
      return;
    }

    currentPage.value++;

    await loadReport(
      refresh: false,
    );
  }

  // ============================================================
  // APPLY FILTERS
  // ============================================================

  Future<void> applyFilters() async {
    await loadReport(
      refresh: true,
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  void setFromDate(
    DateTime date,
  ) {
    fromDate.value =
        _formatDate(date);
  }

  void setToDate(
    DateTime date,
  ) {
    toDate.value =
        _formatDate(date);
  }

  // ============================================================
  // CUSTOMER
  // ============================================================

  void setCustomer(
    String? id,
  ) {
    selectedCustomerId.value =
        id ?? '';
  }

  // ============================================================
  // SCHEME
  // ============================================================

  void setScheme(
    String? id,
  ) {
    selectedSchemeId.value =
        id ?? '';
  }

  // ============================================================
  // PAYMENT MODE
  // ============================================================

  void setPaymentMode(
    String? mode,
  ) {
    paymentMode.value =
        mode ?? '';
  }

  // ============================================================
  // STATUS
  // ============================================================

  void setStatus(
    String? newStatus,
  ) {
    status.value =
        newStatus ?? '';
  }

  // ============================================================
  // SELECTED CUSTOMER
  // ============================================================

  CustomerModel? get selectedCustomer {
    if (selectedCustomerId.value
        .trim()
        .isEmpty) {
      return null;
    }

    final int? id =
        int.tryParse(
      selectedCustomerId.value,
    );

    if (id == null) {
      return null;
    }

    for (final customer
        in customers) {
      if (customer.id == id) {
        return customer;
      }
    }

    return null;
  }

  // ============================================================
  // SELECTED SCHEME
  // ============================================================

  EmiSchemeModel? get selectedScheme {
    if (selectedSchemeId.value
        .trim()
        .isEmpty) {
      return null;
    }

    final int? id =
        int.tryParse(
      selectedSchemeId.value,
    );

    if (id == null) {
      return null;
    }

    for (final scheme
        in schemes) {
      if (scheme.id == id) {
        return scheme;
      }
    }

    return null;
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void> resetFilters() async {
    final today =
        _formatDate(
      DateTime.now(),
    );

    fromDate.value = today;

    toDate.value = today;

    selectedCustomerId.value =
        '';

    selectedSchemeId.value =
        '';

    paymentMode.value =
        '';

    status.value =
        'Active';

    await loadReport(
      refresh: true,
    );
  }

  // ============================================================
  // REFRESH FILTER DATA
  // ============================================================

  Future<void> refreshFilterData() async {
    await Future.wait([
      loadCustomers(),
      loadSchemes(),
    ]);
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

  double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  int _toInt(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  String _formatDate(
    DateTime date,
  ) {
    final year =
        date.year
            .toString()
            .padLeft(4, '0');

    final month =
        date.month
            .toString()
            .padLeft(2, '0');

    final day =
        date.day
            .toString()
            .padLeft(2, '0');

    return '$year-$month-$day';
  }

  void nextPage() {
  if (loading.value || loadingMore.value) {
    return;
  }

  if (currentPage.value >= totalPages.value) {
    return;
  }

  currentPage.value++;
  loadReport();
}

void previousPage() {
  if (loading.value || loadingMore.value) {
    return;
  }

  if (currentPage.value <= 1) {
    return;
  }

  currentPage.value--;
  loadReport();
}
}