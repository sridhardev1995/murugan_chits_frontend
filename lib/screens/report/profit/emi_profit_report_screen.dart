import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sri_murugan_chits/models/report/emi_profit_report_model.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';
import 'emi_profit_report_controller.dart';

class EmiProfitReportScreen extends GetView<EmiProfitReportController> {
  const EmiProfitReportScreen({super.key});

  static const Color primaryColor = Color(0xFF8B1C1C);
  static const Color backgroundColor = Color(0xFFF6F7FB);
  static const Color textColor = Color(0xFF252525);
  static const Color mutedColor = Color(0xFF777777);

  static final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  String money(num value) => currencyFormat.format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        elevation: 0,
        title: Text(
          'EMI Profit Report',
          style: AppTextStyle.heading.copyWith(color: AppColors.black),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh report',
            onPressed: controller.loadReport,
            icon: const Icon(Icons.refresh, color: AppColors.black),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.report.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.report.value == null) {
          return _errorView();
        }

        final report = controller.report.value;

        if (report == null) {
          return _emptyView(
            message: 'No report data available.',
            icon: Icons.assessment_outlined,
          );
        }

        final items = controller.filteredItems;

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: controller.loadReport,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _buildReportHeader(),
              const SizedBox(height: 18),

              _buildSummaryGrid(report.summary),
              const SizedBox(height: 22),

              // _buildFilterSection(context),
              // const SizedBox(height: 20),

