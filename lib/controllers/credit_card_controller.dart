import 'dart:convert';
import 'package:get/get.dart';
import '../Utils/credit_card.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../backed_connections/apis_connect.dart';
import '../email_sync/add_credit_card_bank.dart';
import '../email_sync/data_loading.dart';
import '../finances_screen/creditCard_slider.dart';
import '../model/credit-card-bank.dart';
import '../model/credit_card_model.dart';

class CardDueController extends GetxController {
  RxList<CardDueModel> cardList = <CardDueModel>[].obs;
  RxBool loading=false.obs;

Future<void> fetchCardData() async {
  try {
    // API call (replace url with your actual base url)
    if(!CreditCardScreenStrings().showCreditCard.value)return;
    var response = await getDataApiCall("${url}/email/");
    loading.value=true;
    if (getFlagOfResponse(response)) {
      var data = jsonDecode(response.body)['data'];

      // Convert response into List<CardDueModel>
      cardList.clear();
      cardList.addAll ((data as List)
          .map((e) => CardDueModel.fromJson(e))
          .toList());
     if(!getCreditCardBudgetDebts.value)getCreditCardBudgetDebts.value= cardList.isNotEmpty;
    } else {
      cardList.clear();
    }
  } catch (e) {
    cardList.clear();
  }
  loading.value=false;
}

Future<void> LinkBankData(context) async {
  try {
    // API call (replace url with your actual base url)
    if(selectedBankId.value.isEmpty){
      snackBarCalledfail(context, "Invalid Bank Id");
      pushnameToRoute(context,AddCreditCardBankScreen());
      return;
    }
    var response = await getDataApiCall("${url}/user/readEmail/${selectedBankId.value}");

    if (getFlagOfResponse(response)) 
    {
      var data = jsonDecode(response.body);
      loadingBankdetails.value = true;
      selectedBankId.value="";

       Future.delayed(const Duration(seconds: 2), () {
        pushnameToRoute(context, CardDueCarousel());
      });
      
    } 
  } catch (e) {
    cardList.clear();
  }
}

Future<void> getBanksListCrediCard() async {
  try {
    // API call (replace url with your actual base url)
    var response = await getDataApiCall("${url}/email/get-banks/");

    if (getFlagOfResponse(response))
    {
      var data = jsonDecode(response.body)['data'];
      creditCardBankList.clear();
      creditCardBankList.addAll(CreditCardBank.fromJsonList(data));
    } 

  } catch (e) {
    cardList.clear();
  }
}
}
