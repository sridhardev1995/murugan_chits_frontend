import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/models/report/emi_profit_report_model.dart';


import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class EmiProfitReportRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<EmiProfitReport> getReport({
    String? startDate,
    String? endDate,
    String? status,
    int? customerId,
    int? schemeId,
  }) async {
    final query = <String, dynamic>{};

    if (startDate != null && startDate.isNotEmpty) {
      query['startDate'] = startDate;
    }

    if (endDate != null && endDate.isNotEmpty) {
      query['endDate'] = endDate;
    }

    if (status != null && status.isNotEmpty && status != 'All') {
      query['status'] = status;
    }

    if (customerId != null) {
      query['customerId'] = customerId;
    }

    if (schemeId != null) {
      query['schemeId'] = schemeId;
    }

    try {
      final response = await _apiService.get(
        ApiConstants.emiProfitReport,
        queryParameters: query,
      );

      final body = response.data;

      if (body is! Map) {
        throw Exception('Invalid report response from server');
      }

      final json = Map<String, dynamic>.from(body);

      if (json['success'] != true) {
        throw Exception(
          json['message']?.toString() ??
              'Unable to load EMI profit report',
        );
      }

      return EmiProfitReport.fromJson(json);
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map &&
          responseData['message'] != null) {
        throw Exception(responseData['message'].toString());
      }

      if (error.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (error.response?.statusCode == 403) {
        throw Exception('You do not have permission to view this report.');
      }

      if (error.response == null) {
        throw Exception(
          'Unable to connect to server. Check your network.',
        );
      }

      throw Exception(
        'Report request failed (${error.response?.statusCode})',
      );
    }
  }
}