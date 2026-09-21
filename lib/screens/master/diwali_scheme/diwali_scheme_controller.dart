import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/diwali_scheme.dart/diwali_scheme_model.dart';
import 'package:sri_murugan_chits/services/repositary/diwali_scheme/diwali_scheme_repo.dart';



class DiwaliSchemeController extends GetxController {
  final DiwaliSchemeRepository _repository;

  DiwaliSchemeController(this._repository);

  // ==========================================================
  // STATE
  // ==========================================================

  final schemes = <DiwaliSchemeModel>[].obs;

  final isLoading = false.obs; // full-list loading (first page / refresh)
  final isLoadingMore = false.obs; // pagination loading
  final isSaving = false.obs; // create / update in-flight

  final statusFilter = ''.obs; // '', 'Active', 'Closed'

  final scrollController = ScrollController();

  final page = 1.obs;
  final totalPages = 1.obs;
  static const int _limit = 20;

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void onInit() {
    super.onInit();
    fetchSchemes(reset: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final nearBottom = scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200;
    if (nearBottom) loadMore();
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  void setStatusFilter(String status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    fetchSchemes(reset: true);
  }

  // ==========================================================
  // FETCH / PAGINATION
  // ==========================================================

  Future<void> fetchSchemes({bool reset = false}) async {
    try {
      if (reset) {
        page.value = 1;
        isLoading.value = true;
      }

      final result = await _repository.getSchemes(
        page: page.value,
        limit: _limit,
        status: statusFilter.value,
      );

      final List<DiwaliSchemeModel> fetched = result['schemes'];
      final pagination = result['pagination'] as Map<String, dynamic>? ?? {};
      totalPages.value = (pagination['totalPages'] as num?)?.toInt() ?? 1;

      if (reset) {
        schemes.assignAll(fetched);
      } else {
        schemes.addAll(fetched);
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
    await fetchSchemes();
  }

  Future<void> refreshSchemes() => fetchSchemes(reset: true);

  // ==========================================================
  // CREATE / UPDATE
  // ==========================================================

  /// Returns true on success so the form screen can pop itself.
  Future<bool> saveScheme(Map<String, dynamic> body, {int? id}) async {
    try {
      isSaving.value = true;

      if (id == null) {
        await _repository.createScheme(body);
        Get.snackbar('Success', 'Scheme created successfully',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        await _repository.updateScheme(id, body);
        Get.snackbar('Success', 'Scheme updated successfully',
            snackPosition: SnackPosition.BOTTOM);
      }

      await fetchSchemes(reset: true);
      return true;
    } catch (e) {
      _showError(e);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ==========================================================
  // STATUS TOGGLE
  // ==========================================================

  Future<void> toggleStatus(DiwaliSchemeModel scheme) async {
    final newStatus = scheme.status == 'Active' ? 'Closed' : 'Active';
    final index = schemes.indexWhere((s) => s.id == scheme.id);
    if (index == -1) return;

    // optimistic update
    schemes[index] = scheme.copyWith(status: newStatus);

    try {
      await _repository.changeStatus(scheme.id, newStatus);
    } catch (e) {
      // revert on failure
      schemes[index] = scheme;
      _showError(e);
    }
  }

  void _showError(Object e) {
    Get.snackbar(
      'Error',
      e.toString().replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}