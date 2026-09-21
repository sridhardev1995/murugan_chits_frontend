import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class EnrollmentRepository {
  final ApiService apiService = ApiService();

  Future<Map<String, dynamic>> getEnrollments({
    int page = 1,
    int limit = 20,
    String customerId = '',
    String schemeId = '',
    String status = '',
  }) async {
    final response = await apiService.get(
      ApiConstants.enrollments,
      queryParameters: {
        'page': page,
        'limit': limit,
        'customerId': customerId,
        'schemeId': schemeId,
        'status': status,
      },
    );

    final responseData = response.data;
    final List<dynamic> data = responseData['data'] ?? [];

    final List<EnrollmentModel> enrollments = data
        .map((item) => EnrollmentModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return {
      'enrollments': enrollments,
      'pagination': responseData['pagination'],
    };
  }

  Future<EnrollmentModel> createEnrollment({
    required int customerId,
    required int schemeId,
    required double requestedAmount,
    String? commissionType,
    double? commissionValue,
    int? weeks,
    String? startDate,
  }) async {
    final body = {
      'customerId': customerId,
      'schemeId': schemeId,
      'requestedAmount': requestedAmount,
      if (commissionType != null) 'commissionType': commissionType,
      if (commissionValue != null) 'commissionValue': commissionValue,
      if (weeks != null) 'weeks': weeks,
      if (startDate != null) 'startDate': startDate,
    };

    final response = await apiService.post(ApiConstants.enrollments,data: body);

    return EnrollmentModel.fromJson(
      Map<String, dynamic>.from(response.data['data']),
    );
  }

  Future<void> changeStatus({required int id, required String status}) async {
    await apiService.patch(ApiConstants.enrollmentStatus(id), data:{'status': status});
  }
  Future<EnrollmentModel> getEnrollmentById(int id) async {
  final response = await apiService.get(
    ApiConstants.enrollmentById(id),
  );

  final data = response.data['data'];

  return EnrollmentModel.fromJson(
    Map<String, dynamic>.from(data),
  );
}
}