import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/services/repositary/auth/auth_repositary.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository repository;

  ChangePasswordController(this.repository);

  // ============================================================
  // LOADING
  // ============================================================

  final RxBool isLoading = false.obs;

  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  final RxBool isCurrentPasswordVisible = false.obs;

  final RxBool isNewPasswordVisible = false.obs;

  final RxBool isConfirmPasswordVisible = false.obs;

  // ============================================================
  // TOGGLE CURRENT PASSWORD
  // ============================================================

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value =
        !isCurrentPasswordVisible.value;
  }

  // ============================================================
  // TOGGLE NEW PASSWORD
  // ============================================================

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value =
        !isNewPasswordVisible.value;
  }

  // ============================================================
  // TOGGLE CONFIRM PASSWORD
  // ============================================================

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value =
        !isConfirmPasswordVisible.value;
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // ==========================================================
    // VALIDATION
    // ==========================================================

    final current = currentPassword.trim();
    final newPass = newPassword.trim();
    final confirm = confirmPassword.trim();

    if (current.isEmpty) {
      _showError("Please enter current password");
      return false;
    }

    if (newPass.isEmpty) {
      _showError("Please enter new password");
      return false;
    }

    if (confirm.isEmpty) {
      _showError("Please confirm new password");
      return false;
    }

    if (newPass.length < 6) {
      _showError(
        "New password must be at least 6 characters",
      );
      return false;
    }

    if (newPass != confirm) {
      _showError(
        "New password and confirm password do not match",
      );
      return false;
    }

    if (current == newPass) {
      _showError(
        "New password must be different from current password",
      );
      return false;
    }

    // ==========================================================
    // API CALL
    // ==========================================================

    try {
      isLoading.value = true;

      final response = await repository.changePassword(
        currentPassword: current,
        newPassword: newPass,
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response["success"] == true) {
        Get.snackbar(
          "Success",
          response["message"]?.toString() ??
              "Password updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        return true;
      }

      // ========================================================
      // API FAILURE
      // ========================================================

      _showError(
        response["message"]?.toString() ??
            "Unable to change password",
      );

      return false;
    } catch (e) {
      // ========================================================
      // EXCEPTION
      // ========================================================

      String message = e.toString();

      if (message.startsWith("Exception: ")) {
        message = message.replaceFirst(
          "Exception: ",
          "",
        );
      }

      _showError(message);

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(String message) {
    Get.snackbar(
      "Password Update Failed",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}