import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:sri_murugan_chits/screens/home/home_controller.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

/// ================================================================
/// HOME SCREEN
/// ----------------------------------------------------------------
///   - Pull-to-refresh
///   - Today's Collection summary (Diwali + EMI + Total)
///   - Quick stats: Customers, Diwali Chits
///   - Diwali Chit progress card
///   - EMI progress card
///   - Due & Overdue card
/// ================================================================
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  // ============================================================
  // ADDITIONAL UI COLORS
  // ============================================================

  static const Color _gold = Color(0xFFF6C244);
  static const Color _black = Color(0xFF1A1A1A);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _green = Color(0xFF22A45D);
  static const Color _red = Color(0xFFE0473F);
  static const Color _blue = Color(0xFF3B82F6);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,

      // appBar: AppBar(
      //   backgroundColor: AppColors.black,
      //   foregroundColor: AppColors.white,
      //   elevation: 0,
      //   title: const Text(
      //     'Dashboard',
      //     style: AppTextStyle.heading,
      //   ),
      //   actions: [
      //     Obx(
      //       () => IconButton(
      //         icon: controller.isLoading.value
      //             ? const SizedBox(
      //                 width: 18,
      //                 height: 18,
      //                 child: CircularProgressIndicator(
      //                   strokeWidth: 2,
      //                   color: AppColors.white,
      //                 ),
      //               )
      //             : const Icon(
      //                 Icons.refresh_rounded,
      //                 color: AppColors.white,
      //               ),
      //         onPressed: controller.isLoading.value
      //             ? null
      //             : controller.fetchDashboard,
      //       ),
      //     ),
      //   ],
      // ),

      body: Obx(() {
        // --------------------------------------------------------
        // INITIAL LOADING
        // --------------------------------------------------------

        if (controller.isLoading.value &&
            controller.data == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        // --------------------------------------------------------
        // ERROR STATE
        // --------------------------------------------------------

        if (controller.errorMessage.value.isNotEmpty &&
            controller.data == null) {
          return _buildErrorState();
        }

        // --------------------------------------------------------
        // DASHBOARD CONTENT
        // --------------------------------------------------------

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24,
            ),
            children: [
              _buildTodayCollectionCard(),

              const SizedBox(height: 16),

              _buildQuickStatsRow(),

              const SizedBox(height: 16),

              _buildDiwaliProgressCard(),

              const SizedBox(height: 16),

              _buildEmiProgressCard(),

              const SizedBox(height: 16),

              _buildDueCard(),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: _textGrey,
            ),

            const SizedBox(height: 12),

            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyle.regularSmall.copyWith(
                color: _textGrey,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: controller.fetchDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Retry',
                style: AppTextStyle.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TODAY'S COLLECTION CARD
  // ============================================================

  Widget _buildTodayCollectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        // gradient: const LinearGradient(
        //   colors: [
        //     _black,
        //     Color(0xFF2B2B2B),
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S COLLECTION",
            style: AppTextStyle.semiBoldSmall,
          ),

          const SizedBox(height: 6),

          Obx(
            () => Text(
              _formatCurrency(
                controller.todayTotalCollection,
              ),
              style: AppTextStyle.heading.copyWith(
                color: AppColors.black,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _todaySplitTile(
                    label: 'Diwali',
                    amount:
                        controller.todayDiwaliCollection,
                  ),
                ),
              ),

              Container(
                width: 1,
                height: 32,
                color: AppColors.white.withOpacity(0.24),
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
              ),

              Expanded(
                child: Obx(
                  () => _todaySplitTile(
                    label: 'EMI',
                    amount:
                        controller.todayEmiCollection,
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
  // TODAY SPLIT TILE
  // ============================================================

  Widget _todaySplitTile({
    required String label,
    required double amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.regularSmall.copyWith(
            color: AppColors.black.withOpacity(0.54),
          ),
        ),

        const SizedBox(height: 2),

        Text(
          _formatCurrency(amount),
          style: AppTextStyle.semiBoldLarge.copyWith(
            color: AppColors.black,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK STATS ROW
  // ============================================================

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _statCard(
              icon: Icons.people_alt_rounded,
              iconColor: _blue,
              label: 'Customers',
              value: '${controller.totalCustomers}',
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Obx(
            () => _statCard(
              icon: Icons.card_giftcard_rounded,
              iconColor: _gold,
              label: 'Diwali Chits',
              value:
                  '${controller.totalDiwaliChits}',
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: AppTextStyle.heading.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: AppTextStyle.regularSmall.copyWith(
              color: _textGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIWALI PROGRESS CARD
  // ============================================================

  Widget _buildDiwaliProgressCard() {
    return Obx(
      () => _progressCard(
        title: 'Diwali Chit Collection',
        icon: Icons.card_giftcard_rounded,
        accent: _gold,
        totalAmount:
            controller.diwaliTotalAmount,
        receivedAmount:
            controller.diwaliReceivedAmount,
        pendingAmount:
            controller.diwaliPendingAmount,
      ),
    );
  }

  // ============================================================
  // EMI PROGRESS CARD
  // ============================================================

  Widget _buildEmiProgressCard() {
    return Obx(
      () => _progressCard(
        title: 'EMI Collection',
        icon:
            Icons.account_balance_wallet_rounded,
        accent: _blue,
        totalAmount:
            controller.emiTotalAmount,
        receivedAmount:
            controller.emiCollectedAmount,
        pendingAmount:
            controller.emiPendingCollection,
      ),
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _progressCard({
    required String title,
    required IconData icon,
    required Color accent,
    required double totalAmount,
    required double receivedAmount,
    required double pendingAmount,
  }) {
    final progress = totalAmount <= 0
        ? 0.0
        : (receivedAmount / totalAmount)
            .clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color:
                      accent.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: accent,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style:
                      AppTextStyle.semiBold.copyWith(
                    fontSize: 14.5,
                    color: _textDark,
                  ),
                ),
              ),

              Text(
                _formatCurrency(totalAmount),
                style:
                    AppTextStyle.semiBold.copyWith(
                  fontSize: 13.5,
                  color: _textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  const Color(0xFFEFEFEF),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                accent,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _amountChip(
                label: 'Received',
                amount: receivedAmount,
                color: _green,
              ),

              _amountChip(
                label: 'Pending',
                amount: pendingAmount,
                color: _red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AMOUNT CHIP
  // ============================================================

  Widget _amountChip({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          '$label  ',
          style:
              AppTextStyle.regularSmall.copyWith(
            color: _textGrey,
          ),
        ),

        Text(
          _formatCurrency(amount),
          style:
              AppTextStyle.semiBoldSmall.copyWith(
            color: color,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DUE & OVERDUE CARD
  // ============================================================

  Widget _buildDueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: _red,
              ),

              const SizedBox(width: 8),

              Text(
                'Due & Overdue',
                style:
                    AppTextStyle.semiBold.copyWith(
                  fontSize: 14.5,
                  color: _textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _dueTile(
                    label: "Today's Due",
                    value: _formatCurrency(
                      controller.todayDue,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Obx(
                  () => _dueTile(
                    label: 'Overdue',
                    value: _formatCurrency(
                      controller.overdueAmount,
                    ),
                    valueColor: _red,
                  ),
                ),
              ),

              Expanded(
                child: Obx(
                  () => _dueTile(
                    label: 'Customers',
                    value:
                        '${controller.pendingCustomers}',
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
  // DUE TILE
  // ============================================================

  Widget _dueTile({
    required String label,
    required String value,
    Color valueColor = _textDark,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              AppTextStyle.regularSmall.copyWith(
            color: _textGrey,
            fontSize: 11.5,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style:
              AppTextStyle.semiBold.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return formatter.format(amount);
  }
}