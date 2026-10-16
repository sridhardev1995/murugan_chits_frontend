import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/models/user/user_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';
import 'package:sri_murugan_chits/services/api/storage_service.dart';

class AuthController extends GetxController {
  final ApiService apiService = ApiService();

  final RxBool isLoading = false.obs;

  final RxBool isPasswordVisible = false.obs;

  final Rx<UserModel?> user =
      Rx<UserModel?>(null);

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login(
    String email,
    String password,
  ) async {
    if (email.isEmpty) {
      Get.snackbar(
        "Login Failed",
        "Please enter username",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        "Login Failed",
        "Please enter password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await apiService.post(
        ApiConstants.login,
        data: {
          "username": email,
          "password": password,
        },
      );

      debugPrint(
        "========== LOGIN RESPONSE ==========",
      );

      debugPrint(
        "STATUS CODE: ${response.statusCode}",
      );

      debugPrint(
        "RESPONSE DATA: ${response.data}",
      );

      // ========================================================
      // LOGIN SUCCESS
      // ========================================================

      if (response.data["success"] == true) {
        final String token =
            response.data["token"]?.toString() ?? "";

        // ======================================================
        // TOKEN VALIDATION
        // ======================================================

        if (token.isEmpty) {
          Get.snackbar(
            "Login Failed",
            "Token was not received from server",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // ======================================================
        // ADMIN DATA
        // ======================================================

        final admin =
            response.data["admin"];

        final int? adminId =
            admin?["id"] is int
                ? admin["id"]
                : int.tryParse(
                    admin?["id"]?.toString() ?? "",
                  );

        final String? username =
            admin?["username"]?.toString();

        // ======================================================
        // SAVE SESSION
        // ======================================================

        await StorageService.saveSession(
          token: token,
          adminId: adminId,
          username: username,
        );

        // ======================================================
        // VERIFY TOKEN
        // ======================================================

        final savedToken =
            await StorageService.getToken();

        debugPrint(
          "========== TOKEN CHECK ==========",
        );

        debugPrint(
          "TOKEN RECEIVED: ${token.isNotEmpty}",
        );

        debugPrint(
          "TOKEN SAVED: "
          "${savedToken != null && savedToken.isNotEmpty}",
        );

        debugPrint(
          "TOKEN LENGTH: ${savedToken?.length ?? 0}",
        );

        // ======================================================
        // USER MODEL
        // ======================================================

        if (admin != null) {
          try {
            user.value =
                UserModel.fromJson(admin);
          } catch (e) {
            debugPrint(
              "USER MODEL PARSE ERROR: $e",
            );
          }
        }

        // ======================================================
        // SUCCESS MESSAGE
        // ======================================================

        Get.snackbar(
          "Success",
          response.data["message"]?.toString() ??
              "Login successful",
          snackPosition: SnackPosition.BOTTOM,
        );

        // ======================================================
        // DASHBOARD
        // ======================================================

        Get.offAllNamed("/dashboard");

        return;
      }

      // ========================================================
      // LOGIN FAILED
      // ========================================================

      Get.snackbar(
        "Login Failed",
        response.data["message"]?.toString() ??
            "Invalid username or password",
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      debugPrint(
        "========== LOGIN ERROR ==========",
      );

      debugPrint(
        "STATUS CODE: ${e.response?.statusCode}",
      );

      debugPrint(
        "RESPONSE DATA: ${e.response?.data}",
      );

      debugPrint(
        "REQUEST URL: ${e.requestOptions.uri}",
      );

      debugPrint(
        "REQUEST METHOD: ${e.requestOptions.method}",
      );

      debugPrint(
        "REQUEST DATA: ${e.requestOptions.data}",
      );

      String message =
          "Something went wrong";

      if (e.response?.data is Map) {
        message =
            e.response?.data["message"]?.toString() ??
                "Login failed";
      } else if (e.response?.statusCode != null) {
        message =
            "Request failed "
            "(${e.response?.statusCode})";
      }

      Get.snackbar(
        "Login Failed",
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint(
        "UNKNOWN LOGIN ERROR: $e",
      );

      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
  try {
    await StorageService.logout();

    user.value = null;

    debugPrint("LOGOUT SUCCESS");
    debugPrint("TOKEN CLEARED");

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
  // PASSWORD VISIBILITY
  // ============================================================

  void togglePasswordVisibility() {
    isPasswordVisible.value =
        !isPasswordVisible.value;
  }
}