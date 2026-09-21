class DiwaliSchemeModel {
  final int id;
  final String schemeName;
  final double chitValue;
  final int durationWeeks;
  final double bonusPerChit;
  final String startDate; // stored as 'YYYY-MM-DD'
  final String status; // 'Active' | 'Closed'

  DiwaliSchemeModel({
    required this.id,
    required this.schemeName,
    required this.chitValue,
    required this.durationWeeks,
    required this.bonusPerChit,
    required this.startDate,
    required this.status,
  });

  factory DiwaliSchemeModel.fromJson(Map<String, dynamic> json) {
    return DiwaliSchemeModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      schemeName: json['scheme_name']?.toString() ?? '',
      chitValue: double.tryParse(json['chit_value']?.toString() ?? '0') ?? 0,
      durationWeeks:
          int.tryParse(json['duration_weeks']?.toString() ?? '52') ?? 52,
      bonusPerChit:
          double.tryParse(json['bonus_per_chit']?.toString() ?? '0') ?? 0,
      startDate: json['start_date']?.toString().split('T').first ?? '',
      status: json['status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemeName': schemeName,
      'chitValue': chitValue,
      'durationWeeks': durationWeeks,
      'bonusPerChit': bonusPerChit,
      'startDate': startDate,
    };
  }

  DiwaliSchemeModel copyWith({
    int? id,
    String? schemeName,
    double? chitValue,
    int? durationWeeks,
    double? bonusPerChit,
    String? startDate,
    String? status,
  }) {
    return DiwaliSchemeModel(
      id: id ?? this.id,
      schemeName: schemeName ?? this.schemeName,
      chitValue: chitValue ?? this.chitValue,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      bonusPerChit: bonusPerChit ?? this.bonusPerChit,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
    );
  }
}