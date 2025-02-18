import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/donut_chart.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/week_of_year.dart';

bool getFlagOfResponse(response) {
  if (response.statusCode == 200 || response.statusCode == 201) return true;
  return false;
}

void getAutoMationsTransactions() async {
  var response = await getDataApiCall("${url}/transactionauto/");
  if (getFlagOfResponse(response)) {
    trasactionsData.clear();
    var his = jsonDecode(response.body);
    trasactionsData.addAll(his['allTransactions']['categorized_transactions']);
    changeTrasactiondata();
  } else {}
}

void changeTrasactiondata() async {
  List allTransactions = [];
  //  for (var category in trasactionsData)
  //  {
  //       allTransactions.addAll(category["transactions"]);
  //  }
  for (var category in trasactionsData) {
    String categoryId = category['_id'];
    String categoryName = category['category'];

    for (var transaction in category['transactions']) {
      transaction['categoryId'] = categoryId;
      transaction['categoryName'] = categoryName;
      allTransactions.add(transaction);
    }
  }
  allTransactions.sort((a, b) => DateTime.parse(b["transactionTimestamp"])
      .compareTo(DateTime.parse(a["transactionTimestamp"])));
  listOfRecentTrasactionsData.clear();
  listOfRecentTrasactionsData.addAll(allTransactions);
}

void getAutoMationsTransactionsMonthly() async {
  var response = await getDataApiCall(
      "${url}/transactionauto/getalltransactionsbymonth/${getCurrentMonth()}");
  trasactionsDataMonthlyCredit.clear();
  trasactionsDataMonthlyDebit.clear();

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    List<double> creditTransactions = List<double>.filled(32, 0);
    List<double> debitTransactions = List<double>.filled(32, 0);

    his['data']['debitTransactions'].forEach((element) {
      int index = int.parse(element['day'].toString());
      double amount = double.parse(element['amount'].toString());
      debitTransactions[index] = amount;
      maxDC = max(amount, maxDC);
      minDC = min(amount, maxDC);
    });
    his['data']['creditTransactions'].forEach((element) {
      int index = int.parse(element['day'].toString());
      double amount = double.parse(element['amount'].toString());
      creditTransactions[index] = amount;
      maxDC = max(amount, maxDC);
      minDC = min(amount, maxDC);
    });

    trasactionsDataMonthlyDebit.addAll(debitTransactions);
    trasactionsDataMonthlyCredit.addAll(creditTransactions);
    // getMaxAndMin();
  }
}

void getAutoMationsTransactionsWeekly() async {
  String week = getCurrentWeek();
  var response = await getDataApiCall(
      "${url}/transactionauto/getalltransactionbyweek/${week}");
  trasactionsDataCreditWeekly.clear();
  trasactionsDataDebitWeekly.clear();
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    List creditTransactions = his['data'][week]['creditTransactions'];
    List debitTransactions = his['data'][week]['debitTransactions'];

    creditTransactions.forEach((element) {
      trasactionsDataCreditWeekly.add(element['amount']);
    });
    debitTransactions.forEach((element) {
      trasactionsDataDebitWeekly.add(element['amount']);
    });

    // getMaxAndMin();
  }
}

double getDouble(data){
   return double.parse(data.toString());
}

void getAutoMationsTransactionsCustom(date, context,[weekORmonth='month']) async {
  String urlPath="${url}/transactionauto/getAllCustomTransactions/${weekORmonth.toString().toLowerCase()}/${date}";

  var response = await getDataApiCall(urlPath);
  
  trasactionsDataCreditWeekly.clear();
  trasactionsDataDebitWeekly.clear();

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
     List<String> labelsLocal = [];
    List<double> debitList = [];
    List<double> creditList = [];

     transactionChatGraph.clear();
    labels.clear();

      try{
        Map data = his['data']['transactions'];
        try{
        maxYValue.value=double.parse(his['data']['maxAmount'].toString()) ?? 0.0;
        }catch(e){
             maxYValue.value=500.0;
        }
        if(maxYValue.value==0 || maxYValue.value==0.0)maxYValue.value=500.0;
        his['data']['transactions'].forEach((key, value) {
             selectedButton.value=="Custom"? labelsLocal.add(key.toString())   :  labelsLocal.add(key.toString().substring(key.toString().length-2));
                  debitList.add( getDouble(value['debit']));
                  creditList.add( getDouble(value['credit']));
    });
    }catch(e)
    {
          maxYValue.value= 500;
          debitList=[];
          creditList=[];
          labelsLocal=weekORmonth.toString()=='Week'?getWeekDays():getDaysInMonth(date);
          debitList=  List.filled(labelsLocal.length, 0);
          creditList=  List.filled(labelsLocal.length, 0);
    }
    
    if(selectedButton.value=='Week')
    {
         labelsLocal=getWeekDays();
    }

    transactionChatGraph['credited']=debitList;
    transactionChatGraph['debited']=creditList;
    graphTransaction.value=!graphTransaction.value;
  
    labels.addAll(labelsLocal);
    getGraphData.value=true;

  }
}

