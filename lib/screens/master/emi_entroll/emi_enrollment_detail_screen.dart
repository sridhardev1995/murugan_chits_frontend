import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';

class EmiEnrollmentDetailScreen extends StatefulWidget {
  final int enrollmentId;

  const EmiEnrollmentDetailScreen({
    super.key,
    required this.enrollmentId,
  });

  @override
  State<EmiEnrollmentDetailScreen>
      createState() =>
          _EmiEnrollmentDetailScreenState();
}

class _EmiEnrollmentDetailScreenState
    extends State<EmiEnrollmentDetailScreen> {
  late final EmiEnrollmentController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<EmiEnrollmentController>();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      controller.loadEnrollmentDetail(
        widget.enrollmentId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text(
          'EMI Enrollment Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF1F2937),
        elevation: 0,
      ),

      body: Obx(
        () {
          if (controller
              .isDetailLoading.value) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final enrollment =
              controller
                  .selectedEnrollment
                  .value;

          if (enrollment == null) {
            return const Center(
              child: Text(
                'Enrollment details not found',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller
                  .loadEnrollmentDetail(
                widget.enrollmentId,
              );
            },
            child: ListView(
              padding:
                  const EdgeInsets.all(16),
              children: [
                // ==================================================
                // CUSTOMER CARD
                // ==================================================

                _buildCustomerCard(
                  enrollment,
                ),

                const SizedBox(height: 14),

                // ==================================================
                // LOAN SUMMARY
                // ==================================================

                _buildSectionCard(
                  title: 'Loan Summary',
                  icon: Icons
                      .account_balance_wallet_outlined,
                  child: Column(
                    children: [
                      _infoRow(
                        'Requested Amount',
                        _money(
                          enrollment
                              .requestedAmount,
                        ),
                      ),

                      _infoRow(
                        'Commission Type',
                        _commissionType(
                          enrollment,
                        ),
                      ),

                      _infoRow(
                        'Commission Value',
                        _commissionValue(
                          enrollment,
                        ),
                      ),

                      _infoRow(
                        'Commission Amount',
                        _money(
                          enrollment
                              .commissionAmount,
                        ),
                      ),

                      _infoRow(
                        'Disbursed Amount',
                        _money(
                          enrollment
                              .disbursedAmount,
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // SCHEME DETAILS
                // ==================================================

                _buildSectionCard(
                  title: 'Scheme Details',
                  icon: Icons
                      .description_outlined,
                  child: Column(
                    children: [
                      _infoRow(
                        'Scheme',
                        enrollment
                                .schemeName ??
                            '-',
                      ),

                      _infoRow(
                        'Duration',
                        '${enrollment.weeks ?? 0} weeks',
                      ),

                      _infoRow(
                        'Start Date',
                        _formatDate(
                          enrollment
                              .startDate,
                        ),
                      ),

                      _infoRow(
                        'Status',
                        enrollment
                                .status ??
                            '-',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // CUSTOMER DETAILS
                // ==================================================

                _buildSectionCard(
                  title:
                      'Customer Details',
                  icon:
                      Icons.person_outline,
                  child: Column(
                    children: [
                      _infoRow(
                        'Customer Name',
                        enrollment
                                .customerName ??
                            '-',
                      ),

                      _infoRow(
                        'Phone',
                        enrollment
                                .customerPhone ??
                            '-',
                      ),

                      _infoRow(
                        'Customer ID',
                        '${enrollment.customerId ?? '-'}',
                      ),

                      _infoRow(
                        'Enrollment ID',
                        '${enrollment.id ?? '-'}',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // STATUS ACTIONS
                // ==================================================

                _buildStatusActions(
                  enrollment,
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==============================================================
  // CUSTOMER CARD
  // ==============================================================

  Widget _buildCustomerCard(
    EnrollmentModel enrollment,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFFFF9800),
            Color(0xFFFF5722),
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.20,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  enrollment
                          .customerName ??
                      'Unknown Customer',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  enrollment
                          .customerPhone ??
                      '',
                  style:
                      const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(
                      0.18,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    enrollment
                            .status ??
                        'Unknown',
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SECTION CARD
  // ==============================================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 3),
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
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFFF3E0,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color:
                      const Color(
                    0xFFF57C00,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  // ==============================================================
  // INFO ROW
  // ==============================================================

  Widget _infoRow(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(
        bottom: isLast ? 0 : 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // STATUS ACTIONS
  // ==============================================================

  Widget _buildStatusActions(
    EnrollmentModel enrollment,
  ) {
    final status =
        enrollment.status ?? '';

    if (status == 'Closed' ||
        status == 'Cancelled') {
      return const SizedBox.shrink();
    }

    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Enrollment Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              if (status != 'Closed')
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _confirmStatus(
                        enrollment,
                        'Closed',
                      );
                    },
                    icon: const Icon(
                      Icons.check_circle_outline,
                    ),
                    label:
                        const Text('Close'),
                  ),
                ),

              const SizedBox(width: 10),

              if (status != 'Cancelled')
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _confirmStatus(
                        enrollment,
                        'Cancelled',
                      );
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                    ),
                    label:
                        const Text('Cancel'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CONFIRM STATUS
  // ==============================================================

  void _confirmStatus(
    EnrollmentModel enrollment,
    String status,
  ) {
    Get.dialog(
      AlertDialog(
        title:
            Text('$status Enrollment?'),
        content: Text(
          'Are you sure you want to mark this enrollment as $status?',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child:
                const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              await controller
                  .changeEnrollmentStatus(
                enrollmentId:
                    enrollment.id!,
                status: status,
              );
            },
            child:
                const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HELPERS
  // ==============================================================

  String _money(double? value) {
    return '₹${NumberFormat('#,##0.00').format(value ?? 0)}';
  }

  String _commissionType(
    EnrollmentModel enrollment,
  ) {
    if (enrollment.commissionType ==
        null) {
      return '-';
    }

    return enrollment.commissionType!
        .toUpperCase();
  }

  String _commissionValue(
    EnrollmentModel enrollment,
  ) {
    final value =
        enrollment.commissionValue ?? 0;

    if (enrollment.commissionType ==
        'percent') {
      return '${value.toStringAsFixed(2)}%';
    }

    return _money(value);
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