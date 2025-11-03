class CouponModel {
  final String id;
  final String brand;
  final String title;
  final String link;
  final String image;
  final String code;
  final double actualPricing;
  final String category;
  final String description;
  final String? createdBy; // Changed to String? to match API
  final String? userId;
  final int clickCount;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isLived;
  final DateTime createdAt;
  final int? v;
  final String? status; // Made optional to match API

  CouponModel({
    required this.id,
    required this.brand,
    required this.title,
    required this.link,
    required this.image,
    required this.code,
    required this.actualPricing,
    required this.category,
    required this.description,
    this.createdBy, // String instead of CreatedBy object
    this.userId,
    required this.clickCount,
    required this.startDate,
    required this.expiryDate,
    required this.isLived,
    required this.createdAt,
    this.v,
    this.status, // Optional
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'];
    final createdAtStr = json['createdAt'] ?? '';
    final startDateStr = json['startDate'] ?? '';
    final expiryDateStr = json['expiryDate'] ?? '';

  

    return CouponModel(
      id: id ?? '',
      brand: json['brand'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      image: json['image'] ?? '',
      code: json['code'] ?? '',
      actualPricing: (json['actualPricing'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['createdBy'] is String ? json['createdBy'] : null, // Handle string ID
      userId: json['userId'] ?? '',
      clickCount: json['clickCount'] ?? 0,
      startDate: _parseDate(startDateStr),
      expiryDate: _parseDate(expiryDateStr),
      isLived: json['isLived'] ?? false,
      createdAt: _parseDate(createdAtStr),
      v: json['__v'],
      status: json['status'] ?? 'unknown', // Default value
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDate(String dateStr) {
    try {
      return dateStr.isNotEmpty ? DateTime.parse(dateStr) : DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "brand": brand,
      "title": title,
      "link": link,
      "image": image,
      "code": code,
      "actualPricing": actualPricing,
      "category": category,
      "description": description,
      "createdBy": createdBy,
      "userId": userId,
      "clickCount": clickCount,
      "startDate": startDate.toIso8601String(),
      "expiryDate": expiryDate.toIso8601String(),
      "isLived": isLived,
      "createdAt": createdAt.toIso8601String(),
      "__v": v,
      "status": status,
    };
  }

  CouponModel copyWith({
    String? id,
    String? brand,
    String? title,
    String? link,
    String? image,
    String? code,
    double? actualPricing,
    String? category,
    String? description,
    String? createdBy,
    String? userId,
    int? clickCount,
    DateTime? startDate,
    DateTime? expiryDate,
    bool? isLived,
    DateTime? createdAt,
    int? v,
    String? status,
  }) {
    return CouponModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      title: title ?? this.title,
      link: link ?? this.link,
      image: image ?? this.image,
      code: code ?? this.code,
      actualPricing: actualPricing ?? this.actualPricing,
      category: category ?? this.category,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      userId: userId ?? this.userId,
      clickCount: clickCount ?? this.clickCount,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isLived: isLived ?? this.isLived,
      createdAt: createdAt ?? this.createdAt,
      v: v ?? this.v,
      status: status ?? this.status,
    );
  }

  static List<CouponModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final json = entry.value;
          try {
            if (json == null) {
              return null;
            }
            return CouponModel.fromJson(json);
          } catch (e) {
            return null;
          }
        })
        .whereType<CouponModel>()
        .toList();
  }

  @override
  String toString() {
    return 'CouponModel(id: $id, brand: $brand, title: $title, code: $code, status: $status)';
  }
}