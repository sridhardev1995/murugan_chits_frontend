import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/services/repositary/customer/customer_repositary.dart';

class CustomerController extends GetxController {
  final CustomerRepository _repository;

  CustomerController(this._repository);

  // ==========================================================
  // STATE
  // ==========================================================

  final customers = <CustomerModel>[].obs;

  final isLoading = false.obs; // full-list loading (first page / refresh)
  final isLoadingMore = false.obs; // pagination loading
  final isSaving = false.obs; // create / update in-flight

  final statusFilter = ''.obs; // '', 'Active', 'Inactive'

  final searchController = TextEditingController();
  final scrollController = ScrollController();

  final page = 1.obs;
  final totalPages = 1.obs;
  static const int _limit = 20;

  Timer? _debounce;

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void onInit() {
    super.onInit();
    fetchCustomers(reset: true);
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final nearBottom =
        scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200;
    if (nearBottom) loadMore();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchCustomers(reset: true);
    });
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  void setStatusFilter(String status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    fetchCustomers(reset: true);
  }

  void clearSearch() {
    searchController.clear();
    fetchCustomers(reset: true);
  }

  // ==========================================================
  // FETCH / PAGINATION
  // ==========================================================

  Future<void> fetchCustomers({bool reset = false}) async {
    try {
      if (reset) {
        page.value = 1;
        isLoading.value = true;
      }

      final result = await _repository.getCustomers(
        page: page.value,
        limit: _limit,
        search: searchController.text.trim(),
        status: statusFilter.value,
      );

      final List<CustomerModel> fetched = result['customers'];
      final pagination = result['pagination'] as Map<String, dynamic>? ?? {};
      totalPages.value = (pagination['totalPages'] as num?)?.toInt() ?? 1;

      if (reset) {
        customers.assignAll(fetched);
      } else {
        customers.addAll(fetched);
      }
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value) return;
    if (page.value >= totalPages.value) return;

    isLoadingMore.value = true;
    page.value++;
    await fetchCustomers();
  }

  Future<void> refreshCustomers() => fetchCustomers(reset: true);

  // ==========================================================
  // CREATE / UPDATE
  // ==========================================================

  /// Returns true on success so the form screen can pop itself.
     Future<bool> saveCustomer(Map<String, dynamic> body, {int? id}) async {
    isSaving.value = true;
    bool result = false;

    try {
      debugPrint('[saveCustomer] START id=$id body=$body');

      if (id == null) {
        final res = await _repository.createCustomer(body);
        debugPrint('[saveCustomer] createCustomer response: $res');
      } else {
        final res = await _repository.updateCustomer(id, body);
        debugPrint('[saveCustomer] updateCustomer response: $res');
      }

      result = true;
    } catch (e, st) {
      debugPrint('[saveCustomer] ERROR: $e');
      debugPrint('[saveCustomer] STACK: $st');
      result = false;
      _showError(e); // ❌ failure ah irundha mattum screen-laye kaattanum, so ok
    } finally {
      isSaving.value = false;
    }

    if (result) {
      // background refresh mattum, NO snackbar here anymore
      fetchCustomers(reset: true);
    }

    debugPrint('[saveCustomer] RETURNING $result');
    return result;
  }
  // ==========================================================
  // STATUS TOGGLE
  // ==========================================================

  Future<void> toggleStatus(CustomerModel customer) async {
    final newStatus = customer.status == 'Active' ? 'Inactive' : 'Active';
    final index = customers.indexWhere((c) => c.id == customer.id);
    if (index == -1) return;

    // optimistic update
    customers[index] = customer.copyWith(status: newStatus);

    try {
      await _repository.changeStatus(customer.id, newStatus);
    } catch (e) {
      // revert on failure
      customers[index] = customer;
      _showError(e);
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> confirmAndDelete(CustomerModel customer) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete customer?'),
        content: Text(
          'This will permanently remove "${customer.name}". This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteCustomer(customer);
    }
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    try {
      await _repository.deleteCustomer(customer.id);
      customers.removeWhere((c) => c.id == customer.id);
      Get.snackbar(
        'Deleted',
        '${customer.name} was removed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Backend suggests marking Inactive if delete is blocked by FK constraints
      _showError(
        e,
        actionLabel: 'Mark Inactive',
        onAction: () {
          toggleStatus(customer.copyWith(status: 'Active'));
        },
      );
    }
  }

  void _showError(Object e, {String? actionLabel, VoidCallback? onAction}) {
    Get.snackbar(
      'Error',
      e.toString().replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      mainButton: actionLabel != null && onAction != null
          ? TextButton(
              onPressed: () {
                Get.closeCurrentSnackbar();
                onAction();
              },
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
