import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  int selectedTab = 0;

  // ============================================================
  // TEMP DATA
  // ============================================================

  final List<Map<String, dynamic>> diwaliCollections = [
    {
      'customerName': 'Ramesh Kumar',
      'phone': '9876543210',
      'week': 12,
      'amount': 2000.0,
      'remaining': 8000.0,
      'paymentMode': 'Cash',
      'time': '10:42 AM',
      'receiptNumber': 'SMC-26-27-000125',
    },
    {
      'customerName': 'Suresh',
      'phone': '9876543211',
      'week': 8,
      'amount': 1000.0,
      'remaining': 5000.0,
      'paymentMode': 'UPI',
      'time': '11:25 AM',
      'receiptNumber': 'SMC-26-27-000126',
    },
  ];

  final List<Map<String, dynamic>> emiCollections = [
    {
      'customerName': 'Priya',
      'phone': '9876543212',
      'week': 5,
      'amount': 3000.0,
      'remaining': 12000.0,
      'paymentMode': 'UPI',
      'time': '02:15 PM',
      'receiptNumber': 'SMC-26-27-000127',
    },
    {
      'customerName': 'Karthik',
      'phone': '9876543213',
      'week': 7,
      'amount': 2500.0,
      'remaining': 7500.0,
      'paymentMode': 'Cash',
      'time': '03:10 PM',
      'receiptNumber': 'SMC-26-27-000128',
    },
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final collections = selectedTab == 0
        ? diwaliCollections
        : emiCollections;

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
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.black,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        color: AppColors.primary,

        onRefresh: () async {
          setState(() {});
        },

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
            _buildDateHeader(),

            const SizedBox(height: 16),

            _buildSummary(),

            const SizedBox(height: 18),

            _buildTabs(),

            const SizedBox(height: 16),

            if (collections.isEmpty)
              _buildEmpty()
            else
              ...collections.map(
                (item) => _buildCollectionCard(
                  item,
                ),
              ),
          ],
        ),
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
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.black,
              size: 20,
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
                  style: AppTextStyle.regularSmall
                      .copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  today,
                  style: AppTextStyle.semiBoldLarge,
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

            child: Text(
              'TODAY',
              style: AppTextStyle.semiBoldSmall
                  .copyWith(
                color: Colors.green.shade700,
                fontSize: 10,
              ),
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
    final list = selectedTab == 0
        ? diwaliCollections
        : emiCollections;

    final total = list.fold<double>(
      0,
      (sum, item) =>
          sum + (item['amount'] as double),
    );

    final cash = list
        .where(
          (item) =>
              item['paymentMode'] == 'Cash',
        )
        .fold<double>(
          0,
          (sum, item) =>
              sum + (item['amount'] as double),
        );

    final upi = list
        .where(
          (item) =>
              item['paymentMode'] == 'UPI',
        )
        .fold<double>(
          0,
          (sum, item) =>
              sum + (item['amount'] as double),
        );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Collected',
                value: _currency(total),
                icon:
                    Icons.account_balance_wallet_rounded,
                color: AppColors.black,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _summaryCard(
                title: 'Transactions',
                value: '${list.length}',
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
                value: _currency(cash),
                icon: Icons.payments_rounded,
                color: Colors.green,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _summaryCard(
                title: 'UPI',
                value: _currency(upi),
                icon: Icons.qr_code_rounded,
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
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color: AppColors.black
                .withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(9),
            ),

            child: Icon(
              icon,
              size: 18,
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
                  style: AppTextStyle.semiBold
                      .copyWith(
                    fontSize: 13,
                    color: color,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  title,
                  style: AppTextStyle.regularSmall
                      .copyWith(
                    fontSize: 10,
                    color: Colors.grey.shade600,
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
    return Row(
      children: [
        Expanded(
          child: _tabButton(
            title: 'Diwali',
            index: 0,
            icon: Icons.card_giftcard_rounded,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _tabButton(
            title: 'EMI',
            index: 1,
            icon:
                Icons.account_balance_wallet_rounded,
          ),
        ),
      ],
    );
  }

  Widget _tabButton({
    required String title,
    required int index,
    required IconData icon,
  }) {
    final selected =
        selectedTab == index;

    return InkWell(
      borderRadius:
          BorderRadius.circular(11),

      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.white,

          borderRadius:
              BorderRadius.circular(11),

          border: Border.all(
            color: selected
                ? AppColors.black
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

            const SizedBox(width: 7),

            Text(
              title,
              style: AppTextStyle.semiBold
                  .copyWith(
                color: selected
                    ? AppColors.black
                    : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COLLECTION CARD
  // ============================================================

  Widget _buildCollectionCard(
    Map<String, dynamic> item,
  ) {
    final isDiwali = selectedTab == 0;

    final accent = isDiwali
        ? AppColors.primary
        : Colors.blue;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(15),

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
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ------------------------------------------------------
          // CUSTOMER
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 44,
                height: 44,

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
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      item['customerName']
                          .toString(),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyle
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
                          item['phone'].toString(),
                          style: AppTextStyle
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
                  isDiwali ? 'DIWALI' : 'EMI',
                  style: AppTextStyle
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
          // WEEK / PAYMENT MODE / TIME
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
                    icon: Icons.numbers_rounded,
                    label: isDiwali
                        ? 'Week'
                        : 'EMI Week',
                    value:
                        '${item['week']}',
                  ),
                ),

                Expanded(
                  child: _detailItem(
                    icon:
                        Icons.payments_outlined,
                    label: 'Payment',
                    value:
                        item['paymentMode']
                            .toString(),
                  ),
                ),

                Expanded(
                  child: _detailItem(
                    icon:
                        Icons.access_time_rounded,
                    label: 'Time',
                    value:
                        item['time'].toString(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // AMOUNTS
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _amountItem(
                  label: 'Paid Today',
                  value:
                      item['amount'] as double,
                  color: Colors.green,
                ),
              ),

              Expanded(
                child: _amountItem(
                  label: 'Remaining',
                  value:
                      item['remaining'] as double,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // RECEIPT
          // ------------------------------------------------------

          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 15,
                color: Colors.grey,
              ),

              const SizedBox(width: 5),

              Text(
                item['receiptNumber'].toString(),
                style: AppTextStyle.regularSmall
                    .copyWith(
                  color: Colors.grey.shade700,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {
                  _showCollectionDetails(item);
                },
                child: const Text(
                  'View Details',
                  style: AppTextStyle.semiBold,
                ),
              ),
            ],
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
              color: Colors.grey.shade600,
            ),

            const SizedBox(width: 4),

            Text(
              label,
              style: AppTextStyle.regularSmall
                  .copyWith(
                color: Colors.grey.shade600,
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
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: AppTextStyle.regularSmall
              .copyWith(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          _currency(value),
          style: AppTextStyle.semiBold
              .copyWith(
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
    final isDiwali = selectedTab == 0;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,

        title: const Text(
          'Collection Details',
          style: AppTextStyle.heading,
        ),

        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _dialogRow(
                'Customer',
                item['customerName']
                    .toString(),
              ),

              _dialogRow(
                'Mobile',
                item['phone'].toString(),
              ),

              _dialogRow(
                'Scheme',
                isDiwali
                    ? 'Diwali Chit'
                    : 'EMI',
              ),

              _dialogRow(
                isDiwali
                    ? 'Week'
                    : 'EMI Week',
                item['week'].toString(),
              ),

              _dialogRow(
                'Paid Today',
                _currency(
                  item['amount'] as double,
                ),
              ),

              _dialogRow(
                'Remaining',
                _currency(
                  item['remaining'] as double,
                ),
              ),

              _dialogRow(
                'Payment Mode',
                item['paymentMode']
                    .toString(),
              ),

              _dialogRow(
                'Collection Time',
                item['time'].toString(),
              ),

              _dialogRow(
                'Receipt Number',
                item['receiptNumber']
                    .toString(),
              ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Close',
              style: AppTextStyle.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: AppTextStyle.regularSmall
                  .copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: AppTextStyle.semiBold,
            ),
          ),
        ],
      ),
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
              Icons.receipt_long_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'No collections today',
            style:
                AppTextStyle.semiBoldLarge,
          ),

          const SizedBox(height: 6),

          Text(
            selectedTab == 0
                ? 'No Diwali payments collected today.'
                : 'No EMI payments collected today.',
            textAlign: TextAlign.center,
            style: AppTextStyle.regularSmall
                .copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  String _currency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }
}