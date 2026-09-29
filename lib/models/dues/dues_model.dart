class DuesModel {
  final int? id;
  final int? enrollmentId;

  final int? customerId;
  final String customerName;
  final String customerPhone;

  final String type; // Diwali / EMI
  final String? schemeName;

  final int? weekNo;
  final String? dueDate;

  final double amount;
  final double paidAmount;
  final double balanceAmount;

  final String status;

  final bool isOverdue;
  final int overdueDays;

  DuesModel({
    this.id,
    this.enrollmentId,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.type,
    this.schemeName,
    this.weekNo,
    this.dueDate,
    required this.amount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.status,
    required this.isOverdue,
    required this.overdueDays,
  });

  factory DuesModel.fromDiwali(
    Map<String, dynamic> json, {
    required bool overdue,
  }) {
    final amount = _toDouble(json['amount_due']);
    final paid = _toDouble(json['amount_paid']);

    return DuesModel(
      id: _toInt(json['id']),
      enrollmentId: _toInt(json['enrollment_id']),
      customerId: _toInt(json['customer_id']),
      customerName:
          json['customer_name']?.toString() ?? '',
      customerPhone:
          json['customer_phone']?.toString() ?? '',
      type: 'Diwali',
      schemeName: 'Diwali Chit',
      weekNo: _toInt(json['week_number']),
      dueDate: json['due_date']?.toString(),
      amount: amount,
      paidAmount: paid,
      balanceAmount:
          (amount - paid) < 0 ? 0 : amount - paid,
      status:
          json['status']?.toString() ?? 'Pending',
      isOverdue: overdue,
      overdueDays: overdue
          ? _calculateOverdueDays(
              json['due_date'],
            )
          : 0,
    );
  }

  factory DuesModel.fromEmi(
    Map<String, dynamic> json, {
    required bool overdue,
  }) {
    final amount = _toDouble(json['amount']);
    final paid = _toDouble(json['paid_amount']);

    return DuesModel(
      id: _toInt(json['id']),
      enrollmentId: _toInt(json['enrollment_id']),
      customerId: _toInt(json['customer_id']),
      customerName:
          json['customer_name']?.toString() ?? '',
      customerPhone:
          json['customer_phone']?.toString() ?? '',
      type: 'EMI',
      schemeName:
          json['scheme_name']?.toString(),
      weekNo: _toInt(json['week_no']),
      dueDate: json['due_date']?.toString(),
      amount: amount,
      paidAmount: paid,
      balanceAmount:
          (amount - paid) < 0 ? 0 : amount - paid,
      status:
          json['status']?.toString() ?? 'Pending',
      isOverdue: overdue,
      overdueDays:
          _toInt(json['overdue_days']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(
      value.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static int _calculateOverdueDays(
    dynamic dueDate,
  ) {
    if (dueDate == null) return 0;

    try {
      final date =
          DateTime.parse(
        dueDate.toString(),
      );

      final today = DateTime.now();

      final todayDate = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final dueDateOnly = DateTime(
        date.year,
        date.month,
        date.day,
      );

      final days =
          todayDate.difference(
        dueDateOnly,
      ).inDays;

      return days > 0 ? days : 0;
    } catch (_) {
      return 0;
    }
  }
}