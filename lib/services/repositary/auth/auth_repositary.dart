import 'package:dio/dio.dart';

import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final Response response = await _apiService.post(
        ApiConstants.changePassword,
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception("Invalid response from server");
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map) {
        final message = responseData["message"]?.toString();

        throw Exception(
          message?.isNotEmpty == true
              ? message
              : "Unable to change password",
        );
      }

      throw Exception(
        e.message ?? "Unable to connect to server",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================
  //
  // Forgot Password Flow:
  //
  // Username
  //     ↓
  // Recovery PIN
  //     ↓
  // New Password
  //     ↓
  // Password Reset
  //
  // This API does NOT require JWT token.
  // ============================================================

  Future<Map<String, dynamic>> resetPassword({
    required String username,
    required String recoveryPin,
    required String newPassword,
  }) async {
    try {
      final Response response = await _apiService.post(
        ApiConstants.resetPassword,
        data: {
          "username": username,
          "recoveryPin": recoveryPin,
          "newPassword": newPassword,
        },
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception("Invalid response from server");
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map) {
        final message = responseData["message"]?.toString();

        throw Exception(
          message?.isNotEmpty == true
              ? message
              : "Unable to reset password",
        );
      }

      throw Exception(
        e.message ?? "Unable to connect to server",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }
}