import 'dart:convert';

import 'package:get/get.dart';

import '../backed_connections/apiAutomations/curd.dart';
import '../backed_connections/apis_connect.dart';
import '../model/credit_card_model.dart';

class CardDueController extends GetxController {
  RxList<CardDueModel> cardList = <CardDueModel>[].obs;

Future<void> fetchCardData() async {
  try {
    // API call (replace url with your actual base url)
    var response = await getDataApiCall("${url}/email/");

    if (getFlagOfResponse(response)) {
      var data = jsonDecode(response.body)['data'];

      // Convert response into List<CardDueModel>
      cardList.clear();
      cardList.addAll ((data as List)
          .map((e) => CardDueModel.fromJson(e))
          .toList());
    } else {
      // Handle failure case
      // debugPrint("❌ Failed to fetch card data: ${response.body}");
      cardList.clear();
    }
  } catch (e) {
    print(e);
    // debugPrint("⚠️ Error in fetchCardData: $e"
    cardList.clear();
  }
}
}