List<String> getWeekDays() {
  return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}

List<String> getDaysInMonth(String yearMonth) {
  List<String> days = [];
  List<String> parts = yearMonth.split('-');
  if (parts.length != 2) return days;

  int year = int.tryParse(parts[0]) ?? 0;
  int month = int.tryParse(parts[1]) ?? 0;
  if (year == 0 || month == 0) return days;

  int daysInMonth = DateTime(year, month + 1, 0).day;

  for (int i = 1; i <= daysInMonth; i++) {
    days.add('${i.toString().padLeft(2, '0')}');
  }
   
  return days;
}

Future<http.Response> getDataApiCall(urlPath) async {
  print(urlPath);
  final SharedPreferences pref = await SharedPreferences.getInstance();
  // pref.setString("accessToken",
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3NWMwYWZiZmNiMTcxMDc2NWFiOGU5MCIsImlhdCI6MTczNzcwMzU3NCwiZXhwIjoxNzQyODg3NTc0fQ.zYUUmoy_xlaZwdvM8r4KDOZNADlLyxPirqDm0avEUXg");
  var accessToken = pref.getString("accessToken");
  print(accessToken);
  final response = await http.get(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  return response;
}

Future<http.Response> updateDataApiCall(urlPath) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");

  final response = await http.patch(Uri.parse(urlPath),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({}));
  return response;
}

String getCurrentMonth() {
  DateTime now = DateTime.now();
  String year = now.year.toString();
  String month = now.month.toString().padLeft(2, '0'); // Ensures two digits
  return '$year-$month';
}

String getCurrentWeek() {
  
  final now = DateTime.now();
  final year = now.year;
  String s='$year-W${now.weekOfYear.toString().padLeft(2, '0')}';
  return s;
}

// Function to calculate the week number
int _getWeekNumber(DateTime date) {
  final firstDayOfYear = DateTime(date.year, 1, 1);
  final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
  final weekNumber = ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  return weekNumber;
}

void getUserBankData(context) async {
  String urlPath = "${url}/transactionauto/userDetails/";
  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {
    //  Navigator.pop(context);
  }
}

void updateTheTagOfTarnsactions(
    source_category, destination_category, transactionId, context) async {
  //  updateTransaction/:source_category/:destination_category/:transactionId
  String urlPath =
      "${url}/transactionauto/updateTransaction/${source_category}/${destination_category}/${transactionId}";

  var responce = await getDataApiCall(urlPath);

  void getTransaction(context) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/transaction/history'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    printData(response, context);
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];

      // trasactionsHistory.clear();
      // trasactionsHistory.addAll(obj);
    } else {}
  }

  if (getFlagOfResponse(responce)) {
    getAutoMationsTransactions();
    Navigator.pop(context);
  }
}

void hideTransactions(
    source_category, destination_category_name, transactionId, context) async {
  String urlPath =
      "${url}/transactionauto/hideTransaction/${source_category}/${destination_category_name}/${transactionId}";
  var responce = await getDataApiCall(urlPath);
  if (getFlagOfResponse(responce)) {
    getAutoMationsTransactions();
  }
}

void unHideTransactions(
    source_category, destination_category_name, transactionId, context) async {
  String urlPath =
      "${url}/transactionauto/unHideTransaction/${source_category}/${destination_category_name}/${transactionId}";
  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {
    getAutoMationsTransactions();
    getHideTransactions(context);
  }
}

void getHideTransactions(context) async {
  String urlPath = "${url}/transactionauto/getHideTransaction/";
  var response = await getDataApiCall(urlPath);

  // printData(response, context);
  if (getFlagOfResponse(response)) {
    trasactionsHideData.clear();
    var his = jsonDecode(response.body);
    trasactionsHideData
        .addAll(his['allTransactions']['categorized_transactions']);
  }
}

