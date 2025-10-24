import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd_with_token.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load(fileName: ".env");
String accessToken =
      "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4Nzg5MTk5YmFmZmIyZDJhZjhiZTE5MyIsImlhdCI6MTc2MTI4NzkwOSwiZXhwIjoxNzY2NDcxOTA5fQ.ZJY6Dvu_3TwaEj1FwUaXJk08GCWiJQMg_ozygssVHKA";

  print('================ Starting Bank Accounts & Expenses Integration Test ================');

  group('Bank Accounts & Expenses Integration Test', () {

    test('Fetch Bank Accounts and FIP Info', () async {
      print('\n--- Step 1: Call getBankAccounts() ---');
      var response = await getDataApiCallToken("${url}/transactionauto/get-banks-linked/",accessToken);
      print('Bank Accounts API Status: ${response.statusCode}');
      expect(response.statusCode, anyOf([200, 201]));

      // await getBankAccounts();
      if (response.statusCode == 200 || response.statusCode == 201) {
            storeDataLocal(response);
       }
      print('Bank Account Linked List Count: ${bankAccountLinkedList.length}');
      print('Consent & Handle Details Count: ${consentAndHandleDetails.length}');
      expect(bankAccountLinkedList.isNotEmpty, true, reason: 'Bank account list should not be empty');

      final firstBank = bankAccountLinkedList[0];
      print('First Bank Name: ${firstBank['bankName']}');
      print('First Bank Account ID: ${firstBank['accountId']}');

      print('\n--- Step 2: Call addBankApiCall() ---');
      storeBankDataApi();
     

      expect(isBankLinked.value, true);
      expect(BankName.value.isNotEmpty, true);
      print('Is Bank Linked: ${isBankLinked.value}');
      print('LastFetchDate: ${LastFetchDate.value}');
      print('NextFetchDate: ${nextFecthDate.value}');
      print('FetchCount: ${fetchCount.value}');
      print('BankName: ${BankName.value}');
      print('BankLogo URL: ${BankUrl.value}');

      print('\n--- Step 3: Call getFipAccountInfo() ---');
      print('Fips Metric List Count: ${fipsMetricList.length}');
      getFipAccountInfo(true,accessToken);
      // expect(fipsMetricList.isNotEmpty, true, reason: 'Fips Metric List should not be empty');
      for (var metric in fipsMetricList) {
        print('FipId: ${metric.fipId}, BankName: ${metric.BankName}, Event: ${metric.eventName}, Success%: ${metric.successPercent}');
      }
    }, timeout: const Timeout(Duration(minutes: 5)));


  });

  print('================ Bank Accounts & Expenses Integration Test Completed ================');
}
