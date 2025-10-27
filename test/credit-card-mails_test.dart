import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routers_api.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd_with_token.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  const String email = "nileshtoshniwal743@gmail.com";
  String accessToken =
      "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4Nzg5MTk5YmFmZmIyZDJhZjhiZTE5MyIsImlhdCI6MTc2MTU0Mzk3MywiZXhwIjoxNzY2NzI3OTczfQ.4kSbl1qmVGLm3Ltwz0E1CUylSbpzlfX0rbSmBb_XoHA";

  print('================ Credit Card Mail Tests Start ================');
  print('Access Token: $accessToken\n');

  group('Credit Card Mails Integration Flow', () {
    
    test('Full Flow: Unlinked Cards, Scrape, Linked Cards', () async {
      print('\n--- Step 2: Get Unlinked Cards ---');
      final unlinkedResponse = await getUnlinkedCards(accessToken);
      print('Unlinked Cards Response Status: ${unlinkedResponse.statusCode}');
      print('Unlinked Cards Response Body: ${unlinkedResponse.body}');
      expect(unlinkedResponse.statusCode, anyOf([200, 204]));

      final unlinkedData = jsonDecode(unlinkedResponse.body);
      final unlinkedCards = unlinkedData['data'] ?? [];
      print('Unlinked Cards Count: ${unlinkedCards.length}');

      if (unlinkedCards.isEmpty) {
        print('✅ No unlinked cards found - handled gracefully.');
      } else {
        final bankId = unlinkedCards[0]['bankId'];
        print('Found unlinked card. Bank ID: $bankId');
        
        print('\n--- Step 3: Scrape Bank Data ---');
        final scrapeResponse = await scrapeBankData(bankId, accessToken);
        print('Scrape Response Status: ${scrapeResponse.statusCode}');
        print('Scrape Response Body: ${scrapeResponse.body}');
        expect(scrapeResponse.statusCode, anyOf([200, 201]));

        final scrapeData = jsonDecode(scrapeResponse.body);
        print('Scrape Data Status: ${scrapeData['status']}');
        print('Scrape Data Length: ${scrapeData['data'].length}');
        expect(scrapeData['status'], equals('success'));
        // expect(scrapeData['data'], isNotEmpty);
      }

      print('\n--- Step 4: Fetch Linked Credit Card List ---');
      final listResponse = await fetchCreditCardList(accessToken);
      print('Linked Cards Response Status: ${listResponse.statusCode}');
      //  final listData = jsonDecode(listResponse.body);
      // print('Linked Cards Response Body: ${listResponse.body}');
      expect(listResponse.statusCode, anyOf([200, 201]));

      final listData = jsonDecode(listResponse.body);
      final linkedCards = listData['data'] ?? [];
      print('Linked Cards Count: ${linkedCards.length}');
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('Edge Case: Invalid Access Token', () async {
      print('\n--- Edge Case: Invalid Access Token ---');
      final invalidToken = "Bearer INVALIDTOKEN123";
      final response = await getUnlinkedCards(invalidToken);
      print('Invalid Token Response Status: ${response.statusCode}');
      print('Invalid Token Response Body: ${response.body}');
      expect(response.statusCode, anyOf([401, 403]));
    });

    // test('Edge Case: Revoke Access Token', () async {
    //   print('\n--- Edge Case: Revoke Access Token ---');
    //   final revokeResponse = await revokeAccess(email, accessToken);
    //   print('Revoke Response Status: ${revokeResponse.statusCode}');
    //   print('Revoke Response Body: ${revokeResponse.body}');
    //   expect(revokeResponse.statusCode, anyOf([200, 204]));
    // });

    test('Edge Case: Scrape with Invalid Bank ID', () async {
      print('\n--- Edge Case: Scrape with Invalid Bank ID ---');
      final invalidBankId = "INVALIDBANK123";
      final response = await scrapeBankData(invalidBankId, accessToken);
      print('Invalid Bank Scrape Status: ${response.statusCode}');
      print('Invalid Bank Scrape Body: ${response.body}');
      expect(response.statusCode, anyOf([400, 404]));
    });
  });

  print('================ Credit Card Mail Tests End ================\n');
}

// --- Helper Functions ---
Future<dynamic> getUnlinkedCards(String accessToken) async {
  print('Calling getUnlinkedCards API...');
  print(RouterApi.getUnLinkedCards);
  final response = await getDataApiCallToken(RouterApi.getUnLinkedCards, accessToken);
  print('getUnlinkedCards API returned: ${response.statusCode}');
  return response;
}

Future<dynamic> scrapeBankData(String bankId, String accessToken) async {
  print('Calling scrapeBankData API for Bank ID: $bankId...');
  print(RouterApi.scrape);
  final response = await postDataApiCallToken(
    "${RouterApi.scrape}/",
    {"bankIds": [bankId]},
    accessToken,
  );
  print('scrapeBankData API returned: ${response.statusCode}');
  return response;
}

Future<dynamic> fetchCreditCardList(String accessToken) async {
  print('Calling fetchCreditCardList API...');
  final response = await getDataApiCallToken(RouterApi.getCreditCardList, accessToken);
  print('fetchCreditCardList API returned: ${response.statusCode}');
  return response;
}

Future<dynamic> revokeAccess(String email, String accessToken) async {
  print('Calling revokeAccess API for email: $email...');
  final response = await postDataApiCallToken(
    RouterApi.revokeAccessToken,
    {"email": email},
    accessToken,
  );
  print('revokeAccess API returned: ${response.statusCode}');
  return response;
}
