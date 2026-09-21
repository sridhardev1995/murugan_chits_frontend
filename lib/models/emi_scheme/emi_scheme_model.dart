class EmiSchemeModel {
  final int id;
  final String name;
  final String? description;
  final int defaultWeeks;
  final String defaultCommissionType;
  final double defaultCommissionValue;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  EmiSchemeModel({
    required this.id,
    required this.name,
    this.description,
    required this.defaultWeeks,
    required this.defaultCommissionType,
    required this.defaultCommissionValue,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory EmiSchemeModel.fromJson(Map<String, dynamic> json) {
    return EmiSchemeModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      defaultWeeks:
          int.tryParse(json['default_weeks'].toString()) ?? 0,
      defaultCommissionType:
          json['default_commission_type']?.toString() ?? 'percent',
      defaultCommissionValue:
          double.tryParse(
                json['default_commission_value'].toString(),
              ) ??
              0.0,
      status: json['status']?.toString() ?? 'Active',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}