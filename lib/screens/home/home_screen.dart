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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Obx(() {
        // --------------------------------------------------------
        // INITIAL LOADING
        // --------------------------------------------------------

        if (controller.isLoading.value && controller.data == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
              color: AppColors.textGrey,
            ),

            const SizedBox(height: 12),

            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyle.regularSmall.copyWith(
                color: AppColors.textGrey,
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
              child: const Text('Retry', style: AppTextStyle.semiBold),
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
        color: AppColors.collectionCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TODAY'S COLLECTION", style: AppTextStyle.semiBoldSmall),

          const SizedBox(height: 6),

          Obx(
            () => Text(
              _formatCurrency(controller.todayTotalCollection),
              style: AppTextStyle.heading.copyWith(
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
                    amount: controller.todayDiwaliCollection,
                  ),
                ),
              ),

              Container(
                width: 1,
                height: 32,
                color: AppColors.white.withOpacity(0.24),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              Expanded(
                child: Obx(
                  () => _todaySplitTile(
                    label: 'EMI',
                    amount: controller.todayEmiCollection,
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

  Widget _todaySplitTile({required String label, required double amount}) {
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
          style: AppTextStyle.semiBoldLarge.copyWith(fontSize: 15),
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
              iconColor: AppColors.blue,
              label: 'Customers',
              value: '${controller.totalCustomers}',
              onTap: () => Get.toNamed('/customer'),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Obx(
            () => _statCard(
              icon: Icons.card_giftcard_rounded,
              iconColor: AppColors.gold,
              label: 'Diwali Chits',
              value: '${controller.totalDiwaliChits}',
              onTap: () => Get.toNamed('/diwali-enrollments'),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(radius: 14),
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
              child: Icon(icon, size: 18, color: iconColor),
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: AppTextStyle.heading.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label,
              style: AppTextStyle.regularSmall.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
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
        accent: AppColors.gold,
        totalAmount: controller.diwaliTotalAmount,
        receivedAmount: controller.diwaliReceivedAmount,
        pendingAmount: controller.diwaliPendingAmount,
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
        icon: Icons.account_balance_wallet_rounded,
        accent: AppColors.blue,
        totalAmount: controller.emiTotalAmount,
        receivedAmount: controller.emiCollectedAmount,
        pendingAmount: controller.emiPendingCollection,
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
        : (receivedAmount / totalAmount).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accent),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.semiBold.copyWith(
                    fontSize: 14.5,
                    color: AppColors.textDark,
                  ),
                ),
              ),

              Text(
                _formatCurrency(totalAmount),
                style: AppTextStyle.semiBold.copyWith(
                  fontSize: 13.5,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountChip(
                label: 'Received',
                amount: receivedAmount,
                color: AppColors.green,
              ),

              _amountChip(
                label: 'Pending',
                amount: pendingAmount,
                color: AppColors.red,
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 6),

        Text(
          '$label  ',
          style: AppTextStyle.regularSmall.copyWith(color: AppColors.textGrey),
        ),

        Text(
          _formatCurrency(amount),
          style: AppTextStyle.semiBoldSmall.copyWith(
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
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppColors.red,
              ),

              const SizedBox(width: 8),

              Text(
                'Due & Overdue',
                style: AppTextStyle.semiBold.copyWith(
                  fontSize: 14.5,
                  color: AppColors.textDark,
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
                    value: _formatCurrency(controller.todayDue),
                  ),
                ),
              ),

              Expanded(
                child: Obx(
                  () => _dueTile(
                    label: 'Overdue',
                    value: _formatCurrency(controller.overdueAmount),
                    valueColor: AppColors.red,
                  ),
                ),
              ),

              Expanded(
                child: Obx(
                  () => _dueTile(
                    label: 'Customers',
                    value: '${controller.pendingCustomers}',
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
    Color valueColor = AppColors.textDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.regularSmall.copyWith(
            color: AppColors.textGrey,
            fontSize: 11.5,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: AppTextStyle.semiBold.copyWith(
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

  /// Shared white card decoration (stat card, progress card, due card)
  static BoxDecoration _cardDecoration({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return formatter.format(amount);
  }
}