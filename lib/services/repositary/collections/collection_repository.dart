import 'package:dio/dio.dart';

import 'package:sri_murugan_chits/models/collections/diwali_collection_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class CollectionRepository {
  final ApiService _api = ApiService();

  // ============================================================
  // TODAY DUE
  // ============================================================

  Future<List<DiwaliCollectionModel>>
      getTodayDue() async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliTodayDue,
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid today due response',
        );
      }

      if (data['success'] != true) {
        throw Exception(
          data['message']?.toString() ??
              'Unable to fetch today due',
        );
      }

      final list = data['data'];

      if (list is! List) {
        return [];
      }

      return list
          .map(
            (item) =>
                DiwaliCollectionModel.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e),
      );
    }
  }

  // ============================================================
  // OVERDUE
  // ============================================================

  Future<List<DiwaliCollectionModel>>
      getOverdue() async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliOverdue,
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid overdue response',
        );
      }

      if (data['success'] != true) {
        throw Exception(
          data['message']?.toString() ??
              'Unable to fetch overdue',
        );
      }

      final list = data['data'];

      if (list is! List) {
        return [];
      }

      return list
          .map(
            (item) =>
                DiwaliCollectionModel.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e),
      );
    }
  }

  // ============================================================
  // TODAY SUMMARY
  // ============================================================

  Future<Map<String, dynamic>>
      getTodaySummary() async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliTodaySummary,
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid collection summary response',
        );
      }

      if (data['success'] != true) {
        throw Exception(
          data['message']?.toString() ??
              'Unable to fetch collection summary',
        );
      }

      return Map<String, dynamic>.from(
        data['data'] ?? {},
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e),
      );
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _errorMessage(
    DioException error,
  ) {
    final data =
        error.response?.data;

    if (data is Map &&
        data['message'] != null) {
      return data['message'].toString();
    }

    if (error.message != null &&
        error.message!
            .trim()
            .isNotEmpty) {
      return error.message!;
    }

    return 'Unable to fetch collection data';
  }
}