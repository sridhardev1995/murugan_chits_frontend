

import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class EmiPaymentReportRepository {
  final ApiService apiService = ApiService();

  Future<Map<String, dynamic>> getPaymentReport({
    int page = 1,
    int limit = 20,
    String fromDate = '',
    String toDate = '',
    String customerId = '',
    String schemeId = '',
    String paymentMode = '',
    String status = '',
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (fromDate.trim().isNotEmpty) {
      queryParameters['fromDate'] = fromDate.trim();
    }

    if (toDate.trim().isNotEmpty) {
      queryParameters['toDate'] = toDate.trim();
    }

    if (customerId.trim().isNotEmpty) {
      queryParameters['customerId'] = customerId.trim();
    }

    if (schemeId.trim().isNotEmpty) {
      queryParameters['schemeId'] = schemeId.trim();
    }

    if (paymentMode.trim().isNotEmpty) {
      queryParameters['paymentMode'] =
          paymentMode.trim();
    }

    if (status.trim().isNotEmpty) {
      queryParameters['status'] =
          status.trim();
    }

    final response = await apiService.get(
      ApiConstants.emiPaymentReport,
      queryParameters: queryParameters,
    );

    if (response.data is! Map) {
      throw Exception(
        'Invalid EMI payment report response',
      );
    }

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }
}