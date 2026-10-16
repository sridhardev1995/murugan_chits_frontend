import 'package:dio/dio.dart';

import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class TodayCollectionRepository {
  final ApiService _api;

  TodayCollectionRepository(this._api);

  // ============================================================
  // GET TODAY COLLECTIONS
  // ============================================================

  Future<Map<String, dynamic>> getTodayCollections() async {
    try {
      final response = await _api.get(
        ApiConstants.todayCollections,
      );

      final body = _asMap(response.data);

      if (body['success'] != true) {
        throw Exception(
          body['message']?.toString() ??
              'Failed to fetch today collections',
        );
      }

      return _asMap(body['data']);
    } on DioException catch (e) {
      throw Exception(
        _extractError(e),
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ============================================================
  // GET TODAY COLLECTION SUMMARY
  // ============================================================

  Future<Map<String, dynamic>>
      getTodayCollectionSummary() async {
    try {
      final response = await _api.get(
        ApiConstants.todayCollectionSummary,
      );

      final body = _asMap(response.data);

      if (body['success'] != true) {
        throw Exception(
          body['message']?.toString() ??
              'Failed to fetch collection summary',
        );
      }

      return _asMap(body['data']);
    } on DioException catch (e) {
      throw Exception(
        _extractError(e),
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ============================================================
  // MAP HELPER
  // ============================================================

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }

  // ============================================================
  // ERROR HELPER
  // ============================================================

  String _extractError(
    DioException e,
  ) {
    final responseData =
        e.response?.data;

    if (responseData is Map) {
      final message =
          responseData['message'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final error =
          responseData['error'];

      if (error != null &&
          error.toString().trim().isNotEmpty) {
        return error.toString();
      }
    }

    if (e.message != null &&
        e.message!.trim().isNotEmpty) {
      return e.message!;
    }

    return 'Unable to connect to server';
  }
}