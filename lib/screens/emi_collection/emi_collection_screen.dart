import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_installment_model.dart';


import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

import 'emi_collection_controller.dart';

class EmiCollectionScreen
    extends GetView<EmiCollectionController> {
  const EmiCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        title: Text(
          'EMI Collections',
          style: AppTextStyle.heading,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.refreshCollections,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.black,
            ),
          ),
        ],
      ),

      body: Obx(
        () {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refreshCollections,
            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _summarySection(),
                ),

                SliverToBoxAdapter(
                  child: _tabSection(),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    24,
                  ),
                  sliver: _collectionList(),
                ),
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

  Widget _summarySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              title: 'Today Due',
              amount: controller.todayDueAmount,
              count: controller.todayDueCount,
              icon: Icons.calendar_today_rounded,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(
              title: 'Overdue',
              amount: controller.overdueAmount,
              count: controller.overdueCount,
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
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
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withOpacity(0.20),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.black,
                ),
              ),

              const Spacer(),

              Text(
                '$count',
                style: AppTextStyle.semiBoldSmall,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: AppTextStyle.regularSmall,
          ),

          const SizedBox(height: 4),

          Text(
            _money(amount),
            style: AppTextStyle.semiBoldLarge,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _tabSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        12,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color:
                AppColors.black.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _tabButton(
                title: 'Today Due',
                selected:
                    controller.selectedTab.value == 0,
                onTap: () {
                  controller.changeTab(0);
                },
              ),
            ),

            Expanded(
              child: _tabButton(
                title: 'Overdue',
                selected:
                    controller.selectedTab.value == 1,
                onTap: () {
                  controller.changeTab(1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(9),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: selected
              ? AppTextStyle.semiBold.copyWith(
                  color: AppColors.black,
                )
              : AppTextStyle.semiBold.copyWith(
                  color: AppColors.black
                      .withOpacity(0.55),
                ),
        ),
      ),
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _collectionList() {
    if (controller.isCurrentTabLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    final list = controller.currentList;

    if (list.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _emptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = list[index];

          return Padding(
            padding:
                const EdgeInsets.only(bottom: 12),
            child: _collectionCard(item),
          );
        },
        childCount: list.length,
      ),
    );
  }

  // ============================================================
  // COLLECTION CARD
  // ============================================================

  Widget _collectionCard(
    EmiInstallmentModel item,
  ) {
    final balance = item.balance;

    final isOverdue =
        controller.selectedTab.value == 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              AppColors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // CUSTOMER
          // ----------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
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
                      item.customerName
                                  ?.trim()
                                  .isNotEmpty ==
                              true
                          ? item.customerName!
                          : 'Customer',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyle.semiBoldLarge,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color:
                              AppColors.black,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.customerPhone ??
                              '-',
                          style:
                              AppTextStyle.regularSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _statusBadge(item.status),
            ],
          ),

          const SizedBox(height: 16),

          // ----------------------------------------------------
          // WEEK + SCHEME
          // ----------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  icon:
                      Icons.receipt_long_outlined,
                  title: 'Week',
                  value:
                      '${item.weekNo ?? '-'}',
                ),
              ),

              Expanded(
                child: _infoItem(
                  icon:
                      Icons.category_outlined,
                  title: 'Scheme',
                  value:
                      item.schemeName ?? '-',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // DUE DATE + EMI
          // ----------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  icon:
                      Icons.calendar_month_outlined,
                  title: 'Due Date',
                  value:
                      _formatDate(item.dueDate),
                ),
              ),

              Expanded(
                child: _infoItem(
                  icon:
                      Icons.payments_outlined,
                  title: 'EMI Amount',
                  value:
                      _money(item.amount ?? 0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // PAID + BALANCE
          // ----------------------------------------------------

          Container(
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  AppColors.scaffold,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _amountInfo(
                    title: 'Paid',
                    amount:
                        item.paidAmount ?? 0,
                  ),
                ),

                Container(
                  width: 1,
                  height: 36,
                  color:
                      AppColors.black
                          .withOpacity(0.08),
                ),

                Expanded(
                  child: _amountInfo(
                    title: 'Balance',
                    amount: balance,
                  ),
                ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // OVERDUE DAYS
          // ----------------------------------------------------

          if (isOverdue &&
              item.overdueDays != null &&
              item.overdueDays! > 0) ...[
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color:
                    AppColors.primary
                        .withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.black,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    '${item.overdueDays} days overdue',
                    style:
                        AppTextStyle.semiBoldSmall,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // COLLECT
          // ----------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: balance <= 0
                  ? null
                  : () {
                      // Payment connection later
                    },
              icon: const Icon(
                Icons.payments_rounded,
                size: 19,
              ),
              label: Text(
                'Collect',
                style: AppTextStyle.button,
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    AppColors.black,
                disabledBackgroundColor:
                    AppColors.scaffold,
                disabledForegroundColor:
                    AppColors.black
                        .withOpacity(0.35),
                elevation: 0,
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
  // INFO ITEM
  // ============================================================

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.black
              .withOpacity(0.55),
        ),

        const SizedBox(width: 7),

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
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AMOUNT INFO
  // ============================================================

  Widget _amountInfo({
    required String title,
    required double amount,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                AppTextStyle.regularSmall
                    .copyWith(
              color: AppColors.black
                  .withOpacity(0.45),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            _money(amount),
            style:
                AppTextStyle.semiBoldLarge,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(String? status) {
    final value =
        status ?? 'Pending';

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
        value,
        style:
            AppTextStyle.semiBoldSmall,
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyState() {
    final isOverdue =
        controller.selectedTab.value == 1;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color:
                    AppColors.primary
                        .withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 36,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              isOverdue
                  ? 'No overdue EMI'
                  : 'No EMI due today',
              style:
                  AppTextStyle.semiBoldLarge,
            ),

            const SizedBox(height: 6),

            Text(
              isOverdue
                  ? 'There are no pending overdue EMI collections.'
                  : 'There are no EMI collections due today.',
              textAlign: TextAlign.center,
              style:
                  AppTextStyle.regularSmall,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  String _formatDate(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return '-';
    }

    try {
      final date =
          DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }
}