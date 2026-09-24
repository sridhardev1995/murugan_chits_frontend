import 'package:sri_murugan_chits/models/emi_entroll/emi_enrollment_model.dart';
import 'package:sri_murugan_chits/models/emi_entroll/emi_installment_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class EnrollmentRepository {
  final ApiService apiService = ApiService();

  // ============================================================
  // GET ENROLLMENTS
  // ============================================================

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
        if (customerId.isNotEmpty)
          'customerId': customerId,
        if (schemeId.isNotEmpty)
          'schemeId': schemeId,
        if (status.isNotEmpty)
          'status': status,
      },
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    final List<dynamic> data =
        responseData['data'] ?? [];

    final List<EnrollmentModel> enrollments =
        data
            .map(
              (item) =>
                  EnrollmentModel.fromJson(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            )
            .toList();

    return {
      'enrollments': enrollments,
      'pagination':
          responseData['pagination'],
    };
  }

  // ============================================================
  // CREATE ENROLLMENT
  // ============================================================

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

      if (commissionType != null)
        'commissionType': commissionType,

      if (commissionValue != null)
        'commissionValue': commissionValue,

      if (weeks != null)
        'weeks': weeks,

      if (startDate != null)
        'startDate': startDate,
    };

    final response =
        await apiService.post(
      ApiConstants.enrollments,
      data: body,
    );

    return EnrollmentModel.fromJson(
      Map<String, dynamic>.from(
        response.data['data'],
      ),
    );
  }

  // ============================================================
  // CHANGE ENROLLMENT STATUS
  // ============================================================

  Future<void> changeStatus({
    required int id,
    required String status,
  }) async {
    await apiService.patch(
      ApiConstants.enrollmentStatus(id),
      data: {
        'status': status,
      },
    );
  }

  // ============================================================
  // GET ENROLLMENT BY ID
  // ============================================================

  Future<EnrollmentModel> getEnrollmentById(
    int id,
  ) async {
    final response =
        await apiService.get(
      ApiConstants.enrollmentById(id),
    );

    final data =
        response.data['data'];

    return EnrollmentModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================================
  // GET EMI SCHEDULE
  // ============================================================

  Future<Map<String, dynamic>> getEnrollmentSchedule(
    int enrollmentId,
  ) async {
    final response =
        await apiService.get(
      ApiConstants.enrollmentEmis(
        enrollmentId,
      ),
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    final data =
        Map<String, dynamic>.from(
      responseData['data'] ?? {},
    );

    final scheduleData =
        (data['schedule'] ?? [])
            as List;

    final schedule =
        scheduleData
            .map(
              (item) =>
                  EmiInstallmentModel.fromJson(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            )
            .toList();

    return {
      'enrollment':
          data['enrollment'],

      'schedule':
          schedule,

      'summary':
          data['summary'] ?? {},

      'paymentSummary':
          data['paymentSummary'] ?? {},
    };
  }

  // ============================================================
  // COLLECT SINGLE EMI PAYMENT
  //
  // Cash / UPI
  //
  // Example:
  //
  // collectInstallment(
  //   installmentId: 1,
  //   status: 'Partial',
  //   amount: 400,
  //   paymentMode: 'Cash',
  // )
  // ============================================================

  Future<EmiInstallmentModel>
      collectInstallment({
    required int installmentId,
    required String status,
    required double amount,
    required String paymentMode,
    String? paidDate,
  }) async {
    final response =
        await apiService.patch(
      ApiConstants.collectEmi(
        installmentId,
      ),
      data: {
        'status': status,
        'amount': amount,
        'paymentMode': paymentMode,

        if (paidDate != null)
          'paidDate': paidDate,
      },
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data['data'],
    );

    // Backend new response:
    //
    // data: {
    //   installment: {...},
    //   payment: {...},
    //   paymentSummary: {...}
    // }

    final installmentData =
        responseData['installment'] ??
        responseData;

    return EmiInstallmentModel.fromJson(
      Map<String, dynamic>.from(
        installmentData,
      ),
    );
  }

  // ============================================================
  // COLLECT SPLIT PAYMENT
  //
  // Example:
  //
  // Cash ₹400
  // UPI  ₹600
  //
  // payments = [
  //   {
  //     'amount': 400,
  //     'paymentMode': 'Cash',
  //   },
  //   {
  //     'amount': 600,
  //     'paymentMode': 'UPI',
  //   },
  // ]
  // ============================================================

  Future<EmiInstallmentModel>
      collectSplitPayment({
    required int installmentId,
    required String status,
    required List<Map<String, dynamic>>
        payments,
    String? paidDate,
  }) async {
    if (payments.isEmpty) {
      throw Exception(
        'At least one payment is required',
      );
    }

    final response =
        await apiService.patch(
      ApiConstants.collectEmi(
        installmentId,
      ),
      data: {
        'status': status,
        'payments': payments,

        if (paidDate != null)
          'paidDate': paidDate,
      },
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data['data'],
    );

    final installmentData =
        responseData['installment'] ??
        responseData;

    return EmiInstallmentModel.fromJson(
      Map<String, dynamic>.from(
        installmentData,
      ),
    );
  }

  // ============================================================
  // GET PAYMENT HISTORY
  // ============================================================

  Future<Map<String, dynamic>>
      getPaymentHistory(
    int installmentId,
  ) async {
    final response =
        await apiService.get(
      ApiConstants.emiPaymentHistory(
        installmentId,
      ),
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    final data =
        Map<String, dynamic>.from(
      responseData['data'] ?? {},
    );

    final history =
        (data['history'] ?? [])
            as List;

    return {
      'installment':
          data['installment'],

      'history':
          history
              .map(
                (item) =>
                    Map<String, dynamic>.from(
                  item,
                ),
              )
              .toList(),

      'summary':
          data['summary'] ?? {},
    };
  }

  // ============================================================
  // REVERSE PAYMENT
  // ============================================================
  //
  // IMPORTANT:
  // paymentId = emi_payment_transactions.id
  //
  // NOT installmentId.
  // ============================================================

  Future<Map<String, dynamic>>
      reversePayment({
    required int paymentId,
    String? reason,
  }) async {
    final response =
        await apiService.post(
      ApiConstants.emiReversePayment(
        paymentId,
      ),
      data: {
        'reason':
            reason ??
            'Payment reversed by admin',
      },
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    return {
      'message':
          responseData['message'],

      'data':
          responseData['data'],
    };
  }
}