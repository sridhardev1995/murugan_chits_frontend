import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_detail_screen.dart';

class EmiEnrollmentListScreen extends StatelessWidget {
  const EmiEnrollmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EmiEnrollmentController(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text(
          'EMI Enrollments',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),

      body: Column(
        children: [
          // ======================================================
          // SEARCH + FILTER
          // ======================================================

          Container(
            color: Colors.white,
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
                  decoration: InputDecoration(
                    hintText:
                        'Search customer, phone or scheme...',
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
                    fillColor:
                        const Color(0xFFF6F7FB),
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
                        const Text(
                          'Status:',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child:
                              DropdownButtonFormField<
                                  String>(
                            value: controller
                                    .selectedStatus
                                    .value
                                    .isEmpty
                                ? ''
                                : controller
                                    .selectedStatus
                                    .value,
                            decoration:
                                InputDecoration(
                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor:
                                  const Color(
                                0xFFF6F7FB,
                              ),
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
                      children: const [
                        SizedBox(height: 160),
                        Center(
                          child: Text(
                            'No EMI enrollments found',
                            style: TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 15,
                            ),
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
// ENROLLMENT CARD
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
    final status =
        enrollment.status ?? 'Unknown';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),

        child: Padding(
          padding:
              const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // CUSTOMER
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFFFF3E0,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color:
                          Color(0xFFF57C00),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          enrollment
                                  .customerName ??
                              'Unknown Customer',
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Color(
                              0xFF1F2937,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          enrollment
                                  .customerPhone ??
                              '',
                          style:
                              TextStyle(
                            fontSize: 13,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _StatusBadge(
                    status: status,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(height: 1),

              const SizedBox(height: 14),

              // ==================================================
              // SCHEME
              // ==================================================

              Row(
                children: [
                  const Icon(
                    Icons
                        .account_balance_wallet_outlined,
                    size: 18,
                    color:
                        Color(0xFF6B7280),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      enrollment
                              .schemeName ??
                          'EMI Scheme',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Color(0xFF374151),
                      ),
                    ),
                  ),

                  Text(
                    '#${enrollment.id ?? '-'}',
                    style:
                        TextStyle(
                      fontSize: 12,
                      color: Colors
                          .grey
                          .shade500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // AMOUNT ROW
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child:
                        _AmountItem(
                      label:
                          'Requested',
                      value:
                          enrollment
                                  .requestedAmount ??
                              0,
                    ),
                  ),

                  Expanded(
                    child:
                        _AmountItem(
                      label:
                          'Commission',
                      value:
                          enrollment
                                  .commissionAmount ??
                              0,
                    ),
                  ),

                  Expanded(
                    child:
                        _AmountItem(
                      label:
                          'Disbursed',
                      value:
                          enrollment
                                  .disbursedAmount ??
                              0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // FOOTER
              // ==================================================

              Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_month_outlined,
                    size: 17,
                    color:
                        Color(0xFF6B7280),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    '${enrollment.weeks ?? 0} weeks',
                    style:
                        TextStyle(
                      fontSize: 13,
                      color: Colors
                          .grey
                          .shade700,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Icon(
                    Icons
                        .date_range_outlined,
                    size: 17,
                    color:
                        Color(0xFF6B7280),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    _formatDate(
                      enrollment.startDate,
                    ),
                    style:
                        TextStyle(
                      fontSize: 13,
                      color: Colors
                          .grey
                          .shade700,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons
                        .arrow_forward_ios_rounded,
                    size: 15,
                    color:
                        Color(0xFF9CA3AF),
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
    if (value == null ||
        value.isEmpty) {
      return '-';
    }

    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(
        DateTime.parse(value),
      );
    } catch (_) {
      return value;
    }
  }
}

// ================================================================
// AMOUNT ITEM
// ================================================================

class _AmountItem extends StatelessWidget {
  final String label;
  final double value;

  const _AmountItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors
                .grey
                .shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${NumberFormat('#,##0.00').format(value)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
            color:
                Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// STATUS BADGE
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
        background =
            const Color(0xFFE8F5E9);
        foreground =
            const Color(0xFF2E7D32);
        break;

      case 'closed':
        background =
            const Color(0xFFE3F2FD);
        foreground =
            const Color(0xFF1565C0);
        break;

      case 'cancelled':
        background =
            const Color(0xFFFFEBEE);
        foreground =
            const Color(0xFFC62828);
        break;

      default:
        background =
            const Color(0xFFF3F4F6);
        foreground =
            const Color(0xFF6B7280);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}