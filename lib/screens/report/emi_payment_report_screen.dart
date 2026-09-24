import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/report/emi_payment_report_controller.dart';

// import 'package:sri_murugan_chits/screens/report/controller/emi_payment_report_controller.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';

class EmiPaymentReportScreen
    extends GetView<EmiPaymentReportController> {
  const EmiPaymentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'EMI Payment Report',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.black,
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadReport(),
            icon: const Icon(
              Icons.refresh,
              color: AppColors.black,
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.loading.value &&
              controller.payments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.loadReport(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilters(context),
                const SizedBox(height: 16),
                _buildSummary(),
                const SizedBox(height: 18),
                _buildReportHeader(),
                const SizedBox(height: 10),
                _buildPaymentList(),
                const SizedBox(height: 16),
                _buildPagination(),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Filters',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          // CUSTOMER
          const Text(
            'Customer',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 7),

          Obx(
            () => _buildCustomerDropdown(),
          ),

          const SizedBox(height: 14),

          // SCHEME
          const Text(
            'Scheme',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 7),

          Obx(
            () => _buildSchemeDropdown(),
          ),

          const SizedBox(height: 14),

          // DATE
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  title: 'From Date',
                  value: controller.fromDate.value,
                  onTap: () => _selectFromDate(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  title: 'To Date',
                  value: controller.toDate.value,
                  onTap: () => _selectToDate(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // PAYMENT MODE + STATUS
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildPaymentModeDropdown(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildStatusDropdown(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: controller.loading.value
                        ? null
                        : () => controller.loadReport(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.search,
                      size: 20,
                    ),
                    label: const Text(
                      'Search',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => controller.resetFilters(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(
                      color: AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOMER DROPDOWN
  // ============================================================

  Widget _buildCustomerDropdown() {
    if (controller.customersLoading.value) {
      return _loadingDropdown('Loading customers...');
    }

    final selectedId =
        controller.selectedCustomerId.value;

    final validValue = controller.customers.any(
      (customer) =>
          customer.id.toString() == selectedId,
    )
        ? selectedId
        : '';

    return DropdownButtonFormField<String>(
      value: validValue,
      isExpanded: true,
      decoration: _inputDecoration(
        Icons.person_outline,
        'Select Customer',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text(
            'All Customers',
            style: TextStyle(
              color: AppColors.black,
            ),
          ),
        ),
        ...controller.customers.map(
          (customer) {
            return DropdownMenuItem<String>(
              value: customer.id.toString(),
              child: Text(
                '${customer.name} - ${customer.phone}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
      onChanged: (value) {
        controller.setCustomer(
          value == null || value.isEmpty
              ? null
              : value,
        );
      },
    );
  }

  // ============================================================
  // SCHEME DROPDOWN
  // ============================================================

  Widget _buildSchemeDropdown() {
    if (controller.schemesLoading.value) {
      return _loadingDropdown('Loading schemes...');
    }

    final selectedId =
        controller.selectedSchemeId.value;

    final validValue = controller.schemes.any(
      (scheme) =>
          scheme.id.toString() == selectedId,
    )
        ? selectedId
        : '';

    return DropdownButtonFormField<String>(
      value: validValue,
      isExpanded: true,
      decoration: _inputDecoration(
        Icons.account_balance_wallet_outlined,
        'Select Scheme',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text(
            'All Schemes',
            style: TextStyle(
              color: AppColors.black,
            ),
          ),
        ),
        ...controller.schemes.map(
          (scheme) {
            return DropdownMenuItem<String>(
              value: scheme.id.toString(),
              child: Text(
                scheme.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
      onChanged: (value) {
        controller.setScheme(
          value == null || value.isEmpty
              ? null
              : value,
        );
      },
    );
  }

  Widget _loadingDropdown(String text) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _inputDecoration(
          Icons.calendar_month_outlined,
          title,
        ),
        child: Text(
          value.isEmpty
              ? 'Select date'
              : value,
          style: TextStyle(
            fontSize: 13,
            color: value.isEmpty
                ? Colors.grey.shade600
                : AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT MODE
  // ============================================================

  Widget _buildPaymentModeDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.paymentMode.value,
      isExpanded: true,
      decoration: _inputDecoration(
        Icons.payments_outlined,
        'Payment Mode',
      ),
      items: const [
        DropdownMenuItem(
          value: '',
          child: Text('All Modes'),
        ),
        DropdownMenuItem(
          value: 'Cash',
          child: Text('Cash'),
        ),
        DropdownMenuItem(
          value: 'UPI',
          child: Text('UPI'),
        ),
      ],
      onChanged: (value) {
        controller.setPaymentMode(
          value ?? '',
        );
      },
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.status.value,
      isExpanded: true,
      decoration: _inputDecoration(
        Icons.filter_alt_outlined,
        'Status',
      ),
      items: const [
        DropdownMenuItem(
          value: '',
          child: Text('All Status'),
        ),
        DropdownMenuItem(
          value: 'Active',
          child: Text('Active'),
        ),
        DropdownMenuItem(
          value: 'Reversed',
          child: Text('Reversed'),
        ),
      ],
      onChanged: (value) {
        controller.setStatus(
          value ?? '',
        );
      },
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Summary',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Total Collection',
                value: _money(
                  controller.totalCollection.value,
                ),
                icon: Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                title: 'Cash',
                value: _money(
                  controller.cashTotal.value,
                ),
                icon: Icons.money,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'UPI',
                value: _money(
                  controller.upiTotal.value,
                ),
                icon: Icons.phone_android,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                title: 'Reversed',
                value: _money(
                  controller.reversedTotal.value,
                ),
                icon: Icons.undo,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _summaryCard(
          title: 'Transactions',
          value: controller.transactionCount.value
              .toString(),
          icon: Icons.receipt_long,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.black,
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
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
  // REPORT HEADER
  // ============================================================

  Widget _buildReportHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Payment Transactions',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
        Text(
          '${controller.totalRecords.value} Records',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT LIST
  // ============================================================

  Widget _buildPaymentList() {
    if (controller.payments.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: controller.payments.map(
        (payment) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: _buildPaymentCard(payment),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _buildPaymentCard(
    Map<String, dynamic> payment,
  ) {
    final customerName = _stringValue(
      payment['customer_name'],
      'Unknown Customer',
    );

    final customerPhone = _stringValue(
      payment['customer_phone'],
      '',
    );

    final schemeName = _stringValue(
      payment['scheme_name'],
      'Unknown Scheme',
    );

    final paymentMode = _stringValue(
      payment['payment_mode'],
      '-',
    );

    final status = _stringValue(
      payment['status'],
      'Active',
    );

    final amount = _doubleValue(
      payment['amount'],
    );

    final dueDate = _stringValue(
      payment['due_date'],
      '-',
    );

    final paymentDate = _stringValue(
      payment['payment_date'],
      '-',
    );

    final weekNo =
        payment['week_no']?.toString() ?? '-';

    final installmentAmount =
        _doubleValue(
      payment['installment_amount'],
    );

    final reversedBy = _stringValue(
      payment['reversed_by_username'],
      '',
    );

    final reversalReason = _stringValue(
      payment['reversal_reason'],
      '',
    );

    final reversed =
        status.toLowerCase() == 'reversed';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reversed
              ? Colors.red.shade200
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // TOP
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  paymentMode == 'UPI'
                      ? Icons.phone_android
                      : Icons.money,
                  color: AppColors.black,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),

                    if (customerPhone.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Text(
                          customerPhone,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 4),

                    Text(
                      schemeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 15),

          // AMOUNT
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.scaffold,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _detailItem(
                    'Paid Amount',
                    _money(amount),
                    isAmount: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 35,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _detailItem(
                    'Payment Mode',
                    paymentMode,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // WEEK + INSTALLMENT
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  Icons.calendar_today_outlined,
                  'Week',
                  'Week $weekNo',
                ),
              ),
              Expanded(
                child: _infoRow(
                  Icons.payments_outlined,
                  'Installment',
                  _money(installmentAmount),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // DUE DATE
          _infoRow(
            Icons.event_outlined,
            'Due Date',
            _formatDate(dueDate),
          ),

          const SizedBox(height: 8),

          // PAID DATE
          _infoRow(
            Icons.check_circle_outline,
            'Paid Date',
            _formatDate(paymentDate),
          ),

          // TIMING
          if (!reversed) ...[
            const SizedBox(height: 10),
            _buildPaymentTiming(
              dueDate: dueDate,
              paymentDate: paymentDate,
            ),
          ],

          // REVERSED
          if (reversed) ...[
            const SizedBox(height: 12),
            _buildReversalInfo(
              reversedBy: reversedBy,
              reason: reversalReason,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT TIMING
  // ============================================================

  Widget _buildPaymentTiming({
    required String dueDate,
    required String paymentDate,
  }) {
    final due = DateTime.tryParse(dueDate);
    final paid = DateTime.tryParse(paymentDate);

    if (due == null || paid == null) {
      return const SizedBox.shrink();
    }

    final dueOnly = DateTime(
      due.year,
      due.month,
      due.day,
    );

    final paidOnly = DateTime(
      paid.year,
      paid.month,
      paid.day,
    );

    final difference =
        paidOnly.difference(dueOnly).inDays;

    if (difference > 0) {
      return _timingBadge(
        icon: Icons.warning_amber_rounded,
        text: 'Delayed • $difference days late',
        color: Colors.red,
      );
    }

    if (difference < 0) {
      return _timingBadge(
        icon: Icons.speed,
        text:
            'Paid Early • ${difference.abs()} days before due',
        color: Colors.green,
      );
    }

    return _timingBadge(
      icon: Icons.check_circle_outline,
      text: 'Paid On Time',
      color: Colors.green,
    );
  }

  Widget _timingBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVERSAL
  // ============================================================

  Widget _buildReversalInfo({
    required String reversedBy,
    required String reason,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.undo,
                size: 18,
                color: Colors.red,
              ),
              const SizedBox(width: 7),
              Text(
                'Payment Reversed',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),

          if (reversedBy.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reversed By: $reversedBy',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],

          if (reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Reason: $reason',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    final isReversed =
        status.toLowerCase() == 'reversed';

    final color =
        isReversed ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ITEM
  // ============================================================

  Widget _detailItem(
    String title,
    String value, {
    bool isAmount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 15 : 13,
              fontWeight: isAmount
                  ? FontWeight.w700
                  : FontWeight.w600,
              color: isAmount
                  ? AppColors.black
                  : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 3,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.black,
          ),
          const SizedBox(width: 8),
          Text(
            '$title:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'No payment transactions found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try changing the filters or date range.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination() {
    if (controller.totalPages.value <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                controller.currentPage.value > 1 &&
                        !controller.loadingMore.value
                    ? controller.previousPage
                    : null,
            icon: const Icon(
              Icons.chevron_left,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Page ${controller.currentPage.value} '
                'of ${controller.totalPages.value}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed:
                controller.currentPage.value <
                            controller.totalPages.value &&
                        !controller.loadingMore.value
                    ? controller.nextPage
                    : null,
            icon: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE PICKERS
  // ============================================================

  Future<void> _selectFromDate(
    BuildContext context,
  ) async {
    final initial =
        _parseDate(controller.fromDate.value);

    final selected = await showDatePicker(
      context: context,
      initialDate:
          initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      controller.setFromDate(selected);
    }
  }

  Future<void> _selectToDate(
    BuildContext context,
  ) async {
    final initial =
        _parseDate(controller.toDate.value);

    final selected = await showDatePicker(
      context: context,
      initialDate:
          initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      controller.setToDate(selected);
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
    IconData icon,
    String label,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: AppColors.black,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _stringValue(
    dynamic value,
    String fallback,
  ) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    return result.isEmpty
        ? fallback
        : result;
  }

  double _doubleValue(dynamic value) {
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

  String _money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  String _formatDate(String value) {
    if (value.isEmpty || value == '-') {
      return '-';
    }

    final date =
        DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}