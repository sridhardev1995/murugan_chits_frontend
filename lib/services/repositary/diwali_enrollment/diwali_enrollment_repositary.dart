import 'package:dio/dio.dart';
import 'package:sri_murugan_chits/models/diwali_enrollment/diwali_enrollment_model.dart';
import 'package:sri_murugan_chits/services/api/api_constants.dart';
import 'package:sri_murugan_chits/services/api/api_servies.dart';

class DiwaliEnrollmentRepository {
  final ApiService _api;

  DiwaliEnrollmentRepository(this._api);

  // ============================================================
  // CREATE ENROLLMENT
  // POST /api/diwali-enrollments
  // ============================================================

  Future<Map<String, dynamic>> createEnrollment({
    required int customerId,
    required int schemeId,
    required int chits,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.diwaliEnrollments,
        data: {
          'customerId': customerId,
          'schemeId': schemeId,
          'chits': chits,
        },
      );

      final body = _asMap(response.data);
      final data = _asMap(body['data']);

      return {
        'enrollment': DiwaliEnrollmentModel.fromJson(
          _asMap(data['enrollment']),
        ),
        'weeklyAmount': _toDouble(data['weeklyAmount']),
        'totalPayable': _toDouble(data['totalPayable']),
        'maturityReturn': _toDouble(data['maturityReturn']),
        'message':
            body['message']?.toString() ?? 'Enrolled successfully',
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // GET ENROLLMENTS
  // GET /api/diwali-enrollments
  // ============================================================

  Future<Map<String, dynamic>> getEnrollments({
    int page = 1,
    int limit = 20,
    int? customerId,
    int? schemeId,
    String search = '',
    String status = '',
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliEnrollments,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (customerId != null) 'customerId': customerId,
          if (schemeId != null) 'schemeId': schemeId,
          if (search.trim().isNotEmpty) 'search': search.trim(),
          if (status.trim().isNotEmpty) 'status': status.trim(),
        },
      );

      final body = _asMap(response.data);

      final List<dynamic> list =
          body['data'] is List ? body['data'] as List<dynamic> : [];

      final pagination = body['pagination'] is Map
          ? Map<String, dynamic>.from(body['pagination'] as Map)
          : <String, dynamic>{};

      return {
        'enrollments': list
            .map(
              (e) => DiwaliEnrollmentModel.fromJson(
                _asMap(e),
              ),
            )
            .toList(),
        'pagination': pagination,
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // GET ENROLLMENT DETAIL
  // GET /api/diwali-enrollments/:id
  // ============================================================

  Future<Map<String, dynamic>> getEnrollmentDetail(
    int id,
  ) async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliEnrollmentById(id),
      );

      final body = _asMap(response.data);
      final data = _asMap(body['data']);

      final List<dynamic> weeksJson =
          data['weeks'] is List
              ? data['weeks'] as List<dynamic>
              : [];

      return {
        'enrollment': DiwaliEnrollmentModel.fromJson(
          _asMap(data['enrollment']),
        ),

        'weeks': weeksJson
            .map(
              (w) => DiwaliEnrollmentWeekModel.fromJson(
                _asMap(w),
              ),
            )
            .toList(),

        'summary': EnrollmentSummary.fromJson(
          _asMap(data['summary']),
        ),
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // PAY SINGLE WEEK
  //
  // POST
  // /api/diwali-enrollments/:id/weeks/:weekNumber/pay
  //
  // Backend response:
  // {
  //   success: true,
  //   data: {
  //     paymentGroupId: "...",
  //     week: {...}
  //   }
  // }
  // ============================================================

  Future<Map<String, dynamic>> payWeek({
  required int enrollmentId,
  required int weekNumber,
  required List<Map<String, dynamic>> payments,
  String? paymentDate,
}) async {
  try {
    print(
      '🔵 [payWeek] enrollmentId=$enrollmentId '
      'week=$weekNumber '
      'payments=$payments '
      'date=$paymentDate',
    );

    if (payments.isEmpty) {
      throw Exception('At least one payment is required.');
    }

    final List<Map<String, dynamic>> formattedPayments = [];

    for (final payment in payments) {
      final amount = double.tryParse(
            payment['amount']?.toString() ??
                payment['amountPaid']?.toString() ??
                '0',
          ) ??
          0;

      if (amount <= 0) {
        throw Exception('Payment amount must be greater than zero.');
      }

      final mode =
          payment['mode']?.toString() ??
          payment['paymentMode']?.toString() ??
          'Cash';

      final item = <String, dynamic>{
        'amountPaid': amount,
        'paymentMode': mode,
      };

      if (paymentDate != null &&
          paymentDate.trim().isNotEmpty) {
        item['paymentDate'] = paymentDate;
      } else if (payment['paymentDate'] != null) {
        item['paymentDate'] =
            payment['paymentDate'].toString();
      }

      formattedPayments.add(item);
    }

    final requestBody = <String, dynamic>{
      'payments': formattedPayments,
    };

    print('🟡 [payWeek] REQUEST BODY: $requestBody');

    final response = await _api.post(
      ApiConstants.diwaliWeekPayment(
        enrollmentId,
        weekNumber,
      ),
      data: requestBody,
    );

    print('🟢 [payWeek] RESPONSE: ${response.data}');

    final body = _asMap(response.data);

    if (body['success'] == false) {
      throw Exception(
        body['message']?.toString() ??
            'Payment failed.',
      );
    }

    final data = _asMap(body['data']);

    if (data.isEmpty) {
      throw Exception(
        body['message']?.toString() ??
            'Invalid payment response.',
      );
    }

    final week = DiwaliEnrollmentWeekModel.fromJson(
      _asMap(data['week']),
    );

    return {
      'paymentGroupId':
          data['paymentGroupId']?.toString(),

      'week': week,

      'message':
          body['message']?.toString() ??
              'Payment recorded',
    };
  } on DioException catch (e) {
    final message = _extractError(e);

    print('🔴 [payWeek] DIO ERROR: $message');

    throw Exception(message);
  } catch (e, stackTrace) {
    print('🔴 [payWeek] ERROR: $e');
    print(stackTrace);

    throw Exception(
      e.toString().replaceFirst(
        'Exception: ',
        '',
      ),
    );
  }
}

  // ============================================================
  // BULK PAYMENT
  //
  // POST /api/diwali-enrollments/:id/bulk-pay
  //
  // Backend response:
  // {
  //   paymentGroupId,
  //   totalAmount,
  //   appliedAmount
  // }
  // ============================================================

  Future<Map<String, dynamic>> bulkPay({
    required int enrollmentId,
    required double totalAmount,
    String? paymentMode,
    String? paymentDate,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.diwaliBulkPayment(enrollmentId),
        data: {
          'totalAmount': totalAmount,
          if (paymentMode != null) 'paymentMode': paymentMode,
          if (paymentDate != null) 'paymentDate': paymentDate,
        },
      );

      final body = _asMap(response.data);
      final data = _asMap(body['data']);

      return {
        'paymentGroupId':
            data['paymentGroupId']?.toString(),

        'totalAmount':
            _toDouble(data['totalAmount']),

        'appliedAmount':
            _toDouble(data['appliedAmount']),

        'message':
            body['message']?.toString() ?? 'Payment recorded',
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // PAYMENT HISTORY
  //
  // GET /api/diwali-enrollments/:id/payment-history
  // ============================================================

  Future<List<Map<String, dynamic>>> getPaymentHistory(
    int enrollmentId,
  ) async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliPaymentHistory(enrollmentId),
      );

      final body = _asMap(response.data);

      final List<dynamic> list =
          body['data'] is List
              ? body['data'] as List<dynamic>
              : [];

      return list
          .map(
            (e) => Map<String, dynamic>.from(
              e as Map,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // REVERT SINGLE PAYMENT
  //
  // POST /api/diwali-enrollments/payments/:transactionId/revert
  // ============================================================

  Future<Map<String, dynamic>> revertPayment({
    required int transactionId,
    String? reason,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.diwaliRevertPayment(transactionId),
        data: {
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );

      final body = _asMap(response.data);
      final data = _asMap(body['data']);

      return {
        'transactionId':
            _toInt(data['transactionId']),

        'enrollmentId':
            _toInt(data['enrollmentId']),

        'weekNumber':
            _toInt(data['weekNumber']),

        'reversedAmount':
            _toDouble(data['reversedAmount']),

        'message':
            body['message']?.toString() ?? 'Payment reverted',
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // REVERT PAYMENT GROUP
  //
  // POST
  // /api/diwali-enrollments/payment-groups/:paymentGroupId/revert
  // ============================================================

  Future<Map<String, dynamic>> revertPaymentGroup({
    required String paymentGroupId,
    String? reason,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.diwaliRevertPaymentGroup(
          paymentGroupId,
        ),
        data: {
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );

      final body = _asMap(response.data);
      final data = _asMap(body['data']);

      return {
        'paymentGroupId':
            data['paymentGroupId']?.toString(),

        'transactionCount':
            _toInt(data['transactionCount']),

        'totalReversed':
            _toDouble(data['totalReversed']),

        'message':
            body['message']?.toString() ?? 'Payment group reverted',
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // MODIFY CHITS
  //
  // PATCH /api/diwali-enrollments/:id/modify-chits
  // ============================================================

  Future<Map<String, dynamic>> modifyChits({
    required int enrollmentId,
    required int fromWeekNumber,
    required int newChits,
  }) async {
    try {
      final response = await _api.patch(
        ApiConstants.diwaliModifyChits(enrollmentId),
        data: {
          'fromWeekNumber': fromWeekNumber,
          'newChits': newChits,
        },
      );

      final body = _asMap(response.data);
      final data = _asMap(body['data']);

      final List<dynamic> weeksJson =
          data['weeks'] is List
              ? data['weeks'] as List<dynamic>
              : [];

      final List<dynamic> logsJson =
          data['adjustmentLogs'] is List
              ? data['adjustmentLogs'] as List<dynamic>
              : [];

      return {
        'weeks': weeksJson
            .map(
              (w) => DiwaliEnrollmentWeekModel.fromJson(
                _asMap(w),
              ),
            )
            .toList(),

        'adjustmentLogs': logsJson
            .map(
              (l) => AdjustmentLogModel.fromJson(
                _asMap(l),
              ),
            )
            .toList(),

        'remainingUnappliedExcess':
            _toDouble(data['remainingUnappliedExcess']),

        'message':
            body['message']?.toString() ?? 'Chits updated',
      };
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // ADJUSTMENT LOGS
  //
  // GET /api/diwali-enrollments/:id/adjustment-logs
  // ============================================================

  Future<List<AdjustmentLogModel>> getAdjustmentLogs(
    int enrollmentId,
  ) async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliAdjustmentLogs(enrollmentId),
      );

      final body = _asMap(response.data);

      final List<dynamic> list =
          body['data'] is List
              ? body['data'] as List<dynamic>
              : [];

      return list
          .map(
            (e) => AdjustmentLogModel.fromJson(
              _asMap(e),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  String _extractError(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final errors = data['errors'];

      if (errors != null) {
        return errors.toString();
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please check your connection.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Please check your connection.';
    }

    return 'Something went wrong. Please try again.';
  }
}