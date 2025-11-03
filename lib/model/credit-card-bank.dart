class CreditCardBank {
  final String id;
  final String name;
  final String logo;
  final String bankId;

  CreditCardBank({
    required this.id,
    required this.name,
    required this.logo,
    required this.bankId,
  });

  factory CreditCardBank.fromJson(Map<String, dynamic> json) {
    return CreditCardBank(
      id: json["bankId"] ?? "",
      name: json["name"] ?? "",
      logo: json["logo"] ?? "",
      bankId: json["bankId"] ?? "",
    );
  }

  static List<CreditCardBank> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CreditCardBank.fromJson(json)).toList();
  }
}
