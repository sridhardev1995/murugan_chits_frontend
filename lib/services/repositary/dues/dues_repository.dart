import 'package:dio/dio.dart';

import 'package:sri_murugan_chits/models/dues/dues_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class DuesRepository {
  final ApiService _apiService = ApiService();

  // ============================================================
  // DIWALI TODAY DUE
  // ============================================================

  Future<List<DuesModel>> getDiwaliTodayDue() async {
    try {
      final response = await _apiService.get(ApiConstants.diwaliTodayDue);

      final data = response.data;

      if (data is Map && data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map>()
            .map(
              (item) => DuesModel.fromDiwali(
                Map<String, dynamic>.from(item),
                overdue: false,
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Unable to load Diwali today due',
      );
    }
  }

  // ============================================================
  // DIWALI OVERDUE
  // ============================================================

  Future<List<DuesModel>> getDiwaliOverdue() async {
    try {
      final response = await _apiService.get(ApiConstants.diwaliOverdue);

      final data = response.data;

      if (data is Map && data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map>()
            .map(
              (item) => DuesModel.fromDiwali(
                Map<String, dynamic>.from(item),
                overdue: true,
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Unable to load Diwali overdue',
      );
    }
  }

  // ============================================================
  // EMI TODAY DUE
  // ============================================================

  Future<List<DuesModel>> getEmiTodayDue() async {
    try {
      final response = await _apiService.get(ApiConstants.emiTodayDue);

      final data = response.data;

      if (data is Map && data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map>()
            .map(
              (item) => DuesModel.fromEmi(
                Map<String, dynamic>.from(item),
                overdue: false,
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Unable to load EMI today due',
      );
    }
  }

  // ============================================================
  // EMI OVERDUE
  // ============================================================

  Future<List<DuesModel>> getEmiOverdue() async {
    try {
      final response = await _apiService.get(ApiConstants.emiOverdue);

      final data = response.data;

      if (data is Map && data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map>()
            .map(
              (item) => DuesModel.fromEmi(
                Map<String, dynamic>.from(item),
                overdue: true,
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Unable to load EMI overdue',
      );
    }
  }
}
