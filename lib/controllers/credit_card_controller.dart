import 'dart:convert';

import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'package:get/get.dart';

import '../backed_connections/apiAutomations/curd.dart';
import '../backed_connections/apis_connect.dart';
import '../email_sync/add_credit_card_bank.dart';
import '../email_sync/data_loading.dart';
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

Future<void> LinkBankData() async {
  try {
    // API call (replace url with your actual base url)
    var response = await getDataApiCall("${url}/user/readEmail/${selectedBankName.value}");

    if (getFlagOfResponse(response)) {
      var data = jsonDecode(response.body);
      loadingBankdetails.value = true;

    } 
  } catch (e) {
    print(e);
    // debugPrint("⚠️ Error in fetchCardData: $e"
    cardList.clear();
  }
}




}
