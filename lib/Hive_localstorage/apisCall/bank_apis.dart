// import '../../Utils/homepageStrings.dart.dart';
// import '../../backed_connections/bankServices/nextFetch.dart';
// import '../../backed_connections/apis_connect.dart';
// import '../../repository/bankinfo.dart';
// import '../bank_bata/bank_account_model.dart';
// import '../bank_bata/consent_detail_model.dart';
// import '../hive_storage.dart';
// import 'init_hive.dart';

// class BankStorage {

// static Future<void>  cacheBankDataLocally() async {
// try{
//  HiveHelper.openBoxIfNot<BankAccountModel>(HiveStorage.bankAccountsBoxName);
//   HiveHelper.openBoxIfNot<ConsentDetailModel>(HiveStorage.consentDetailsBoxName);
//   final bankBox =await HiveStorage.bankAccountsBox;
//   final consentBox =await HiveStorage.consentDetailsBox;

// await bankBox.clear();
// await consentBox.clear();
//   for (var item in bankAccountLinkedList) {
//     bankBox.add(
//       BankAccountModel(
//         bankId: item['bankId'],
//         bankName: item['bankName'],
//         bankLogo: item['bankLogo'],
//         fipId: item['fipId'],
//         accountId: item['accountId'],
//         maskedAccNumber: "XXXXXXXXXX",//item['maskedAccNumber'],
//         type: item['type'],
//         currentBalance: HomepageStringsDart().lockPatterns[0],//item['currentBalance'].toString(),
//         lastFetch: item['lastFetch'],
//         nextFetch: item['nextFetch'],
//         fetchCount: item['fetchCount'].toString(),
//       ),
//     );
//   }

//   for (var item in consentAndHandleDetails) {
//     consentBox.add(
//       ConsentDetailModel(
//         consentId: item['consentId'],
//         consendHandleId: item['consendHandleId'],
//         sessionId: item['sessionId'],
//         custId: item['custId'],
//         lastFetch: item['lastFetch'],
//         nextFetch: item['nextFetch'],
//         fetchCount: item['fetchCount'].toString(),
//       ),
//     );
//   }
//   }catch(e)
//   {
//   }
// }



// static Future<void> loadBankDataFromHive() async {
//   HiveHelper.openBoxIfNot<BankAccountModel>(HiveStorage.bankAccountsBoxName);
//   HiveHelper.openBoxIfNot<ConsentDetailModel>(HiveStorage.consentDetailsBoxName);
//  final bankBox =await HiveStorage.bankAccountsBox;
//   final consentBox =await HiveStorage.consentDetailsBox;
//   bankAccountLinkedList.clear();
//   try{
//   for (var item in bankBox.values) {
//     bankAccountLinkedList.add({
//       'bankId': item.bankId,
//       'bankName': item.bankName,
//       'bankLogo': item.bankLogo,
//       'fipId': item.fipId,
//       'accountId': item.accountId,
//       'maskedAccNumber': item.maskedAccNumber,
//       'type': item.type,
//       'currentBalance': item.currentBalance.toString(),
//       'lastFetch': item.lastFetch,
//       'nextFetch': item.nextFetch,
//       'fetchCount': item.fetchCount.toString(),
//     });
//   }

//   consentAndHandleDetails.clear();
//   for (var item in consentBox.values) {
//     consentAndHandleDetails.add({
//       'consentId': item.consentId,
//       'consendHandleId': item.consendHandleId,
//       'sessionId': item.sessionId,
//       'custId': item.custId,
//       'lastFetch': item.lastFetch,
//       'nextFetch': item.nextFetch,
//       'fetchCount': item.fetchCount.toString(),
//     });
//   }
//    addBankApiCall();
//   accountId.value=bankAccountLinkedList.isNotEmpty?bankAccountLinkedList.first['accountId']:"";
//   userController.selectedBank.value=accountId.value;
//    isBankLinked.value = bankAccountLinkedList.isNotEmpty;
//   }catch(e){
//   }
// }
// }


import '../../Utils/homepageStrings.dart.dart';
import '../../backed_connections/bankServices/nextFetch.dart';
import '../../backed_connections/apis_connect.dart';
import '../../model/bank_model.dart';
import '../../repository/bankinfo.dart';
import '../bank_data/bank_account_model.dart' as hive;      // 👈 alias
import '../bank_data/consent_detail_model.dart' as hive;   // 👈 alias
import '../hive_storage.dart';
import 'init_hive.dart';

