import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/customers/customer_model.dart';
import 'package:sri_murugan_chits/models/diwali_scheme.dart/diwali_scheme_model.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

import 'diwali_enrollment_controller.dart';

class DiwaliEnrollmentFormView
    extends GetView<DiwaliEnrollmentController> {
  const DiwaliEnrollmentFormView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const _EnrollmentForm();
  }
}

class _EnrollmentForm
    extends StatefulWidget {
  const _EnrollmentForm();

  @override
  State<_EnrollmentForm> createState() =>
      _EnrollmentFormState();
}

class _EnrollmentFormState
    extends State<_EnrollmentForm> {
  final _formKey =
      GlobalKey<FormState>();

  final _chitsController =
      TextEditingController();

  DiwaliEnrollmentController
      get controller =>
          Get.find<
              DiwaliEnrollmentController>();

  @override
  void initState() {
    super.initState();

    controller.clearFormSelections();
    _chitsController.clear();
  }

  @override
  void dispose() {
    _chitsController.dispose();
    super.dispose();
  }

  // ============================================================
  // CUSTOMER
  // ============================================================

  Future<void> _pickCustomer() async {
    final customers =
        await controller.searchCustomers(
      '',
    );

    if (!mounted) return;

    final selected =
        await showModalBottomSheet<
            CustomerModel>(
      context: context,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) =>
          _CustomerPickerSheet(
        initialCustomers:
            customers,
        onSearch:
            controller.searchCustomers,
      ),
    );

    if (selected != null) {
      controller.pickCustomer(
        selected,
      );
    }
  }

  // ============================================================
  // SCHEME
  // ============================================================

  Future<void> _pickScheme() async {
    final schemes =
        await controller
            .searchActiveSchemes();

    if (!mounted) return;

    final selected =
        await showModalBottomSheet<
            DiwaliSchemeModel>(
      context: context,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) =>
          _SchemePickerSheet(
        schemes: schemes,
      ),
    );

    if (selected != null) {
      controller.pickScheme(
        selected,
      );
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final chits =
        int.tryParse(
              _chitsController.text
                  .trim(),
            ) ??
            0;

    final result =
        await controller
            .createEnrollment(
      chits,
    );

    if (result == null ||
        !mounted) {
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _EnrollmentPreviewDialog(
        weeklyAmount:
            result['weeklyAmount']
                as double,
        totalPayable:
            result['totalPayable']
                as double,
        maturityReturn:
            result['maturityReturn']
                as double,
      ),
    );

    if (!mounted) return;

    Get.back();

    Get.snackbar(
      'Success',
      result['message']
              ?.toString() ??
          'Enrolled successfully',
      snackPosition:
          SnackPosition.BOTTOM,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: Text(
          'New Enrollment',
          style: AppTextStyle.heading,
        ),
        backgroundColor:
            const Color(0xFFF6F7FB),
        elevation: 0,
        foregroundColor:
            const Color(0xFF1F2937),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(20),
          children: [
            Text(
              'Customer',
              style: AppTextStyle
                  .semiBold
                  .copyWith(
                color:
                    const Color(
                  0xFF6B7280,
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Obx(() {
              final customer =
                  controller
                      .selectedCustomer
                      .value;

              return _pickerTile(
                icon:
                    Icons.person_outline,
                label: customer == null
                    ? 'Select a customer'
                    : '${customer.name} · ${customer.phone}',
                filled:
                    customer != null,
                onTap:
                    _pickCustomer,
              );
            }),

            const SizedBox(
              height: 20,
            ),

            Text(
              'Scheme',
              style: AppTextStyle
                  .semiBold
                  .copyWith(
                color:
                    const Color(
                  0xFF6B7280,
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Obx(() {
              final scheme =
                  controller
                      .selectedScheme
                      .value;

              return _pickerTile(
                icon: Icons
                    .local_fire_department_outlined,
                label: scheme == null
                    ? 'Select an active scheme'
                    : '${scheme.schemeName} · ₹${scheme.chitValue.toStringAsFixed(0)}/chit · ${scheme.durationWeeks} wks',
                filled:
                    scheme != null,
                onTap:
                    _pickScheme,
              );
            }),

            const SizedBox(
              height: 20,
            ),

            Text(
              'Number of Chits',
              style: AppTextStyle
                  .semiBold
                  .copyWith(
                color:
                    const Color(
                  0xFF6B7280,
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            TextFormField(
              controller:
                  _chitsController,
              keyboardType:
                  TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter
                    .digitsOnly,
              ],
              validator: (value) {
                final count =
                    int.tryParse(
                  value?.trim() ??
                      '',
                );

                if (count == null ||
                    count <= 0) {
                  return 'Enter a valid number of chits';
                }

                return null;
              },
              decoration:
                  InputDecoration(
                hintText: 'e.g. 2',
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            Obx(() {
              final saving =
                  controller
                      .isSaving
                      .value;

              return SizedBox(
                height: 52,
                child:
                    ElevatedButton(
                  onPressed:
                      saving
                          ? null
                          : _submit,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2563EB,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.white,
                            strokeWidth:
                                2.5,
                          ),
                        )
                      : Text(
                          'Enroll Customer',
                          style:
                              AppTextStyle
                                  .button,
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PICKER TILE
  // ============================================================

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(12),
          border:
              Border.all(
            color:
                Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: filled
                  ? const Color(
                      0xFF2563EB,
                    )
                  : Colors.grey.shade500,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                label,
                style: AppTextStyle
                    .regular
                    .copyWith(
                  color: filled
                      ? const Color(
                          0xFF1F2937,
                        )
                      : Colors.grey
                          .shade500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color:
                  Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER PICKER
// ============================================================

class _CustomerPickerSheet
    extends StatefulWidget {
  final List<CustomerModel>
      initialCustomers;

  final Future<
          List<CustomerModel>>
      Function(String query)
      onSearch;

  const _CustomerPickerSheet({
    required this.initialCustomers,
    required this.onSearch,
  });

  @override
  State<_CustomerPickerSheet>
      createState() =>
          _CustomerPickerSheetState();
}

class _CustomerPickerSheetState
    extends State<
        _CustomerPickerSheet> {
  late List<CustomerModel>
      _results;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _results =
        widget.initialCustomers;
  }

  Future<void> _search(
    String query,
  ) async {
    setState(() {
      _loading = true;
    });

    final results =
        await widget.onSearch(
      query,
    );

    if (!mounted) return;

    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (
        context,
        scrollController,
      ) {
        return Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Select Customer',
                style: AppTextStyle
                    .semiBoldLarge,
              ),

              const SizedBox(
                height: 12,
              ),

              TextField(
                onChanged: _search,
                decoration:
                    InputDecoration(
                  hintText:
                      'Search by name or phone',
                  prefixIcon:
                      const Icon(
                    Icons.search,
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
                      12,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Expanded(
                child: _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              'No active customers found',
                              style: AppTextStyle
                                  .regular
                                  .copyWith(
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller:
                                scrollController,
                            itemCount:
                                _results
                                    .length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final customer =
                                  _results[
                                      index];

                              return ListTile(
                                leading:
                                    CircleAvatar(
                                  backgroundColor:
                                      const Color(
                                    0xFFE8F0FE,
                                  ),
                                  child:
                                      Text(
                                    customer
                                            .name
                                            .isNotEmpty
                                        ? customer
                                            .name
                                            .substring(
                                              0,
                                              1,
                                            )
                                            .toUpperCase()
                                        : '?',
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF2563EB,
                                      ),
                                    ),
                                  ),
                                ),
                                title:
                                    Text(
                                  customer
                                      .name,
                                  style:
                                      AppTextStyle
                                          .semiBold,
                                ),
                                subtitle:
                                    Text(
                                  customer
                                      .phone,
                                  style:
                                      AppTextStyle
                                          .regularSmall,
                                ),
                                onTap: () {
                                  Get.back(
                                    result:
                                        customer,
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// SCHEME PICKER
// ============================================================

class _SchemePickerSheet
    extends StatelessWidget {
  final List<DiwaliSchemeModel>
      schemes;

  const _SchemePickerSheet({
    required this.schemes,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (
        context,
        scrollController,
      ) {
        return Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Select Active Scheme',
                style: AppTextStyle
                    .semiBoldLarge,
              ),

              const SizedBox(
                height: 12,
              ),

              Expanded(
                child: schemes.isEmpty
                    ? Center(
                        child: Text(
                          'No active schemes available',
                          style: AppTextStyle
                              .regular
                              .copyWith(
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller:
                            scrollController,
                        itemCount:
                            schemes.length,
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final scheme =
                              schemes[
                                  index];

                          return ListTile(
                            leading:
                                const Icon(
                              Icons
                                  .local_fire_department_outlined,
                              color:
                                  Color(
                                0xFFFF5722,
                              ),
                            ),
                            title:
                                Text(
                              scheme
                                  .schemeName,
                              style:
                                  AppTextStyle
                                      .semiBold,
                            ),
                            subtitle:
                                Text(
                              '₹${scheme.chitValue.toStringAsFixed(0)}/chit · '
                              '${scheme.durationWeeks} wks · '
                              'Bonus ₹${scheme.bonusPerChit.toStringAsFixed(0)}',
                              style:
                                  AppTextStyle
                                      .regularSmall,
                            ),
                            onTap: () {
                              Get.back(
                                result:
                                    scheme,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// PREVIEW
// ============================================================

class _EnrollmentPreviewDialog
    extends StatelessWidget {
  final double weeklyAmount;
  final double totalPayable;
  final double maturityReturn;

  const _EnrollmentPreviewDialog({
    required this.weeklyAmount,
    required this.totalPayable,
    required this.maturityReturn,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      title: Text(
        'Enrollment Summary',
        style:
            AppTextStyle.semiBoldLarge,
      ),
      content: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          _row(
            'Weekly Amount',
            weeklyAmount,
          ),
          _row(
            'Total Payable',
            totalPayable,
          ),
          _row(
            'Maturity Return',
            maturityReturn,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              () => Get.back(),
          child: Text(
            'Done',
            style: AppTextStyle
                .semiBold
                .copyWith(
              color:
                  const Color(
                0xFF2563EB,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(
    String label,
    double value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            label,
            style:
                AppTextStyle.regular,
          ),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style:
                AppTextStyle.semiBold,
          ),
        ],
      ),
    );
  }
}