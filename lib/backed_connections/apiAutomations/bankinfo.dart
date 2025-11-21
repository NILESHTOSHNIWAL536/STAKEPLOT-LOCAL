import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd_with_token.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:get/get.dart';

import '../../Hive_localstorage/apisCall/bank_apis.dart';
import '../../Hive_localstorage/apisCall/fipmetric_apis.dart';
import '../../model/fips_metric_model.dart';
import '../../routes/route_finvu.dart';


RxList bankAccountLinkedList = [].obs;
RxList<FipsMetric>  fipsMetricList = <FipsMetric>[].obs;
RxList consentAndHandleDetails = [].obs;
RxMap bankImagemap = {}.obs;

Future<void> getBankAccounts() async {
  try{
     var response = await getDataApiCall(BankTransactionRoutes.getBanksLinkedAndAccounts);
    if (getFlagOfResponse(response))
    {
      print("Bank Accounts Fetched Successfully");
      print(response.body);
    
      storeDataLocal(response);
    }
    addBankApiCall();
    BankStorage.cacheBankDataLocally();
  }catch(e)
  {
    await BankStorage.loadBankDataFromHive();
    addBankApiCall();
  }
}

void storeDataLocal(response){
   var his = jsonDecode(response.body);
    consentAndHandleDetails.clear();
    bankAccountLinkedList.clear();
    FipIdsConnected.clear();
    his['data'].forEach((bank) {
      if (bank['consentId'] != null && bank['consendHandleId'] != null) {
        if (!consentAndHandleDetails.any((item) =>
            item['consentId'] == bank['consentId'] &&
            item['consendHandleId'] == bank['consendHandleId'])) {
          consentAndHandleDetails.add({
            "consentId": bank['consentId'],
            "consendHandleId": bank['consendHandleId'],
            "sessionId": bank['sessionId'],
            "custId": bank['custId'],
            'lastFetch': bank['accounts'][0]['lastFetch'] ?? "",
            'nextFetch': bank['accounts'][0]['nextFetch'] ?? "",
            'fetchCount': bank['accounts'][0]['fetchCount'] ?? "0",
            'accountId': bank['accounts'][0]['accountId'] ?? "accountId",
            'bankName': bank['bankName'] ?? "BankName",
            'fipId': bank['fipId'] ?? "fipId",
          });
        }
      }
      bank['accounts'].forEach((account) {
        var profile= account['profile']?['holder'] ?? {};
        if (accountId.value == "") accountId.value = account['accountId'];
        FipIdsConnected.add(account['maskedAccNumber']);
        bankAccountLinkedList.add({
          'bankId': bank['bankId'],
          'bankName': bank['bankName'],
          'bankLogo': bank['bankLogo'] ?? bankImage,
          'fipId': bank['fipId'],
          'accountId': account['accountId'],
          'maskedAccNumber': account['maskedAccNumber'],
          'type': account['type'],
          'currentBalance': account['currentBalance'],
          'lastFetch': account['lastFetch'] ?? "",
          'nextFetch': account['nextFetch'] ?? "",
          'fetchCount': account['fetchCount'] ?? "0",
          'name':  profile['name'] ?? "0",
          'pan': profile['pan'] ?? "0",
          'dob':    profile['dob'] ?? "0",
          'mobile': profile['mobile'] ?? "0",
          'address': profile['address'] ?? "0",
          'ifscCode': account['ifscCode'] ?? "0",
          'branchAddress': account['branchAddress'] ?? "0",
        });
      });
    });
}


void storeBankDataApi(){
   if (bankAccountLinkedList.isNotEmpty)
   {
    // isBankLinked.value = true;
    LastFetchDate.value = bankAccountLinkedList[0]['lastFetch'].toString();
    nextFecthDate.value = bankAccountLinkedList[0]['nextFetch'].toString();
   
    fetchCount.value = bankAccountLinkedList[0]['fetchCount'].toString();
    BankName.value = bankAccountLinkedList[0]['bankName'].toString();
    BankUrl.value = bankAccountLinkedList[0]['bankLogo'].toString();
  }
  isBankLinked.value = bankAccountLinkedList.isNotEmpty;
  loadBanks.value = false;
  loadBalance.value = !loadBalance.value;
}

void addBankApiCall() {
  storeBankDataApi();
  getFipAccountInfo();
}

void getWeeklyfetchData(consentId, consendHandleId, sessionId, custId, last,bankName,fipId,fetchCount,accountId) async {
  
  final String apiUrl =FinvuRoutes.fetchWeekly;
  final String userUrl = UserRoutes.updateFetchStatus;

  var body = {
    'handleId': consendHandleId,
    'custId': custId,
    'consentId': consentId,
    'sessionId': sessionId,
    'userId': userController.userId.value,
    'isCron': false,
    'FROM': last,
    'bankName':bankName,
    'fipId':fipId,
    'fetchCount':fetchCount,
    'accountId':accountId,
  };

  var userBody = {
    "fetchInProgress": true,
  };

  try {
     await updateDataApiCall2(userUrl, userBody);
     await postDataApiCall(apiUrl, body);
  } catch (e) {
      isFected.value = false;
      await updateDataApiCall2(userUrl, {
              "fetchInProgress": false,
      });
  }
}

void calledFunctionToFetchData(context) async {
  if (accountId.value.isEmpty)
  {
    getGraphData.value = false;
    await getBankAccounts();
  }

  if (selectedButton.value == "Month") {
    getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context);
  } else if (selectedButton.value == "Week") {
    getWeeklyGraphAndCustomDateGraph(getCurrentWeek(), context, weekORmonth: 'Week');
  } else {
    getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context,weekORmonth: 'Custom');
  }
}

Future<void> getFipAccountInfo([bool testing=false,String token=""]) async
{
   try{ 
   List<String> fipIds=[];
   Map<String,String> bankNameMap=new Map();
   bankAccountLinkedList.forEach((d){
      fipIds.add(d["fipId"]);
      bankNameMap[d["fipId"]]=d['bankName'];
   });

    if(fipIds.isEmpty)return;
    String urlPath=FinvuRoutes.getFipDetails;
    var body={
       "fipIds":fipIds
    };
 
    var response=  (!testing?await postDataApiCall(urlPath,body): await postDataApiCallToken(urlPath, body, token));
     
      // printData(response);
    if(getFlagOfResponse(response))
    {
        var data=jsonDecode(response.body)['data'];
  
        fipsMetricList.clear();
        List<FipsMetric> list = (data as List) .map((item) => FipsMetric.fromJson(item,bankNameMap[item['fip_id']]??"")).toList();
       
        if(list.isEmpty){
          list.add(FipsMetric(timestamp: DateTime(2027), fipId: fipIds.isEmpty? "":fipIds.first , eventName: "", BankName: BankName.value, latencyAvgMs: 100, successPercent: 100, timeoutPercent: 10, accNotFoundPercent: 10, serverErrorPercent: 10, clientErrorPercent: 10, latencyP99Ms: 10, latencyP95Ms: 10, latencyP50Ms: 10));
        }
        fipsMetricList.addAll(list);
        FipsMetricLocalStorage.saveFipsMetricsToHive();
    }
   }catch(e)
   {
       print("Error in getFipAccountInfo: $e");
        FipsMetricLocalStorage.loadFipsMetricsFromHive();
   }

}