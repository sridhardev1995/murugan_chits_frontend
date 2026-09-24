import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_detail_screen.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';
// import 'package:sri_murugan_chits/utils/text_styles/app_text_style.dart';

class EmiEnrollmentListScreen extends StatelessWidget {
  const EmiEnrollmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EmiEnrollmentController(),
    );

    return Scaffold(
      backgroundColor: AppColors.scaffold,

      appBar: AppBar(
        title: Text(
          'EMI Enrollments',
          style: AppTextStyle.semiBoldLarge,
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),

      body: Column(
        children: [
          // ======================================================
          // SEARCH + FILTER
          // ======================================================

          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              14,
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  style: AppTextStyle.regular,
                  decoration: InputDecoration(
                    hintText:
                        'Search customer, phone or scheme...',
                    hintStyle: AppTextStyle.regular.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon:
                        const Icon(Icons.search),
                    suffixIcon: Obx(
                      () {
                        if (controller
                            .searchText
                            .value
                            .isEmpty) {
                          return const SizedBox();
                        }

                        return IconButton(
                          icon: const Icon(
                            Icons.close,
                          ),
                          onPressed:
                              controller.clearSearch,
                        );
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.scaffold,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // STATUS FILTER
                Obx(
                  () {
                    return Row(
                      children: [
                        Text(
                          'Status:',
                          style: AppTextStyle.semiBold,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child:
                              DropdownButtonFormField<
                                  String>(
                            initialValue: controller
                                    .selectedStatus
                                    .value
                                    .isEmpty
                                ? ''
                                : controller
                                    .selectedStatus
                                    .value,
                            style: AppTextStyle.regular,
                            decoration:
                                InputDecoration(
                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: AppColors.scaffold,
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                                borderSide:
                                    BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: '',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'Active',
                                child:
                                    Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'Closed',
                                child:
                                    Text('Closed'),
                              ),
                              DropdownMenuItem(
                                value: 'Cancelled',
                                child:
                                    Text('Cancelled'),
                              ),
                            ],
                            onChanged:
                                controller
                                    .changeStatus,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // ======================================================
          // LIST
          // ======================================================

          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final items =
                    controller.filteredEnrollments;

                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh:
                        controller
                            .refreshEnrollments,
                    child: ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 160),
                        Center(
                          child: Text(
                            'No EMI enrollments found',
                            style: AppTextStyle.regular
                                .copyWith(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh:
                      controller
                          .refreshEnrollments,
                  child: NotificationListener<
                      ScrollNotification>(
                    onNotification:
                        (notification) {
                      if (notification
                              is ScrollEndNotification &&
                          notification.metrics
                                  .extentAfter <
                              200) {
                        controller
                            .loadMore();
                      }

                      return false;
                    },
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      itemCount:
                          items.length,
                      itemBuilder:
                          (context, index) {
                        final enrollment =
                            items[index];

                        return _EnrollmentCard(
                          enrollment:
                              enrollment,
                          onTap: () {
                            Get.to(
                              () =>
                                  EmiEnrollmentDetailScreen(
                                enrollmentId:
                                    enrollment.id!,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ENROLLMENT CARD  (uses AppColors / AppTextStyle theme)
// ================================================================

class _EnrollmentCard extends StatelessWidget {
  final EnrollmentModel enrollment;
  final VoidCallback onTap;

  const _EnrollmentCard({
    required this.enrollment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = enrollment.status ?? 'Unknown';
    final initial = (enrollment.customerName ?? 'U').trim().isNotEmpty
        ? enrollment.customerName!.trim()[0].toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // CUSTOMER HEADER — avatar + name + phone + status
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular initial avatar (uses primary color tint)
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial,
                      style: AppTextStyle.semiBoldLarge.copyWith(
                        color: const Color(0xFF8A7B00),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          enrollment.customerName ??
                              'Unknown Customer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.semiBoldLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          enrollment.customerPhone ?? '',
                          style: AppTextStyle.regularSmall.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${enrollment.schemeName ?? 'EMI Scheme'} · ${enrollment.weeks ?? 0} weeks',
                          style: AppTextStyle.regularSmall.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _StatusBadge(status: status),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 6),

              // ==================================================
              // SUMMARY ROWS — color-coded like reference screen
              // ==================================================
              _SummaryRow(
                label: 'Requested',
                value: enrollment.requestedAmount ?? 0,
                valueColor: AppColors.black,
              ),
              _SummaryRow(
                label: 'Commission',
                value: enrollment.commissionAmount ?? 0,
                valueColor: const Color(0xFFC62828),
              ),
              _SummaryRow(
                label: 'Disbursed',
                value: enrollment.disbursedAmount ?? 0,
                valueColor: const Color(0xFF2E7D32),
                showDivider: false,
              ),

              const SizedBox(height: 10),

              // ==================================================
              // FOOTER — start date + id + arrow
              // ==================================================
              Row(
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(enrollment.startDate),
                    style: AppTextStyle.regularSmall.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '#${enrollment.id ?? '-'}',
                    style: AppTextStyle.regularSmall.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }
}

// ================================================================
// SUMMARY ROW — mirrors "Total Paid / Total Due" row style
// ================================================================

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color valueColor;
  final bool showDivider;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyle.regularSmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '₹${NumberFormat('#,##0').format(value)}',
                style: AppTextStyle.semiBold.copyWith(
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}

// ================================================================
// STATUS BADGE (pill)
// ================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status.toLowerCase()) {
      case 'active':
        background = const Color(0xFFE8F5E9);
        foreground = const Color(0xFF2E7D32);
        break;

      case 'closed':
        background = const Color(0xFFE3F2FD);
        foreground = const Color(0xFF1565C0);
        break;

      case 'cancelled':
        background = const Color(0xFFFFEBEE);
        foreground = const Color(0xFFC62828);
        break;

      default:
        background = const Color(0xFFF3F4F6);
        foreground = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyle.semiBoldSmall.copyWith(
          color: foreground,
        ),
      ),
    );
  }
}