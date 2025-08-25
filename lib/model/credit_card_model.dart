import 'package:get/get.dart';

class CardDueModel {
  String id;
  String userId;
  String category;
  double amount;
  String date;
  String cardNumber;
  String transactionId;
  String totalDue;
  String mode;
  String type;
  String bank;
  DateTime createdAt;
  DateTime updatedAt;

  CardDueModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.date,
    required this.cardNumber,
    required this.transactionId,
    required this.totalDue,
    required this.mode,
    required this.type,
    required this.bank,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardDueModel.fromJson(Map<String, dynamic> json) {
    return CardDueModel(
      id: json["_id"]["\$oid"],
      userId: json["userId"]["\$oid"],
      category: json["category"],
      amount: double.tryParse(json["amount"].toString()) ?? 0.0,
      date: json["date"],
      cardNumber: json["card_number"],
      transactionId: json["transaction_id"],
      totalDue: json["total_due"] ?? "",
      mode: json["mode"],
      type: json["type"] ?? "",
      bank: json["bank"],
      createdAt: DateTime.parse(json["createdAt"]["\$date"]),
      updatedAt: DateTime.parse(json["updatedAt"]["\$date"]),
    );
  }
}
