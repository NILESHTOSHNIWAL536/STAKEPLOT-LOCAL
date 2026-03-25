import 'dart:async';
import 'dart:convert';

import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_last_two_months_apis.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora_last2months_dashboard.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';

import '../controllers/controllerManagement.dart';
import '../controllers/finora_controller.dart';

 void getFinoraPreviousMonthData() async {
  // FinoraController finoraController = ControllerManagement.finoraController;
    isLoading.value = true;
    FinoraLoading.value = false;
    try {
      var response = await getDataApiCall(BankTransactionRoutes.getUserMonthlySpending);

      if (getFlagOfResponse(response)) {

        try {
          await FinoraLastTwoMonthsStorage.cacheFinoraLastTwoMonthsDataLocally(
              jsonDecode(response.body)['data']);
        } catch (e) {
        }

        finoraTransactionData = jsonDecode(response.body)['data'] ?? {};
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      await FinoraLastTwoMonthsStorage.loadFinoraLastTwoMonthsDataFromHive();
       isFinoraVisible.value = true;
      // isFinoraVisible.value = true;
    }
  }


void getCategoryData() async {
  //  FinoraController finoraController = ControllerManagement.finoraController;
  try {
    // API call inside try
    var res = await getDataApiCall(BankTransactionRoutes.categorizeTransactions);

    if (getFlagOfResponse(res)) {
      print("response finora ${res.body}");
    
      var data = jsonDecode(res.body);
      
       categoriesList.clear();
     
       frequentPayments.clear();
       moreDrasticChange.clear();
       categoriesListWeek.clear();
       frequentPaymentsWeek.clear();
       moreDrasticChangeWeek.clear();
       mostSpentCategoryInMonth.clear();
       mostSpentDayInMonth.clear();
       weeklyTrend.clear();
      // spendingsOnCategories.clear();
      // throw Error();
      
    
       categoriesList.addAll(
        (data["data"]['categorized'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
      

     

      // frequentPayments.addAll(data["data"]['frequentPayments']);
      // moreDrasticChange.addAll(data["data"]['moreDrasticChange']);
       frequentPayments.addAll(
        (data["data"]['frequentPayments'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );

       moreDrasticChange.addAll(
        (data["data"]['moreDrasticChange'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );

       totalDebitThisMonth.value = double.parse(
          doubleToFixed(data["data"]['totalDebitThisMonth'].toString()));

       categoriesListWeek.addAll(
        (data["data"]['week']['categorized'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
       frequentPaymentsWeek.addAll(
        (data["data"]['week']['frequentPayments'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
       moreDrasticChangeWeek.addAll(
        (data["data"]['week']['moreDrasticChange'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
     mostSpentCategoryInMonth.addAll(
  (data["data"]['mostSpentCategory'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);
if (data["data"]['mostSpentDay'] != null) {
   mostSpentDayInMonth.add(
    data["data"]['mostSpentDay'] as Map<String, dynamic>,
  );
}
if (data["data"]['weeklyTrend'] != null) {
   weeklyTrend.add(
    data["data"]['weeklyTrend'] as Map<String, dynamic>,
  );
}

      // Refresh reactive lists
       categoriesList.refresh();
       frequentPayments.refresh();
       moreDrasticChange.refresh();
       categoriesListWeek.refresh();
       frequentPaymentsWeek.refresh();
       moreDrasticChangeWeek.refresh();
       mostSpentCategoryInMonth.refresh();
       mostSpentDayInMonth.refresh();
       weeklyTrend.refresh();
       isFinoraVisible.value = ! isFinoraVisible.value;
       setDonectChat.value = ! setDonectChat.value;
      processChartData();
      unawaited(CategoryStorage().cacheCardInsightsDataLocally());
    }
  } catch (e)
  {
    await CategoryStorage().loadCardInsightsDataFromHive();
  }
}



