import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/user/user_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/api/storage_service.dart';

class AuthController extends GetxController {
  final ApiService apiService = ApiService();

  // ============================================================
  // LOADING STATE
  // ============================================================

  final RxBool isLoading = false.obs;

  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  final RxBool isPasswordVisible = false.obs;

  // ============================================================
  // LOGGED-IN USER
  // ============================================================

  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login(String email, String password) async {
    // Validate email
    if (email.isEmpty) {
      Get.snackbar(
        "Login Failed",
        "Please enter email",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate password
    if (password.isEmpty) {
      Get.snackbar(
        "Login Failed",
        "Please enter password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Start loading
      isLoading.value = true;

      // ========================================================
      // API REQUEST
      // ========================================================

      final response = await apiService.post(
        ApiConstants.login,
        data: {"username": email, "password": password},
      );

      // Debug response
      debugPrint("========== LOGIN RESPONSE ==========");
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RESPONSE DATA: ${response.data}");

      // ========================================================
      // CHECK SUCCESS
      // ========================================================

      if (response.data["success"] == true) {
        // ======================================================
        // GET TOKEN
        // ======================================================

        final String token = response.data["token"].toString();

        debugPrint("TOKEN RECEIVED: $token");

        // ======================================================
        // SAVE TOKEN TO HIVE
        // ======================================================

        await StorageService.saveToken(token);

        debugPrint("TOKEN SAVED SUCCESSFULLY");

        // ======================================================
        // GET USER
        // ======================================================

        if (response.data["user"] != null) {
          user.value = UserModel.fromJson(response.data["user"]);
        }

        // ======================================================
        // SUCCESS MESSAGE
        // ======================================================

        Get.snackbar(
          "Success",
          response.data["message"]?.toString() ?? "Login successful",
          snackPosition: SnackPosition.BOTTOM,
        );

        // ======================================================
        // NAVIGATE TO DASHBOARD
        // ======================================================

        Get.offAllNamed("/dashboard");
      } else {
        // ======================================================
        // BACKEND SUCCESS FALSE
        // ======================================================

        Get.snackbar(
          "Login Failed",
          response.data["message"]?.toString() ?? "Invalid email or password",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
    // ==========================================================
    // DIO ERROR
    // ==========================================================
    on DioException catch (e) {
      debugPrint("========== LOGIN ERROR ==========");
      debugPrint("STATUS CODE: ${e.response?.statusCode}");
      debugPrint("RESPONSE DATA: ${e.response?.data}");
      debugPrint("REQUEST URL: ${e.requestOptions.uri}");
      debugPrint("REQUEST METHOD: ${e.requestOptions.method}");
      debugPrint("REQUEST DATA: ${e.requestOptions.data}");

      String message = "Something went wrong";

      if (e.response?.data is Map) {
        message = e.response?.data["message"]?.toString() ?? "Login failed";
      } else if (e.response?.statusCode != null) {
        message = "Bad request (${e.response?.statusCode})";
      }

      Get.snackbar(
        "Login Failed",
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    // ==========================================================
    // UNKNOWN ERROR
    // ==========================================================
    catch (e) {
      debugPrint("UNKNOWN LOGIN ERROR: $e");

      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    // ==========================================================
    // STOP LOADING
    // ==========================================================
    finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      // Clear token and all stored data
      await StorageService.logout();

      // Clear user
      user.value = null;

      debugPrint("LOGOUT SUCCESS");
      debugPrint("TOKEN CLEARED");

      // Navigate to login
      Get.offAllNamed("/login");
    } catch (e) {
      debugPrint("LOGOUT ERROR: $e");

      Get.snackbar(
        "Error",
        "Unable to logout",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // TOGGLE PASSWORD VISIBILITY
  // ============================================================

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}
