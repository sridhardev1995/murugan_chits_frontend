import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:sri_murugan_chits/models/dues/dues_model.dart';
import 'package:sri_murugan_chits/screens/dues/dues_controller.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class DuesScreen extends GetView<DuesController> {
  const DuesScreen({
    super.key,
  });

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color _success =
      Color(0xFF22A45D);

  static const Color _danger =
      Color(0xFFE0473F);

  static const Color _info =
      Color(0xFF3B82F6);

  static const Color _textGrey =
      Color(0xFF6B7280);

  static const Color _borderGrey =
      Color(0xFFE5E7EB);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        // foregroundColor: AppColors.white,
        elevation: 0,

        title: const Text(
          'Dues',
          style: AppTextStyle.heading,
        ),

        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.refreshDues,
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.black,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.black,
                    ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Obx(
        () {
          // ----------------------------------------------------
          // INITIAL LOADING
          // ----------------------------------------------------

          if (controller.isLoading.value &&
              controller.totalCount == 0) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (controller.errorMessage.value.isNotEmpty &&
              controller.totalCount == 0) {
            return _buildError();
          }

          // ----------------------------------------------------
          // CONTENT
          // ----------------------------------------------------

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refreshDues,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                24,
              ),
              children: [
                _buildSummary(),

                const SizedBox(height: 16),

                _buildSearch(),

                const SizedBox(height: 16),

                _buildTabs(),

                const SizedBox(height: 16),

                if (controller.isCurrentTabLoading)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else
                  _buildList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _summaryCard(
              title: 'Total Due',
              amount: controller.totalDue,
              count: controller.totalCount,
              color: AppColors.black,
              icon:
                  Icons.account_balance_wallet_rounded,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Obx(
            () => _summaryCard(
              title: 'Today',
              amount: controller.todayTotal,
              count: controller.todayCount,
              color: _info,
              icon: Icons.today_rounded,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Obx(
            () => _summaryCard(
              title: 'Overdue',
              amount: controller.overdueTotal,
              count: controller.overdueCount,
              color: _danger,
              icon:
                  Icons.warning_amber_rounded,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 17,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _formatCurrency(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.semiBold.copyWith(
              fontSize: 14,
              color: color,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            '$title ($count)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                AppTextStyle.regularSmall.copyWith(
              fontSize: 10.5,
              color: _textGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return TextField(
      onChanged: controller.updateSearch,
      style: AppTextStyle.regular,

      decoration: InputDecoration(
        hintText:
            'Search customer, mobile, scheme...',

        hintStyle:
            AppTextStyle.regularSmall.copyWith(
          color: _textGrey,
        ),

        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _textGrey,
        ),

        suffixIcon: Obx(
          () => controller.searchText.value.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.updateSearch('');
                  },
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 20,
                    color: AppColors.black,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        filled: true,
        fillColor: AppColors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    return Obx(
      () => Row(
        children: [
          _tabButton(
            title: 'All',
            count: controller.totalCount,
            index: 0,
          ),

          const SizedBox(width: 8),

          _tabButton(
            title: 'Today',
            count: controller.todayCount,
            index: 1,
          ),

          const SizedBox(width: 8),

          _tabButton(
            title: 'Overdue',
            count: controller.overdueCount,
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required int count,
    required int index,
  }) {
    final selected =
        controller.selectedTab.value == index;

    return Expanded(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(10),
        onTap: () {
          controller.changeTab(index);
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.white,
            borderRadius:
                BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.black
                  : _borderGrey,
            ),
          ),
          child: Center(
            child: Text(
              '$title ($count)',
              style:
                  AppTextStyle.semiBoldSmall
                      .copyWith(
                color: selected
                    ? AppColors.white
                    : AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _buildList() {
    final list = controller.currentList;

    if (list.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: list
          .map(
            (item) => _buildDueCard(item),
          )
          .toList(),
    );
  }

  // ============================================================
  // DUE CARD
  // ============================================================

  Widget _buildDueCard(
    DuesModel item,
  ) {
    final isDiwali =
        item.type == 'Diwali';

    final accent = isDiwali
        ? AppColors.primary
        : _info;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: item.isOverdue
              ? _danger.withOpacity(0.20)
              : _borderGrey,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black
                    .withOpacity(0.035),
            blurRadius: 8,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ====================================================
          // CUSTOMER HEADER
          // ====================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      accent.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDiwali
                      ? Icons.card_giftcard_rounded
                      : Icons
                          .account_balance_wallet_rounded,
                  color: accent,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName
                              .trim()
                              .isEmpty
                          ? 'Unknown Customer'
                          : item.customerName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyle
                              .semiBoldLarge
                              .copyWith(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: _textGrey,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          item.customerPhone
                                  .trim()
                                  .isEmpty
                              ? '-'
                              : item.customerPhone,
                          style:
                              AppTextStyle
                                  .regularSmall
                                  .copyWith(
                            color: _textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _typeBadge(
                item.type,
                accent,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ====================================================
          // DETAILS
          // ====================================================

          Container(
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.scaffold,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _detailItem(
                        icon: Icons
                            .calendar_today_outlined,
                        label: 'Due Date',
                        value:
                            _formatDate(
                          item.dueDate,
                        ),
                      ),
                    ),

                    Expanded(
                      child: _detailItem(
                        icon:
                            Icons.numbers_rounded,
                        label: isDiwali
                            ? 'Week'
                            : 'EMI Week',
                        value:
                            item.weekNo
                                    ?.toString() ??
                                '-',
                      ),
                    ),

                    Expanded(
                      child: _detailItem(
                        icon:
                            Icons.category_outlined,
                        label: 'Type',
                        value: item.type,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _amountDetail(
                        label: 'Due',
                        amount: item.amount,
                        color: AppColors.black,
                      ),
                    ),

                    Expanded(
                      child: _amountDetail(
                        label: 'Paid',
                        amount:
                            item.paidAmount,
                        color: _success,
                      ),
                    ),

                    Expanded(
                      child: _amountDetail(
                        label: 'Balance',
                        amount:
                            item.balanceAmount,
                        color: _danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // STATUS
          // ====================================================

          Row(
            children: [
              if (item.isOverdue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        _danger.withOpacity(
                      0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      7,
                    ),
                  ),
                  child: Text(
                    '${item.overdueDays} days overdue',
                    style:
                        AppTextStyle
                            .semiBoldSmall
                            .copyWith(
                      color: _danger,
                      fontSize: 11,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        _info.withOpacity(
                      0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      7,
                    ),
                  ),
                  child: Text(
                    'Today Due',
                    style:
                        AppTextStyle
                            .semiBoldSmall
                            .copyWith(
                      color: _info,
                      fontSize: 11,
                    ),
                  ),
                ),

              const Spacer(),

              Text(
                'Balance ${_formatCurrency(item.balanceAmount)}',
                style:
                    AppTextStyle.semiBold.copyWith(
                  color: _danger,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ====================================================
          // WHATSAPP
          // ====================================================

          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () {
                _showWhatsAppMessage(item);
              },
              icon: const Icon(
                Icons.message_outlined,
                size: 18,
              ),
              label: const Text(
                'WhatsApp Reminder',
                style:
                    AppTextStyle.semiBold,
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor: _success,
                side: BorderSide(
                  color:
                      _success.withOpacity(
                    0.50,
                  ),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TYPE BADGE
  // ============================================================

  Widget _typeBadge(
    String type,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style:
            AppTextStyle.semiBoldSmall
                .copyWith(
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ITEM
  // ============================================================

  Widget _detailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: _textGrey,
            ),

            const SizedBox(width: 4),

            Text(
              label,
              style:
                  AppTextStyle.regularSmall
                      .copyWith(
                color: _textGrey,
                fontSize: 10.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          value,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              AppTextStyle.semiBoldSmall,
        ),
      ],
    );
  }

  // ============================================================
  // AMOUNT DETAIL
  // ============================================================

  Widget _amountDetail({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              AppTextStyle.regularSmall
                  .copyWith(
            color: _textGrey,
            fontSize: 10.5,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          _formatCurrency(amount),
          style:
              AppTextStyle.semiBold.copyWith(
            color: color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 70,
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .check_circle_outline_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'No dues found',
            style:
                AppTextStyle.semiBoldLarge,
          ),

          const SizedBox(height: 6),

          Text(
            'There are no pending payments in this section.',
            textAlign: TextAlign.center,
            style:
                AppTextStyle.regularSmall
                    .copyWith(
              color: _textGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 46,
              color: _textGrey,
            ),

            const SizedBox(height: 12),

            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style:
                  AppTextStyle.regularSmall
                      .copyWith(
                color: _textGrey,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed:
                  controller.loadDues,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    AppColors.black,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Retry',
                style:
                    AppTextStyle.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WHATSAPP MESSAGE
  // ============================================================

 void _showWhatsAppMessage(
  DuesModel item,
) {
  final phone = _cleanPhoneNumber(
    item.customerPhone,
  );

  if (phone.isEmpty) {
    Get.snackbar(
      'WhatsApp',
      'Customer mobile number not available.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  final String schemeType = item.type == 'Diwali'
      ? 'Diwali Chit'
      : 'EMI';

  final String installmentText =
      item.weekNo != null
          ? item.type == 'Diwali'
              ? 'Week ${item.weekNo}'
              : 'EMI Week ${item.weekNo}'
          : '';

  final String dueDate =
      _formatDate(item.dueDate);

  final String message;

  if (item.isOverdue) {
    message =
        '''
🙏 Sri Murugan Chits

Dear ${item.customerName},

This is a friendly reminder regarding your pending payment.

📌 Scheme: $schemeType
📅 $installmentText
📆 Due Date: $dueDate

💰 Amount Due: ${_formatCurrency(item.amount)}
💵 Amount Paid: ${_formatCurrency(item.paidAmount)}
⚠️ Balance Due: ${_formatCurrency(item.balanceAmount)}

⏰ This payment is overdue by ${item.overdueDays} days.

Kindly make the pending payment at your earliest convenience to keep your account up to date.

Thank you for your cooperation.

Regards,
Sri Murugan Chits
''';
  } else {
    message =
        '''
🙏 Sri Murugan Chits

Dear ${item.customerName},

This is a friendly reminder that your payment is due today.

📌 Scheme: $schemeType
📅 $installmentText
📆 Due Date: $dueDate

💰 Amount Due: ${_formatCurrency(item.amount)}
💵 Amount Paid: ${_formatCurrency(item.paidAmount)}
⚠️ Balance Due: ${_formatCurrency(item.balanceAmount)}

Kindly make the payment today.

Thank you for your cooperation.

Regards,
Sri Murugan Chits
''';
  }

  Get.dialog(
    AlertDialog(
      backgroundColor: AppColors.white,

      title: const Text(
        'WhatsApp Reminder',
        style: AppTextStyle.semiBoldLarge,
      ),

      content: SingleChildScrollView(
        child: Text(
          message,
          style: AppTextStyle.regular,
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            'Cancel',
            style: AppTextStyle.semiBold,
          ),
        ),

        ElevatedButton.icon(
          onPressed: () async {
            Get.back();

            await _openWhatsApp(
              phone: phone,
              message: message,
            );
          },
          icon: const Icon(
            Icons.message,
            size: 18,
          ),
          label: const Text(
            'Open WhatsApp',
            style: AppTextStyle.semiBold,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _success,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    ),
  );
}
Future<void> _openWhatsApp({
  required String phone,
  required String message,
}) async {
  try {
    final encodedMessage =
        Uri.encodeComponent(message);

    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$phone?text=$encodedMessage',
    );

    final launched = await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      Get.snackbar(
        'WhatsApp',
        'Unable to open WhatsApp.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    Get.snackbar(
      'WhatsApp',
      'Unable to open WhatsApp.',
      snackPosition:
          SnackPosition.BOTTOM,
    );
  }
}

String _cleanPhoneNumber(
  String phone,
) {
  String value = phone.trim();

  if (value.isEmpty) {
    return '';
  }

  // Remove spaces, -, brackets, etc.
  value = value.replaceAll(
    RegExp(r'[^0-9+]'),
    '',
  );

  // Already India country code
  if (value.startsWith('+91')) {
    return value.substring(1);
  }

  if (value.startsWith('91') &&
      value.length == 12) {
    return value;
  }

  // Indian 10-digit number
  if (value.length == 10) {
    return '91$value';
  }

  return value.replaceFirst(
    '+',
    '',
  );
}

  // ============================================================
  // HELPERS
  // ============================================================

  static String _formatCurrency(
    double amount,
  ) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  static String _formatDate(
    String? date,
  ) {
    if (date == null ||
        date.trim().isEmpty) {
      return '-';
    }

    try {
      final parsed =
          DateTime.parse(date);

      return DateFormat(
        'dd MMM yyyy',
      ).format(parsed);
    } catch (_) {
      return date;
    }
  }
}