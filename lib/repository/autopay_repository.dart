import 'dart:async';
import 'dart:convert';

import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/autopays_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';

Future<List<CardData>> getAutoPayInfo({bool flag=false}) async {
  try {
    // Fetch both false and true auto pay info
    // if(flag)return allAutoPayData;
    final responses = await Future.wait([
      getDataApiCall(BankTransactionRoutes.getRecurringPayments(isActive: false)),
      getDataApiCall(BankTransactionRoutes.getRecurringPayments(isActive: true)),
    ]);

    allAutoPayData.clear();
    for (int i = 0; i < responses.length; i++) {
      final response = responses[i];
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> autoPayDataInfo = jsonData['data'];
          allAutoPayData.addAll(
            autoPayDataInfo.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value as Map<String, dynamic>;
              return CardData.fromJson(
                  {...data, 'index': allAutoPayData.length + index});
            }),
          );
        }
      }
    }

    unawaited(CardsLocalStorage.saveCardsToHive(cardList: allAutoPayData));
    isAutoPayFected.value = !isAutoPayFected.value;

    return allAutoPayData;
  } catch (e) {
    isAutoPayFected.value = !isAutoPayFected.value;
    await CardsLocalStorage.loadCardsFromHive();
    return allAutoPayData;
  }
}

Future<bool> addRecurringPayment(String id, bool isActive) async {
  try {
    final response = await updateDataApiCall2(
         BankTransactionRoutes.updateRecurringPayment(id: id),{'isActive': isActive});

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['success'] == true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> addRecurringPaymentForDaily(String id, bool isDaily) async {
  try {
    final response = await updateDataApiCall2(
          BankTransactionRoutes.updateRecurringPayment(id: id), {'isDaily': isDaily});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['success'] == true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> updateRecurringPaymentDate(
    String id, DateTime reminderDate, bool isActive) async {
  try {
    // Format the DateTime to ISO 8601 with fixed time (9:00 AM UTC)
    final formattedDate = DateTime.utc(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9, // Fixed hour (9 AM)
      0, // Fixed minute
      0, // Fixed second
      0, // Fixed millisecond
    ).toIso8601String();

    final response = await updateDataApiCall2(
       BankTransactionRoutes.updateRecurringPayment(id: id),
      {'nextReminderAt': formattedDate, 'isActive': isActive},
    );

    // Debug prints for response

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['success'] == true;
    } else {
      return false;
    }
  } catch (e, stackTrace) {
    return false;
  }
}

Future<bool> ignoreRecurringPayment(String id) async {
  try {
    final response =
        await deleteDataApiCall(  BankTransactionRoutes.deleteRecurringPayment(id: id),);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      await getAutoPayInfo(flag: false);
      return jsonData['success'] == true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
