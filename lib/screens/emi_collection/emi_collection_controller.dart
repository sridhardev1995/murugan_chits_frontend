
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/emi_entroll/emi_installment_model.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';
import 'package:sri_murugan_chits/services/repositary/emi_collections/emi_collection_repository.dart';

class EmiCollectionController extends GetxController {
  final EmiCollectionRepository _repository =
      EmiCollectionRepository();

  // ============================================================
  // LISTS
  // ============================================================

  final RxList<EmiInstallmentModel> todayDueList =
      <EmiInstallmentModel>[].obs;

  final RxList<EmiInstallmentModel> overdueList =
      <EmiInstallmentModel>[].obs;

  // ============================================================
  // STATE
  // ============================================================

  final RxBool isLoading = false.obs;
  final RxBool isTodayDueLoading = false.obs;
  final RxBool isOverdueLoading = false.obs;
  final RxBool isPaymentDialogLoading = false.obs;

  final RxInt selectedTab = 0.obs;
  final RxString errorMessage = ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    loadCollections();
  }

  // ============================================================
  // LOAD BOTH COLLECTION LISTS
  // ============================================================

  Future<void> loadCollections() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.wait([
        fetchTodayDue(),
        fetchOverdue(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // TODAY DUE
  // ============================================================

  Future<void> fetchTodayDue() async {
    try {
      isTodayDueLoading.value = true;

      final result = await _repository.getTodayDue();

      todayDueList.assignAll(result);
    } catch (e, st) {
      debugPrint(
        '[EMI Today Due] ERROR: $e\n$st',
      );

      errorMessage.value = 'Unable to load EMI today due';
    } finally {
      isTodayDueLoading.value = false;
    }
  }

  // ============================================================
  // OVERDUE
  // ============================================================

  Future<void> fetchOverdue() async {
    try {
      isOverdueLoading.value = true;

      final result = await _repository.getOverdue();

      overdueList.assignAll(result);
    } catch (e, st) {
      debugPrint(
        '[EMI Overdue] ERROR: $e\n$st',
      );

      errorMessage.value = 'Unable to load EMI overdue';
    } finally {
      isOverdueLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshCollections() async {
    await loadCollections();
  }

  // ============================================================
  // TAB
  // ============================================================

  void changeTab(int index) {
    if (index != 0 && index != 1) return;
    selectedTab.value = index;
  }

  // ============================================================
  // CURRENT LIST
  // ============================================================

  List<EmiInstallmentModel> get currentList {
    return selectedTab.value == 0
        ? todayDueList
        : overdueList;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  double get todayDueAmount {
    return todayDueList.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );
  }

  double get overdueAmount {
    return overdueList.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );
  }

  int get todayDueCount => todayDueList.length;

  int get overdueCount => overdueList.length;

  double get totalPendingAmount {
    return currentList.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );
  }

  bool get isCurrentTabLoading {
    return selectedTab.value == 0
        ? isTodayDueLoading.value
        : isOverdueLoading.value;
  }

  // ============================================================
  // COLLECT PAYMENT
  // ============================================================

  Future<void> collectPayment(
    EmiInstallmentModel installment,
  ) async {
    if (isPaymentDialogLoading.value) return;

    if (installment.id == null) {
      _showError(
        'Invalid Installment',
        'EMI installment ID is missing.',
      );
      return;
    }

    if (installment.balance <= 0) {
      _showError(
        'No Pending Balance',
        'This installment is already paid.',
      );
      return;
    }

    if (!Get.isRegistered<EmiEnrollmentController>()) {
      _showError(
        'Controller Not Found',
        'EmiEnrollmentController is not registered. Register it in your route binding before collecting payment.',
      );
      return;
    }

    final enrollmentController =
        Get.find<EmiEnrollmentController>();

    final amountController = TextEditingController(
      text: installment.balance.toStringAsFixed(2),
    );

    String paymentMode = 'Cash';
    bool dialogOpened = false;

    try {
      isPaymentDialogLoading.value = true;

      final confirmed = await Get.dialog<bool>(
        StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Collect Week ${installment.weekNo ?? '-'}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer: ${_customerName(installment)}',
                    ),

                    const SizedBox(height: 16),

                    _paymentInfo(
                      'EMI Amount',
                      (installment.amount ?? 0).toDouble(),
                    ),

                    _paymentInfo(
                      'Already Paid',
                      (installment.paidAmount ?? 0).toDouble(),
                    ),

                    _paymentInfo(
                      'Pending Balance',
                      installment.balance,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Collection Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: amountController,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        hintText: 'Enter amount',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Payment Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cash'),
                      value: 'Cash',
                      groupValue: paymentMode,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          paymentMode = value;
                        });
                      },
                    ),

                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('UPI'),
                      value: 'UPI',
                      groupValue: paymentMode,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          paymentMode = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(result: false);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (amount == null ||
                        !amount.isFinite ||
                        amount <= 0) {
                      _showError(
                        'Invalid Amount',
                        'Enter a valid payment amount.',
                      );
                      return;
                    }

                    if (amount > installment.balance + 0.001) {
                      _showError(
                        'Invalid Amount',
                        'Payment cannot exceed the pending balance.',
                      );
                      return;
                    }

                    Get.back(result: true);
                  },
                  child: const Text('Confirm Payment'),
                ),
              ],
            );
          },
        ),
        barrierDismissible: false,
      );

      dialogOpened = true;

      if (confirmed != true) return;

      final amount = double.tryParse(
        amountController.text.trim(),
      );

      if (amount == null ||
          !amount.isFinite ||
          amount <= 0 ||
          amount > installment.balance + 0.001) {
        _showError(
          'Invalid Amount',
          'Please enter a valid amount within the pending balance.',
        );
        return;
      }

      // Full payment or partial payment.
      final status = amount >= installment.balance - 0.001
          ? 'Paid'
          : 'Partial';

      debugPrint(
        '[EMI Collection] '
        'installmentId=${installment.id}, '
        'amount=$amount, '
        'mode=$paymentMode, '
        'status=$status',
      );

      // Use existing payment API and receipt logic.
      final success =
          await enrollmentController.collectInstallment(
        installment: installment,
        amount: amount,
        status: status,
        paymentMode: paymentMode,
      );

      if (success) {
        // Reload both tabs so the latest balance/status appears.
        await refreshCollections();

        debugPrint(
          '[EMI Collection] Payment completed and lists refreshed.',
        );
      }
    } catch (e, st) {
      debugPrint(
        '[EMI Collection] ERROR: $e\n$st',
      );

      _showError(
        'Payment Failed',
        'Unable to process payment. Please check the logs.',
      );
    } finally {
      if (!dialogOpened) {
        // No action needed; this flag only tracks dialog completion.
      }

      amountController.dispose();
      isPaymentDialogLoading.value = false;
    }
  }

  // ============================================================
  // PAYMENT INFO
  // ============================================================

  Widget _paymentInfo(
    String label,
    double amount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          const SizedBox(width: 12),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOMER NAME
  // ============================================================

  String _customerName(
    EmiInstallmentModel installment,
  ) {
    final name = installment.customerName?.trim();

    if (name == null || name.isEmpty) {
      return 'Customer';
    }

    return name;
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(
    String title,
    String message,
  ) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
