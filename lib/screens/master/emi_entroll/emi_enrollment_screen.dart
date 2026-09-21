import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_controller.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/scheme_picker_sheet.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/customer_picker_sheet.dart';

class AddEnrollmentScreen extends StatelessWidget {
  const AddEnrollmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmiEnrollmentController());

    return Scaffold(
      appBar: AppBar(title: const Text('New Enrollment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Obx(() {
              final customer = controller.selectedCustomer.value;
              return InkWell(
                onTap: () async {
                  final picked = await showCustomerPicker(context);
                  if (picked != null) controller.pickCustomer(picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(customer?.name ?? 'Tap to select customer'),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 18),
            const Text('Scheme', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Obx(() {
              final scheme = controller.selectedScheme.value;
              return InkWell(
                onTap: () async {
                  final picked = await showSchemePicker(context);
                  if (picked != null) controller.pickScheme(picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(scheme?.name ?? 'Tap to select scheme'),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 18),
            TextField(
              controller: controller.amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Requested Amount',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: controller.weeksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weeks',
                prefixIcon: Icon(Icons.calendar_month),
              ),
            ),

            const SizedBox(height: 12),
            Obx(() {
              return DropdownButtonFormField<String>(
                value: controller.selectedCommissionType.value,
                decoration: const InputDecoration(labelText: 'Commission Type'),
                items: const [
                  DropdownMenuItem(value: 'percent', child: Text('Percentage')),
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
                ],
                onChanged: (v) {
                  if (v != null) controller.selectedCommissionType.value = v;
                },
              );
            }),

            const SizedBox(height: 12),
            TextField(
              controller: controller.commissionValueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Commission Value',
                prefixIcon: Icon(Icons.payments),
              ),
            ),

            const SizedBox(height: 12),
            Obx(() {
              return InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.startDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) controller.startDate.value = picked;
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 10),
                      Text(DateFormat('dd MMM yyyy').format(controller.startDate.value)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value ? null : controller.createEnrollment,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enroll Customer'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}