class DiwaliCollectionModel {
  final int id;
  final int enrollmentId;
  final int customerId;

  final String customerName;
  final String customerPhone;

  final int weekNumber;
  final String dueDate;

  final int chits;

  final double amountDue;
  final double amountPaid;

  final String status;

  final String? paymentDate;
  final String? paymentMode;

  DiwaliCollectionModel({
    required this.id,
    required this.enrollmentId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.weekNumber,
    required this.dueDate,
    required this.chits,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    this.paymentDate,
    this.paymentMode,
  });

  factory DiwaliCollectionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiwaliCollectionModel(
      id: _toInt(json['id']),
      enrollmentId: _toInt(
        json['enrollment_id'],
      ),
      customerId: _toInt(
        json['customer_id'],
      ),

      customerName:
          json['customer_name']?.toString() ?? '-',

      customerPhone:
          json['customer_phone']?.toString() ?? '-',

      weekNumber:
          _toInt(json['week_number']),

      dueDate:
          json['due_date']?.toString() ?? '',

      chits:
          _toInt(json['chits']),

      amountDue:
          _toDouble(json['amount_due']),

      amountPaid:
          _toDouble(json['amount_paid']),

      status:
          json['status']?.toString() ?? 'Unpaid',

      paymentDate:
          json['payment_date']?.toString(),

      paymentMode:
          json['payment_mode']?.toString(),
    );
  }

  double get balanceDue {
    final balance =
        amountDue - amountPaid;

    return balance < 0 ? 0 : balance;
  }

  bool get isPaid {
    return balanceDue <= 0;
  }

  bool get isPartial {
    return amountPaid > 0 &&
        balanceDue > 0;
  }
}

// ============================================================
// PARSING
// ============================================================

int _toInt(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value.toString(),
      ) ??
      0;
}

double _toDouble(dynamic value) {
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