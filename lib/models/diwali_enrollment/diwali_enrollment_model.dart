class DiwaliEnrollmentModel {
  final int id;
  final int customerId;
  final String customerName;
  final String customerPhone;

  final int schemeId;
  final String schemeName;

  final double chitValue;
  final double bonusPerChit;
  final int durationWeeks;

  final String startDate;

  final int originalChits;
  final int currentChits;

  final String status;
  final String? schemeStatus;

  const DiwaliEnrollmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.schemeId,
    required this.schemeName,
    required this.chitValue,
    required this.bonusPerChit,
    required this.durationWeeks,
    required this.startDate,
    required this.originalChits,
    required this.currentChits,
    required this.status,
    this.schemeStatus,
  });

  factory DiwaliEnrollmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiwaliEnrollmentModel(
      id: _toInt(json['id']),
      customerId: _toInt(json['customer_id']),
      customerName:
          json['customer_name']?.toString() ?? '',
      customerPhone:
          json['customer_phone']?.toString() ?? '',
      schemeId: _toInt(json['scheme_id']),
      schemeName:
          json['scheme_name']?.toString() ?? '',
      chitValue: _toDouble(
        json['chit_value'],
      ),
      bonusPerChit: _toDouble(
        json['bonus_per_chit'],
      ),
      durationWeeks: _toInt(
        json['duration_weeks'],
      ),
      startDate: _dateOnly(
        json['start_date'],
      ),
      originalChits: _toInt(
        json['original_chits'],
      ),
      currentChits: _toInt(
        json['current_chits'],
      ),
      status:
          json['status']?.toString() ?? 'Active',
      schemeStatus:
          json['scheme_status']?.toString(),
    );
  }
}

// ============================================================
// DIWALI ENROLLMENT WEEK
// ============================================================

class DiwaliEnrollmentWeekModel {
  final int id;
  final int enrollmentId;
  final int weekNumber;

  final String dueDate;

  final int chits;

  final double amountDue;
  final double amountPaid;

  final String? paymentDate;
  final String? paymentMode;

  final String status;

  const DiwaliEnrollmentWeekModel({
    required this.id,
    required this.enrollmentId,
    required this.weekNumber,
    required this.dueDate,
    required this.chits,
    required this.amountDue,
    required this.amountPaid,
    this.paymentDate,
    this.paymentMode,
    required this.status,
  });

  factory DiwaliEnrollmentWeekModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiwaliEnrollmentWeekModel(
      id: _toInt(json['id']),
      enrollmentId:
          _toInt(json['enrollment_id']),
      weekNumber:
          _toInt(json['week_number']),
      dueDate:
          _dateOnly(json['due_date']),
      chits:
          _toInt(json['chits']),
      amountDue:
          _toDouble(json['amount_due']),
      amountPaid:
          _toDouble(json['amount_paid']),
      paymentDate:
          _nullableDate(json['payment_date']),
      paymentMode:
          _nullableString(json['payment_mode']),
      status:
          json['status']?.toString() ?? 'Unpaid',
    );
  }

  double get outstanding {
    final value =
        amountDue - amountPaid;

    return value < 0 ? 0 : value;
  }

  bool get isPaid =>
      status.toLowerCase() == 'paid';

  bool get isPartial =>
      status.toLowerCase() == 'partial';

  bool get isUnpaid =>
      status.toLowerCase() == 'unpaid';
}

// ============================================================
// ENROLLMENT SUMMARY
// ============================================================

class EnrollmentSummary {
  final double totalPaid;
  final double totalDue;
  final double balance;

  final int balanceWeeks;

  final double maturityReturn;

  const EnrollmentSummary({
    required this.totalPaid,
    required this.totalDue,
    required this.balanceWeeks,
    required this.balance,
    required this.maturityReturn,
  });

  factory EnrollmentSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return EnrollmentSummary(
      totalPaid:
          _toDouble(json['totalPaid']),
      totalDue:
          _toDouble(json['totalDue']),
      balance:
          _toDouble(json['balance']),
      balanceWeeks:
          _toInt(json['balanceWeeks']),
      maturityReturn:
          _toDouble(json['maturityReturn']),
    );
  }

  double get paidPercentage {
    if (totalDue <= 0) {
      return 0;
    }

    final percentage =
        totalPaid / totalDue;

    if (percentage < 0) {
      return 0;
    }

    if (percentage > 1) {
      return 1;
    }

    return percentage;
  }
}

// ============================================================
// ADJUSTMENT LOG
// ============================================================

class AdjustmentLogModel {
  final int id;

  final String sourceWeeks;

  final double sourceExcessTotal;

  final int targetWeek;

  final double appliedAmount;

  final String note;

  const AdjustmentLogModel({
    required this.id,
    required this.sourceWeeks,
    required this.sourceExcessTotal,
    required this.targetWeek,
    required this.appliedAmount,
    required this.note,
  });

