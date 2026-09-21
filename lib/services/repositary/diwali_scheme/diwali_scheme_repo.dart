import 'package:dio/dio.dart';
import 'package:sri_murugan_chits/models/diwali_scheme.dart/diwali_scheme_model.dart';

import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';


class DiwaliSchemeRepository {
  final ApiService _api;

  DiwaliSchemeRepository(this._api);

  // GET /api/diwali-schemes?page=&limit=&status=
  Future<Map<String, dynamic>> getSchemes({
    int page = 1,
    int limit = 20,
    String status = '',
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliSchemes,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status.isNotEmpty) 'status': status,
        },
      );

      final body = response.data as Map<String, dynamic>;
      final List list = body['data'] ?? [];

      return {
        'schemes': list
            .map((e) => DiwaliSchemeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        'pagination': body['pagination'] ?? {},
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // GET /api/diwali-schemes/:id
  Future<DiwaliSchemeModel> getSchemeById(int id) async {
    try {
      final response = await _api.get('${ApiConstants.diwaliSchemes}/$id');
      final body = response.data as Map<String, dynamic>;
      return DiwaliSchemeModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // POST /api/diwali-schemes
  Future<DiwaliSchemeModel> createScheme(Map<String, dynamic> body) async {
    try {
      final response = await _api.post(ApiConstants.diwaliSchemes, data:body);
      final data = response.data as Map<String, dynamic>;
      return DiwaliSchemeModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // PUT /api/diwali-schemes/:id
  Future<DiwaliSchemeModel> updateScheme(int id, Map<String, dynamic> body) async {
    try {
      final response = await _api.put('${ApiConstants.diwaliSchemes}/$id', data: body);
      final data = response.data as Map<String, dynamic>;
      return DiwaliSchemeModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // PATCH /api/diwali-schemes/:id/status   { status: "Active" | "Closed" }
  Future<void> changeStatus(int id, String status) async {
    try {
      await _api.patch('${ApiConstants.diwaliSchemes}/$id/status', data:{'status': status});
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // Note: backend currently has no DELETE route for diwali schemes,
  // so no deleteScheme() method here. Add one on both sides if needed later.

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please check your connection.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Please check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}