class DashboardModel {
  final CustomerDashboardModel customers;
  final DiwaliDashboardModel diwali;
  final EmiDashboardModel emi;
  final TodayDashboardModel today;
  final DueDashboardModel due;

  DashboardModel({
    required this.customers,
    required this.diwali,
    required this.emi,
    required this.today,
    required this.due,
  });

  factory DashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardModel(
      customers: CustomerDashboardModel.fromJson(
        json['customers'] ?? {},
      ),
      diwali: DiwaliDashboardModel.fromJson(
        json['diwali'] ?? {},
      ),
      emi: EmiDashboardModel.fromJson(
        json['emi'] ?? {},
      ),
      today: TodayDashboardModel.fromJson(
        json['today'] ?? {},
      ),
      due: DueDashboardModel.fromJson(
        json['due'] ?? {},
      ),
    );
  }
}

// ============================================================
// CUSTOMERS
// ============================================================

class CustomerDashboardModel {
  final int total;

  CustomerDashboardModel({
    required this.total,
  });

  factory CustomerDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerDashboardModel(
      total: _toInt(json['total']),
    );
  }
}

// ============================================================
// DIWALI
// ============================================================

class DiwaliDashboardModel {
  final int totalChits;
  final double totalAmount;
  final double receivedAmount;
  final double pendingAmount;

  DiwaliDashboardModel({
    required this.totalChits,
    required this.totalAmount,
    required this.receivedAmount,
    required this.pendingAmount,
  });

  factory DiwaliDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiwaliDashboardModel(
      totalChits: _toInt(
        json['total_chits'],
      ),
      totalAmount: _toDouble(
        json['total_amount'],
      ),
      receivedAmount: _toDouble(
        json['received_amount'],
      ),
      pendingAmount: _toDouble(
        json['pending_amount'],
      ),
    );
  }
}

// ============================================================
// EMI
// ============================================================

class EmiDashboardModel {
  final double totalAmount;
  final double collectedAmount;
  final double pendingCollection;

  EmiDashboardModel({
    required this.totalAmount,
    required this.collectedAmount,
    required this.pendingCollection,
  });

  factory EmiDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmiDashboardModel(
      totalAmount: _toDouble(
        json['total_amount'],
      ),
      collectedAmount: _toDouble(
        json['collected_amount'],
      ),
      pendingCollection: _toDouble(
        json['pending_collection'],
      ),
    );
  }
}

// ============================================================
// TODAY
// ============================================================

class TodayDashboardModel {
  final double diwaliCollection;
  final double emiCollection;
  final double totalCollection;

  TodayDashboardModel({
    required this.diwaliCollection,
    required this.emiCollection,
    required this.totalCollection,
  });

  factory TodayDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TodayDashboardModel(
      diwaliCollection: _toDouble(
        json['diwali_collection'],
      ),
      emiCollection: _toDouble(
        json['emi_collection'],
      ),
      totalCollection: _toDouble(
        json['total_collection'],
      ),
    );
  }
}

// ============================================================
// DUE
// ============================================================

class DueDashboardModel {
  final double todayDue;
  final double overdueAmount;
  final int pendingCustomers;

  DueDashboardModel({
    required this.todayDue,
    required this.overdueAmount,
    required this.pendingCustomers,
  });

  factory DueDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DueDashboardModel(
      todayDue: _toDouble(
        json['today_due'],
      ),
      overdueAmount: _toDouble(
        json['overdue_amount'],
      ),
      pendingCustomers: _toInt(
        json['pending_customers'],
      ),
    );
  }
}

// ============================================================
// SAFE PARSING HELPERS
// ============================================================

double _toDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value.toString(),
      ) ??
      0.0;
}

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