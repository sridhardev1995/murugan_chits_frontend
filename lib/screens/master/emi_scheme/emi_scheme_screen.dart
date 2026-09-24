import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/emi_scheme/emi_scheme_model.dart';
import 'package:sri_murugan_chits/screens/master/emi_scheme/emi_scheme_controller.dart';


class EmiSchemeScreen
    extends GetView<EmiSchemeController> {
  const EmiSchemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EMI Schemes',
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.setAddMode();

          _showSchemeDialog(
            context,
            isEdit: false,
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),

      body: Column(
        children: [
          _buildSearchAndFilter(context),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.schemes.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () {
                  return controller.fetchSchemes(
                    showLoader: false,
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      controller.schemes.length,
                  itemBuilder:
                      (context, index) {
                    final scheme =
                        controller.schemes[index];

                    return _buildSchemeCard(
                      context,
                      scheme,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SEARCH + FILTER
  // --------------------------------------------------

  Widget _buildSearchAndFilter(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged:
                  controller.searchSchemes,
              decoration: InputDecoration(
                hintText:
                    'Search scheme...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Obx(() {
            return DropdownButton<String>(
              value:
                  controller.selectedStatus
                          .value
                          .isEmpty
                      ? null
                      : controller
                          .selectedStatus
                          .value,
              hint: const Text(
                'Status',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Active',
                  child: Text(
                    'Active',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Inactive',
                  child: Text(
                    'Inactive',
                  ),
                ),
              ],
              onChanged: (value) {
                controller.filterByStatus(
                  value ?? '',
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // CARD
  // --------------------------------------------------

  Widget _buildSchemeCard(
    BuildContext context,
    EmiSchemeModel scheme,
  ) {
    final isActive =
        scheme.status == 'Active';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            color: Colors.black
                .withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 150,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green
                  : Colors.grey,
              borderRadius:
                  const BorderRadius.only(
                topLeft:
                    Radius.circular(16),
                bottomLeft:
                    Radius.circular(16),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scheme.name ??
                              'Unnamed Scheme',
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      _statusBadge(
                        scheme.status ??
                            'Inactive',
                      ),
                    ],
                  ),

                  if ((scheme.description ??
                          '')
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      scheme.description!,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color:
                            Colors.grey[600],
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 14,
                  ),

                  Row(
                    children: [
                      _infoItem(
                        Icons.calendar_month,
                        '${scheme.defaultWeeks ?? 0} Weeks',
                      ),

                      const SizedBox(
                        width: 20,
                      ),

                      _infoItem(
                        Icons.percent,
                        '${scheme.defaultCommissionValue ?? 0} ${scheme.defaultCommissionType == 'percent' ? '%' : '₹'}',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () {
                          controller
                              .setEditScheme(
                            scheme,
                          );

                          _showSchemeDialog(
                            context,
                            isEdit: true,
                          );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                      ),

                      IconButton(
                        tooltip:
                            'Change Status',
                        onPressed: () {
                          controller
                              .changeStatus(
                            scheme,
                          );
                        },
                        icon: Icon(
                          isActive
                              ? Icons
                                  .toggle_on_outlined
                              : Icons
                                  .toggle_off_outlined,
                        ),
                      ),

                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () {
                          _confirmDelete(
                            context,
                            scheme,
                          );
                        },
                        icon: const Icon(
                          Icons
                              .delete_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // STATUS BADGE
  // --------------------------------------------------

  Widget _statusBadge(
    String status,
  ) {
    final active =
        status == 'Active';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? Colors.green
                .withOpacity(0.10)
            : Colors.grey
                .withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
          color: active
              ? Colors.green
              : Colors.grey[700],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // INFO ITEM
  // --------------------------------------------------

  Widget _infoItem(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[700],
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          text,
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // EMPTY
  // --------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons
                .account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            'No EMI schemes found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ADD / EDIT DIALOG
  // --------------------------------------------------

  void _showSchemeDialog(
    BuildContext context, {
    required bool isEdit,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          isEdit
              ? 'Edit EMI Scheme'
              : 'Add EMI Scheme',
        ),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextField(
                controller:
                    controller.nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'Scheme Name',
                  prefixIcon:
                      Icon(Icons.title),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              TextField(
                controller: controller
                    .descriptionController,
                maxLines: 2,
                decoration:
                    const InputDecoration(
                  labelText: 'Description',
                  prefixIcon:
                      Icon(Icons.description),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              TextField(
                controller:
                    controller.weeksController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Default Weeks',
                  prefixIcon:
                      Icon(Icons.calendar_month),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Obx(() {
                return DropdownButtonFormField<
                    String>(
                  initialValue: controller
                      .selectedCommissionType
                      .value,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Commission Type',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'percent',
                      child:
                          Text('Percentage'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed',
                      child:
                          Text('Fixed Amount'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller
                          .selectedCommissionType
                          .value = value;
                    }
                  },
                );
              }),

              const SizedBox(
                height: 12,
              ),

              TextField(
                controller: controller
                    .commissionValueController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText:
                      'Commission Value',
                  prefixIcon:
                      Icon(Icons.payments),
                ),
              ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearForm();
            },
            child: const Text(
              'Cancel',
            ),
          ),

          Obx(() {
            return ElevatedButton(
              onPressed:
                  controller.isSaving.value
                      ? null
                      : () {
                          if (isEdit) {
                            controller
                                .updateScheme();
                          } else {
                            controller
                                .createScheme();
                          }
                        },
              child:
                  controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEdit
                              ? 'Update'
                              : 'Save',
                        ),
            );
          }),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DELETE CONFIRM
  // --------------------------------------------------

  void _confirmDelete(
    BuildContext context,
    EmiSchemeModel scheme,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Scheme',
        ),
        content: Text(
          'Are you sure you want to delete "${scheme.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();

              controller.deleteScheme(
                scheme,
              );
            },
            child: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );
  }
}