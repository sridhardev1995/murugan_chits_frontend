import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/services/repositary/auth/auth_repositary.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository repository;

  ForgotPasswordController(this.repository);

  // ============================================================
  // LOADING
  // ============================================================

  final RxBool isLoading = false.obs;

  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  final RxBool isNewPasswordVisible = false.obs;

  final RxBool isConfirmPasswordVisible = false.obs;

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
  // RESET PASSWORD
  // ============================================================

  Future<bool> resetPassword({
    required String username,
    required String recoveryPin,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final user = username.trim();
    final pin = recoveryPin.trim();
    final newPass = newPassword.trim();
    final confirmPass = confirmPassword.trim();

    // ==========================================================
    // USERNAME VALIDATION
    // ==========================================================

    if (user.isEmpty) {
      _showError(
        "Please enter username",
      );
      return false;
    }

    // ==========================================================
    // RECOVERY PIN VALIDATION
    // ==========================================================

    if (pin.isEmpty) {
      _showError(
        "Please enter recovery PIN",
      );
      return false;
    }

    if (pin.length != 6) {
      _showError(
        "Recovery PIN must be 6 digits",
      );
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      _showError(
        "Recovery PIN must contain only numbers",
      );
      return false;
    }

    // ==========================================================
    // NEW PASSWORD VALIDATION
    // ==========================================================

    if (newPass.isEmpty) {
      _showError(
        "Please enter new password",
      );
      return false;
    }

    if (newPass.length < 6) {
      _showError(
        "New password must be at least 6 characters",
      );
      return false;
    }

    // ==========================================================
    // CONFIRM PASSWORD VALIDATION
    // ==========================================================

    if (confirmPass.isEmpty) {
      _showError(
        "Please confirm new password",
      );
      return false;
    }

    if (newPass != confirmPass) {
      _showError(
        "New password and confirm password do not match",
      );
      return false;
    }

    // ==========================================================
    // API CALL
    // ==========================================================

    try {
      isLoading.value = true;

      debugPrint(
        "========================================",
      );
      debugPrint(
        "RESET PASSWORD",
      );
      debugPrint(
        "USERNAME : $user",
      );
      debugPrint(
        "RECOVERY PIN : ******",
      );
      debugPrint(
        "========================================",
      );

      final response =
          await repository.resetPassword(
        username: user,
        recoveryPin: pin,
        newPassword: newPass,
      );

      debugPrint(
        "RESET PASSWORD RESPONSE: $response",
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response["success"] == true) {
        Get.snackbar(
          "Success",
          response["message"]?.toString() ??
              "Password reset successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return true;
      }

      // ========================================================
      // API FAILED
      // ========================================================

      _showError(
        response["message"]?.toString() ??
            "Unable to reset password",
      );

      return false;
    } catch (e) {
      debugPrint(
        "RESET PASSWORD ERROR: $e",
      );

      String message = e.toString();

      if (message.startsWith("Exception: ")) {
        message =
            message.replaceFirst(
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
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    Get.snackbar(
      "Password Reset Failed",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}