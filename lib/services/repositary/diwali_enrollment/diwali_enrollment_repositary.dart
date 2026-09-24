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
        'weeklyAmount': _toDouble(
          data['weeklyAmount'],
        ),
        'totalPayable': _toDouble(
          data['totalPayable'],
        ),
        'maturityReturn': _toDouble(
          data['maturityReturn'],
        ),
        'message':
            body['message']?.toString() ??
                'Enrolled successfully',
      };
    } on DioException catch (e) {
      throw Exception(
        _extractError(e),
      );
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
          if (customerId != null)
            'customerId': customerId,
          if (schemeId != null)
            'schemeId': schemeId,
          if (search.trim().isNotEmpty)
            'search': search.trim(),
          if (status.trim().isNotEmpty)
            'status': status.trim(),
        },
      );

      final body = _asMap(response.data);

      final List<dynamic> list =
          body['data'] is List
              ? body['data'] as List<dynamic>
              : [];

      final pagination =
          body['pagination'] is Map
              ? Map<String, dynamic>.from(
                  body['pagination'] as Map,
                )
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
      throw Exception(
        _extractError(e),
      );
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
      throw Exception(
        _extractError(e),
      );
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
  //     receiptNumber: "SMC-26-27-000001",
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
        '🔵 [payWeek] '
        'enrollmentId=$enrollmentId '
        'week=$weekNumber '
        'payments=$payments '
        'date=$paymentDate',
      );

      if (payments.isEmpty) {
        throw Exception(
          'At least one payment is required.',
        );
      }

      // ----------------------------------------------------------
      // Format payments
      // ----------------------------------------------------------

      final List<Map<String, dynamic>>
          formattedPayments = [];

      for (final payment in payments) {
        final amount = double.tryParse(
              payment['amount']?.toString() ??
                  payment['amountPaid']?.toString() ??
                  '0',
            ) ??
            0;

        if (amount <= 0) {
          throw Exception(
            'Payment amount must be greater than zero.',
          );
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

      // ----------------------------------------------------------
      // Request body
      // ----------------------------------------------------------

      final requestBody = <String, dynamic>{
        'payments': formattedPayments,
      };

      print(
        '🟡 [payWeek] REQUEST BODY: $requestBody',
      );

      // ----------------------------------------------------------
      // API
      // ----------------------------------------------------------

      final response = await _api.post(
        ApiConstants.diwaliWeekPayment(
          enrollmentId,
          weekNumber,
        ),
        data: requestBody,
      );

      print(
        '🟢 [payWeek] RESPONSE: ${response.data}',
      );

      final body = _asMap(
        response.data,
      );

      if (body['success'] == false) {
        throw Exception(
          body['message']?.toString() ??
              'Payment failed.',
        );
      }

      final data = _asMap(
        body['data'],
      );

      if (data.isEmpty) {
        throw Exception(
          body['message']?.toString() ??
              'Invalid payment response.',
        );
      }

      // ----------------------------------------------------------
      // Parse week
      // ----------------------------------------------------------

      final week =
          DiwaliEnrollmentWeekModel.fromJson(
        _asMap(
          data['week'],
        ),
      );

      // ----------------------------------------------------------
      // Parse receipt number
      // ----------------------------------------------------------

      final receiptNumber =
          data['receiptNumber']?.toString() ??
              data['receipt_number']?.toString();

      // ----------------------------------------------------------
      // Calculate paid amount from request
      // ----------------------------------------------------------

      final paidAmount =
          formattedPayments.fold<double>(
        0,
        (total, payment) =>
            total +
            _toDouble(
              payment['amountPaid'],
            ),
      );

      // ----------------------------------------------------------
      // Return
      // ----------------------------------------------------------

      return {
        'paymentGroupId':
            data['paymentGroupId']?.toString() ??
                data['payment_group_id']
                    ?.toString(),

        'receiptNumber':
            receiptNumber,

        'week': week,

        'paidAmount':
            paidAmount,

        'paymentMode':
            _extractPaymentMode(
              formattedPayments,
            ),

        'remainingBalance':
            _extractRemainingBalance(
              data,
            ),

        'message':
            body['message']?.toString() ??
                'Payment recorded',
      };
    } on DioException catch (e) {
      final message = _extractError(e);

      print(
        '🔴 [payWeek] DIO ERROR: $message',
      );

      throw Exception(message);
    } catch (e, stackTrace) {
      print(
        '🔴 [payWeek] ERROR: $e',
      );

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
  //   receiptNumber,
  //   totalAmount,
  //   appliedAmount,
  //   coveredWeeks: [...]
  // }
  // ============================================================

  Future<Map<String, dynamic>> bulkPay({
    required int enrollmentId,
    required double totalAmount,
    String? paymentMode,
    String? paymentDate,
  }) async {
    try {
      print(
        '🔵 [bulkPay] '
        'enrollmentId=$enrollmentId '
        'totalAmount=$totalAmount '
        'paymentMode=$paymentMode '
        'paymentDate=$paymentDate',
      );

      final response = await _api.post(
        ApiConstants.diwaliBulkPayment(
          enrollmentId,
        ),
        data: {
          'totalAmount': totalAmount,
          if (paymentMode != null)
            'paymentMode': paymentMode,
          if (paymentDate != null)
            'paymentDate': paymentDate,
        },
      );

      print(
        '🟢 [bulkPay] RESPONSE: ${response.data}',
      );

      final body = _asMap(
        response.data,
      );

      final data = _asMap(
        body['data'],
      );

      // ----------------------------------------------------------
      // Receipt number
      // ----------------------------------------------------------

      final receiptNumber =
          data['receiptNumber']?.toString() ??
              data['receipt_number']?.toString();

      // ----------------------------------------------------------
      // Covered weeks
      // ----------------------------------------------------------

      final coveredWeeks =
          _extractCoveredWeeks(
        data,
      );

      // ----------------------------------------------------------
      // Remaining balance
      // ----------------------------------------------------------

      final remainingBalance =
          _extractRemainingBalance(
        data,
      );

      return {
        'paymentGroupId':
            data['paymentGroupId']?.toString() ??
                data['payment_group_id']
                    ?.toString(),

        'receiptNumber':
            receiptNumber,

        'totalAmount':
            _toDouble(
              data['totalAmount'] ??
                  data['total_amount'],
            ),

        'appliedAmount':
            _toDouble(
              data['appliedAmount'] ??
                  data['applied_amount'],
            ),

        'coveredWeeks':
            coveredWeeks,

        'remainingBalance':
            remainingBalance,

        'paymentMode':
            paymentMode,

        'paymentDate':
            paymentDate,

        'message':
            body['message']?.toString() ??
                'Payment recorded',
      };
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
  // PAYMENT HISTORY
  //
  // GET /api/diwali-enrollments/:id/payment-history
  // ============================================================

  Future<List<Map<String, dynamic>>> getPaymentHistory(
    int enrollmentId,
  ) async {
    try {
      final response = await _api.get(
        ApiConstants.diwaliPaymentHistory(
          enrollmentId,
        ),
      );

      final body = _asMap(
        response.data,
      );

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
      throw Exception(
        _extractError(e),
      );
    }
  }

  // ============================================================
  // REVERT SINGLE PAYMENT
  //
  // POST
  // /api/diwali-enrollments/payments/:transactionId/revert
  // ============================================================

  Future<Map<String, dynamic>> revertPayment({
    required int transactionId,
    String? reason,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.diwaliRevertPayment(
          transactionId,
        ),
        data: {
          if (reason != null &&
              reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );

      final body = _asMap(
        response.data,
      );

      final data = _asMap(
        body['data'],
      );

      return {
        'transactionId':
            _toInt(
          data['transactionId'] ??
              data['transaction_id'],
        ),

        'enrollmentId':
            _toInt(
          data['enrollmentId'] ??
              data['enrollment_id'],
        ),

        'weekNumber':
            _toInt(
          data['weekNumber'] ??
              data['week_number'],
        ),

        'reversedAmount':
            _toDouble(
          data['reversedAmount'] ??
              data['reversed_amount'],
        ),

        'receiptNumber':
            data['receiptNumber']?.toString() ??
                data['receipt_number']?.toString(),

        'message':
            body['message']?.toString() ??
                'Payment reverted',
      };
    } on DioException catch (e) {
      throw Exception(
        _extractError(e),
      );
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
          if (reason != null &&
              reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );

      final body = _asMap(
        response.data,
      );

      final data = _asMap(
        body['data'],
      );

      return {
        'paymentGroupId':
            data['paymentGroupId']?.toString() ??
                data['payment_group_id']
                    ?.toString(),

        'transactionCount':
            _toInt(
          data['transactionCount'] ??
              data['transaction_count'],
        ),

        'totalReversed':
            _toDouble(
          data['totalReversed'] ??
              data['total_reversed'],
        ),

        'receiptNumber':
            data['receiptNumber']?.toString() ??
                data['receipt_number']?.toString(),

        'message':
            body['message']?.toString() ??
                'Payment group reverted',
      };
    } on DioException catch (e) {
      throw Exception(
        _extractError(e),
      );
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
        ApiConstants.diwaliModifyChits(
          enrollmentId,
        ),
        data: {
          'fromWeekNumber': fromWeekNumber,
          'newChits': newChits,
        },
      );

      final body = _asMap(
        response.data,
      );

      final data = _asMap(
        body['data'],
      );

      final List<dynamic> weeksJson =
          data['weeks'] is List
              ? data['weeks'] as List<dynamic>
              : [];

      final List<dynamic> logsJson =
          data['adjustmentLogs'] is List
              ? data['adjustmentLogs']
                  as List<dynamic>
              : [];

      return {
        'weeks': weeksJson
            .map(
              (w) =>
                  DiwaliEnrollmentWeekModel
                      .fromJson(
                _asMap(w),
              ),
            )
            .toList(),

        'adjustmentLogs': logsJson
            .map(
              (l) =>
                  AdjustmentLogModel.fromJson(
                _asMap(l),
              ),
            )
            .toList(),

        'remainingUnappliedExcess':
            _toDouble(
          data['remainingUnappliedExcess'] ??
              data['remaining_unapplied_excess'],
        ),

        'message':
            body['message']?.toString() ??
                'Chits updated',
      };
    } on DioException catch (e) {
      throw Exception(
        _extractError(e),
      );
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
        ApiConstants.diwaliAdjustmentLogs(
          enrollmentId,
        ),
      );

      final body = _asMap(
        response.data,
      );

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
      throw Exception(
        _extractError(e),
      );
    }
  }

  // ============================================================
  // EXTRACT PAYMENT MODE
  // ============================================================

  String? _extractPaymentMode(
    List<Map<String, dynamic>> payments,
  ) {
    if (payments.isEmpty) {
      return null;
    }

    final modes = <String>{};

    for (final payment in payments) {
      final mode =
          payment['paymentMode'] ??
              payment['payment_mode'];

      if (mode != null &&
          mode.toString().trim().isNotEmpty) {
        modes.add(
          mode.toString(),
        );
      }
    }

    if (modes.isEmpty) {
      return null;
    }

    if (modes.length == 1) {
      return modes.first;
    }

    return modes.join(' + ');
  }

  // ============================================================
  // EXTRACT REMAINING BALANCE
  // ============================================================

  double _extractRemainingBalance(
    Map<String, dynamic> data,
  ) {
    final value =
        data['remainingBalance'] ??
            data['remaining_balance'] ??
            data['balance'] ??
            data['totalDue'] ??
            data['total_due'];

    return _toDouble(value);
  }

  // ============================================================
  // EXTRACT COVERED WEEKS
  // ============================================================

  List<String> _extractCoveredWeeks(
    Map<String, dynamic> data,
  ) {
    final raw =
        data['coveredWeeks'] ??
            data['covered_weeks'] ??
            data['weeksCovered'] ??
            data['weeks_covered'];

    if (raw is! List) {
      return [];
    }

    return raw.map((item) {
      if (item is Map) {
        final week =
            item['weekNumber'] ??
                item['week_number'] ??
                item['week'];

        if (week != null) {
          return 'Week $week';
        }

        return item.toString();
      }

      final value = item.toString();

      if (value.startsWith('Week')) {
        return value;
      }

      return 'Week $value';
    }).toList();
  }

  // ============================================================
  // HELPERS
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

  double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  int _toInt(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  String _extractError(
    DioException e,
  ) {
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

    if (e.type ==
            DioExceptionType.connectionTimeout ||
        e.type ==
            DioExceptionType.sendTimeout ||
        e.type ==
            DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please check your connection.';
    }

    if (e.type ==
        DioExceptionType.connectionError) {
      return 'Could not reach the server. Please check your connection.';
    }

    return 'Something went wrong. Please try again.';
  }
}