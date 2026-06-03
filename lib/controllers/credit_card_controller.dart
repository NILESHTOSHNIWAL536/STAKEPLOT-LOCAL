import 'dart:convert';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:get/get.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../backed_connections/apis_connect.dart';
import '../email_sync/add_credit_card_bank.dart';
import '../email_sync/email_loading_screen.dart';
import '../model/credit-card-bank.dart';
import '../model/credit_card_model.dart';

class CardDueController extends GetxController {
  RxList<CardDueModel> cardList = <CardDueModel>[].obs;
  RxBool loading = false.obs;
  RxBool forceLogin = false.obs;
  RxString selectedBankId = "".obs;
  RxString selectedEmail = "".obs;
  RxString selectedBankName = "".obs;
  RxBool statementPasswordRequired = false.obs;
  RxBool statementPasswordSubmitting = false.obs;
  RxString statementPasswordError = "".obs;
  RxMap<String, dynamic> statementPasswordRequest = <String, dynamic>{}.obs;

  void applyStatementPasswordRequest(Map requestData) {
    final requests = requestData["passwordRequests"];
    if (requests is! List || requests.isEmpty || requests.first is! Map) {
      return;
    }

    statementPasswordRequest.value =
        Map<String, dynamic>.from(requests.first as Map);
    statementPasswordError.value =
        statementPasswordRequest["reason"] == "invalid_password"
            ? "The saved password did not unlock this PDF. Please enter it again."
            : "";
    statementPasswordRequired.value = true;
  }

  Future<void> fetchCardData() async {
    try {
      // API call (replace url with your actual base url)
      // if(!CreditCardScreenStrings().showCreditCard.value)return;
      var response = await getDataApiCall(AuthApiRoutes.getCreditCardList);
      loading.value = true;
      if (getFlagOfResponse(response)) {
        var data = jsonDecode(response.body)['data'];

        // Convert response into List<CardDueModel>
        cardList.clear();
        cardList.addAll(
            (data as List).map((e) => CardDueModel.fromJson(e)).toList());
      }
    } catch (e) {
      cardList.clear();
    }
    loading.value = false;
  }

  Future<bool> LinkBankData(context) async {
    try {
      // API call (replace url with your actual base url)
      if (selectedBankId.value.isEmpty) {
        snackBarCalledfail(context, "Invalid Bank Id");
        Future.delayed(const Duration(seconds: 2), () {
          pushnameToRoute(context, AddCreditCardBankScreen());
        });
        return false;
      }

      var response = await postDataApiCall("${AuthApiRoutes.scrape}/", {
        "bankIds": [selectedBankId.value],
        "email": selectedEmail.value,
      });

      if (getFlagOfResponse(response)) {
        var data = jsonDecode(response.body);
        final responseData = data["data"];

        if (responseData is Map &&
            responseData["requiresPassword"] == true &&
            responseData["passwordRequests"] is List &&
            (responseData["passwordRequests"] as List).isNotEmpty) {
          applyStatementPasswordRequest(responseData);
          return false;
        }

        statementPasswordRequired.value = false;
        statementPasswordRequest.clear();
        statementPasswordError.value = "";
        loadingBankdetails.value = true;
        selectedBankId.value = "";
        return true;
      }
    } catch (e) {
      statementPasswordError.value =
          "We could not complete statement extraction. Please try again.";
    }
    return false;
  }

  Future<void> saveStatementPasswordAndRetry(
      context, String password) async {
    final requestBankId = statementPasswordRequest["bankId"]?.toString() ?? "";
    final bankId = requestBankId.isNotEmpty ? requestBankId : selectedBankId.value;
    if (password.trim().isEmpty || bankId.isEmpty) return;

    statementPasswordSubmitting.value = true;
    statementPasswordError.value = "";
    try {
      final response = await postDataApiCall(AuthApiRoutes.statementPassword, {
        "bankId": bankId,
        "email": selectedEmail.value,
        "accountHint": statementPasswordRequest["accountHint"]?.toString() ?? "",
        "password": password.trim(),
      });

      if (getFlagOfResponse(response)) {
        statementPasswordRequired.value = false;
        statementPasswordRequest.clear();
        await LinkBankData(context);
      } else {
        statementPasswordError.value =
            "We could not save the password. Please try again.";
      }
    } catch (e) {
      statementPasswordError.value =
          "We could not save the password. Please try again.";
    }
    statementPasswordSubmitting.value = false;
  }

  Future<void> getBanksListCrediCard() async {
    try {
      // API call (replace url with your actual base url)
      var response = await getDataApiCall(AuthApiRoutes.getUnLinkedCards);

      if (getFlagOfResponse(response)) {
        var data = jsonDecode(response.body);
        creditCardBankList.clear();
        creditCardBankList.addAll(CreditCardBank.fromJsonList(data));
      }
    } catch (e) {
      cardList.clear();
    }
  }
}
