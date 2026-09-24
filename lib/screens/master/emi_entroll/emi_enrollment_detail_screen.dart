import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_installment_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_payment_model.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/colors/app_gradients.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

class EmiEnrollmentDetailScreen extends StatefulWidget {
  final int enrollmentId;

  const EmiEnrollmentDetailScreen({
    super.key,
    required this.enrollmentId,
  });

  @override
  State<EmiEnrollmentDetailScreen> createState() =>
      _EmiEnrollmentDetailScreenState();
}

class _EmiEnrollmentDetailScreenState
    extends State<EmiEnrollmentDetailScreen> {
  late final EmiEnrollmentController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<EmiEnrollmentController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
          'EMI Enrollment Details',
          style: AppTextStyle.semiBoldLarge,
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final enrollment =
            controller.selectedEnrollment.value;

        if (enrollment == null) {
          return Center(
            child: Text(
              'Enrollment details not found',
              style: AppTextStyle.regular,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadData();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ==================================================
              // CUSTOMER CARD
              // ==================================================

              _buildCustomerCard(enrollment),

              const SizedBox(height: 14),

              // ==================================================
              // CUSTOMER DETAILS
              // ==================================================

              _buildSectionCard(
                title: 'Customer Details',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    _infoRow(
                      'Customer Name',
                      enrollment.customerName ?? '-',
                    ),
                    _infoRow(
                      'Phone',
                      enrollment.customerPhone ?? '-',
                    ),
                    _infoRow(
                      'Customer ID',
                      '${enrollment.customerId ?? '-'}',
                    ),
                    _infoRow(
                      'Enrollment ID',
                      '${enrollment.id ?? '-'}',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // EMI SUMMARY
              // ==================================================

              _buildEmiSummary(),

              const SizedBox(height: 14),

              // ==================================================
              // EMI PAYMENT SUMMARY
              // ==================================================

              _buildPaymentSummary(),

              const SizedBox(height: 14),

              // ==================================================
              // EMI WEEKLY SCHEDULE
              // ==================================================

              _buildEmiSchedule(),

              const SizedBox(height: 14),

              // ==================================================
              // STATUS ACTIONS
              // ==================================================

              _buildStatusActions(enrollment),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // ==============================================================
  // CUSTOMER CARD
  // ==============================================================

  Widget _buildCustomerCard(
    EnrollmentModel enrollment,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  enrollment.customerName ??
                      'Unknown Customer',
                  style:
                      AppTextStyle.heading.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  enrollment.customerPhone ?? '',
                  style:
                      AppTextStyle.regularSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(0.18),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    enrollment.status ?? 'Unknown',
                    style:
                        AppTextStyle.semiBoldSmall
                            .copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SECTION CARD
  // ==============================================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withOpacity(0.18),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF8A7B00),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style:
                      AppTextStyle.semiBoldLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ==============================================================
  // INFO ROW
  // ==============================================================

  Widget _infoRow(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  AppTextStyle.regularSmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  AppTextStyle.semiBoldSmall,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EMI SUMMARY
  // ==============================================================

  Widget _buildEmiSummary() {
    return Obx(() {
      final summary = controller.emiSummary;

      final total =
          _toInt(summary['totalEmis']);

      final paid =
          _toInt(summary['paidEmis']);

      final collected =
          _toDouble(summary['totalCollected']);

      final balance =
          _toDouble(summary['balance']);

      final overdue =
          _toInt(summary['overdueEmis']);

      return _buildSectionCard(
        title: 'EMI Summary',
        icon: Icons.analytics_outlined,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _summaryBox(
                    'Total EMIs',
                    '$total',
                    Icons.calendar_month_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryBox(
                    'Paid EMIs',
                    '$paid',
                    Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _summaryBox(
                    'Collected',
                    _money(collected),
                    Icons.payments_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryBox(
                    'Balance',
                    _money(balance),
                    Icons.account_balance_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _summaryBox(
              'Overdue EMIs',
              '$overdue',
              Icons.warning_amber_outlined,
              fullWidth: true,
            ),
          ],
        ),
      );
    });
  }

  // ==============================================================
  // PAYMENT SUMMARY
  // ==============================================================

  Widget _buildPaymentSummary() {
    return Obx(() {
      final total =
          controller.paymentTotal.value;

      final cash =
          controller.cashTotal.value;

      final upi =
          controller.upiTotal.value;

      return _buildSectionCard(
        title: 'Payment Summary',
        icon: Icons.payments_outlined,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _paymentSummaryBox(
                    title: 'Total Paid',
                    value: _money(total),
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _paymentSummaryBox(
                    title: 'Cash',
                    value: _money(cash),
                    icon: Icons.money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _paymentSummaryBox(
                    title: 'UPI',
                    value: _money(upi),
                    icon: Icons.phone_android,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _paymentSummaryBox(
                    title: 'Transactions',
                    value:
                        '${controller.paymentHistory.length}',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showAllPaymentHistory();
                },
                icon: const Icon(
                  Icons.history,
                ),
                label: const Text(
                  'View Payment History',
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ==============================================================
  // PAYMENT SUMMARY BOX
  // ==============================================================

  Widget _paymentSummaryBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF8A7B00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTextStyle.regularSmall
                          .copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyle.semiBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SUMMARY BOX
  // ==============================================================

  Widget _summaryBox(
    String title,
    String value,
    IconData icon, {
    bool fullWidth = false,
  }) {
    return Container(
      width:
          fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF8A7B00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTextStyle.regularSmall
                          .copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyle.semiBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EMI SCHEDULE
  // ==============================================================

  Widget _buildEmiSchedule() {
    return Obx(() {
      final installments =
          controller.installments;

      return _buildSectionCard(
        title: 'EMI Weekly Schedule',
        icon: Icons.view_week_outlined,
        child:
            controller.isScheduleLoading.value &&
                    installments.isEmpty
                ? const Padding(
                    padding:
                        EdgeInsets.all(20),
                    child:
                        Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  )
                : installments.isEmpty
                    ? Padding(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        child: Text(
                          'No EMI schedule found',
                          style:
                              AppTextStyle.regular,
                        ),
                      )
                    : Column(
                        children:
                            installments
                                .map(
                                  _buildInstallmentCard,
                                )
                                .toList(),
                      ),
      );
    });
  }

  // ==============================================================
  // INSTALLMENT CARD
  // ==============================================================

  Widget _buildInstallmentCard(
    EmiInstallmentModel emi,
  ) {
    final amount =
        emi.amount ?? 0;

    final paid =
        emi.paidAmount ?? 0;

    final balance =
        emi.balance;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              emi.overdue &&
                      !emi.isPaid
                  ? const Color(
                      0xFFFFCDD2,
                    )
                  : const Color(
                      0xFFE5E7EB,
                    ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withOpacity(
                    0.18,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  '${emi.weekNo ?? '-'}',
                  style:
                      AppTextStyle.semiBold
                          .copyWith(
                    fontWeight:
                        FontWeight.w800,
                    color:
                        const Color(
                      0xFF8A7B00,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week ${emi.weekNo ?? '-'}',
                      style:
                          AppTextStyle.semiBoldLarge,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    _dueStatusLine(emi),
                  ],
                ),
              ),
              _statusChip(emi),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(height: 1),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _amountColumn(
                  'EMI',
                  _money(amount),
                ),
              ),
              Expanded(
                child: _amountColumn(
                  'Paid',
                  _money(paid),
                ),
              ),
              Expanded(
                child: _amountColumn(
                  'Balance',
                  _money(balance),
                ),
              ),
            ],
          ),

          // ========================================================
          // PAYMENT BUTTONS
          // ========================================================

          if (balance > 0)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          controller
                                  .isPaymentLoading
                                  .value
                              ? null
                              : () =>
                                  _showCollectDialog(
                                    emi,
                                  ),
                      icon: const Icon(
                        Icons.payments_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Collect',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        foregroundColor:
                            AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _showInstallmentHistory(
                        emi,
                      );
                    },
                    child: const Icon(
                      Icons.history,
                      size: 20,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 12,
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showInstallmentHistory(
                      emi,
                    );
                  },
                  icon: const Icon(
                    Icons.history,
                  ),
                  label: const Text(
                    'View Payment History',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==============================================================
  // DUE STATUS
  // ==============================================================

  Widget _dueStatusLine(
    EmiInstallmentModel emi,
  ) {
    DateTime? dueDate;

    try {
      dueDate =
          (emi.dueDate != null &&
                  emi.dueDate!.isNotEmpty)
              ? DateTime.parse(
                  emi.dueDate!,
                )
              : null;
    } catch (_) {}

    // ------------------------------------------------------------
    // PAID
    // ------------------------------------------------------------

    if (emi.isPaid) {
      DateTime? paidDate;

      try {
        paidDate =
            (emi.paidDate != null &&
                    emi.paidDate!.isNotEmpty)
                ? DateTime.parse(
                    emi.paidDate!,
                  )
                : null;
      } catch (_) {}

      if (dueDate != null &&
          paidDate != null) {
        final diff =
            DateTime(
              paidDate.year,
              paidDate.month,
              paidDate.day,
            ).difference(
              DateTime(
                dueDate.year,
                dueDate.month,
                dueDate.day,
              ),
            ).inDays;

        if (diff <= 0) {
          return _statusLine(
            icon:
                Icons.check_circle_outline,
            text:
                'Due ${_formatDate(emi.dueDate)} · '
                'Paid ${_formatDate(emi.paidDate)}',
            color:
                const Color(0xFF2E7D32),
          );
        }

        return _statusLine(
          icon:
              Icons.error_outline,
          text:
              'Due ${_formatDate(emi.dueDate)} · '
              'Paid ${_formatDate(emi.paidDate)} '
              '($diff day${diff > 1 ? 's' : ''} late)',
          color:
              const Color(0xFFC62828),
        );
      }

      return _statusLine(
        icon:
            Icons.check_circle_outline,
        text:
            'Paid · ${_formatDate(emi.paidDate)}',
        color:
            const Color(0xFF2E7D32),
      );
    }

    // ------------------------------------------------------------
    // NOT PAID
    // ------------------------------------------------------------

    if (dueDate != null) {
      final today =
          DateTime.now();

      final diff =
          DateTime(
            today.year,
            today.month,
            today.day,
          ).difference(
            DateTime(
              dueDate.year,
              dueDate.month,
              dueDate.day,
            ),
          ).inDays;

      if (diff > 0) {
        return _statusLine(
          icon:
              Icons.warning_amber_outlined,
          text:
              'Overdue by $diff day${diff > 1 ? 's' : ''} · '
              'Due ${_formatDate(emi.dueDate)}',
          color:
              const Color(0xFFC62828),
        );
      }

      return _statusLine(
        icon:
            Icons.event_outlined,
        text:
            'Due ${_formatDate(emi.dueDate)}',
        color:
            Colors.grey.shade600,
      );
    }

    return _statusLine(
      icon:
          Icons.event_outlined,
      text:
          'Due date not set',
      color:
          Colors.grey.shade500,
    );
  }

  // ==============================================================
  // STATUS LINE
  // ==============================================================

  Widget _statusLine({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            overflow:
                TextOverflow.ellipsis,
            style:
                AppTextStyle.semiBoldSmall
                    .copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // AMOUNT COLUMN
  // ==============================================================

  Widget _amountColumn(
    String label,
    String value,
  ) =>
      Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                AppTextStyle.regularSmall
                    .copyWith(
              fontSize: 11,
              color:
                  Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            overflow:
                TextOverflow.ellipsis,
            style:
                AppTextStyle.semiBold
                    .copyWith(
              fontSize: 12,
            ),
          ),
        ],
      );

  // ==============================================================
  // STATUS CHIP
  // ==============================================================

  Widget _statusChip(
    EmiInstallmentModel emi,
  ) {
    String text =
        emi.status ?? 'Pending';

    Color bg =
        const Color(0xFFFFF3E0);

    Color fg =
        const Color(0xFFE65100);

    if (emi.overdue &&
        !emi.isPaid) {
      text = 'Overdue';

      bg =
          const Color(0xFFFFEBEE);

      fg =
          const Color(0xFFC62828);
    } else if (emi.isPaid) {
      text = 'Paid';

      bg =
          const Color(0xFFE8F5E9);

      fg =
          const Color(0xFF2E7D32);
    } else if (emi.isPartial) {
      text = 'Partial';

      bg =
          const Color(0xFFFFF8E1);

      fg =
          const Color(0xFFF57F17);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
            AppTextStyle.semiBoldSmall
                .copyWith(
          color: fg,
          fontSize: 10,
        ),
      ),
    );
  }

  // ==============================================================
  // COLLECT PAYMENT DIALOG
  // ==============================================================

  Future<void> _showCollectDialog(
    EmiInstallmentModel emi,
  ) async {
    final amountController =
        TextEditingController(
      text:
          emi.balance.toStringAsFixed(2),
    );

    final cashController =
        TextEditingController();

    final upiController =
        TextEditingController();

    String selectedStatus =
        'Paid';

    String paymentType =
        'Cash';

    await Get.dialog(
      StatefulBuilder(
        builder:
            (
              context,
              setState,
            ) {
          final balance =
              emi.balance;

          return AlertDialog(
            title: Text(
              'Collect Week ${emi.weekNo ?? '-'}',
              style:
                  AppTextStyle.semiBoldLarge,
            ),
            content:
                SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  _dialogInfoRow(
                    'EMI Amount',
                    _money(emi.amount),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _dialogInfoRow(
                    'Already Paid',
                    _money(emi.paidAmount),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _dialogInfoRow(
                    'Balance',
                    _money(balance),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // PAYMENT TYPE
                  // ==================================================

                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Text(
                      'Payment Type',
                      style:
                          AppTextStyle.semiBoldSmall,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _paymentTypeButton(
                          title: 'Cash',
                          icon:
                              Icons.money,
                          selected:
                              paymentType ==
                                  'Cash',
                          onTap: () {
                            setState(() {
                              paymentType =
                                  'Cash';
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child:
                            _paymentTypeButton(
                          title: 'UPI',
                          icon:
                              Icons.phone_android,
                          selected:
                              paymentType ==
                                  'UPI',
                          onTap: () {
                            setState(() {
                              paymentType =
                                  'UPI';
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child:
                            _paymentTypeButton(
                          title: 'Split',
                          icon:
                              Icons.call_split,
                          selected:
                              paymentType ==
                                  'Split',
                          onTap: () {
                            setState(() {
                              paymentType =
                                  'Split';
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ==================================================
                  // NORMAL PAYMENT
                  // ==================================================

                  if (paymentType !=
                      'Split')
                    TextField(
                      controller:
                          amountController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          InputDecoration(
                        labelText:
                            'Paid Amount',
                        prefixText:
                            '₹ ',
                        border:
                            const OutlineInputBorder(),
                        helperText:
                            'Maximum ${_money(balance)}',
                      ),
                    ),

                  // ==================================================
                  // SPLIT PAYMENT
                  // ==================================================

                  if (paymentType ==
                      'Split') ...[
                    TextField(
                      controller:
                          cashController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Cash Amount',
                        prefixText:
                            '₹ ',
                        border:
                            OutlineInputBorder(),
                      ),
                      onChanged:
                          (_) =>
                              setState(
                        () {},
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      controller:
                          upiController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'UPI Amount',
                        prefixText:
                            '₹ ',
                        border:
                            OutlineInputBorder(),
                      ),
                      onChanged:
                          (_) =>
                              setState(
                        () {},
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _splitTotalBox(
                      cash:
                          _parseDouble(
                        cashController
                            .text,
                      ),
                      upi:
                          _parseDouble(
                        upiController
                            .text,
                      ),
                      balance:
                          balance,
                    ),
                  ],

                  const SizedBox(
                    height: 14,
                  ),

                  // ==================================================
                  // STATUS
                  // ==================================================

                  DropdownButtonFormField<String>(
                    initialValue:
                        selectedStatus,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Status',
                      border:
                          OutlineInputBorder(),
                    ),
                    items:
                        const [
                      DropdownMenuItem(
                        value: 'Paid',
                        child:
                            Text('Paid'),
                      ),
                      DropdownMenuItem(
                        value:
                            'Partial',
                        child:
                            Text(
                          'Partial',
                        ),
                      ),
                    ],
                    onChanged:
                        (value) {
                      if (value !=
                          null) {
                        setState(() {
                          selectedStatus =
                              value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    Get.back,
                child:
                    const Text(
                  'Cancel',
                ),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      AppColors.black,
                ),
                onPressed: () async {
                  // --------------------------------------------------
                  // NORMAL PAYMENT
                  // --------------------------------------------------

                  if (paymentType !=
                      'Split') {
                    final amount =
                        _parseDouble(
                      amountController
                          .text,
                    );

                    if (amount <= 0) {
                      Get.snackbar(
                        'Validation',
                        'Enter a valid paid amount',
                      );
                      return;
                    }

                    if (amount >
                        balance) {
                      Get.snackbar(
                        'Validation',
                        'Payment cannot exceed balance',
                      );
                      return;
                    }

                    if (selectedStatus ==
                            'Paid' &&
                        amount !=
                            balance) {
                      Get.snackbar(
                        'Validation',
                        'For Paid status, full balance ${_money(balance)} is required',
                      );
                      return;
                    }

                    if (selectedStatus ==
                            'Partial' &&
                        amount >=
                            balance) {
                      Get.snackbar(
                        'Validation',
                        'Use Paid status when full balance is collected',
                      );
                      return;
                    }

                    Get.back();

                    await controller
                        .collectInstallment(
                      installment:
                          emi,
                      amount:
                          amount,
                      status:
                          selectedStatus,
                      paymentMode:
                          paymentType,
                    );

                    return;
                  }

                  // --------------------------------------------------
                  // SPLIT PAYMENT
                  // --------------------------------------------------

                  final cash =
                      _parseDouble(
                    cashController.text,
                  );

                  final upi =
                      _parseDouble(
                    upiController.text,
                  );

                  final splitTotal =
                      cash + upi;

                  if (cash <= 0 &&
                      upi <= 0) {
                    Get.snackbar(
                      'Validation',
                      'Enter Cash or UPI amount',
                    );
                    return;
                  }

                  if (splitTotal >
                      balance) {
                    Get.snackbar(
                      'Validation',
                      'Split payment cannot exceed balance',
                    );
                    return;
                  }

                  if (selectedStatus ==
                          'Paid' &&
                      splitTotal !=
                          balance) {
                    Get.snackbar(
                      'Validation',
                      'For Paid status, Cash + UPI must equal ${_money(balance)}',
                    );
                    return;
                  }

                  if (selectedStatus ==
                          'Partial' &&
                      splitTotal >=
                          balance) {
                    Get.snackbar(
                      'Validation',
                      'Use Paid status when full balance is collected',
                    );
                    return;
                  }

                  final payments =
                      <Map<String, dynamic>>[];

                  if (cash > 0) {
                    payments.add({
                      'amount': cash,
                      'paymentMode':
                          'Cash',
                    });
                  }

                  if (upi > 0) {
                    payments.add({
                      'amount': upi,
                      'paymentMode':
                          'UPI',
                    });
                  }

                  Get.back();

                  await controller
                      .collectSplitPayment(
                    installment:
                        emi,
                    payments:
                        payments,
                    status:
                        selectedStatus,
                  );
                },
                child:
                    const Text(
                  'Collect',
                ),
              ),
            ],
          );
        },
      ),
    );

    amountController.dispose();
    cashController.dispose();
    upiController.dispose();
  }

  // ==============================================================
  // PAYMENT TYPE BUTTON
  // ==============================================================

  Widget _paymentTypeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(10),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
                  .withOpacity(0.18)
              : Colors.grey.shade50,
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade300,
            width:
                selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? const Color(
                      0xFF8A7B00,
                    )
                  : Colors.grey.shade600,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              title,
              style:
                  AppTextStyle.semiBoldSmall
                      .copyWith(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SPLIT TOTAL
  // ==============================================================

  Widget _splitTotalBox({
    required double cash,
    required double upi,
    required double balance,
  }) {
    final total =
        cash + upi;

    final remaining =
        balance - total;

    final valid =
        total > 0 &&
            total <= balance;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: valid
            ? const Color(
                0xFFF1F8E9,
              )
            : const Color(
                0xFFFFEBEE,
              ),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: valid
              ? const Color(
                  0xFFC5E1A5,
                )
              : const Color(
                  0xFFFFCDD2,
                ),
        ),
      ),
      child: Column(
        children: [
          _dialogInfoRow(
            'Cash',
            _money(cash),
          ),
          const SizedBox(
            height: 5,
          ),
          _dialogInfoRow(
            'UPI',
            _money(upi),
          ),
          const Divider(),
          _dialogInfoRow(
            'Total',
            _money(total),
          ),
          const SizedBox(
            height: 5,
          ),
          _dialogInfoRow(
            'Remaining',
            _money(
              remaining < 0
                  ? 0
                  : remaining,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INSTALLMENT PAYMENT HISTORY
  // ==============================================================

  Future<void> _showInstallmentHistory(
    EmiInstallmentModel emi,
  ) async {
    if (emi.id == null) {
      return;
    }

    await controller.loadPaymentHistory(
      emi.id!,
    );

    Get.dialog(
      _paymentHistoryDialog(
        title:
            'Week ${emi.weekNo ?? '-'} Payment History',
        installment:
            emi,
      ),
    );
  }

  // ==============================================================
  // ALL PAYMENT HISTORY
  // ==============================================================

  void _showAllPaymentHistory() {
    Get.dialog(
      _paymentHistoryDialog(
        title:
            'Payment History',
        installment: null,
      ),
    );
  }

  // ==============================================================
  // PAYMENT HISTORY DIALOG
  // ==============================================================

  Widget _paymentHistoryDialog({
    required String title,
    required EmiInstallmentModel?
        installment,
  }) {
    return Dialog(
      insetPadding:
          const EdgeInsets.all(16),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style:
                          AppTextStyle.semiBoldLarge,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        Get.back,
                    icon:
                        const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),

              const Divider(),

              Obx(() {
                if (controller
                    .isPaymentLoading
                    .value) {
                  return const Padding(
                    padding:
                        EdgeInsets.all(30),
                    child:
                        Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                final history =
                    controller
                        .paymentHistory;

                if (history.isEmpty) {
                  return Padding(
                    padding:
                        const EdgeInsets.all(
                      30,
                    ),
                    child: Center(
                      child: Text(
                        'No payment history found',
                        style:
                            AppTextStyle.regular,
                      ),
                    ),
                  );
                }

                return Flexible(
                  child: ListView.separated(
                    shrinkWrap:
                        true,
                    itemCount:
                        history.length,
                    separatorBuilder:
                        (_, __) =>
                            const Divider(
                      height: 1,
                    ),
                    itemBuilder:
                        (context, index) {
                      final payment =
                          history[index];

                      return _paymentHistoryItem(
                        payment,
                        installment,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // PAYMENT HISTORY ITEM
  // ==============================================================

  Widget _paymentHistoryItem(
    EmiPaymentModel payment,
    EmiInstallmentModel?
        installment,
  ) {
    final isReversed =
        payment.isReversed;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color: isReversed
                  ? const Color(
                      0xFFFFEBEE,
                    )
                  : payment.isCash
                      ? const Color(
                          0xFFE8F5E9,
                        )
                      : const Color(
                          0xFFE3F2FD,
                        ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              payment.isCash
                  ? Icons.money
                  : Icons.phone_android,
              size: 20,
              color: isReversed
                  ? const Color(
                      0xFFC62828,
                    )
                  : payment.isCash
                      ? const Color(
                          0xFF2E7D32,
                        )
                      : const Color(
                          0xFF1565C0,
                        ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        payment.paymentMode ??
                            '-',
                        style:
                            AppTextStyle.semiBoldSmall,
                      ),
                    ),
                    Text(
                      _money(
                        payment.amount,
                      ),
                      style:
                          AppTextStyle.semiBold,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _formatDateTime(
                    payment.paymentDate,
                  ),
                  style:
                      AppTextStyle.regularSmall
                          .copyWith(
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Row(
                  children: [
                    _paymentStatusChip(
                      payment.status ??
                          '-',
                    ),
                    if (payment
                            .reversedByUsername !=
                        null) ...[
                      const SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: Text(
                          'By ${payment.reversedByUsername}',
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              AppTextStyle.regularSmall
                                  .copyWith(
                            fontSize: 10,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (payment
                            .reversalReason !=
                        null &&
                    payment
                        .reversalReason!
                        .isNotEmpty) ...[
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Reason: ${payment.reversalReason}',
                    style:
                        AppTextStyle.regularSmall
                            .copyWith(
                      fontSize: 10,
                      color:
                          Colors.red.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (!isReversed)
            IconButton(
              tooltip:
                  'Reverse Payment',
              onPressed: () {
                _confirmReversePayment(
                  payment,
                  installment,
                );
              },
              icon:
                  const Icon(
                Icons.undo,
                color:
                    Color(0xFFC62828),
              ),
            ),
        ],
      ),
    );
  }

  // ==============================================================
  // PAYMENT STATUS CHIP
  // ==============================================================

  Widget _paymentStatusChip(
    String status,
  ) {
    final reversed =
        status == 'Reversed';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration:
          BoxDecoration(
        color: reversed
            ? const Color(
                0xFFFFEBEE,
              )
            : const Color(
                0xFFE8F5E9,
              ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        status,
        style:
            AppTextStyle.semiBoldSmall
                .copyWith(
          fontSize: 9,
          color: reversed
              ? const Color(
                  0xFFC62828,
                )
              : const Color(
                  0xFF2E7D32,
                ),
        ),
      ),
    );
  }

  // ==============================================================
  // CONFIRM REVERSE PAYMENT
  // ==============================================================

  void _confirmReversePayment(
    EmiPaymentModel payment,
    EmiInstallmentModel?
        installment,
  ) {
    final reasonController =
        TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Reverse Payment?',
          style:
              AppTextStyle.semiBoldLarge,
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${_money(payment.amount)}',
              style:
                  AppTextStyle.semiBoldSmall,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'Mode: ${payment.paymentMode ?? '-'}',
              style:
                  AppTextStyle.regularSmall,
            ),
            const SizedBox(
              height: 14,
            ),
            TextField(
              controller:
                  reasonController,
              maxLines: 2,
              decoration:
                  const InputDecoration(
                labelText:
                    'Reversal Reason',
                hintText:
                    'Enter reason',
                border:
                    OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed:
                Get.back,
            child:
                const Text(
              'Cancel',
            ),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFFC62828,
              ),
              foregroundColor:
                  Colors.white,
            ),
            onPressed: () async {
              if (payment.id ==
                  null) {
                return;
              }

              if (installment?.id ==
                  null) {
                Get.back();

                Get.snackbar(
                  'Error',
                  'Installment not found',
                );

                return;
              }

              final reason =
                  reasonController
                      .text
                      .trim();

              Get.back();

              final success =
                  await controller
                      .reversePayment(
                paymentId:
                    payment.id!,
                installmentId:
                    installment!.id!,
                reason:
                    reason.isEmpty
                        ? 'Payment reversed by admin'
                        : reason,
              );

              if (success) {
                // Refresh payment history
                await controller
                    .loadPaymentHistory(
                  installment.id!,
                );
              }
            },
            child:
                const Text(
              'Reverse',
            ),
          ),
        ],
      ),
    ).then((_) {
      reasonController.dispose();
    });
  }

  // ==============================================================
  // DIALOG INFO ROW
  // ==============================================================

  Widget _dialogInfoRow(
    String label,
    String value,
  ) =>
      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                AppTextStyle.regular.copyWith(
              color:
                  Colors.grey.shade600,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  AppTextStyle.semiBold,
            ),
          ),
        ],
      );

  // ==============================================================
  // LOAD DATA
  // ==============================================================

  Future<void> _loadData() async {
    await controller
        .loadEnrollmentDetail(
      widget.enrollmentId,
    );

    await controller
        .loadEnrollmentSchedule(
      widget.enrollmentId,
    );

    // Load first available payment history
    // so payment summary is visible.
    if (controller.installments.isNotEmpty) {
      final firstInstallment =
          controller.installments.first;

      if (firstInstallment.id !=
          null) {
        await controller
            .loadPaymentHistory(
          firstInstallment.id!,
        );
      }
    }
  }

  // ==============================================================
  // STATUS ACTIONS
  // ==============================================================

  Widget _buildStatusActions(
    EnrollmentModel enrollment,
  ) {
    final status =
        enrollment.status ?? '';

    if (status == 'Closed' ||
        status == 'Cancelled') {
      return const SizedBox.shrink();
    }

    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Enrollment Actions',
            style:
                AppTextStyle.semiBoldLarge,
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              if (status != 'Closed')
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _confirmStatus(
                        enrollment,
                        'Closed',
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .check_circle_outline,
                    ),
                    label:
                        const Text(
                      'Close',
                    ),
                  ),
                ),
              if (status != 'Closed' &&
                  status != 'Cancelled')
                const SizedBox(
                  width: 10,
                ),
              if (status != 'Cancelled')
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _confirmStatus(
                        enrollment,
                        'Cancelled',
                      );
                    },
                    icon:
                        const Icon(
                      Icons.cancel_outlined,
                    ),
                    label:
                        const Text(
                      'Cancel',
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CONFIRM STATUS
  // ==============================================================

  void _confirmStatus(
    EnrollmentModel enrollment,
    String status,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(
          '$status Enrollment?',
          style:
              AppTextStyle.semiBoldLarge,
        ),
        content: Text(
          'Are you sure you want to mark this enrollment as $status?',
          style:
              AppTextStyle.regular,
        ),
        actions: [
          TextButton(
            onPressed:
                Get.back,
            child:
                const Text('No'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.primary,
              foregroundColor:
                  AppColors.black,
            ),
            onPressed: () async {
              Get.back();

              await controller
                  .changeEnrollmentStatus(
                enrollmentId:
                    enrollment.id!,
                status:
                    status,
              );
            },
            child:
                const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // DOUBLE PARSER
  // ==============================================================

  double _parseDouble(
    String value,
  ) {
    return double.tryParse(
          value.trim(),
        ) ??
        0;
  }

  // ==============================================================
  // INT PARSER
  // ==============================================================

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

  // ==============================================================
  // DOUBLE PARSER
  // ==============================================================

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

  // ==============================================================
  // MONEY
  // ==============================================================

  String _money(
    double? value,
  ) {
    return '₹${NumberFormat('#,##0.00').format(value ?? 0)}';
  }

  // ==============================================================
  // DATE
  // ==============================================================

  String _formatDate(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return '-';
    }

    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(
        DateTime.parse(value),
      );
    } catch (_) {
      return value;
    }
  }

  // ==============================================================
  // DATE TIME
  // ==============================================================

  String _formatDateTime(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return '-';
    }

    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(
        DateTime.parse(value),
      );
    } catch (_) {
      return value;
    }
  }
}