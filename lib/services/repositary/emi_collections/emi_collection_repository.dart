import 'package:dio/dio.dart';

import 'package:sri_murugan_chits/models/emi_entroll/emi_installment_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class EmiCollectionRepository {
  final ApiService _apiService = ApiService();

  // ============================================================
  // TODAY DUE
  // ============================================================

  Future<List<EmiInstallmentModel>> getTodayDue() async {
    try {
      final response = await _apiService.get(
        ApiConstants.emiTodayDue,
      );

      final data = response.data;

      if (data is Map &&
          data['success'] == true &&
          data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map>()
            .map(
              (item) => EmiInstallmentModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Unable to load EMI today due',
      );
    } catch (e) {
      throw Exception(
        'Unable to load EMI today due',
      );
    }
  }

  // ============================================================
  // OVERDUE
  // ============================================================

  Future<List<EmiInstallmentModel>> getOverdue() async {
    try {
      final response = await _apiService.get(
        ApiConstants.emiOverdue,
      );

      final data = response.data;

      if (data is Map &&
          data['success'] == true &&
          data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map>()
            .map(
              (item) => EmiInstallmentModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Unable to load EMI overdue',
      );
    } catch (e) {
      throw Exception(
        'Unable to load EMI overdue',
      );
    }
  }
}