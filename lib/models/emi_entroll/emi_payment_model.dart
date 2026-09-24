class EmiPaymentModel {
  final int? id;
  final int? enrollmentId;
  final int? installmentId;
  final double? amount;
  final String? paymentMode;
  final String? paymentDate;

  // Receipt number
  final String? receiptNumber;

  final String? status;
  final String? reversedAt;
  final int? reversedBy;
  final String? reversedByUsername;
  final String? reversalReason;
  final String? createdAt;

  EmiPaymentModel({
    this.id,
    this.enrollmentId,
    this.installmentId,
    this.amount,
    this.paymentMode,
    this.paymentDate,

    // Receipt number
    this.receiptNumber,

    this.status,
    this.reversedAt,
    this.reversedBy,
    this.reversedByUsername,
    this.reversalReason,
    this.createdAt,
  });

  factory EmiPaymentModel.fromJson(
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

    return EmiPaymentModel(
      id: toInt(json['id']),

      enrollmentId:
          toInt(json['enrollment_id']),

      installmentId:
          toInt(json['installment_id']),

      amount:
          toDouble(json['amount']),

      paymentMode:
          json['payment_mode']?.toString(),

      paymentDate:
          json['payment_date']?.toString(),

      // Receipt number
      receiptNumber:
          json['receipt_number']?.toString(),

      status:
          json['status']?.toString(),

      reversedAt:
          json['reversed_at']?.toString(),

      reversedBy:
          toInt(json['reversed_by']),

      reversedByUsername:
          json['reversed_by_username']
              ?.toString(),

      reversalReason:
          json['reversal_reason']
              ?.toString(),

      createdAt:
          json['created_at']?.toString(),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get isActive =>
      status == 'Active';

  bool get isReversed =>
      status == 'Reversed';

  bool get isCash =>
      paymentMode == 'Cash';

  bool get isUpi =>
      paymentMode == 'UPI';
}