class BankStorage {
  static Future<void> cacheBankDataLocally() async {
    try {
      // Open boxes with HIVE models (not our network models)
      HiveHelper.openBoxIfNot<hive.BankAccountModel>(
          HiveStorage.bankAccountsBoxName);
      HiveHelper.openBoxIfNot<hive.ConsentDetailModel>(
          HiveStorage.consentDetailsBoxName);

      final bankBox = await HiveStorage.bankAccountsBox;
      final consentBox = await HiveStorage.consentDetailsBox;

      await bankBox.clear();
      await consentBox.clear();

      // ---- Save bank accounts ----
      for (var item in bankAccountLinkedList) {
        // item is BankAccountModel
        bankBox.add(
          hive.BankAccountModel(
            bankId: item.bankId,
            bankName: item.bankName,
            bankLogo: item.bankLogo,
            fipId: item.fipId,
            accountId: item.accountId,
            maskedAccNumber:
                "XXXXXXXXXX", // you were masking it earlier also
            type: item.type,
            currentBalance: HomepageStringsDart()
                .lockPatterns[0], // store masked text instead of real value
            lastFetch: item.lastFetch,
            nextFetch: item.nextFetch,
            fetchCount: item.fetchCount.toString(),
          ),
        );
      }

      // ---- Save consent details ----
      for (var item in consentAndHandleDetails) {
        // item is ConsentInfoModel
        consentBox.add(
          hive.ConsentDetailModel(
            consentId: item.consentId,
            consendHandleId: item.consendHandleId,
            sessionId: item.sessionId,
            custId: item.custId,
            lastFetch: item.lastFetch,
            nextFetch: item.nextFetch,
            fetchCount: item.fetchCount.toString(),
          ),
        );
      }
    } catch (e) {
      // ignore silently as in your original code
    }
  }

  static Future<void> loadBankDataFromHive() async {
    HiveHelper.openBoxIfNot<hive.BankAccountModel>(
        HiveStorage.bankAccountsBoxName);
    HiveHelper.openBoxIfNot<hive.ConsentDetailModel>(
        HiveStorage.consentDetailsBoxName);

    final bankBox = await HiveStorage.bankAccountsBox;
    final consentBox = await HiveStorage.consentDetailsBox;

    bankAccountLinkedList.clear();

    try {
      // ---- Load bank accounts from Hive into BankAccountModel list ----
      for (var item in bankBox.values) {
        bankAccountLinkedList.add(
          BankAccountModel(
            bankId: item.bankId,
            bankName: item.bankName,
            bankLogo: item.bankLogo,
            fipId: item.fipId,
            accountId: item.accountId,
            maskedAccNumber: item.maskedAccNumber,
            type: item.type,
            // you stored a masked string in Hive, so you can't get real balance here
            currentBalance: 0.0,
            lastFetch: item.lastFetch,
            nextFetch: item.nextFetch,
            fetchCount: int.tryParse(item.fetchCount.toString()) ?? 0,
            // profile & branch info not stored in Hive -> keep empty
            name: "",
            pan: "",
            dob: "",
            mobile: "",
            address: "",
            ifscCode: "",
            branchAddress: "",
          ),
        );
      }

      // ---- Load consent details into ConsentInfoModel list ----
      consentAndHandleDetails.clear();
      for (var item in consentBox.values) {
        consentAndHandleDetails.add(
          ConsentInfoModel(
            consentId: item.consentId,
            consendHandleId: item.consendHandleId,
            sessionId: item.sessionId,
            custId: item.custId,
            lastFetch: item.lastFetch,
            nextFetch: item.nextFetch,
            fetchCount: int.tryParse(item.fetchCount.toString()) ?? 0,
            // these were not stored in Hive earlier, so set defaults
            accountId: "",
            bankName: "",
            fipId: "",
          ),
        );
      }

      addBankApiCall();

      accountId.value = bankAccountLinkedList.isNotEmpty
          ? bankAccountLinkedList.first.accountId
          : "";
      userController.selectedBank.value = accountId.value;
      isBankLinked.value = bankAccountLinkedList.isNotEmpty;
    } catch (e) {
      // ignore silently
    }
  }
}
