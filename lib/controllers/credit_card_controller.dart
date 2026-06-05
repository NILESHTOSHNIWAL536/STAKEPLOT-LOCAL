import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:get/get.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../backed_connections/apis_connect.dart';
import '../email_sync/add_credit_card_bank.dart';
import '../email_sync/email_loading_screen.dart';
import '../model/credit-card-bank.dart';
import '../model/credit_card_model.dart';
import 'bank-account-model.dart';

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
  RxString auth = "".obs;
  RxMap<String, dynamic> statementPasswordRequest = <String, dynamic>{}.obs;
  RxString statementPasswordRequestId = "".obs;
  RxList<Map<String, dynamic>> pendingStatements = <Map<String, dynamic>>[].obs;
  RxBool pendingStatementsLoading = false.obs;
  RxList<String> connectedBankIds = <String>[].obs;
  RxList<CreditCardBank> availableBanks = <CreditCardBank>[].obs;
  RxBool bankSelectionBottomSheetOpen = false.obs;

  void applyStatementPasswordRequest(Map requestData) {
    try {
      final requests = requestData["passwordRequests"];
      if (requests is! List || requests.isEmpty || requests.first is! Map) {
        return;
      }

      final nextRequest = Map<String, dynamic>.from(requests.first as Map);
      final nextRequestId = _statementPasswordRequestKey(nextRequest);
      if (statementPasswordRequired.value &&
          statementPasswordRequestId.value == nextRequestId) {
        return;
      }

      statementPasswordRequired.value = false;

      Future.delayed(const Duration(milliseconds: 100), () {
        statementPasswordRequired.value = true;
      });
      statementPasswordRequest.value = nextRequest;
      statementPasswordRequestId.value = nextRequestId;
      statementPasswordError.value = statementPasswordRequest["reason"] ==
              "invalid_password"
          ? "The saved password did not unlock this PDF. Please enter it again."
          : "";
    } catch (e) {
      appLog(e);
    }
  }

  String _statementPasswordRequestKey(Map<String, dynamic> request) {
    final explicitId = request["requestId"]?.toString() ?? "";
    if (explicitId.isNotEmpty) return explicitId;

    return [
      request["bankId"]?.toString() ?? "",
      request["messageId"]?.toString() ?? "",
      request["filename"]?.toString() ?? "",
    ].join(":");
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
        await fetchPendingStatements();
      }
    } catch (e) {
      cardList.clear();
    }
    loading.value = false;
  }

  Future<bool> addBankMappingApi(
    BuildContext context,
  ) async {
    try {
      final response = await postDataApiCall(
        AuthApiRoutes.addbankMapping,
        {
          "email": selectedEmail.value,
          "bankId": selectedBankId.value,
        },
      );

      if (getFlagOfResponse(response)) {
        Navigator.of(context).pop();
        pushnameToRoute(context, GettingDataScreen());
      }
      return false;
    } catch (e) {
      snackBarCalledfail(
        context,
        "Failed to add bank mapping",
      );
      return false;
    }
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
          pendingStatements.clear();
          pendingStatements.assignAll(
            List<Map<String, dynamic>>.from(responseData['passwordRequests']),
          );
          statementPasswordRequestId.value = "";
          applyStatementPasswordRequest(responseData);
          return false;
        }

        statementPasswordRequired.value = false;
        statementPasswordRequest.clear();
        statementPasswordRequestId.value = "";
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

  Future<void> saveStatementPasswordAndRetry(context, String password) async {
    final requestBankId = statementPasswordRequest["bankId"]?.toString() ?? "";
    final bankId =
        requestBankId.isNotEmpty ? requestBankId : selectedBankId.value;
    if (password.trim().isEmpty || bankId.isEmpty) return;

    statementPasswordSubmitting.value = true;
    statementPasswordError.value = "";
    try {
      final response = await postDataApiCall(AuthApiRoutes.statementPassword, {
        "bankId": bankId,
        "email": selectedEmail.value,
        "accountHint":
            statementPasswordRequest["accountHint"]?.toString() ?? "",
        "password": password.trim(),
      });

      if (getFlagOfResponse(response)) {
        final requestId = (statementPasswordRequest["requestId"] ??
                statementPasswordRequestId.value)
            .toString();

        final processed = await processPendingStatement(requestId);

        if (processed) {
          if (pendingStatements.isNotEmpty) {
            statementPasswordSubmitting.value = false;
            pendingStatements.removeAt(0);
            if (pendingStatements.length > 0) {
              applyStatementPasswordRequest(
                  {"passwordRequests": pendingStatements});
              return;
            }
          }
          statementPasswordRequired.value = false;
          statementPasswordRequest.clear();
          statementPasswordRequestId.value = "";
          statementPasswordError.value = "";
          loadingBankdetails.value = true;
        }
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

  Future<void> fetchPendingStatements() async {
    pendingStatementsLoading.value = true;
    try {
      final response = await getDataApiCall(AuthApiRoutes.pendingStatements);
      if (getFlagOfResponse(response)) {
        final decoded = jsonDecode(response.body);
        final data = decoded["data"];
        pendingStatements.value = data is List
            ? data
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : <Map<String, dynamic>>[];
      }
    } catch (e) {
      pendingStatements.clear();
    }
    pendingStatementsLoading.value = false;
  }

  Future<bool> processPendingStatement(String requestId) async {
    if (requestId.trim().isEmpty) {
      statementPasswordError.value =
          "We could not find the pending statement. Please try again.";
      return false;
    }

    final response = await postDataApiCall(
      AuthApiRoutes.processPendingStatement,
      {"requestId": requestId.trim()},
    );

    if (getFlagOfResponse(response)) {
      final decoded = jsonDecode(response.body);
      final data = decoded["data"];
      appLog(data['pendingdocs']);
      final bankFilterData = (data['pendingdocs'] as List)
          .where((e) =>
              (e['bankId'] ?? '').toString().toLowerCase().trim() ==
              selectedBankId.value.toString().toLowerCase().trim())
          .toList();

      statementPasswordRequestId.value = "";
      pendingStatements.clear();
      pendingStatements.assignAll(
        List<Map<String, dynamic>>.from(bankFilterData),
      );
      var res = pendingStatements.where((item) =>
          (item["requestId"] ?? item["id"] ?? "").toString() ==
          requestId.trim());
      if (res.isEmpty) return true;
      appLog(res.first['status'] == 'FAILED');
      if (res.first['status'] == 'FAILED')
        statementPasswordError.value =
            "That password did not unlock the statement. Please try again.";
      return res.first['status'] != 'FAILED';
    }

    statementPasswordError.value =
        "That password did not unlock the statement. Please try again.";
    return false;
  }

  Future<bool> savePasswordForPendingStatement(
    BuildContext context,
    Map<String, dynamic> pending,
    String password,
  ) async {
    final bankId = pending["bankId"]?.toString() ?? "";
    final requestId = (pending["requestId"] ?? pending["id"] ?? "").toString();
    if (password.trim().isEmpty || bankId.isEmpty || requestId.isEmpty) {
      return false;
    }

    statementPasswordSubmitting.value = true;
    statementPasswordError.value = "";
    try {
      final response = await postDataApiCall(AuthApiRoutes.statementPassword, {
        "bankId": bankId,
        "email": selectedEmail.value.isNotEmpty
            ? selectedEmail.value
            : pending["email"]?.toString(),
        "accountHint": pending["accountHint"]?.toString() ?? "",
        "password": password.trim(),
      });

      if (getFlagOfResponse(response)) {
        return await processPendingStatement(requestId);
      }
      await fetchPendingStatements();
      statementPasswordError.value =
          "We could not save the password. Please try again.";
    } catch (e) {
      statementPasswordError.value =
          "We could not process this statement. Please try again.";
    } finally {
      statementPasswordSubmitting.value = false;
    }

    return false;
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

  Future<bool> generateTokenApi(
    BuildContext context,
    String authCode,
  ) async {
    final response = await postDataApiCall(
      AuthApiRoutes.generateToken,
      {
        'idToken': authCode,
        'bankId':
            selectedBankId.value.isEmpty ? "HDFCLtd-FIP" : selectedBankId.value,
      },
    );

    if (getFlagOfResponse(response)) {
      return true;
    }

    final data = jsonDecode(response.body);

    if ((data['message'] ?? '')
        .toString()
        .toLowerCase()
        .contains('bank already connected')) {
      snackBarCalledfail(
        context,
        "Bank already connected. Please select another bank",
      );

      print("Connected IDs: ${data['connectedIds']}");
      connectedBankIds.value = List<String>.from(data['connectedIds'] ?? []);

      availableBanks.value = creditCardBankList
          .where((e) => !connectedBankIds.contains(e.id))
          .toList();

      BankSelectionBottomSheet.show(context);
      return false;
    }

    snackBarCalledfail(
      context,
      data['message'] ?? data['error'] ?? "Failed to generate token",
    );
    return false;
  }
}
