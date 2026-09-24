class EmiInstallmentModel {
  final int? id;
  final int? enrollmentId;
  final int? weekNo;
  final String? dueDate;
  final double? amount;
  final double? paidAmount;
  final String? paidDate;
  final String? status;
  final int? isOverdue;

  EmiInstallmentModel({
    this.id,
    this.enrollmentId,
    this.weekNo,
    this.dueDate,
    this.amount,
    this.paidAmount,
    this.paidDate,
    this.status,
    this.isOverdue,
  });

  factory EmiInstallmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    int? toInt(dynamic value) {
      if (value == null) return null;

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

    double? toDouble(dynamic value) {
      if (value == null) return null;

      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(
        value.toString(),
      );
    }

    return EmiInstallmentModel(
      id: toInt(json['id']),

      enrollmentId:
          toInt(json['enrollment_id']),

      weekNo:
          toInt(json['week_no']),

      dueDate:
          json['due_date']?.toString(),

      amount:
          toDouble(json['amount']),

      paidAmount:
          toDouble(json['paid_amount']),

      paidDate:
          json['paid_date']?.toString(),

      status:
          json['status']?.toString(),

      isOverdue:
          toInt(json['is_overdue']),
    );
  }

  // ============================================================
  // BALANCE
  // ============================================================

  double get balance {
    final remaining =
        (amount ?? 0) -
        (paidAmount ?? 0);

    return remaining < 0
        ? 0
        : remaining;
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isPaid =>
      status == 'Paid';

  bool get isPartial =>
      status == 'Partial';

  bool get isPending =>
      status == 'Pending' ||
      status == 'Unpaid';

  bool get overdue =>
      isOverdue == 1;
}