
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/diwali_scheme.dart/diwali_scheme_model.dart';
import 'package:sri_murugan_chits/screens/master/diwali_scheme/diwali_scheme_form_view.dart';
import 'package:sri_murugan_chits/utils/colors/app_gradients.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

import 'diwali_scheme_controller.dart';

class DiwaliSchemeView extends GetView<DiwaliSchemeController> {
  const DiwaliSchemeView({super.key});

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Diwali Schemes',
          style: AppTextStyle.heading,
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryGradient,
          ),
        ),
        foregroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.refreshSchemes,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Get.to(() => const DiwaliSchemeFormView());
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Add Scheme',
          style: AppTextStyle.button,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusFilters(),
            const SizedBox(height: 8),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS FILTERS
  // ============================================================

  Widget _buildStatusFilters() {
    const filters = ['', 'Active', 'Closed'];

    const labels = {
      '': 'All',
      'Active': 'Active',
      'Closed': 'Closed',
    };

    return Obx(() {
      final currentFilter = controller.statusFilter.value;

      return SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final value = filters[index];
            final selected = currentFilter == value;

            return ChoiceChip(
              label: Text(labels[value]!),
              selected: selected,
              onSelected: (_) => controller.setStatusFilter(value),
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              labelStyle: AppTextStyle.semiBoldSmall.copyWith(
                color: selected
                    ? Colors.white
                    : const Color(0xFF1F2937),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? primaryColor
                      : Colors.grey.shade300,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ============================================================
  // SCHEME LIST
  // ============================================================

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.schemes.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.schemes.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshSchemes,
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
          itemCount: controller.schemes.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.schemes.length) {
              return Obx(() {
                if (!controller.isLoadingMore.value) {
                  return const SizedBox.shrink();
                }

                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              });
            }

            final scheme = controller.schemes[index];

            return _buildSchemeCard(scheme);
          },
        ),
      );
    });
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No schemes found',
            style: AppTextStyle.regularLarge.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: controller.refreshSchemes,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCHEME CARD
  // ============================================================

  Widget _buildSchemeCard(DiwaliSchemeModel scheme) {
    final isActive = scheme.status == 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openEditScreen(scheme),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF9800),
                      Color(0xFFFF5722),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_fire_department_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.schemeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.semiBoldLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Chit ₹${scheme.chitValue.toStringAsFixed(0)} · '
                      '${scheme.durationWeeks} wks',
                      style: AppTextStyle.regularSmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Bonus ₹${scheme.bonusPerChit.toStringAsFixed(0)}',
                      style: AppTextStyle.regularSmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Starts ${scheme.startDate}',
                      style: AppTextStyle.regularSmall.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status and edit actions
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(
                    scheme.status,
                    isActive,
                  ),
                  const SizedBox(height: 4),

                  // EDIT BUTTON
                  IconButton(
                    tooltip: 'Edit Scheme',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _openEditScreen(scheme),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),

                  // STATUS TOGGLE
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: isActive,
                      onChanged: (_) {
                        controller.toggleStatus(scheme);
                      },
                      activeThumbColor: Colors.green.shade600,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EDIT NAVIGATION
  // ============================================================

  void _openEditScreen(DiwaliSchemeModel scheme) {
    Get.to(
      () => DiwaliSchemeFormView(scheme: scheme),
    )?.then((result) {
      // Refresh when form returns after a successful update.
      if (result == true) {
        controller.refreshSchemes();
      }
    });
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(String status, bool isActive) {
    final color = isActive
        ? Colors.green.shade700
        : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyle.semiBoldSmall.copyWith(
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}
