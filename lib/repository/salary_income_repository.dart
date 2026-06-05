import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/model/salary_income_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';

Future<List<SalaryIncomeSource>> getSalarySuggestions() async {
  try {
    final response =
        await getDataApiCall(BankTransactionRoutes.salarySuggestions);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['success'] == true) {
        final data = (jsonData['data'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(SalaryIncomeSource.fromJson)
            .toList();
        allSalaryIncomeData
          ..clear()
          ..addAll(data);
        isSalaryIncomeFetched.value = !isSalaryIncomeFetched.value;
        return data;
      }
    }
  } catch (e) {
    appLog("Salary suggestions fetch failed", e);
  }
  return allSalaryIncomeData;
}

Future<List<SalaryIncomeSource>> getConfirmedSalaryAccounts() async {
  try {
    final response = await getDataApiCall(BankTransactionRoutes.salaryAccounts);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['success'] == true) {
        return (jsonData['data'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(SalaryIncomeSource.fromJson)
            .toList();
      }
    }
  } catch (e) {
    appLog("Confirmed salary accounts fetch failed", e);
  }
  return [];
}

Future<bool> confirmSalaryIncome(
  String id, {
  String? sourceName,
  double? predictedAmount,
  int? expectedCreditDay,
}) async {
  try {
    final response = await postDataApiCall(
      BankTransactionRoutes.confirmSalaryIncome(id: id),
      {
        if (sourceName != null) 'sourceName': sourceName,
        if (predictedAmount != null) 'predictedAmount': predictedAmount,
        if (expectedCreditDay != null) 'expectedCreditDay': expectedCreditDay,
      },
    );
    final jsonData = jsonDecode(response.body);
    return (response.statusCode == 200 || response.statusCode == 201) &&
        jsonData['success'] == true;
  } catch (e) {
    return false;
  }
}

Future<bool> updateSalaryIncome(String id, Map<String, dynamic> body) async {
  try {
    final response = await updateDataApiCall2(
      BankTransactionRoutes.updateSalaryIncome(id: id),
      body,
    );
    final jsonData = jsonDecode(response.body);
    return response.statusCode == 200 && jsonData['success'] == true;
  } catch (e) {
    return false;
  }
}

Future<bool> ignoreSalaryIncome(String id) async {
  try {
    final response = await postDataApiCall(
      BankTransactionRoutes.ignoreSalaryIncome(id: id),
      {},
    );
    final jsonData = jsonDecode(response.body);
    return response.statusCode == 200 && jsonData['success'] == true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteSalaryIncome(String id) async {
  try {
    final response = await deleteDataApiCall(
      BankTransactionRoutes.deleteSalaryIncome(id: id),
    );
    final jsonData = jsonDecode(response.body);
    return response.statusCode == 200 && jsonData['success'] == true;
  } catch (e) {
    return false;
  }
}

Future<bool> recalculateSalaryIncome() async {
  try {
    final response = await postDataApiCall(
      BankTransactionRoutes.recalculateSalaryIncome,
      {},
    );
    final jsonData = jsonDecode(response.body);
    return response.statusCode == 200 && jsonData['success'] == true;
  } catch (e) {
    return false;
  }
}