void addTransaction(String amount, String subCategory, String categories,
    BuildContext context, String dropdownValue,
    [bool isSplit = false]) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  var body = {
    'amount': amount.toString(),
    'category': categories.toString().toLowerCase(),
    'label': subCategory.toString(),
    'account': dropdownValue.toString(),
    'room': {},
    'isSplit': isSplit,
  };
 
  final response = await http.post(
    Uri.parse('${url}/transaction/add'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  );
  printData(response);
  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    if (!isSplit) snackBarCalled(context, "Added Trasactions!", Colors.black);
    getAllTransaction(context);
    getCategoryData();
     setDonectChat.value = !setDonectChat.value;
      processChartData();
    Navigator.pop(context);
  } else {
    snackBarCalled(context, "can't Add Trasactions!", Colors.red);
  }
}

 void processChartData() {
    List<ChartData> newData = [];
    double newTotalValue = 0.0;

    Map<String, Color> categoryColors = {
      "Food": Color.fromARGB(255, 198, 172, 245),
      "Shopping": Color.fromARGB(255, 103, 133, 146),
      "Travel": Color.fromARGB(255, 206, 231, 243),
      "Health": Color.fromARGB(255, 130, 175, 167),
      "Subscriptions": Color.fromARGB(255, 132, 203, 119),
      "Entertainment": Color.fromARGB(255, 193, 118, 175),
      "Insurance": Color(0xFF0288D1),
      "Emi": Color(0xFFFFC107),
      "Investments": Color.fromARGB(255, 247, 114, 114),
      "Untagged": Color.fromARGB(255, 74, 117, 139),
    };

    
   for (var item in categoriesList) {
      String category = item["category"];
      double value = item["total_debit"].toDouble();
      Color color = categoryColors[category] ?? Colors.grey; // Default color

      newData.add(ChartData(category, value, color));
      newTotalValue += value;
    }


      chartData.value= newData;
      totalValue.value = newTotalValue;
  
  }

void getTransaction(context) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse('${url}/transaction/history'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  printData(response, context);
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    trasactionsHistory.clear();
    trasactionsHistory.addAll(obj);
  } else {}
}
Future postDataApiCall(String urlPath, Map body) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");
  
  final response = await http.post(
    Uri.parse(urlPath),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  );
  return response;
}




  Future<void> pickCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      // initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            color: AppColors.mt,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height *
                0.5, // Adjust height (60% of screen height)
            child: child!,
          ),
        );
      },
    );
    String s= picked!.start.toString().substring(0,10)+","+ picked.end.toString().substring(0,10);
    getAutoMationsTransactionsCustom(s, context,'custom');
    print("...........lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll");
    print(s);
    selectedButton.value='Custom';
    getGraphData.value=false;
    // if (picked != null && picked != selectedDateRange) {

        // selectedDateRange = picked;
        // selectedButton = 'Custom';

    // }
  }

void getWeekDate()
{
    //   if (selectedButton == 'Week') {
    //   final currentWeek = weekData[0]!;
    //   chartData = {
    //     "credited": currentWeek.values.toList(),
    //     "debited": currentWeek.values
    //         .map((e) => e * 0.8)
    //         .toList(), // Debited is 80% of credited
    //   };
    //   labels = currentWeek.keys.toList();
    // } else if (selectedButton == 'Month') {
    //   chartData = {
    //     "credited": List.generate(
    //       30,
    //       (index) => creditedData[index + 1]?.reduce((a, b) => a + b) ?? 0.0,
    //     ),
    //     "debited": List.generate(
    //       30,
    //       (index) => debitedData[index + 1]?.reduce((a, b) => a + b) ?? 0.0,
    //     ),
    //   };
    //   labels = List.generate(30, (index) => (index + 1).toString());
    // } else if (selectedButton == 'Custom' && selectedDateRange != null) {
    //   final startDate = selectedDateRange!.start;
    //   final endDate = selectedDateRange!.end;

    //   // Filter data for the selected range
    //   chartData = {
    //     "credited": List.generate(
    //       endDate.difference(startDate).inDays + 1,
    //       (index) => creditedData[startDate.add(Duration(days: index)).day]!
    //           .reduce((a, b) => a + b),
    //     ),
    //     "debited": List.generate(
    //       endDate.difference(startDate).inDays + 1,
    //       (index) => debitedData[startDate.add(Duration(days: index)).day]!
    //           .reduce((a, b) => a + b),
    //     ),
    //   };

    //   // Generate labels for the selected date range
    //   labels = List.generate(
    //     endDate.difference(startDate).inDays + 1,
    //     (index) => (startDate.add(Duration(days: index))).day.toString(),
    //   );
    // } else {
    //   // Default case
    //   chartData = {
    //     "credited": [],
    //     "debited": [],
    //   };
    //   labels = [];
    // }
    
}


 //double totalSpent = calculateTotal(chartData);
  //  totalSpent =chartData["credited"]!.isNotEmpty && chartData["debited"]!.isNotEmpty? calculateTotal(chartData): 0.0;


 double calculateTotal(Map<String, List<double>> data) {
    return data["credited"]!.reduce((a, b) => a + b) -
        data["debited"]!.reduce((a, b) => a + b);
  }