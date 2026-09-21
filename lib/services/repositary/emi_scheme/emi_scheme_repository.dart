
import 'package:sri_murugan_chits/models/emi_scheme/emi_scheme_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class EmiSchemeRepository {
  final ApiService apiService = ApiService();

  // --------------------------------------------------
  // GET SCHEMES
  // --------------------------------------------------

  Future<Map<String, dynamic>> getSchemes({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    final response = await apiService.get(
      ApiConstants.schemes,
      queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
        'status': status,
      },
    );

    final responseData = response.data;

    final List<dynamic> data =
        responseData['data'] ?? [];

    final List<EmiSchemeModel> schemes = data
        .map(
          (item) => EmiSchemeModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    return {
      'schemes': schemes,
      'pagination': responseData['pagination'],
    };
  }

  // --------------------------------------------------
  // GET SINGLE SCHEME
  // --------------------------------------------------

  Future<EmiSchemeModel> getSchemeById(int id) async {
    final response = await apiService.get(
      ApiConstants.schemeById(id),
    );

    return EmiSchemeModel.fromJson(
      Map<String, dynamic>.from(
        response.data['data'],
      ),
    );
  }

  // --------------------------------------------------
  // CREATE
  // --------------------------------------------------

  Future<EmiSchemeModel> createScheme({
    required String name,
    String? description,
    required int defaultWeeks,
    required String defaultCommissionType,
    required double defaultCommissionValue,
  }) async {
    final response = await apiService.post(
      ApiConstants.schemes,data:
      {
        'name': name,
        'description': description,
        'defaultWeeks': defaultWeeks,
        'defaultCommissionType': defaultCommissionType,
        'defaultCommissionValue': defaultCommissionValue,
      },
    );

    return EmiSchemeModel.fromJson(
      Map<String, dynamic>.from(
        response.data['data'],
      ),
    );
  }

  // --------------------------------------------------
  // UPDATE
  // --------------------------------------------------

  Future<EmiSchemeModel> updateScheme({
    required int id,
    required String name,
    String? description,
    required int defaultWeeks,
    required String defaultCommissionType,
    required double defaultCommissionValue,
  }) async {
    final response = await apiService.put(
      ApiConstants.schemeById(id),data:
      {
        'name': name,
        'description': description,
        'defaultWeeks': defaultWeeks,
        'defaultCommissionType': defaultCommissionType,
        'defaultCommissionValue': defaultCommissionValue,
      },
    );

    return EmiSchemeModel.fromJson(
      Map<String, dynamic>.from(
        response.data['data'],
      ),
    );
  }

  // --------------------------------------------------
  // CHANGE STATUS
  // --------------------------------------------------

  Future<void> changeStatus({
    required int id,
    required String status,
  }) async {
    await apiService.patch(
      ApiConstants.schemeStatus(id),data:
      {
        'status': status,
      },
    );
  }

  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------

  Future<void> deleteScheme(int id) async {
    await apiService.delete(
      ApiConstants.schemeById(id),
    );
  }
}