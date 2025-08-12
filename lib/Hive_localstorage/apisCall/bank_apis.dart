import 'package:hive/hive.dart';
import '../../Utils/homepageStrings.dart.dart';
import '../../backed_connections/apiAutomations/bankinfo.dart';
import '../../backed_connections/apiAutomations/nextFetch.dart';
import '../bank_bata/bank_account_model.dart';
import '../bank_bata/consent_detail_model.dart';


class BankStorage{

static Future<void>  cacheBankDataLocally() async {
  final bankBox = Hive.box<BankAccountModel>('bankAccountsBox');
  final consentBox = Hive.box<ConsentDetailModel>('consentDetailsBox');

await bankBox.clear();
await consentBox.clear();
try{
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
      print(e);
  }
}



static Future<void> loadBankDataFromHive() async {
  final bankBox = Hive.box<BankAccountModel>('bankAccountsBox');
  final consentBox = Hive.box<ConsentDetailModel>('consentDetailsBox');
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
   isBankLinked.value =false;
   isBankLinked.value = bankAccountLinkedList.isNotEmpty;
  }catch(e){
    
  }
}
}