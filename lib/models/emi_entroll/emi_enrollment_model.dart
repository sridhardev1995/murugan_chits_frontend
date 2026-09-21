class EnrollmentModel {
  final int? id;
  final int? customerId;
  final int? schemeId;

  final String? customerName;
  final String? customerPhone;
  final String? schemeName;

  final double? requestedAmount;
  final String? commissionType;
  final double? commissionValue;
  final double? commissionAmount;
  final double? disbursedAmount;

  final int? weeks;

  final String? startDate;
  final String? status;

  EnrollmentModel({
    this.id,
    this.customerId,
    this.schemeId,
    this.customerName,
    this.customerPhone,
    this.schemeName,
    this.requestedAmount,
    this.commissionType,
    this.commissionValue,
    this.commissionAmount,
    this.disbursedAmount,
    this.weeks,
    this.startDate,
    this.status,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    // ------------------------------------------------------------
    // Safe Integer Conversion
    // Handles:
    //   10
    //   10.0
    //   "10"
    //   "10.0"
    //   null
    // ------------------------------------------------------------
    int? toInt(dynamic value) {
      if (value == null) return null;

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(value.toString());
    }

    // ------------------------------------------------------------
    // Safe Double Conversion
    // Handles:
    //   10000
    //   10000.0
    //   "10000"
    //   "10000.00"
    //   null
    // ------------------------------------------------------------
    double? toDouble(dynamic value) {
      if (value == null) return null;

      if (value is double) {
        return value;
      }

      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(value.toString());
    }

    // ------------------------------------------------------------
    // Safe String Conversion
    // ------------------------------------------------------------
    String? toStringValue(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    return EnrollmentModel(
      id: toInt(json['id']),

      customerId: toInt(json['customer_id']),

      schemeId: toInt(json['scheme_id']),

      customerName: toStringValue(
        json['customer_name'],
      ),

      customerPhone: toStringValue(
        json['customer_phone'],
      ),

      schemeName: toStringValue(
        json['scheme_name'],
      ),

      requestedAmount: toDouble(
        json['requested_amount'],
      ),

      commissionType: toStringValue(
        json['commission_type'],
      ),

      commissionValue: toDouble(
        json['commission_value'],
      ),

      commissionAmount: toDouble(
        json['commission_amount'],
      ),

      disbursedAmount: toDouble(
        json['disbursed_amount'],
      ),

      weeks: toInt(
        json['weeks'],
      ),

      startDate: toStringValue(
        json['start_date'],
      ),

      status: toStringValue(
        json['status'],
      ),
    );
  }

  // ------------------------------------------------------------
  // Optional: Convert model back to JSON
  // Useful for debugging / editing / API requests later
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'scheme_id': schemeId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'scheme_name': schemeName,
      'requested_amount': requestedAmount,
      'commission_type': commissionType,
      'commission_value': commissionValue,
      'commission_amount': commissionAmount,
      'disbursed_amount': disbursedAmount,
      'weeks': weeks,
      'start_date': startDate,
      'status': status,
    };
  }
}