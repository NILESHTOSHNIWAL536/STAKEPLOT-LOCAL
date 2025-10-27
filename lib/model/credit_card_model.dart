import 'package:get/get.dart';

class CardDueModel {
  String id;
  String userId;
  String category;
  String amount;
  String date;
  String cardNumber;
  String transactionId;
  String totalDue;
  String mode;
  String type;
  String bank;
  String matched_bank;
  String bankName;
  String logo;
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
    required this.logo,
     this.bank="",
     this.matched_bank="",
    required this.bankName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardDueModel.fromJson(Map<String, dynamic> json) {
    return CardDueModel(
      id: json["_id"]??"",
      userId: json["userId"]??"",
      category: json["category"]??"",
      amount: json["amount"].toString()??"",
      date: json["date"]??"",
      cardNumber: json["card_number"]??"",
      transactionId: json["transaction_id"]??"",
      totalDue: json["total_due"] ?? "",
      mode: json["mode"]?? "",
      type: json["type"] ?? "",
      logo: json["logo"] ?? "",
      bankName: json["bankName"] ?? "",
      bank: json["bank"] ?? "",
      matched_bank: json["matched_bank"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}
