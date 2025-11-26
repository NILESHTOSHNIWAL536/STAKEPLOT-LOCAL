import 'dart:convert';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd_with_token.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  const String email = "nileshtoshniwal743@gmail.com";
  String accessToken =
      "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4Nzg5MTk5YmFmZmIyZDJhZjhiZTE5MyIsImlhdCI6MTc2MTU0Mzk3MywiZXhwIjoxNzY2NzI3OTczfQ.4kSbl1qmVGLm3Ltwz0E1CUylSbpzlfX0rbSmBb_XoHA";

  appLog('================ Credit Card Mail Tests Start ================');
  appLog('Access Token: $accessToken\n');

  group('Credit Card Mails Integration Flow', () {
    
    test('Full Flow: Unlinked Cards, Scrape, Linked Cards', () async {
      appLog('\n--- Step 2: Get Unlinked Cards ---');
      final unlinkedResponse = await getUnlinkedCards(accessToken);
      appLog('Unlinked Cards Response Status: ${unlinkedResponse.statusCode}');
      appLog('Unlinked Cards Response Body: ${unlinkedResponse.body}');
      expect(unlinkedResponse.statusCode, anyOf([200, 204]));

      final unlinkedData = jsonDecode(unlinkedResponse.body);
      final unlinkedCards = unlinkedData['data'] ?? [];
      appLog('Unlinked Cards Count: ${unlinkedCards.length}');

      if (unlinkedCards.isEmpty) {
        appLog('✅ No unlinked cards found - handled gracefully.');
      } else {
        final bankId = unlinkedCards[0]['bankId'];
        appLog('Found unlinked card. Bank ID: $bankId');
        
        appLog('\n--- Step 3: Scrape Bank Data ---');
        final scrapeResponse = await scrapeBankData(bankId, accessToken);
        appLog('Scrape Response Status: ${scrapeResponse.statusCode}');
        appLog('Scrape Response Body: ${scrapeResponse.body}');
        expect(scrapeResponse.statusCode, anyOf([200, 201]));

        final scrapeData = jsonDecode(scrapeResponse.body);
        appLog('Scrape Data Status: ${scrapeData['status']}');
        appLog('Scrape Data Length: ${scrapeData['data'].length}');
        expect(scrapeData['status'], equals('success'));
        // expect(scrapeData['data'], isNotEmpty);
      }

      appLog('\n--- Step 4: Fetch Linked Credit Card List ---');
      final listResponse = await fetchCreditCardList(accessToken);
      appLog('Linked Cards Response Status: ${listResponse.statusCode}');
      //  final listData = jsonDecode(listResponse.body);
      // appLog('Linked Cards Response Body: ${listResponse.body}');
      expect(listResponse.statusCode, anyOf([200, 201]));

      final listData = jsonDecode(listResponse.body);
      final linkedCards = listData['data'] ?? [];
      appLog('Linked Cards Count: ${linkedCards.length}');
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('Edge Case: Invalid Access Token', () async {
      appLog('\n--- Edge Case: Invalid Access Token ---');
      final invalidToken = "Bearer INVALIDTOKEN123";
      final response = await getUnlinkedCards(invalidToken);
      appLog('Invalid Token Response Status: ${response.statusCode}');
      appLog('Invalid Token Response Body: ${response.body}');
      expect(response.statusCode, anyOf([401, 403]));
    });

    // test('Edge Case: Revoke Access Token', () async {
    //   appLog('\n--- Edge Case: Revoke Access Token ---');
    //   final revokeResponse = await revokeAccess(email, accessToken);
    //   appLog('Revoke Response Status: ${revokeResponse.statusCode}');
    //   appLog('Revoke Response Body: ${revokeResponse.body}');
    //   expect(revokeResponse.statusCode, anyOf([200, 204]));
    // });

    test('Edge Case: Scrape with Invalid Bank ID', () async {
      appLog('\n--- Edge Case: Scrape with Invalid Bank ID ---');
      final invalidBankId = "INVALIDBANK123";
      final response = await scrapeBankData(invalidBankId, accessToken);
      appLog('Invalid Bank Scrape Status: ${response.statusCode}');
      appLog('Invalid Bank Scrape Body: ${response.body}');
      expect(response.statusCode, anyOf([400, 404]));
    });
  });

  appLog('================ Credit Card Mail Tests End ================\n');
}

// --- Helper Functions ---
Future<dynamic> getUnlinkedCards(String accessToken) async {
  appLog('Calling getUnlinkedCards API...');
  appLog(AuthApiRoutes.getUnLinkedCards);
  final response = await getDataApiCallToken(AuthApiRoutes.getUnLinkedCards, accessToken);
  appLog('getUnlinkedCards API returned: ${response.statusCode}');
  return response;
}

Future<dynamic> scrapeBankData(String bankId, String accessToken) async {
  appLog('Calling scrapeBankData API for Bank ID: $bankId...');
  appLog(AuthApiRoutes.scrape);
  final response = await postDataApiCallToken(
    "${AuthApiRoutes.scrape}/",
    {"bankIds": [bankId]},
    accessToken,
  );
  appLog('scrapeBankData API returned: ${response.statusCode}');
  return response;
}

Future<dynamic> fetchCreditCardList(String accessToken) async {
  appLog('Calling fetchCreditCardList API...');
  final response = await getDataApiCallToken(AuthApiRoutes.getCreditCardList, accessToken);
  appLog('fetchCreditCardList API returned: ${response.statusCode}');
  return response;
}

Future<dynamic> revokeAccess(String email, String accessToken) async {
  appLog('Calling revokeAccess API for email: $email...');
  final response = await postDataApiCallToken(
    AuthApiRoutes.revokeAccessToken,
    {"email": email},
    accessToken,
  );
  appLog('revokeAccess API returned: ${response.statusCode}');
  return response;
}
