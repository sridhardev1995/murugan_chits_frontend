import 'package:dio/dio.dart';

import 'package:sri_murugan_chits/models/dashboard/dashboard_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class HomeRepository {
  final ApiService _api = ApiService();

  // ============================================================
  // GET HOME SUMMARY
  // ============================================================

  Future<DashboardModel> getDashboardSummary() async {
    try {
      final response = await _api.get(
        ApiConstants.dashboardSummary,
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid dashboard response',
        );
      }

      final responseData =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      if (responseData['success'] != true) {
        throw Exception(
          responseData['message']?.toString() ??
              'Unable to fetch dashboard',
        );
      }

      final data =
          responseData['data'];

      if (data is! Map) {
        throw Exception(
          'Dashboard data not found',
        );
      }

      return DashboardModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(
        _extractError(e),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _extractError(
    DioException error,
  ) {
    final data = error.response?.data;

    if (data is Map &&
        data['message'] != null) {
      return data['message'].toString();
    }

    if (error.message != null &&
        error.message!.trim().isNotEmpty) {
      return error.message!;
    }

    return 'Unable to fetch dashboard';
  }
}