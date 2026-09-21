import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/emi_scheme/emi_scheme_model.dart';
import 'package:sri_murugan_chits/services/repositary/emi_scheme/emi_scheme_repository.dart';


class EmiSchemeController extends GetxController {
  final EmiSchemeRepository repository = EmiSchemeRepository();

  // --------------------------------------------------
  // TEXT CONTROLLERS
  // --------------------------------------------------

  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  final weeksController = TextEditingController();

  final commissionValueController =
      TextEditingController();

  // --------------------------------------------------
  // OBSERVABLES
  // --------------------------------------------------

  final RxList<EmiSchemeModel> schemes =
      <EmiSchemeModel>[].obs;

  final RxBool isLoading = false.obs;

  final RxBool isSaving = false.obs;

  final RxString searchText = ''.obs;

  final RxString selectedStatus = ''.obs;

  final RxString selectedCommissionType =
      'percent'.obs;

  final RxInt currentPage = 1.obs;

  final RxInt totalPages = 1.obs;

  final RxInt totalItems = 0.obs;

  // --------------------------------------------------
  // EDIT
  // --------------------------------------------------

  final RxBool isEditing = false.obs;

  final RxInt editingId = 0.obs;

  // --------------------------------------------------
  // INIT
  // --------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    fetchSchemes();
  }

  // --------------------------------------------------
  // FETCH
  // --------------------------------------------------

  Future<void> fetchSchemes({
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      final result = await repository.getSchemes(
        page: currentPage.value,
        limit: 20,
        search: searchText.value,
        status: selectedStatus.value,
      );

      schemes.assignAll(
        result['schemes'] as List<EmiSchemeModel>,
      );

      final pagination = result['pagination'];

      if (pagination != null) {
        totalPages.value =
            pagination['totalPages'] ?? 1;

        totalItems.value =
            pagination['total'] ?? 0;
      }
    } catch (e) {
      debugPrint(
        'Fetch schemes error: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to fetch schemes',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------------------------------------
  // CREATE
  // --------------------------------------------------

  Future<void> createScheme() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isSaving.value = true;

      await repository.createScheme(
        name: nameController.text.trim(),
        description:
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        defaultWeeks:
            int.parse(weeksController.text.trim()),
        defaultCommissionType:
            selectedCommissionType.value,
        defaultCommissionValue:
            double.parse(
          commissionValueController.text.trim(),
        ),
      );

      Get.back();

      clearForm();

      await fetchSchemes(
        showLoader: false,
      );

      Get.snackbar(
        'Success',
        'Scheme created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint(
        'Create scheme error: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to create scheme',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // --------------------------------------------------
  // UPDATE
  // --------------------------------------------------

  Future<void> updateScheme() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isSaving.value = true;

      await repository.updateScheme(
        id: editingId.value,
        name: nameController.text.trim(),
        description:
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        defaultWeeks:
            int.parse(weeksController.text.trim()),
        defaultCommissionType:
            selectedCommissionType.value,
        defaultCommissionValue:
            double.parse(
          commissionValueController.text.trim(),
        ),
      );

      Get.back();

      clearForm();

      await fetchSchemes(
        showLoader: false,
      );

      Get.snackbar(
        'Success',
        'Scheme updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint(
        'Update scheme error: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to update scheme',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // --------------------------------------------------
  // STATUS
  // --------------------------------------------------

  Future<void> changeStatus(
    EmiSchemeModel scheme,
  ) async {

    final newStatus =
        scheme.status == 'Active'
            ? 'Inactive'
            : 'Active';

    try {
      await repository.changeStatus(
        id: scheme.id!,
        status: newStatus,
      );

      await fetchSchemes(
        showLoader: false,
      );

      Get.snackbar(
        'Success',
        'Scheme marked as $newStatus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint(
        'Change status error: $e',
      );

      Get.snackbar(
        'Error',
        'Unable to update status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------

  Future<void> deleteScheme(
    EmiSchemeModel scheme,
  ) async {

    try {
      await repository.deleteScheme(
        scheme.id!,
      );

      schemes.removeWhere(
        (item) => item.id == scheme.id,
      );

      Get.snackbar(
        'Success',
        'Scheme deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint(
        'Delete scheme error: $e',
      );

      Get.snackbar(
        'Error',
        'Could not delete scheme',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // --------------------------------------------------
  // EDIT FORM
  // --------------------------------------------------

  void setEditScheme(
    EmiSchemeModel scheme,
  ) {
    isEditing.value = true;

    editingId.value = scheme.id ?? 0;

    nameController.text =
        scheme.name ?? '';

    descriptionController.text =
        scheme.description ?? '';

    weeksController.text =
        scheme.defaultWeeks?.toString() ?? '';

    commissionValueController.text =
        scheme.defaultCommissionValue
                ?.toString() ??
            '';

    selectedCommissionType.value =
        scheme.defaultCommissionType ??
            'percent';
  }

  // --------------------------------------------------
  // ADD FORM
  // --------------------------------------------------

  void setAddMode() {
    clearForm();

    isEditing.value = false;

    editingId.value = 0;

    weeksController.text = '10';

    commissionValueController.text = '15';

    selectedCommissionType.value =
        'percent';
  }

  // --------------------------------------------------
  // VALIDATION
  // --------------------------------------------------

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation',
        'Scheme name is required',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    final weeks =
        int.tryParse(
      weeksController.text.trim(),
    );

    if (weeks == null || weeks <= 0) {
      Get.snackbar(
        'Validation',
        'Default weeks must be a positive whole number',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    final commission =
        double.tryParse(
      commissionValueController.text.trim(),
    );

    if (commission == null || commission < 0) {
      Get.snackbar(
        'Validation',
        'Commission value must be a valid number',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }

    return true;
  }

  // --------------------------------------------------
  // SEARCH
  // --------------------------------------------------

  void searchSchemes(String value) {
    searchText.value = value.trim();

    currentPage.value = 1;

    fetchSchemes();
  }

  // --------------------------------------------------
  // STATUS FILTER
  // --------------------------------------------------

  void filterByStatus(String value) {
    selectedStatus.value = value;

    currentPage.value = 1;

    fetchSchemes();
  }

  // --------------------------------------------------
  // FORM CLEAR
  // --------------------------------------------------

  void clearForm() {
    nameController.clear();

    descriptionController.clear();

    weeksController.clear();

    commissionValueController.clear();

    selectedCommissionType.value =
        'percent';

    isEditing.value = false;

    editingId.value = 0;
  }

  // --------------------------------------------------
  // DISPOSE
  // --------------------------------------------------

  @override
  void onClose() {
    nameController.dispose();

    descriptionController.dispose();

    weeksController.dispose();

    commissionValueController.dispose();

    super.onClose();
  }
}