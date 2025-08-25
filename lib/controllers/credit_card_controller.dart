import 'package:get/get.dart';

import '../model/credit_card_model.dart';

class CardDueController extends GetxController {
  RxList<CardDueModel> cardList = <CardDueModel>[].obs;

  Future<void> fetchCardData() async {
    // Replace this with your API call
    final response = [
      {
        "_id": {"\$oid": "68a80df028f2a0a4adadd276"},
        "userId": {"\$oid": "68789199baffb2d2af8be193"},
        "category": "Outstanding / Due",
        "amount": "4250.75",
        "date": "19-08-2025",
        "card_number": "4321",
        "transaction_id": "Amount",
        "total_due": "",
        "mode": "CREDIT CARD",
        "type": "",
        "bank": "Axis Bank Credit Card",
        "createdAt": {"\$date": "2025-08-22T06:28:00.711Z"},
        "updatedAt": {"\$date": "2025-08-22T06:28:00.711Z"}
      },
      {
        "_id": {"\$oid": "68a80df028f2a0a4adadd276"},
        "userId": {"\$oid": "68789199baffb2d2af8be193"},
        "category": "Outstanding / Due",
        "amount": "4250.75",
        "date": "19-08-2025",
        "card_number": "4321",
        "transaction_id": "Amount",
        "total_due": "",
        "mode": "CREDIT CARD",
        "type": "",
        "bank": "Axis Bank Credit Card",
        "createdAt": {"\$date": "2025-08-22T06:28:00.711Z"},
        "updatedAt": {"\$date": "2025-08-22T06:28:00.711Z"}
      }
    ];

    cardList.value = response.map((e) => CardDueModel.fromJson(e)).toList();
  }
}