  factory AdjustmentLogModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdjustmentLogModel(
      id: _toInt(json['id']),
      sourceWeeks:
          json['source_weeks']
                  ?.toString() ??
              '',
      sourceExcessTotal:
          _toDouble(
        json['source_excess_total'],
      ),
      targetWeek:
          _toInt(json['target_week']),
      appliedAmount:
          _toDouble(
        json['applied_amount'],
      ),
      note:
          json['note']?.toString() ?? '',
    );
  }
}

// ============================================================
// PAYMENT TRANSACTION
// ============================================================

class DiwaliPaymentTransactionModel {
  final int id;

  final int enrollmentId;
  final int weekNumber;

  final double amount;

  final String paymentMode;
  final String paymentDate;

  final String? paymentGroupId;

  final String status;

  final String? reversedAt;
  final int? reversedBy;

  final String? reversalReason;
  final String? createdAt;

  final String? reversedByUsername;

  const DiwaliPaymentTransactionModel({
    required this.id,
    required this.enrollmentId,
    required this.weekNumber,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    this.paymentGroupId,
    required this.status,
    this.reversedAt,
    this.reversedBy,
    this.reversalReason,
    this.createdAt,
    this.reversedByUsername,
  });

  factory DiwaliPaymentTransactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiwaliPaymentTransactionModel(
      id:
          _toInt(json['id']),

      enrollmentId:
          _toInt(json['enrollment_id']),

      weekNumber:
          _toInt(json['week_number']),

      amount:
          _toDouble(json['amount']),

      paymentMode:
          json['payment_mode']?.toString() ??
              'Other',

      paymentDate:
          _dateOnly(json['payment_date']),

      paymentGroupId:
          _nullableString(
        json['payment_group_id'],
      ),

      status:
          json['status']?.toString() ??
              'Active',

      reversedAt:
          _nullableDateTime(
        json['reversed_at'],
      ),

      reversedBy:
          _nullableInt(
        json['reversed_by'],
      ),

      reversalReason:
          _nullableString(
        json['reversal_reason'],
      ),

      createdAt:
          _nullableDateTime(
        json['created_at'],
      ),

      reversedByUsername:
          _nullableString(
        json['reversed_by_username'],
      ),
    );
  }

  bool get isActive =>
      status.toLowerCase() ==
      'active';

  bool get isReversed =>
      status.toLowerCase() ==
      'reversed';
}

// ============================================================
// PAYMENT RESULT
// ============================================================

class DiwaliPaymentResult {
  final String? paymentGroupId;

  final DiwaliEnrollmentWeekModel week;

  const DiwaliPaymentResult({
    this.paymentGroupId,
    required this.week,
  });
}

// ============================================================
// BULK PAYMENT RESULT
// ============================================================

class DiwaliBulkPaymentResult {
  final String? paymentGroupId;

  final double totalAmount;
  final double appliedAmount;

  const DiwaliBulkPaymentResult({
    this.paymentGroupId,
    required this.totalAmount,
    required this.appliedAmount,
  });

  double get unappliedAmount {
    final value =
        totalAmount - appliedAmount;

    return value < 0 ? 0 : value;
  }
}

// ============================================================
// SINGLE REVERT RESULT
// ============================================================

class DiwaliPaymentRevertResult {
  final int transactionId;
  final int enrollmentId;
  final int weekNumber;
  final double reversedAmount;

  const DiwaliPaymentRevertResult({
    required this.transactionId,
    required this.enrollmentId,
    required this.weekNumber,
    required this.reversedAmount,
  });
}

// ============================================================
// BULK REVERT RESULT
// ============================================================

class DiwaliPaymentGroupRevertResult {
  final String? paymentGroupId;

  final int transactionCount;

  final double totalReversed;

  const DiwaliPaymentGroupRevertResult({
    this.paymentGroupId,
    required this.transactionCount,
    required this.totalReversed,
  });
}

// ============================================================
// HELPERS
// ============================================================

int _toInt(dynamic value) {
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

int? _nullableInt(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
    value.toString(),
  );
}

double _toDouble(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value.toString(),
      ) ??
      0;
}

String? _nullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  final valueString =
      value.toString().trim();

  if (valueString.isEmpty ||
      valueString.toLowerCase() ==
          'null') {
    return null;
  }

  return valueString;
}

String _dateOnly(dynamic value) {
  if (value == null) {
    return '';
  }

  final text =
      value.toString().trim();

  if (text.isEmpty ||
      text.toLowerCase() == 'null') {
    return '';
  }

  return text.split('T').first
      .split(' ')
      .first;
}

String? _nullableDate(dynamic value) {
  final result = _dateOnly(value);

  return result.isEmpty
      ? null
      : result;
}

String? _nullableDateTime(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  final text =
      value.toString().trim();

  if (text.isEmpty ||
      text.toLowerCase() == 'null') {
    return null;
  }

  return text;
}