              // Row(
              //   children: [
              //     const Expanded(
              //       child: Text(
              //         'Enrollment Details',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //           color: textColor,
              //         ),
              //       ),
              //     ),
              //     Container(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 11,
              //         vertical: 6,
              //       ),
              //       decoration: BoxDecoration(
              //         color: primaryColor.withOpacity(0.09),
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       child: Text(
              //         '${items.length} records',
              //         style: const TextStyle(
              //           color: primaryColor,
              //           fontSize: 12,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 12),

              // if (controller.errorMessage.value.isNotEmpty) _inlineError(),

              // if (items.isEmpty)
              //   _emptyView(
              //     message: 'No enrollments match your filters.',
              //     icon: Icons.search_off,
              //   )
              // else
              //   ...items.map(_buildEnrollmentCard),

              // const SizedBox(height: 12),
              // _buildReportNote(),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildReportHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.18),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white24,
            child: Icon(Icons.trending_up, color: AppColors.black, size: 30),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMI Business Overview',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Loan amount, commission and collection',
                  style: TextStyle(color: AppColors.black, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY GRID
  // ============================================================

  Widget _buildSummaryGrid(EmiProfitReportSummary summary) {
    final cards = <_SummaryData>[
      _SummaryData(
        title: 'Total Enrollments',
        value: '${summary.enrollmentCount}',
        icon: Icons.groups_outlined,
        color: const Color(0xFF4568DC),
        isCurrency: false,
      ),
      _SummaryData(
        title: 'Requested Amount',
        value: money(summary.totalRequestedAmount),
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF287D50),
      ),
      _SummaryData(
        title: 'Profit Amount',
        value: money(summary.totalCommission),
        icon: Icons.trending_up,
        color: const Color(0xFF8B1C1C),
      ),
      _SummaryData(
        title: 'Total Disbursed',
        value: money(summary.totalDisbursed),
        icon: Icons.payments_outlined,
        color: const Color(0xFF8053B5),
      ),
      _SummaryData(
        title: 'Total Collected',
        value: money(summary.totalCollected),
        icon: Icons.check_circle_outline,
        color: const Color(0xFF168578),
      ),
      _SummaryData(
        title: 'Total Pending',
        value: money(summary.totalPending),
        icon: Icons.pending_actions_outlined,
        color: const Color(0xFFD47716),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 800 ? 3 : 2;

        final ratio = constraints.maxWidth >= 500 ? 1.85 : 1.45;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, index) {
            return _buildSummaryCard(cards[index]);
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(_SummaryData data) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 33,
                width: 33,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.color, size: 19),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: TextStyle(
                color: data.color,
                fontSize: data.isCurrency ? 15 : 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: primaryColor, size: 21),
              SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // DATE RANGE
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  title: 'Start Date',
                  value: controller.startDate.value,
                  onTap: () => _selectDate(context, isStartDate: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  title: 'End Date',
                  value: controller.endDate.value,
                  onTap: () => _selectDate(context, isStartDate: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // STATUS
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: controller.selectedStatus.value,
            isExpanded: true,
            decoration: _inputDecoration(
              label: 'Enrollment Status',
              prefixIcon: Icons.flag_outlined,
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Statuses')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              controller.setStatus(value);
            },
          ),
          const SizedBox(height: 14),

          // SEARCH
          TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            decoration:
                _inputDecoration(
                  label: 'Search customer or scheme',
                  prefixIcon: Icons.search,
                ).copyWith(
                  suffixIcon: IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      controller.searchController.clear();
                      controller.onSearchChanged('');
                    },
                    icon: const Icon(Icons.close, size: 19),
                  ),
                ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Clear Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.loadReport,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Apply / Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String title,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final displayValue = value == null
        ? 'Select date'
        : _formatPickedDate(value);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(
          label: title,
          prefixIcon: Icons.calendar_month_outlined,
        ),
        child: Text(
          displayValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: value == null ? mutedColor : textColor,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon, color: primaryColor, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final current = isStartDate
        ? controller.startDate.value
        : controller.endDate.value;

    final selected = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    if (isStartDate) {
      controller.setStartDate(selected);
    } else {
      controller.setEndDate(selected);
    }
  }

  // DateTime -> "dd-MM-yyyy" (filter date field)
  String _formatPickedDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  // String ("2026-10-14") -> "dd-MM-yyyy" (enrollment card start date)
  String _displayDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('dd-MM-yyyy').format(parsed);
  }

  // ============================================================
  // ENROLLMENT CARD
  // ============================================================

  Widget _buildEnrollmentCard(EmiProfitReportItem item) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAEAEA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: primaryColor.withOpacity(0.09),
                  child: const Icon(Icons.person_outline, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.customerName.isEmpty
                            ? 'Customer #${item.customerId}'
                            : item.customerName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enrollment #${item.enrollmentId}',
                        style: const TextStyle(fontSize: 12, color: mutedColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.schemeName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(item.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 13),

            _detailRow('Requested Amount', money(item.requestedAmount)),
            _detailRow('Commission Type', _commissionDescription(item)),
            _detailRow(
              'Commission Amount',
              money(item.commissionAmount),
              valueColor: primaryColor,
              isBold: true,
            ),
            _detailRow('Disbursed Amount', money(item.disbursedAmount)),
            _detailRow('Total EMI Payable', money(item.totalEmiPayable)),
            _detailRow(
              'Total Collected',
              money(item.totalCollected),
              valueColor: const Color(0xFF168578),
            ),
            _detailRow(
              'Pending Collection',
              money(item.pendingCollection),
              valueColor: item.pendingCollection > 0
                  ? const Color(0xFFD47716)
                  : const Color(0xFF168578),
              isBold: true,
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Start Date',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  const Spacer(),
                  Text(
                    _displayDate(item.startDate),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.date_range_outlined,
                    size: 16,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${item.weeks} weeks',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
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

  String _commissionDescription(EmiProfitReportItem item) {
    if (item.commissionType.toLowerCase() == 'percent') {
      return '${item.commissionValue}%';
    }

    return 'Fixed (${money(item.commissionValue)})';
  }

  Widget _detailRow(
    String label,
    String value, {
    Color valueColor = textColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: mutedColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                color: valueColor,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();

    final Color color = normalized == 'active'
        ? const Color(0xFF168578)
        : normalized == 'completed'
        ? const Color(0xFF4568DC)
        : normalized == 'cancelled'
        ? const Color(0xFFD04444)
        : const Color(0xFF777777);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY / ERROR STATES
  // ============================================================

  Widget _emptyView({required String message, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 55, color: primaryColor),
            const SizedBox(height: 14),
            const Text(
              'Unable to load EMI Profit Report',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: mutedColor, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: controller.loadReport,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inlineError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: controller.loadReport,
            icon: const Icon(Icons.refresh, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildReportNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0E1B9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 19, color: Color(0xFF946200)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Expected Commission is calculated from the saved enrollment '
              'commission. It is not the same as net profit. Collection '
              'and pending values are based on the report API response.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF72520A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY MODEL FOR UI
// ============================================================

class _SummaryData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCurrency;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isCurrency = true,
  });
}
