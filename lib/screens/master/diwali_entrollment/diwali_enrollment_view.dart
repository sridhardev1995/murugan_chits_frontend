import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/diwali_enrollment/diwali_enrollment_model.dart';
import 'package:sri_murugan_chits/screens/master/diwali_entrollment/diwali_enrollment_detail_view.dart';
import 'package:sri_murugan_chits/screens/master/diwali_entrollment/diwali_enrollment_form_view.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

import 'diwali_enrollment_controller.dart';

class DiwaliEnrollmentView
    extends GetView<DiwaliEnrollmentController> {
  const DiwaliEnrollmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: Text(
          'Diwali Enrollments',
          style: AppTextStyle.heading,
        ),
        backgroundColor:
            const Color(0xFFF6F7FB),
        elevation: 0,
        foregroundColor:
            const Color(0xFF1F2937),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xFF2563EB),
        onPressed: () {
          Get.to(
            () =>
                const DiwaliEnrollmentFormView(),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          'New Enrollment',
          style: AppTextStyle.button,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilter(),
            Expanded(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        8,
      ),
      child: Container(
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.04),
              blurRadius: 8,
              offset:
                  const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller:
              controller.searchController,
          decoration:
              InputDecoration(
            hintText:
                'Search customer name',
            hintStyle:
                TextStyle(
              color:
                  Colors.grey.shade500,
              fontSize: 14,
            ),
            prefixIcon:
                const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            suffixIcon:
                Obx(() {
              if (!controller
                  .hasSearchText
                  .value) {
                return const SizedBox
                    .shrink();
              }

              return IconButton(
                icon:
                    const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey,
                ),
                onPressed:
                    controller
                        .clearSearch,
              );
            }),
            border:
                InputBorder.none,
            contentPadding:
                const EdgeInsets
                    .symmetric(
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilter() {
    return SizedBox(
      height: 48,
      child: Obx(
        () => ListView(
          scrollDirection:
              Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          children: [
            _filterChip(
              label: 'All',
              value: '',
            ),
            _filterChip(
              label: 'Active',
              value: 'Active',
            ),
            _filterChip(
              label: 'Completed',
              value: 'Completed',
            ),
            _filterChip(
              label: 'Cancelled',
              value: 'Cancelled',
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required String value,
  }) {
    final selected =
        controller
                .selectedStatus
                .value ==
            value;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          controller.changeStatus(
            value,
          );
        },
      ),
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.enrollments.isEmpty) {
        return const Center(
          child:
              CircularProgressIndicator(),
        );
      }

      if (controller
          .enrollments
          .isEmpty) {
        return RefreshIndicator(
          onRefresh:
              controller
                  .refreshEnrollments,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height:
                    Get.height * 0.6,
                child:
                    _buildEmptyState(),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh:
            controller
                .refreshEnrollments,
        child: ListView.builder(
          controller:
              controller
                  .scrollController,
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            100,
          ),
          itemCount:
              controller.enrollments.length +
                  1,
          itemBuilder:
              (context, index) {
            if (index ==
                controller
                    .enrollments
                    .length) {
              return Obx(() {
                if (!controller
                    .isLoadingMore
                    .value) {
                  return const SizedBox
                      .shrink();
                }

                return const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                );
              });
            }

            final enrollment =
                controller
                    .enrollments[index];

            return _buildEnrollmentCard(
              enrollment,
            );
          },
        ),
      );
    });
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons
                .card_giftcard_outlined,
            size: 64,
            color:
                Colors.grey.shade400,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'No enrollments found',
            style: AppTextStyle
                .regularLarge
                .copyWith(
              color:
                  Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildEnrollmentCard(
    DiwaliEnrollmentModel enrollment,
  ) {
    final isActive =
        enrollment.status ==
            'Active';

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),
            blurRadius: 8,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: () {
          Get.to(
            () =>
                DiwaliEnrollmentDetailView(
              enrollmentId:
                  enrollment.id,
            ),
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    const Color(
                  0xFFE8F0FE,
                ),
                child: Text(
                  enrollment
                          .customerName
                          .isNotEmpty
                      ? enrollment
                          .customerName
                          .substring(
                            0,
                            1,
                          )
                          .toUpperCase()
                      : '?',
                  style: AppTextStyle
                      .semiBoldLarge
                      .copyWith(
                    color:
                        const Color(
                      0xFF2563EB,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      enrollment
                          .customerName,
                      style: AppTextStyle
                          .semiBoldLarge.copyWith(fontSize: 17),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                                        Text(
                      enrollment.schemeName,
                      style: AppTextStyle
                          .regular
                          .copyWith(
                        color:
                            Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 13
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      '${enrollment.currentChits} chits · '
                      '₹${enrollment.chitValue.toStringAsFixed(0)}/chit',
                      style: AppTextStyle
                          .regular
                          .copyWith(
                        color:
                            Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color: isActive
                      ? Colors.green
                          .withOpacity(
                          0.1,
                        )
                      : Colors.grey
                          .withOpacity(
                          0.15,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  enrollment.status,
                  style: AppTextStyle
                      .semiBoldSmall
                      .copyWith(
                    color: isActive
                        ? Colors.green
                            .shade700
                        : Colors.grey
                            .shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}