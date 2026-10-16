class EmiProfitReportSummary {
  final int enrollmentCount;
  final double totalRequestedAmount;
  final double totalCommission;
  final double totalDisbursed;
  final double totalEmiPayable;
  final double totalCollected;
  final double totalPending;

  const EmiProfitReportSummary({
    this.enrollmentCount = 0,
    this.totalRequestedAmount = 0,
    this.totalCommission = 0,
    this.totalDisbursed = 0,
    this.totalEmiPayable = 0,
    this.totalCollected = 0,
    this.totalPending = 0,
  });

  factory EmiProfitReportSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmiProfitReportSummary(
      enrollmentCount: _toInt(json['enrollmentCount']),
      totalRequestedAmount: _toDouble(
        json['totalRequestedAmount'],
      ),
      totalCommission: _toDouble(json['totalCommission']),
      totalDisbursed: _toDouble(json['totalDisbursed']),
      totalEmiPayable: _toDouble(json['totalEmiPayable']),
      totalCollected: _toDouble(json['totalCollected']),
      totalPending: _toDouble(json['totalPending']),
    );
  }
}

class EmiProfitReportItem {
  final int enrollmentId;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final int schemeId;
  final String schemeName;
  final double requestedAmount;
  final String commissionType;
  final double commissionValue;
  final double commissionAmount;
  final double disbursedAmount;
  final int weeks;
  final String startDate;
  final String status;
  final double totalEmiPayable;
  final double totalCollected;
  final double pendingCollection;
  final double expectedCommission;

  const EmiProfitReportItem({
    required this.enrollmentId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.schemeId,
    required this.schemeName,
    required this.requestedAmount,
    required this.commissionType,
    required this.commissionValue,
    required this.commissionAmount,
    required this.disbursedAmount,
    required this.weeks,
    required this.startDate,
    required this.status,
    required this.totalEmiPayable,
    required this.totalCollected,
    required this.pendingCollection,
    required this.expectedCommission,
  });

  factory EmiProfitReportItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmiProfitReportItem(
      enrollmentId: _toInt(json['enrollmentId']),
      customerId: _toInt(json['customerId']),
      customerName: _toString(json['customerName'], 'Unknown'),
      customerPhone: _toString(json['customerPhone'], ''),
      schemeId: _toInt(json['schemeId']),
      schemeName: _toString(json['schemeName'], '-'),
      requestedAmount: _toDouble(json['requestedAmount']),
      commissionType: _toString(json['commissionType'], 'fixed'),
      commissionValue: _toDouble(json['commissionValue']),
      commissionAmount: _toDouble(json['commissionAmount']),
      disbursedAmount: _toDouble(json['disbursedAmount']),
      weeks: _toInt(json['weeks']),
      startDate: _toString(json['startDate'], ''),
      status: _toString(json['status'], 'Active'),
      totalEmiPayable: _toDouble(json['totalEmiPayable']),
      totalCollected: _toDouble(json['totalCollected']),
      pendingCollection: _toDouble(json['pendingCollection']),
      expectedCommission: _toDouble(json['expectedCommission']),
    );
  }

  String get commissionDescription {
    if (commissionType.toLowerCase() == 'percent') {
      return '${commissionValue.toStringAsFixed(2)}%';
    }

    return '₹${commissionValue.toStringAsFixed(2)} fixed';
  }
}

class EmiProfitReport {
  final EmiProfitReportSummary summary;
  final List<EmiProfitReportItem> items;

  const EmiProfitReport({
    required this.summary,
    required this.items,
  });

  factory EmiProfitReport.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawSummary = json['summary'];
    final rawData = json['data'];

    final summaryMap = rawSummary is Map
        ? Map<String, dynamic>.from(rawSummary)
        : <String, dynamic>{};

    final itemList = rawData is List
        ? rawData
            .whereType<Map>()
            .map(
              (item) => EmiProfitReportItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <EmiProfitReportItem>[];

    return EmiProfitReport(
      summary: EmiProfitReportSummary.fromJson(summaryMap),
      items: itemList,
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;

  if (value is num) return value.toDouble();

  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;

  if (value is num) return value.toInt();

  return int.tryParse(value.toString()) ?? 0;
}

String _toString(dynamic value, [String fallback = '-']) {
  if (value == null) return fallback;

  final result = value.toString().trim();

  return result.isEmpty ? fallback : result;
}