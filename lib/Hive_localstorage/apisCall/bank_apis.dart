import '../../Utils/homepageStrings.dart.dart';
import '../../backed_connections/apiAutomations/bankinfo.dart';
import '../../backed_connections/apiAutomations/nextFetch.dart';
import '../../backed_connections/apis_connect.dart';
import '../bank_bata/bank_account_model.dart';
import '../bank_bata/consent_detail_model.dart';
import '../hive_storage.dart';
import 'init_hive.dart';

class BankStorage {


static Future<void>  cacheBankDataLocally() async {
try{
 HiveHelper.openBoxIfNot<BankAccountModel>(HiveStorage.bankAccountsBoxName);
  HiveHelper.openBoxIfNot<ConsentDetailModel>(HiveStorage.consentDetailsBoxName);
  final bankBox =await HiveStorage.bankAccountsBox;
  final consentBox =await HiveStorage.consentDetailsBox;

await bankBox.clear();
await consentBox.clear();
  for (var item in bankAccountLinkedList) {
    bankBox.add(
      BankAccountModel(
        bankId: item['bankId'],
        bankName: item['bankName'],
        bankLogo: item['bankLogo'],
        fipId: item['fipId'],
        accountId: item['accountId'],
        maskedAccNumber: "XXXXXXXXXX",//item['maskedAccNumber'],
        type: item['type'],
        currentBalance: HomepageStringsDart().lockPatterns[0],//item['currentBalance'].toString(),
        lastFetch: item['lastFetch'],
        nextFetch: item['nextFetch'],
        fetchCount: item['fetchCount'].toString(),
      ),
    );
  }

  for (var item in consentAndHandleDetails) {
    consentBox.add(
      ConsentDetailModel(
        consentId: item['consentId'],
        consendHandleId: item['consendHandleId'],
        sessionId: item['sessionId'],
        custId: item['custId'],
        lastFetch: item['lastFetch'],
        nextFetch: item['nextFetch'],
        fetchCount: item['fetchCount'].toString(),
      ),
    );
  }
  }catch(e)
  {
  }
}



static Future<void> loadBankDataFromHive() async {
  HiveHelper.openBoxIfNot<BankAccountModel>(HiveStorage.bankAccountsBoxName);
  HiveHelper.openBoxIfNot<ConsentDetailModel>(HiveStorage.consentDetailsBoxName);
 final bankBox =await HiveStorage.bankAccountsBox;
  final consentBox =await HiveStorage.consentDetailsBox;
  bankAccountLinkedList.clear();
  try{
  for (var item in bankBox.values) {
    bankAccountLinkedList.add({
      'bankId': item.bankId,
      'bankName': item.bankName,
      'bankLogo': item.bankLogo,
      'fipId': item.fipId,
      'accountId': item.accountId,
      'maskedAccNumber': item.maskedAccNumber,
      'type': item.type,
      'currentBalance': item.currentBalance.toString(),
      'lastFetch': item.lastFetch,
      'nextFetch': item.nextFetch,
      'fetchCount': item.fetchCount.toString(),
    });
  }

  consentAndHandleDetails.clear();
  for (var item in consentBox.values) {
    consentAndHandleDetails.add({
      'consentId': item.consentId,
      'consendHandleId': item.consendHandleId,
      'sessionId': item.sessionId,
      'custId': item.custId,
      'lastFetch': item.lastFetch,
      'nextFetch': item.nextFetch,
      'fetchCount': item.fetchCount.toString(),
    });
  }
   addBankApiCall();
   accountId.value=bankAccountLinkedList.isNotEmpty?bankAccountLinkedList.first['accountId']:"";
    userController.selectedBank.value=accountId.value;
   isBankLinked.value =false;
   isBankLinked.value = bankAccountLinkedList.isNotEmpty;
  }catch(e){
  }
}
}
