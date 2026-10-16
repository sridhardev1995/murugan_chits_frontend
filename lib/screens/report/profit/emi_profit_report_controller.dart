import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/report/emi_profit_report_model.dart';
import 'package:sri_murugan_chits/services/repositary/report/emi_profit_report_repository.dart';



class EmiProfitReportController extends GetxController {
  final EmiProfitReportRepository _repository =
      EmiProfitReportRepository();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final report = Rxn<EmiProfitReport>();

  final selectedStatus = 'All'.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final searchController = TextEditingController();
  final searchText = ''.obs;

  List<EmiProfitReportItem> get allItems =>
      report.value?.items ?? <EmiProfitReportItem>[];

  EmiProfitReportSummary get summary =>
      report.value?.summary ?? const EmiProfitReportSummary();

  List<EmiProfitReportItem> get filteredItems {
    final query = searchText.value.trim().toLowerCase();

    return allItems.where((item) {
      if (query.isNotEmpty) {
        final matches = item.customerName.toLowerCase().contains(query) ||
            item.customerPhone.toLowerCase().contains(query) ||
            item.schemeName.toLowerCase().contains(query) ||
            item.enrollmentId.toString().contains(query) ||
            item.customerId.toString().contains(query);

        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadReport();
  }

  Future<void> loadReport() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.getReport(
        startDate: _formatDate(startDate.value),
        endDate: _formatDate(endDate.value),
        status: selectedStatus.value,
      );

      report.value = result;
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setStartDate(DateTime? date) async {
    if (date == null) return;

    if (endDate.value != null && date.isAfter(endDate.value!)) {
      errorMessage.value = 'Start date cannot be after end date';
      return;
    }

    startDate.value = date;
    await loadReport();
  }

  Future<void> setEndDate(DateTime? date) async {
    if (date == null) return;

    if (startDate.value != null && date.isBefore(startDate.value!)) {
      errorMessage.value = 'End date cannot be before start date';
      return;
    }

    endDate.value = date;
    await loadReport();
  }

  Future<void> setStatus(String? status) async {
    if (status == null || status.isEmpty) return;

    selectedStatus.value = status;
    await loadReport();
  }

  Future<void> clearFilters() async {
    startDate.value = null;
    endDate.value = null;
    selectedStatus.value = 'All';
    searchController.clear();
    searchText.value = '';
    await loadReport();
  }

  void onSearchChanged(String value) {
    searchText.value = value;
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}