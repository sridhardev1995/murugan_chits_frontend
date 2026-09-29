import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'collection_controller.dart';
import 'package:sri_murugan_chits/models/collections/diwali_collection_model.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

class DiwaliCollecion extends GetView<CollectionController> {
  const DiwaliCollecion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,

        title: Text(
          'Collections',
          style: AppTextStyle.heading,
        ),

        centerTitle: true,

        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.refreshCollections,
              icon: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.black,
                        strokeWidth: 2,
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

      // ============================================================
      // BODY
      // ============================================================

      body: Obx(
        () {
          if (controller.isLoading.value &&
              controller.todayDueList.isEmpty &&
              controller.overdueList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.black,
            backgroundColor: AppColors.primary,
            onRefresh: controller.refreshCollections,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummary(),

                const SizedBox(height: 18),

                _buildTabs(),

                const SizedBox(height: 16),

                _buildCollectionList(),
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
          child: _summaryCard(
            title: 'Today Due',
            value: _money(
              controller.todayDueAmount,
            ),
            icon: Icons.event_available_outlined,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _summaryCard(
            title: 'Overdue',
            value: _money(
              controller.overdueAmount,
            ),
            icon: Icons.warning_amber_rounded,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(0.18),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.black,
                  size: 21,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style:
                    AppTextStyle.regularSmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style:
                AppTextStyle.semiBoldLarge,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    return Obx(
      () {
        final selected =
            controller.selectedTab.value;

        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
                BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.black.withOpacity(
                  0.03,
                ),
                blurRadius: 8,
                offset:
                    const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _tabButton(
                  title: 'Today Due',
                  count: controller
                      .todayDueList
                      .length,
                  selected: selected == 0,
                  onTap: () {
                    controller.changeTab(0);
                  },
                ),
              ),

              Expanded(
                child: _tabButton(
                  title: 'Overdue',
                  count: controller
                      .overdueList
                      .length,
                  selected: selected == 1,
                  onTap: () {
                    controller.changeTab(1);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton({
    required String title,
    required int count,
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
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: selected
                  ? AppTextStyle.semiBoldSmall
                  : AppTextStyle.semiBoldSmall
                      .copyWith(
                      color: AppColors.black
                          .withOpacity(0.55),
                    ),
            ),

            const SizedBox(width: 7),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.white
                        .withOpacity(0.20)
                    : AppColors.primary
                        .withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: selected
                    ? AppTextStyle.semiBoldSmall
                        .copyWith(
                        color:
                            AppColors.black,
                      )
                    : AppTextStyle
                        .semiBoldSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COLLECTION LIST
  // ============================================================

  Widget _buildCollectionList() {
    final list =
        controller.currentList;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list
          .map(
            (item) => _buildCollectionCard(
              item,
            ),
          )
          .toList(),
    );
  }

  // ============================================================
  // COLLECTION CARD
  // ============================================================

  Widget _buildCollectionCard(
    DiwaliCollectionModel item,
  ) {
    final balance =
        item.balanceDue;

    final paid =
        item.amountPaid;

    final due =
        item.amountDue;

    final isPaid =
        balance <= 0;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black.withOpacity(
              0.04,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            // ==================================================
            // CUSTOMER
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(0.18),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color:
                        AppColors.black,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.customerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyle.semiBoldLarge,
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: AppColors
                                .black
                                .withOpacity(
                              0.55,
                            ),
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            item.customerPhone,
                            style:
                                AppTextStyle
                                    .regularSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _statusBadge(
                  item.status,
                  isPaid,
                ),
              ],
            ),

            const SizedBox(height: 15),

            Divider(
              height: 1,
              color: AppColors.black
                  .withOpacity(0.08),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // INSTALLMENT INFO
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    icon:
                        Icons.calendar_today_outlined,
                    label: 'Due Date',
                    value:
                        _formatDate(
                      item.dueDate,
                    ),
                  ),
                ),

                Expanded(
                  child: _infoItem(
                    icon:
                        Icons.format_list_numbered,
                    label: 'Week',
                    value:
                        'Week ${item.weekNumber}',
                  ),
                ),

                Expanded(
                  child: _infoItem(
                    icon:
                        Icons.confirmation_number_outlined,
                    label: 'Chits',
                    value:
                        '${item.chits}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // AMOUNT
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color:
                    AppColors.scaffold,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _amountItem(
                      title: 'Due',
                      value: due,
                    ),
                  ),

                  Expanded(
                    child: _amountItem(
                      title: 'Paid',
                      value: paid,
                    ),
                  ),

                  Expanded(
                    child: _amountItem(
                      title: 'Balance',
                      value: balance,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // COLLECT BUTTON
            // ==================================================

            if (!isPaid) ...[
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    _showCollectDialog(
                      item,
                    );
                  },

                  icon: const Icon(
                    Icons.payments_outlined,
                    size: 19,
                    color:
                        AppColors.black,
                  ),

                  label: Text(
                    'Collect Payment',
                    style:
                        AppTextStyle.button
                            .copyWith(
                      color:
                          AppColors.black,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        AppColors.black,
                    elevation: 0,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 13,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 17,
          color:
              AppColors.black.withOpacity(
            0.55,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          style:
              AppTextStyle.regularSmall.copyWith(
            fontSize: 10,
            color: AppColors.black
                .withOpacity(0.45),
          ),
        ),

        const SizedBox(height: 3),

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
  // AMOUNT ITEM
  // ============================================================

  Widget _amountItem({
    required String title,
    required double value,
  }) {
    return Column(
      children: [
        Text(
          title,
          style:
              AppTextStyle.regularSmall.copyWith(
            fontSize: 10,
            color: AppColors.black
                .withOpacity(0.45),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          _money(value),
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              AppTextStyle.semiBold,
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(
    String status,
    bool isPaid,
  ) {
    final normalized =
        status.toLowerCase();

    String text;

    if (isPaid ||
        normalized == 'paid') {
      text = 'Paid';
    } else if (normalized ==
        'partial') {
      text = 'Partial';
    } else {
      text = 'Pending';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary
            .withOpacity(0.18),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
            AppTextStyle.semiBoldSmall,
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    final isToday =
        controller.selectedTab.value == 0;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black.withOpacity(
              0.03,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.18),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Icon(
              isToday
                  ? Icons
                      .event_available_outlined
                  : Icons
                      .check_circle_outline,
              size: 34,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            isToday
                ? 'No collections due today'
                : 'No overdue collections',
            style:
                AppTextStyle.semiBoldLarge,
          ),

          const SizedBox(height: 6),

          Text(
            isToday
                ? 'All today collections are clear.'
                : 'There are no pending overdue payments.',
            textAlign: TextAlign.center,
            style:
                AppTextStyle.regularSmall,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLLECT DIALOG
  // ============================================================

  void _showCollectDialog(
    DiwaliCollectionModel item,
  ) {
    final amountController =
        TextEditingController(
      text: item.balanceDue
          .toStringAsFixed(0),
    );

    final selectedMode =
        'Cash'.obs;

    Get.dialog(
      Dialog(
        backgroundColor:
            Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 24,
        ),
        child: Container(
          padding:
              const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
                BorderRadius.circular(22),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .primary
                            .withOpacity(
                          0.18,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          13,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .payments_outlined,
                        color:
                            AppColors.black,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Collect Payment',
                            style:
                                AppTextStyle
                                    .semiBoldLarge,
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            item.customerName,
                            style:
                                AppTextStyle
                                    .regularSmall,
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon:
                          const Icon(
                        Icons.close,
                        color:
                            AppColors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // BALANCE
                // ==================================================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(
                      0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Balance Due',
                          style:
                              AppTextStyle
                                  .semiBold,
                        ),
                      ),

                      Text(
                        _money(
                          item.balanceDue,
                        ),
                        style:
                            AppTextStyle
                                .semiBoldLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // AMOUNT
                // ==================================================

                const Text(
                  'Collection Amount',
                  style:
                      AppTextStyle.semiBold,
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      amountController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  style:
                      AppTextStyle.regularLarge,
                  decoration:
                      InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle:
                        AppTextStyle
                            .semiBold,
                    hintText:
                        'Enter amount',
                    hintStyle:
                        AppTextStyle
                            .regular,
                    filled: true,
                    fillColor:
                        AppColors.scaffold,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      borderSide:
                          BorderSide(
                        color: AppColors
                            .black
                            .withOpacity(
                          0.08,
                        ),
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // PAYMENT MODE
                // ==================================================

                const Text(
                  'Payment Mode',
                  style:
                      AppTextStyle.semiBold,
                ),

                const SizedBox(height: 10),

                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _paymentMode(
                          title: 'Cash',
                          icon:
                              Icons.money,
                          selected:
                              selectedMode
                                      .value ==
                                  'Cash',
                          onTap: () {
                            selectedMode
                                .value =
                                'Cash';
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: _paymentMode(
                          title: 'UPI',
                          icon: Icons
                              .qr_code_2,
                          selected:
                              selectedMode
                                      .value ==
                                  'UPI',
                          onTap: () {
                            selectedMode
                                .value =
                                'UPI';
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // SAVE
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () {
                      final isCollecting =
                          controller
                              .isCollecting
                              .value;

                      return ElevatedButton(
                        onPressed:
                            isCollecting
                                ? null
                                : () async {
                                    final amount =
                                        double.tryParse(
                                      amountController
                                          .text
                                          .trim(),
                                    );

                                    // --------------------------------
                                    // VALIDATE AMOUNT
                                    // --------------------------------

                                    if (amount ==
                                            null ||
                                        amount <=
                                            0) {
                                      Get.snackbar(
                                        'Invalid Amount',
                                        'Please enter a valid collection amount.',
                                        snackPosition:
                                            SnackPosition
                                                .BOTTOM,
                                      );

                                      return;
                                    }

                                    // --------------------------------
                                    // VALIDATE BALANCE
                                    // --------------------------------

                                    if (amount >
                                        item.balanceDue) {
                                      Get.snackbar(
                                        'Invalid Amount',
                                        'Collection cannot exceed the balance due.',
                                        snackPosition:
                                            SnackPosition
                                                .BOTTOM,
                                      );

                                      return;
                                    }

                                    // --------------------------------
                                    // SAVE PAYMENT
                                    // --------------------------------

                                    final success =
                                        await controller
                                            .collectPayment(
                                      item: item,
                                      amount:
                                          amount,
                                      paymentMode:
                                          selectedMode
                                              .value,
                                    );

                                    if (!success) {
                                      return;
                                    }

                                    debugPrint(
                                      '🟢 Collection payment completed',
                                    );

                                    // IMPORTANT:
                                    //
                                    // Do NOT call Get.back()
                                    // here.
                                    //
                                    // Existing
                                    // DiwaliEnrollmentController
                                    // handles closing the payment
                                    // dialog and opening receipt.
                                  },
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              AppColors.primary,
                          foregroundColor:
                              AppColors.black,
                          disabledBackgroundColor:
                              AppColors.scaffold,
                          disabledForegroundColor:
                              AppColors.black
                                  .withOpacity(
                            0.35,
                          ),
                          elevation: 0,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                        child: isCollecting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      AppColors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Collection',
                                style:
                                    AppTextStyle
                                        .button
                                        .copyWith(
                                  color:
                                      AppColors.black,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT MODE
  // ============================================================

  Widget _paymentMode({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
                  .withOpacity(0.15)
              : AppColors.white,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.black
                    .withOpacity(0.10),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: AppColors.black,
            ),

            const SizedBox(width: 7),

            Text(
              title,
              style:
                  AppTextStyle.semiBoldSmall,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
    String date,
  ) {
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

  // ============================================================
  // MONEY
  // ============================================================

  String _money(
    double amount,
  ) {
    return '₹${_formatAmount(amount)}';
  }

  String _formatAmount(
    double amount,
  ) {
    final value =
        amount.round();

    final text =
        value.toString();

    if (text.length <= 3) {
      return text;
    }

    final parts =
        <String>[];

    int end =
        text.length;

    while (end > 3) {
      final start =
          end - 3;

      parts.insert(
        0,
        text.substring(
          start,
          end,
        ),
      );

      end = start;
    }

    parts.insert(
      0,
      text.substring(
        0,
        end,
      ),
    );

    return parts.join(',');
  }
}