import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/utils/colors/app_gradients.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';
import 'customer_controller.dart';
import 'customer_form_view.dart';


class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text('Customers', style: AppTextStyle.heading),
          flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryGradient,
          ),
        ),
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => Get.to(() => const CustomerFormView()),
        icon: const Icon(Icons.add),
        label: Text('Add Customer', style: AppTextStyle.button),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildStatusFilters(),
            const SizedBox(height: 8),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        controller: controller.searchController,
        style: AppTextStyle.regular,
        decoration: InputDecoration(
          hintText: 'Search by name or phone',
          hintStyle: AppTextStyle.regular.copyWith(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.clearSearch,
              );
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS FILTER CHIPS
  // ============================================================

  Widget _buildStatusFilters() {
    final filters = const ['', 'Active', 'Inactive'];
    final labels = {'': 'All', 'Active': 'Active', 'Inactive': 'Inactive'};

    return Obx(() {
      final currentFilter = controller.statusFilter.value;

      return SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final value = filters[index];
            final selected = currentFilter == value;

            return ChoiceChip(
              label: Text(labels[value]!),
              selected: selected,
              onSelected: (_) => controller.setStatusFilter(value),
              selectedColor: const Color(0xFF2563EB),
              backgroundColor: Colors.white,
              labelStyle: AppTextStyle.semiBoldSmall.copyWith(
                color: selected ? Colors.white : const Color(0xFF1F2937),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            );
          },
        ),
      );
    });
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value && controller.customers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.customers.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshCustomers,
        child: ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
          itemCount: controller.customers.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.customers.length) {
              return Obx(() {
                if (!controller.isLoadingMore.value) {
                  return const SizedBox.shrink();
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              });
            }

            final customer = controller.customers[index];
            return _buildCustomerCard(customer);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: AppTextStyle.regularLarge.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOMER CARD
  // ============================================================

  Widget _buildCustomerCard(CustomerModel customer) {
    final isActive = customer.status == 'Active';

    return Dismissible(
      key: ValueKey(customer.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await controller.confirmAndDelete(customer);
        return false; // controller updates the list itself; avoid double-remove
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          onTap: () => Get.to(() => CustomerFormView(customer: customer)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE8F0FE),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: AppTextStyle.semiBoldLarge.copyWith(
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name, style: AppTextStyle.semiBoldLarge),
                      const SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: AppTextStyle.regularSmall.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 👇 Status label + explicit Switch toggle (visually obvious now)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          customer.status,
                          style: AppTextStyle.semiBoldSmall.copyWith(
                            color: isActive
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.75,
                          child: Switch(
                            value: isActive,
                            onChanged: (_) => controller.toggleStatus(customer),
                            activeColor: Colors.green.shade600,
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => controller.confirmAndDelete(customer),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}