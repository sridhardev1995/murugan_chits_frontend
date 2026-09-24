import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/report/emi_payment_report_controller.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';



class EmiPaymentReportScreen extends GetView<EmiPaymentReportController> {
  const EmiPaymentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'EMI Payment Report',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () => controller.loadReport(refresh: true),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.loading.value && controller.payments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B1C1C)),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      children: [
        _buildFilterCard(context),
        const SizedBox(height: 14),
        _buildSummarySection(),
        const SizedBox(height: 14),
        _buildReportHeader(),
        const SizedBox(height: 10),
        _buildPaymentList(),
        const SizedBox(height: 14),
        _buildPagination(),
      ],
    );
  }

  // ============================================================
  // FILTER CARD
  // ============================================================

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.filter_alt_outlined,
                color: Color(0xFF8B1C1C),
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Report Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // DATE
          Row(
            children: [
              Expanded(
                child: _dateField(
                  context: context,
                  label: 'From Date',
                  value: controller.fromDate.value,
                  onTap: () => _selectFromDate(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateField(
                  context: context,
                  label: 'To Date',
                  value: controller.toDate.value,
                  onTap: () => _selectToDate(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // PAYMENT MODE
          _dropdownField(
            label: 'Payment Mode',
            value: controller.paymentMode.value.isEmpty
                ? 'All'
                : controller.paymentMode.value,
            items: const ['All', 'Cash', 'UPI'],
            icon: Icons.payments_outlined,
            onChanged: (value) {
              if (value == null) return;

              controller.setPaymentMode(value == 'All' ? '' : value);
            },
          ),

          const SizedBox(height: 12),

          // STATUS
          _dropdownField(
            label: 'Status',
            value: controller.status.value.isEmpty
                ? 'All'
                : controller.status.value,
            items: const ['All', 'Active', 'Reversed'],
            icon: Icons.info_outline,
            onChanged: (value) {
              if (value == null) return;

              controller.setStatus(value == 'All' ? '' : value);
            },
          ),

          const SizedBox(height: 14),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: controller.loading.value
                        ? null
                        : () {
                            controller.applyFilters();
                          },
                    icon: const Icon(Icons.search, size: 20),
                    label: const Text(
                      'Search',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B1C1C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: controller.loading.value
                      ? null
                      : () {
                          controller.resetFilters();
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B1C1C),
                    side: const BorderSide(color: Color(0xFF8B1C1C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(fontWeight: FontWeight.w600),
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
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: Color(0xFF8B1C1C),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value.isEmpty ? 'Select Date' : value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: value.isEmpty ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF8B1C1C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.75,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _summaryCard(
              title: 'Total Collection',
              value: _money(controller.totalCollection.value),
              icon: Icons.account_balance_wallet_outlined,
            ),
            _summaryCard(
              title: 'Cash Total',
              value: _money(controller.cashTotal.value),
              icon: Icons.money_outlined,
            ),
            _summaryCard(
              title: 'UPI Total',
              value: _money(controller.upiTotal.value),
              icon: Icons.phone_android_outlined,
            ),
            _summaryCard(
              title: 'Reversed',
              value: _money(controller.reversedTotal.value),
              icon: Icons.undo_outlined,
            ),
          ],
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1C1C).withOpacity(.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: Color(0xFF8B1C1C),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Transactions',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Text(
                '${controller.transactionCount.value}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B1C1C),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF8B1C1C).withOpacity(.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: const Color(0xFF8B1C1C), size: 20),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        if (controller.loadingMore.value)
          const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF8B1C1C),
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
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No payment transactions found',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: controller.payments.map((payment) {
        return _paymentCard(payment);
      }).toList(),
    );
  }

  Widget _paymentCard(Map<String, dynamic> payment) {
    final String customerName = _stringValue(payment['customer_name']);

    final String schemeName = _stringValue(payment['scheme_name']);

    final int weekNo = _intValue(payment['week_no']);

    final double amount = _doubleValue(payment['amount']);

    final String mode = _stringValue(payment['payment_mode']);

    final String status = _stringValue(payment['status']);

    final String paymentDate = _stringValue(payment['payment_date']);

    final bool isReversed = status.toLowerCase() == 'reversed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isReversed ? Colors.red.shade100 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1C1C).withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF8B1C1C),
                ),
              ),
              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.isEmpty ? 'Unknown Customer' : customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (schemeName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        schemeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 14),

          Divider(height: 1, color: Colors.grey.shade200),

          const SizedBox(height: 12),

          // DETAILS
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  icon: Icons.calendar_view_week_outlined,
                  label: 'Week',
                  value: 'Week $weekNo',
                ),
              ),
              Expanded(
                child: _detailItem(
                  icon: Icons.payments_outlined,
                  label: 'Mode',
                  value: mode.isEmpty ? '-' : mode,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _detailItem(
                  icon: Icons.event_outlined,
                  label: 'Payment Date',
                  value: _displayDate(paymentDate),
                ),
              ),
              Expanded(
                child: _detailItem(
                  icon: Icons.currency_rupee,
                  label: 'Amount',
                  value: _money(amount),
                  valueBold: true,
                ),
              ),
            ],
          ),

          if (isReversed) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 17,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'This payment has been reversed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String label,
    required String value,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.grey.shade600),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    final bool reversed = status.toLowerCase() == 'reversed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: reversed ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: reversed ? Colors.red.shade700 : Colors.green.shade700,
        ),
      ),
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination() {
    if (controller.payments.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool hasMore =
        controller.currentPage.value < controller.totalPages.value;

    return Column(
      children: [
        Text(
          'Page ${controller.currentPage.value} '
          'of ${controller.totalPages.value} '
          '• ${controller.totalRecords.value} transactions',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        if (hasMore)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: controller.loadingMore.value
                  ? null
                  : () {
                      controller.loadMore();
                    },
              icon: controller.loadingMore.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more),
              label: Text(
                controller.loadingMore.value ? 'Loading...' : 'Load More',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B1C1C),
                side: const BorderSide(color: Color(0xFF8B1C1C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // DATE PICKERS
  // ============================================================

 Future<void> _selectFromDate(BuildContext context) async {
  final DateTime? selected = await showDatePicker(
    context: context,
    initialDate: _parseDate(controller.fromDate.value) ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );

  if (selected == null) return;

  controller.setFromDate(selected); // was: controller.setFromDate(_formatDate(selected))
}

Future<void> _selectToDate(BuildContext context) async {
  final DateTime? selected = await showDatePicker(
    context: context,
    initialDate: _parseDate(controller.toDate.value) ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );

  if (selected == null) return;

  controller.setToDate(selected); // was: controller.setToDate(_formatDate(selected))
}

  // ============================================================
  // HELPERS
  // ============================================================

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  int _intValue(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }

  double _doubleValue(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String _money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  String _displayDate(String value) {
    if (value.isEmpty) return '-';

    try {
      final DateTime date = DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) return null;

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
