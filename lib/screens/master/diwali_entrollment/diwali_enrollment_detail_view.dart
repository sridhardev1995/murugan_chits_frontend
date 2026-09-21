import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/diwali_enrollment/diwali_enrollment_model.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

import 'diwali_enrollment_controller.dart';

class DiwaliEnrollmentDetailView extends GetView<DiwaliEnrollmentController> {
  final int enrollmentId;

  const DiwaliEnrollmentDetailView({super.key, required this.enrollmentId});

  @override
  Widget build(BuildContext context) {
    // Load only when this screen does not already contain this enrollment.
    // The previous implementation scheduled the API call on every rebuild,
    // which could cause repeated requests and unnecessary rebuilds.
    final currentId = controller.currentEnrollment.value?.id;

    if (currentId != enrollmentId && !controller.isDetailLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.currentEnrollment.value?.id != enrollmentId &&
            !controller.isDetailLoading.value) {
          controller.loadEnrollmentDetail(enrollmentId);
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: Text('Enrollment Details', style: AppTextStyle.heading),
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),

        actions: [
          IconButton(
            tooltip: 'Payment History',
            icon: const Icon(Icons.history),
            onPressed: () {
              _showPaymentHistory(context);
            },
          ),

          Obx(() {
            final enrollment = controller.currentEnrollment.value;

            if (enrollment == null) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: 'Modify Chits',
              icon: const Icon(Icons.tune),
              onPressed: () {
                _showModifyChitsDialog(context, enrollment);
              },
            );
          }),

          IconButton(
            tooltip: 'Bulk Payment',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () {
              _showBulkPayDialog(context, enrollmentId);
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Obx(() {
          if (controller.isDetailLoading.value &&
              controller.currentEnrollment.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final enrollment = controller.currentEnrollment.value;

          final summary = controller.summary.value;

          if (enrollment == null || summary == null) {
            return Center(
              child: Text(
                'Could not load enrollment',
                style: AppTextStyle.regular,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadEnrollmentDetail(enrollmentId);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeaderCard(enrollment),

                const SizedBox(height: 14),

                _buildSummaryCard(summary),

                const SizedBox(height: 20),

                _buildSectionTitle('Weekly Schedule'),

                const SizedBox(height: 10),

                if (controller.weeks.isEmpty)
                  _buildNoData('No weekly schedule found')
                else
                  ...controller.weeks.map(
                    (week) => _buildWeekTile(context, enrollment, week),
                  ),

                const SizedBox(height: 20),

                _buildAdjustmentSection(context),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeaderCard(DiwaliEnrollmentModel e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE8F0FE),
            child: Text(
              e.customerName.isNotEmpty
                  ? e.customerName.substring(0, 1).toUpperCase()
                  : '?',
              style: AppTextStyle.semiBoldLarge.copyWith(
                color: const Color(0xFF2563EB),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.customerName, style: AppTextStyle.semiBoldLarge),

                const SizedBox(height: 3),

                Text(
                  e.customerPhone,
                  style: AppTextStyle.regularSmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${e.schemeName} · '
                  '${e.currentChits} chits · '
                  '₹${e.chitValue.toStringAsFixed(0)}/chit',
                  style: AppTextStyle.regularSmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCard(EnrollmentSummary s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Total Paid', s.totalPaid, Colors.green.shade700),

          const Divider(height: 20),

          _summaryRow('Total Due', s.totalDue, const Color(0xFF1F2937)),

          const Divider(height: 20),

          _summaryRow('Balance', s.balance, Colors.red.shade600),

          const Divider(height: 20),

          _summaryRow(
            'Weeks Remaining',
            s.balanceWeeks.toDouble(),
            const Color(0xFF1F2937),
            isCount: true,
          ),

          const Divider(height: 20),

          _summaryRow(
            'Maturity Return',
            s.maturityReturn,
            const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double value,
    Color color, {
    bool isCount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyle.regular.copyWith(color: Colors.grey.shade600),
        ),
        Text(
          isCount ? value.toStringAsFixed(0) : '₹${value.toStringAsFixed(0)}',
          style: AppTextStyle.semiBoldLarge.copyWith(color: color),
        ),
      ],
    );
  }

  // ============================================================
  // WEEK TILE
  // ============================================================

  Widget _buildWeekTile(
    BuildContext context,
    DiwaliEnrollmentModel enrollment,
    DiwaliEnrollmentWeekModel week,
  ) {
    Color statusColor;

    switch (week.status) {
      case 'Paid':
        statusColor = Colors.green.shade700;
        break;

      case 'Partial':
        statusColor = Colors.orange.shade700;
        break;

      default:
        statusColor = Colors.red.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'W${week.weekNumber}',
              style: AppTextStyle.semiBoldSmall.copyWith(color: statusColor),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${week.amountPaid.toStringAsFixed(0)} / '
                  '₹${week.amountDue.toStringAsFixed(0)}',
                  style: AppTextStyle.semiBold,
                ),

                const SizedBox(height: 3),

                Text(
                  'Due ${week.dueDate}',
                  style: AppTextStyle.regularSmall.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),

                if (week.paymentDate != null)
                  Text(
                    'Paid ${week.paymentDate}'
                    '${week.paymentMode != null ? ' · ${week.paymentMode}' : ''}',
                    style: AppTextStyle.regularSmall.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              week.status,
              style: AppTextStyle.semiBoldSmall.copyWith(color: statusColor),
            ),
          ),

          if (week.status != 'Paid') ...[
            const SizedBox(width: 4),

            IconButton(
              tooltip: 'Record Payment',
              icon: const Icon(
                Icons.payments_outlined,
                color: Color(0xFF2563EB),
              ),
              onPressed: () {
                _showPayDialog(context, enrollment, week);
              },
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SINGLE PAYMENT DIALOG
  // ============================================================

  Future<void> _showPayDialog(
    BuildContext context,
    DiwaliEnrollmentModel enrollment,
    DiwaliEnrollmentWeekModel week,
  ) async {
    final cashController = TextEditingController();

    final upiController = TextEditingController();

    String? errorText;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            double cash() => double.tryParse(cashController.text.trim()) ?? 0;

            double upi() => double.tryParse(upiController.text.trim()) ?? 0;

            double total() => cash() + upi();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Pay Week ${week.weekNumber}',
                style: AppTextStyle.semiBoldLarge,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outstanding: ₹${week.outstanding.toStringAsFixed(0)}',
                      style: AppTextStyle.regularSmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _amountField(
                      controller: cashController,
                      label: 'Cash Amount',
                      icon: Icons.money,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    _amountField(
                      controller: upiController,
                      label: 'UPI Amount',
                      icon: Icons.qr_code,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Total: ₹${total().toStringAsFixed(0)}',
                      style: AppTextStyle.semiBold,
                    ),

                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                Obx(() {
                  final paying = controller.isPaying.value;

                  return ElevatedButton(
                    onPressed: paying
                        ? null
                        : () async {
                            final amount = total();

                            if (amount <= 0) {
                              setState(() {
                                errorText = 'Enter at least one amount';
                              });
                              return;
                            }

                            if (amount > week.outstanding) {
                              setState(() {
                                errorText =
                                    'Total exceeds outstanding ₹${week.outstanding.toStringAsFixed(0)}';
                              });
                              return;
                            }

                            final payments = <Map<String, dynamic>>[
                              if (cash() > 0)
                                {'amount': cash(), 'mode': 'Cash'},
                              if (upi() > 0) {'amount': upi(), 'mode': 'UPI'},
                            ];

                            final success = await controller.payWeek(
                              enrollmentId: enrollment.id,
                              weekNumber: week.weekNumber,
                              payments: payments,
                            );

                            if (success && dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                    child: paying
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Confirm', style: AppTextStyle.button),
                  );
                }),
              ],
            );
          },
        );
      },
    );

    // // Dispose only after showDialog has completely finished.
    // cashController.dispose();
    // upiController.dispose();
  }

  Widget _amountField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: '₹ ',
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ============================================================
  // BULK PAYMENT
  // ============================================================

  Future<void> _showBulkPayDialog(
    BuildContext context,
    int enrollmentId,
  ) async {
    final amountController = TextEditingController();

    String selectedMode = 'Cash';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Bulk Payment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter total amount. '
                        'The backend will automatically apply it to upcoming dues.',
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Total Amount',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedMode,
                      decoration: const InputDecoration(
                        labelText: 'Payment Mode',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          const [
                                'Cash',
                                'UPI',
                                'Bank Transfer',
                                'Cheque',
                                'Other',
                              ]
                              .map(
                                (mode) => DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMode = value ?? 'Cash';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                Obx(() {
                  final loading = controller.isBulkPaying.value;

                  return ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            final amount = double.tryParse(
                              amountController.text.trim(),
                            );

                            if (amount == null || amount <= 0) {
                              Get.snackbar(
                                'Invalid amount',
                                'Enter a valid amount',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            final success = await controller.bulkPayEnrollment(
                              enrollmentId: enrollmentId,
                              totalAmount: amount,
                              paymentMode: selectedMode,
                            );

                            if (success && dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Pay'),
                  );
                }),
              ],
            );
          },
        );
      },
    );

    // Dispose only after showDialog has completely finished.
    amountController.dispose();
  }

  // ============================================================
  // PAYMENT HISTORY
  // ============================================================

  void _showPaymentHistory(BuildContext context) {
    controller.loadPaymentHistory(enrollmentId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6F7FB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 12),

                Text('Payment History', style: AppTextStyle.semiBoldLarge),

                const SizedBox(height: 10),

                Expanded(
                  child: Obx(() {
                    if (controller.isPaymentHistoryLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.paymentHistory.isEmpty) {
                      return _buildNoData('No payment history');
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.paymentHistory.length,
                      itemBuilder: (context, index) {
                        final payment = controller.paymentHistory[index];

                        return _paymentHistoryCard(context, payment);
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // PAYMENT HISTORY CARD
  // ============================================================

  Widget _paymentHistoryCard(
    BuildContext context,
    Map<String, dynamic> payment,
  ) {
    final status = payment['status']?.toString() ?? 'Active';

    final amount = _toDouble(payment['amount']);

    final weekNumber = payment['week_number']?.toString() ?? '-';

    final mode = payment['payment_mode']?.toString() ?? '-';

    final paymentDate = payment['payment_date']?.toString() ?? '-';

    final groupId = payment['payment_group_id']?.toString();

    final transactionId = _toInt(payment['id']);

    final reversedBy = payment['reversed_by_username']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: status == 'Active'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  child: Icon(
                    status == 'Active'
                        ? Icons.check_circle_outline
                        : Icons.undo,
                    color: status == 'Active'
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Week $weekNumber', style: AppTextStyle.semiBold),
                      Text(
                        '$mode · $paymentDate',
                        style: AppTextStyle.regularSmall.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: AppTextStyle.semiBoldLarge.copyWith(
                    color: status == 'Active'
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _statusBadge(status),

                if (groupId != null && groupId.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Group: ${_shortId(groupId)}',
                      style: AppTextStyle.regularSmall.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            if (status == 'Reversed' &&
                reversedBy != null &&
                reversedBy.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Reversed by: $reversedBy',
                style: AppTextStyle.regularSmall.copyWith(
                  color: Colors.red.shade600,
                ),
              ),
            ],

            if (status == 'Active') ...[
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _confirmSingleRevert(context, transactionId);
                    },
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Revert'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),

                  if (groupId != null && groupId.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        _confirmGroupRevert(context, groupId);
                      },
                      icon: const Icon(Icons.history_toggle_off, size: 18),
                      label: const Text('Revert Group'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final active = status == 'Active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: AppTextStyle.semiBoldSmall.copyWith(
          color: active ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }

  // ============================================================
  // SINGLE REVERT CONFIRM
  // ============================================================

  Future<void> _confirmSingleRevert(
    BuildContext context,
    int transactionId,
  ) async {
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Revert Payment?'),
          content: TextField(
            controller: reasonController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isRevertingPayment.value
                    ? null
                    : () async {
                        final success = await controller.revertPayment(
                          enrollmentId: enrollmentId,
                          transactionId: transactionId,
                          reason: reasonController.text,
                        );

                        if (success && dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: controller.isRevertingPayment.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Revert'),
              );
            }),
          ],
        );
      },
    );

    // Dispose only after showDialog has completely finished.
    reasonController.dispose();
  }

  // ============================================================
  // GROUP REVERT CONFIRM
  // ============================================================

  Future<void> _confirmGroupRevert(
    BuildContext context,
    String paymentGroupId,
  ) async {
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Revert Entire Payment Group?'),
          content: TextField(
            controller: reasonController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isRevertingPaymentGroup.value
                    ? null
                    : () async {
                        final success = await controller.revertPaymentGroup(
                          enrollmentId: enrollmentId,
                          paymentGroupId: paymentGroupId,
                          reason: reasonController.text,
                        );

                        if (success && dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                ),
                child: controller.isRevertingPaymentGroup.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Revert Group'),
              );
            }),
          ],
        );
      },
    );

    // Dispose only after showDialog has completely finished.
    reasonController.dispose();
  }

  // ============================================================
  // MODIFY CHITS
  // ============================================================

  Future<void> _showModifyChitsDialog(
    BuildContext context,
    DiwaliEnrollmentModel enrollment,
  ) async {
    final fromWeekController = TextEditingController();

    final newChitsController = TextEditingController(
      text: enrollment.currentChits.toString(),
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Modify Chit Quantity',
            style: AppTextStyle.semiBoldLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current: ${enrollment.currentChits} chits',
                    style: AppTextStyle.regularSmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: fromWeekController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'From Week Number',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: newChitsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'New Chit Count',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Any excess from previously paid weeks will be adjusted against upcoming dues.',
                  style: AppTextStyle.regularSmall.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            Obx(() {
              final loading = controller.isModifyingChits.value;

              return ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        final fromWeek =
                            int.tryParse(fromWeekController.text.trim()) ?? 0;

                        final newChits =
                            int.tryParse(newChitsController.text.trim()) ?? 0;

                        if (fromWeek <= 0 || newChits <= 0) {
                          Get.snackbar(
                            'Invalid',
                            'Enter valid values',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        final success = await controller.modifyChits(
                          enrollmentId: enrollment.id,
                          fromWeekNumber: fromWeek,
                          newChits: newChits,
                        );

                        if (success && dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Update'),
              );
            }),
          ],
        );
      },
    );

    // Dispose only after showDialog has completely finished.
    fromWeekController.dispose();
    newChitsController.dispose();
  }

  // ============================================================
  // ADJUSTMENT LOGS
  // ============================================================

  Widget _buildAdjustmentSection(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text('Adjustment Logs', style: AppTextStyle.semiBold),
      children: [
        Obx(() {
          if (controller.isAdjustmentLogsLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.adjustmentLogs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No adjustment logs',
                style: AppTextStyle.regularSmall,
              ),
            );
          }

          return Column(
            children: controller.adjustmentLogs
                .map((log) => _adjustmentLogTile(log))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _adjustmentLogTile(AdjustmentLogModel log) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Source Weeks: ${log.sourceWeeks}',
            style: AppTextStyle.semiBoldSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Source Excess: ₹${log.sourceExcessTotal.toStringAsFixed(2)}',
            style: AppTextStyle.regularSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Applied to Week ${log.targetWeek}: '
            '₹${log.appliedAmount.toStringAsFixed(2)}',
            style: AppTextStyle.regularSmall,
          ),
          const SizedBox(height: 4),
          Text(
            log.note,
            style: AppTextStyle.regularSmall.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.semiBold.copyWith(color: const Color(0xFF6B7280)),
    );
  }

  // ============================================================
  // NO DATA
  // ============================================================

  Widget _buildNoData(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.regular.copyWith(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  String _shortId(String id) {
    if (id.length <= 12) {
      return id;
    }

    return '${id.substring(0, 8)}...';
  }
}
