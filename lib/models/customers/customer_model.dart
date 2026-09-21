class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? address;
  final String? aadharNumber;
  final String? panNumber;
  final String? refName;
  final String? refPhone;
  final String? paymentNumber;
  final String? photoUrl;
  final String status;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.aadharNumber,
    this.panNumber,
    this.refName,
    this.refPhone,
    this.paymentNumber,
    this.photoUrl,
    this.status = 'Active',
    this.createdAt,
  });

  // Backend SELECT returns snake_case columns (see customerModel.findAll)
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      aadharNumber: json['aadhar_number']?.toString(),
      panNumber: json['pan_number']?.toString(),
      refName: json['ref_name']?.toString(),
      refPhone: json['ref_phone']?.toString(),
      paymentNumber: json['payment_number']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  // Create/update endpoints expect camelCase body keys
  // (see validateCustomerInput / create / update controllers)
  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'refName': refName,
      'refPhone': refPhone,
      'paymentNumber': paymentNumber,
      'photoUrl': photoUrl,
    };
  }

  CustomerModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? aadharNumber,
    String? panNumber,
    String? refName,
    String? refPhone,
    String? paymentNumber,
    String? photoUrl,
    String? status,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      refName: refName ?? this.refName,
      refPhone: refPhone ?? this.refPhone,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}