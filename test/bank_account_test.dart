import 'dart:convert';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/model/bank_model.dart';
import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd_with_token.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load(fileName: ".env");
String accessToken =
      "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4Nzg5MTk5YmFmZmIyZDJhZjhiZTE5MyIsImlhdCI6MTc2MTI4NzkwOSwiZXhwIjoxNzY2NDcxOTA5fQ.ZJY6Dvu_3TwaEj1FwUaXJk08GCWiJQMg_ozygssVHKA";

  appLog('================ Starting Bank Accounts & Expenses Integration Test ================');

  group('Bank Accounts & Expenses Integration Test', () {

    test('Fetch Bank Accounts and FIP Info', () async {
      appLog('\n--- Step 1: Call getBankAccounts() ---');
      var response = await getDataApiCallToken(BankTransactionRoutes.getBanksLinkedAndAccounts,accessToken);
      appLog('Bank Accounts API Status: ${response.statusCode}');
      expect(response.statusCode, anyOf([200, 201]));

      // await getBankAccounts();
      if (response.statusCode == 200 || response.statusCode == 201) {
            storeDataLocal(response);
       }
      appLog('Bank Account Linked List Count: ${bankAccountLinkedList.length}');
      appLog('Consent & Handle Details Count: ${consentAndHandleDetails.length}');
      expect(bankAccountLinkedList.isNotEmpty, true, reason: 'Bank account list should not be empty');

      // final firstBank = bankAccountLinkedList[0];
            final BankAccountModel firstBank = bankAccountLinkedList[0];
      appLog('First Bank Name: ${firstBank.bankName}');
      appLog('First Bank Account ID: ${firstBank.accountId}');

      // appLog('First Bank Name: ${firstBank['bankName']}');
      // appLog('First Bank Account ID: ${firstBank['accountId']}');

      appLog('\n--- Step 2: Call addBankApiCall() ---');
      storeBankDataApi();
     

      expect(isBankLinked.value, true);
      expect(BankName.value.isNotEmpty, true);
      appLog('Is Bank Linked: ${isBankLinked.value}');
      appLog('LastFetchDate: ${LastFetchDate.value}');
      appLog('NextFetchDate: ${nextFecthDate.value}');
      appLog('FetchCount: ${fetchCount.value}');
      appLog('BankName: ${BankName.value}');
      appLog('BankLogo URL: ${BankUrl.value}');

      appLog('\n--- Step 3: Call getFipAccountInfo() ---');
      appLog('Fips Metric List Count: ${fipsMetricList.length}');
      getFipAccountInfo(true,accessToken);
      // expect(fipsMetricList.isNotEmpty, true, reason: 'Fips Metric List should not be empty');
      for (var metric in fipsMetricList) {
        appLog('FipId: ${metric.fipId}, BankName: ${metric.BankName}, Event: ${metric.eventName}, Success%: ${metric.successPercent}');
      }
    }, timeout: const Timeout(Duration(minutes: 5)));


  });

  appLog('================ Bank Accounts & Expenses Integration Test Completed ================');
}
