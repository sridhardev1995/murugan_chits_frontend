import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/scheme_picker_sheet.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/customer_picker_sheet.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';


class AddEnrollmentScreen extends StatelessWidget {
  const AddEnrollmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmiEnrollmentController());

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        title: const Text('New Enrollment', style: AppTextStyle.heading),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer', style: AppTextStyle.semiBold),
            const SizedBox(height: 6),
            Obx(() {
              final customer = controller.selectedCustomer.value;
              return _PickerTile(
                icon: Icons.person_outline,
                text: customer?.name ?? 'Tap to select customer',
                isPlaceholder: customer == null,
                onTap: () async {
                  final picked = await showCustomerPicker(context);
                  if (picked != null) controller.pickCustomer(picked);
                },
              );
            }),

            const SizedBox(height: 18),
            const Text('Scheme', style: AppTextStyle.semiBold),
            const SizedBox(height: 6),
            Obx(() {
              final scheme = controller.selectedScheme.value;
              return _PickerTile(
                icon: Icons.account_balance_wallet_outlined,
                text: scheme?.name ?? 'Tap to select scheme',
                isPlaceholder: scheme == null,
                onTap: () async {
                  final picked = await showSchemePicker(context);
                  if (picked != null) controller.pickScheme(picked);
                },
              );
            }),

            const SizedBox(height: 18),
            TextField(
              controller: controller.amountController,
              style: AppTextStyle.regular,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('Requested Amount',
                  icon: Icons.currency_rupee),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: controller.weeksController,
              style: AppTextStyle.regular,
              keyboardType: TextInputType.number,
              decoration:
                  _inputDecoration('Weeks', icon: Icons.calendar_month),
            ),

            const SizedBox(height: 12),
            Obx(() {
              return DropdownButtonFormField<String>(
                initialValue: controller.selectedCommissionType.value,
                style: AppTextStyle.regular,
                decoration: _inputDecoration('Commission Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'percent',
                    child: Text('Percentage', style: AppTextStyle.regular),
                  ),
                  DropdownMenuItem(
                    value: 'fixed',
                    child: Text('Fixed Amount', style: AppTextStyle.regular),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) controller.selectedCommissionType.value = v;
                },
              );
            }),

            const SizedBox(height: 12),
            TextField(
              controller: controller.commissionValueController,
              style: AppTextStyle.regular,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  _inputDecoration('Commission Value', icon: Icons.payments),
            ),

            const SizedBox(height: 12),
            Obx(() {
              return _PickerTile(
                icon: Icons.date_range,
                text: DateFormat('dd MMM yyyy')
                    .format(controller.startDate.value),
                showChevron: false,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.startDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) controller.startDate.value = picked;
                },
              );
            }),

            const SizedBox(height: 24),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    // AppTextStyle.button is white; on yellow it's unreadable,
                    // so the button text is overridden to black below.
                    foregroundColor: AppColors.black,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.createEnrollment,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.black,
                          ),
                        )
                      : Text(
                          'Enroll Customer',
                          style: AppTextStyle.button
                              .copyWith(color: AppColors.black),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration(String label, {IconData? icon}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyle.regular,
      prefixIcon: icon == null ? null : Icon(icon, color: AppColors.black),
      filled: true,
      fillColor: AppColors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.black, width: 1.5),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isPlaceholder = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isPlaceholder;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.black),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: isPlaceholder
                    ? AppTextStyle.regular.copyWith(color: Colors.grey)
                    : AppTextStyle.regular,
              ),
            ),
            if (showChevron) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}