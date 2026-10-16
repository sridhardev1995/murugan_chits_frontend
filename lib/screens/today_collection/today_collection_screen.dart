import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:sri_murugan_chits/screens/today_collection/today_collection_controller.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/repositary/today_collection/today_collection_repository.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

class TodayCollectionScreen extends StatefulWidget {
  const TodayCollectionScreen({
    super.key,
  });

  @override
  State<TodayCollectionScreen> createState() =>
      _TodayCollectionScreenState();
}

class _TodayCollectionScreenState
    extends State<TodayCollectionScreen> {
late TodayCollectionController controller;

@override
void initState() {
  super.initState();

  if (!Get.isRegistered<ApiService>()) {
    Get.put<ApiService>(
      ApiService(),
    );
  }

  if (!Get.isRegistered<TodayCollectionRepository>()) {
    Get.put<TodayCollectionRepository>(
      TodayCollectionRepository(
        Get.find<ApiService>(),
      ),
    );
  }

  if (!Get.isRegistered<TodayCollectionController>()) {
    Get.put<TodayCollectionController>(
      TodayCollectionController(
        Get.find<TodayCollectionRepository>(),
      ),
    );
  }

  controller =
      Get.find<TodayCollectionController>();
}
  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,

        title: const Text(
          'Today Collection',
          style: AppTextStyle.heading,
        ),

        actions: [
          Obx(
            () => controller.isRefreshing.value
                ? const Padding(
                    padding: EdgeInsets.only(
                      right: 16,
                    ),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.black,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      controller.refreshCollections();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.black,
                    ),
                  ),
          ),
        ],
      ),

      body: Obx(
        () {
          // ------------------------------------------------------
          // INITIAL LOADING
          // ------------------------------------------------------

          if (controller.isLoading.value &&
              controller.diwaliCollections.isEmpty &&
              controller.emiCollections.isEmpty) {
            return _buildLoading();
          }

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (controller.errorMessage.value.isNotEmpty &&
              controller.diwaliCollections.isEmpty &&
              controller.emiCollections.isEmpty) {
            return _buildError();
          }

          return RefreshIndicator(
            color: AppColors.primary,

            onRefresh: () async {
              await controller.refreshCollections();
            },

            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                30,
              ),

              children: [
                _buildDateHeader(),

                const SizedBox(height: 14),

                _buildLiveStatus(),

                const SizedBox(height: 16),

                _buildSummary(),

                const SizedBox(height: 18),

                _buildTabs(),

                const SizedBox(height: 16),

                _buildCollectionHeader(),

                const SizedBox(height: 10),

                _buildCollectionList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DATE HEADER
  // ============================================================

  Widget _buildDateHeader() {
    final today = DateFormat(
      'dd MMMM yyyy',
    ).format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: AppColors.black
              .withOpacity(0.06),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.12),

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.black,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Collection Date',
                  style: AppTextStyle
                      .regularSmall
                      .copyWith(
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  today,
                  style:
                      AppTextStyle.semiBoldLarge,
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: Colors.green
                  .withOpacity(0.10),

              borderRadius:
                  BorderRadius.circular(8),
            ),

            child: Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Container(
                  width: 6,
                  height: 6,

                  decoration:
                      const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  'TODAY',
                  style: AppTextStyle
                      .semiBoldSmall
                      .copyWith(
                    color:
                        Colors.green.shade700,
                    fontSize: 10,
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
  // LIVE STATUS
  // ============================================================

  Widget _buildLiveStatus() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.green
            .withOpacity(0.07),

        borderRadius:
            BorderRadius.circular(11),

        border: Border.all(
          color: Colors.green
              .withOpacity(0.15),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,

            decoration:
                const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Live collection data',
              style: AppTextStyle.semiBoldSmall
                  .copyWith(
                color:
                    Colors.green.shade800,
              ),
            ),
          ),

          Text(
            'Auto refresh 20s',
            style: AppTextStyle.regularSmall
                .copyWith(
              color:
                  Colors.green.shade700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Collected',
                value: _currency(
                  controller.currentTabTotal,
                ),
                icon:
                    Icons.account_balance_wallet_rounded,
                color: AppColors.black,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _summaryCard(
                title: 'Transactions',
                value:
                    '${controller.currentTabCount}',
                icon:
                    Icons.receipt_long_rounded,
                color: Colors.blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Cash',
                value: _currency(
                  controller.currentTabCash,
                ),
                icon:
                    Icons.payments_rounded,
                color: Colors.green,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _summaryCard(
                title: 'UPI',
                value: _currency(
                  controller.currentTabUpi,
                ),
                icon:
                    Icons.qr_code_rounded,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: AppColors.white,

        borderRadius:
            BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color: AppColors.black
                .withOpacity(0.035),
            blurRadius: 8,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color:
                  color.withOpacity(0.10),

              borderRadius:
                  BorderRadius.circular(9),
            ),

            child: Icon(
              icon,
              size: 19,
              color: color,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      AppTextStyle.semiBold
                          .copyWith(
                    fontSize: 14,
                    color: color,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  title,
                  style:
                      AppTextStyle.regularSmall
                          .copyWith(
                    fontSize: 10,
                    color:
                        Colors.grey.shade600,
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
  // TABS
  // ============================================================

  Widget _buildTabs() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _tabButton(
              title: 'Diwali',
              index: 0,
              count:
                  controller.diwaliCollections.length,
              icon:
                  Icons.card_giftcard_rounded,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _tabButton(
              title: 'EMI',
              index: 1,
              count:
                  controller.emiCollections.length,
              icon:
                  Icons.account_balance_wallet_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required int index,
    required int count,
    required IconData icon,
  }) {
    final selected =
        controller.selectedTab.value ==
            index;

    final color = index == 0
        ? AppColors.primary
        : Colors.blue;

    return InkWell(
      borderRadius:
          BorderRadius.circular(12),

      onTap: () {
        controller.changeTab(index);
      },

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),

        decoration: BoxDecoration(
          color: selected
              ? color
              : AppColors.white,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: selected
                ? color
                : Colors.grey.shade300,
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? AppColors.black
                  : Colors.grey.shade700,
            ),

            const SizedBox(width: 6),

            Text(
              title,
              style:
                  AppTextStyle.semiBold.copyWith(
                color:
                    AppColors.black,
              ),
            ),

            const SizedBox(width: 7),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 2,
              ),

              decoration: BoxDecoration(
                color: selected
                    ? AppColors.black
                        .withOpacity(0.10)
                    : Colors.grey.shade100,

                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Text(
                '$count',
                style:
                    AppTextStyle.semiBoldSmall
                        .copyWith(
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COLLECTION HEADER
  // ============================================================

  Widget _buildCollectionHeader() {
    final isDiwali =
        controller.selectedTab.value == 0;

    final count =
        controller.currentTabCount;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                isDiwali
                    ? 'Diwali Collections'
                    : 'EMI Collections',
                style:
                    AppTextStyle.semiBoldLarge
                        .copyWith(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                '$count transaction${count == 1 ? '' : 's'} collected today',
                style:
                    AppTextStyle.regularSmall
                        .copyWith(
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        if (controller.isRefreshing.value)
          const SizedBox(
            width: 18,
            height: 18,
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
      ],
    );
  }

  // ============================================================
  // COLLECTION LIST
  // ============================================================

  Widget _buildCollectionList() {
    final collections =
        controller.currentCollections;

    if (collections.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: collections
          .map(
            (item) =>
                _buildCollectionCard(item),
          )
          .toList(),
    );
  }

  // ============================================================
  // COLLECTION CARD
  // ============================================================

  Widget _buildCollectionCard(
    Map<String, dynamic> item,
  ) {
    final isDiwali =
        controller.selectedTab.value == 0;

    final accent = isDiwali
        ? AppColors.primary
        : Colors.blue;

    final customerName =
        _stringValue(
      item['customer_name'],
      fallback: 'Unknown Customer',
    );

    final phone =
        _stringValue(
      item['customer_phone'],
      fallback: '-',
    );

    final amount =
        _toDouble(item['amount']);

    final remaining =
        _toDouble(
      item['remaining_balance'],
    );

    final paymentMode =
        _stringValue(
      item['payment_mode'],
      fallback: '-',
    );

    final receiptNumber =
        _stringValue(
      item['receipt_number'],
      fallback: 'Receipt not available',
    );

    final paymentTime =
        _stringValue(
      item['payment_time'],
      fallback: '-',
    );

    final week = isDiwali
        ? _stringValue(
            item['week_number'],
            fallback: '-',
          )
        : _stringValue(
            item['week_no'],
            fallback: '-',
          );

    final schemeName =
        isDiwali
            ? 'Diwali Chit'
            : _stringValue(
                item['scheme_name'],
                fallback: 'EMI',
              );

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
          color: Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.black
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
          // ------------------------------------------------------
          // CUSTOMER HEADER
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color:
                      accent.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  isDiwali
                      ? Icons
                          .card_giftcard_rounded
                      : Icons
                          .account_balance_wallet_rounded,
                  color: accent,
                  size: 22,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      customerName,
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
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          phone,
                          style:
                              AppTextStyle
                                  .regularSmall
                                  .copyWith(
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color:
                      accent.withOpacity(0.10),

                  borderRadius:
                      BorderRadius.circular(8),
                ),

                child: Text(
                  isDiwali
                      ? 'DIWALI'
                      : 'EMI',
                  style:
                      AppTextStyle
                          .semiBoldSmall
                          .copyWith(
                    color: accent,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------------
          // TRANSACTION INFORMATION
          // ------------------------------------------------------

          Container(
            padding:
                const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: AppColors.scaffold,
              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: Row(
              children: [
                Expanded(
                  child: _detailItem(
                    icon:
                        Icons.numbers_rounded,
                    label: isDiwali
                        ? 'Week'
                        : 'EMI Week',
                    value: week,
                  ),
                ),

                Expanded(
                  child: _detailItem(
                    icon:
                        Icons.payments_outlined,
                    label: 'Payment',
                    value: paymentMode,
                  ),
                ),

                Expanded(
                  child: _detailItem(
                    icon:
                        Icons.access_time_rounded,
                    label: 'Time',
                    value: paymentTime,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          // ------------------------------------------------------
          // AMOUNT SECTION
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _amountItem(
                  label: 'Paid Today',
                  value: amount,
                  color: Colors.green,
                  icon:
                      Icons.check_circle_outline,
                ),
              ),

              Container(
                width: 1,
                height: 42,
                color:
                    Colors.grey.shade200,
              ),

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(
                    left: 15,
                  ),
                  child: _amountItem(
                    label: 'Remaining',
                    value: remaining,
                    color: Colors.red,
                    icon:
                        Icons.pending_actions_rounded,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ------------------------------------------------------
          // RECEIPT
          // ------------------------------------------------------

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),

            decoration: BoxDecoration(
              color: Colors.grey
                  .withOpacity(0.06),

              borderRadius:
                  BorderRadius.circular(9),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 16,
                  color: Colors.grey,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Receipt Number',
                        style:
                            AppTextStyle
                                .regularSmall
                                .copyWith(
                          fontSize: 9,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        receiptNumber,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyle
                                .semiBoldSmall
                                .copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () {
                    _showCollectionDetails(
                      item,
                    );
                  },

                  child: const Text(
                    'View Details',
                    style:
                        AppTextStyle.semiBold,
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
              color:
                  Colors.grey.shade600,
            ),

            const SizedBox(width: 4),

            Text(
              label,
              style:
                  AppTextStyle.regularSmall
                      .copyWith(
                color:
                    Colors.grey.shade600,
                fontSize: 10,
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
  // AMOUNT ITEM
  // ============================================================

  Widget _amountItem({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),

            const SizedBox(width: 4),

            Text(
              label,
              style:
                  AppTextStyle.regularSmall
                      .copyWith(
                color:
                    Colors.grey.shade600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        Text(
          _currency(value),
          style:
              AppTextStyle.semiBold.copyWith(
            color: color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DETAILS DIALOG
  // ============================================================

  void _showCollectionDetails(
    Map<String, dynamic> item,
  ) {
    final isDiwali =
        controller.selectedTab.value == 0;

    final customerName =
        _stringValue(
      item['customer_name'],
      fallback: 'Unknown Customer',
    );

    final phone =
        _stringValue(
      item['customer_phone'],
      fallback: '-',
    );

    final amount =
        _toDouble(item['amount']);

    final remaining =
        _toDouble(
      item['remaining_balance'],
    );

    final paymentMode =
        _stringValue(
      item['payment_mode'],
      fallback: '-',
    );

    final paymentTime =
        _stringValue(
      item['payment_time'],
      fallback: '-',
    );

    final receiptNumber =
        _stringValue(
      item['receipt_number'],
      fallback: '-',
    );

    final week = isDiwali
        ? _stringValue(
            item['week_number'],
            fallback: '-',
          )
        : _stringValue(
            item['week_no'],
            fallback: '-',
          );

    final scheme = isDiwali
        ? 'Diwali Chit'
        : _stringValue(
            item['scheme_name'],
            fallback: 'EMI',
          );

    Get.dialog(
      Dialog(
        backgroundColor:
            Colors.transparent,

        insetPadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),

        child: Container(
          padding:
              const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: AppColors.white,

            borderRadius:
                BorderRadius.circular(20),
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ------------------------------------------------
                // HEADER
                // ------------------------------------------------

                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,

                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(
                          11,
                        ),
                      ),

                      child: const Icon(
                        Icons
                            .receipt_long_rounded,
                        color:
                            AppColors.black,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Collection Details',
                            style:
                                AppTextStyle
                                    .heading,
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          Text(
                            isDiwali
                                ? 'Diwali Payment'
                                : 'EMI Payment',
                            style:
                                AppTextStyle
                                    .regularSmall
                                    .copyWith(
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // PAID AMOUNT
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.green
                        .withOpacity(0.07),

                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),

                    border: Border.all(
                      color: Colors.green
                          .withOpacity(0.15),
                    ),
                  ),

                  child: Column(
                    children: [
                      Text(
                        'Paid Today',
                        style: AppTextStyle
                            .regularSmall
                            .copyWith(
                          color: Colors
                              .grey
                              .shade700,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        _currency(amount),
                        style: AppTextStyle
                            .semiBold
                            .copyWith(
                          fontSize: 25,
                          color: Colors
                              .green
                              .shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ------------------------------------------------
                // DETAILS
                // ------------------------------------------------

                _dialogRow(
                  'Customer',
                  customerName,
                ),

                _dialogRow(
                  'Mobile',
                  phone,
                ),

                _dialogRow(
                  'Scheme',
                  scheme,
                ),

                _dialogRow(
                  isDiwali
                      ? 'Week'
                      : 'EMI Week',
                  week,
                ),

                _dialogRow(
                  'Payment Mode',
                  paymentMode,
                ),

                _dialogRow(
                  'Collection Time',
                  paymentTime,
                ),

                _dialogRow(
                  'Remaining',
                  _currency(remaining),
                  valueColor:
                      Colors.red.shade700,
                ),

                _dialogRow(
                  'Receipt Number',
                  receiptNumber,
                  valueColor:
                      AppColors.black,
                ),

                const SizedBox(height: 10),

                // ------------------------------------------------
                // CLOSE
                // ------------------------------------------------

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },

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
                          11,
                        ),
                      ),
                    ),

                    child: const Text(
                      'Close',
                      style:
                          AppTextStyle.semiBold,
                    ),
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
  // DIALOG ROW
  // ============================================================

  Widget _dialogRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 115,

            child: Text(
              label,
              style:
                  AppTextStyle.regularSmall
                      .copyWith(
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,

              style:
                  AppTextStyle.semiBold
                      .copyWith(
                color:
                    valueColor ??
                        AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.all(16),

      children: [
        _loadingBox(
          height: 76,
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _loadingBox(
                height: 72,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _loadingBox(
                height: 72,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _loadingBox(
                height: 72,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _loadingBox(
                height: 72,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _loadingBox(
          height: 50,
        ),

        const SizedBox(height: 14),

        _loadingBox(
          height: 190,
        ),

        const SizedBox(height: 12),

        _loadingBox(
          height: 190,
        ),
      ],
    );
  }

  Widget _loadingBox({
    required double height,
  }) {
    return Container(
      height: height,

      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(14),
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
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                color: Colors.red
                    .withOpacity(0.08),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons
                    .cloud_off_rounded,
                size: 34,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load collections',
              textAlign: TextAlign.center,
              style:
                  AppTextStyle.semiBoldLarge,
            ),

            const SizedBox(height: 7),

            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,

              style:
                  AppTextStyle.regularSmall
                      .copyWith(
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: () {
                controller.loadTodayCollections();
              },

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'Retry',
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    AppColors.black,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    final isDiwali =
        controller.selectedTab.value == 0;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 65,
      ),

      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,

            decoration: BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons
                  .receipt_long_outlined,
              size: 37,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No collections today',
            style:
                AppTextStyle.semiBoldLarge,
          ),

          const SizedBox(height: 7),

          Text(
            isDiwali
                ? 'No Diwali payments collected today.'
                : 'No EMI payments collected today.',
            textAlign: TextAlign.center,

            style:
                AppTextStyle.regularSmall
                    .copyWith(
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {
              controller.refreshCollections();
            },

            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),

            label: const Text(
              'Refresh',
            ),

            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  AppColors.black,

              side: BorderSide(
                color:
                    Colors.grey.shade300,
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _stringValue(
    dynamic value, {
    String fallback = '-',
  }) {
    if (value == null) {
      return fallback;
    }

    final text =
        value.toString().trim();

    if (text.isEmpty ||
        text == 'null') {
      return fallback;
    }

    return text;
  }

  double _toDouble(dynamic value) {
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

  String _currency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }
}