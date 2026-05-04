import '../../backed_connections/bankServices/nextFetch.dart';
import '../../backed_connections/apis_connect.dart';
import '../../model/bank_model.dart';
import '../../repository/bankinfo.dart';
import '../bank_data/bank_account_model.dart' as hive; // 👈 alias
import '../bank_data/consent_detail_model.dart' as hive; // 👈 alias
import '../hive_storage.dart';
import 'init_hive.dart';

class BankStorage {
  static Future<void> cacheBankDataLocally() async {
    try {
      // Open boxes with HIVE models (not our network models)
      await HiveHelper.openBoxIfNot<hive.BankAccountModel>(
          HiveStorage.bankAccountsBoxName);
      await HiveHelper.openBoxIfNot<hive.ConsentDetailModel>(
          HiveStorage.consentDetailsBoxName);

      final bankBox = HiveStorage.bankAccountsBox;
      final consentBox = HiveStorage.consentDetailsBox;

      await bankBox.clear();
      await consentBox.clear();

      // ---- Save bank accounts ----
      await bankBox.addAll(
        bankAccountLinkedList.map(
          (item) => hive.BankAccountModel(
            bankId: item.bankId,
            bankName: item.bankName,
            bankLogo: item.bankLogo,
            fipId: item.fipId,
            accountId: item.accountId,
            maskedAccNumber: item.maskedAccNumber,
            type: item.type,
            currentBalance: item.currentBalance.toString(),
            lastFetch: item.lastFetch,
            nextFetch: item.nextFetch,
            fetchCount: item.fetchCount.toString(),
          ),
        ),
      );

      // ---- Save consent details ----
      await consentBox.addAll(
        consentAndHandleDetails.map(
          (item) => hive.ConsentDetailModel(
            consentId: item.consentId,
            consendHandleId: item.consendHandleId,
            sessionId: item.sessionId,
            custId: item.custId,
            lastFetch: item.lastFetch,
            nextFetch: item.nextFetch,
            fetchCount: item.fetchCount.toString(),
          ),
        ),
      );
    } catch (e) {
      // ignore silently as in your original code
    }
  }

  static Future<void> loadBankDataFromHive() async {
    await HiveHelper.openBoxIfNot<hive.BankAccountModel>(
        HiveStorage.bankAccountsBoxName);
    await HiveHelper.openBoxIfNot<hive.ConsentDetailModel>(
        HiveStorage.consentDetailsBoxName);

    final bankBox = HiveStorage.bankAccountsBox;
    final consentBox = HiveStorage.consentDetailsBox;

    try {
      // ---- Load bank accounts from Hive into BankAccountModel list ----
      final accounts = bankBox.values
          .map(
            (item) => BankAccountModel(
              bankId: item.bankId,
              bankName: item.bankName,
              bankLogo: item.bankLogo,
              fipId: item.fipId,
              accountId: item.accountId,
              maskedAccNumber: item.maskedAccNumber,
              type: item.type,
              currentBalance: double.tryParse(item.currentBalance) ?? 0.0,
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
          )
          .toList();

      // ---- Load consent details into ConsentInfoModel list ----
      final consents = consentBox.values
          .map(
            (item) => ConsentInfoModel(
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
          )
          .toList();

      bankAccountLinkedList
        ..clear()
        ..addAll(accounts);
      consentAndHandleDetails
        ..clear()
        ..addAll(consents);

      accountId.value = bankAccountLinkedList.isNotEmpty
          ? bankAccountLinkedList.first.accountId
          : "";
      userController.selectedBank.value = accountId.value;
      isBankLinked.value = bankAccountLinkedList.isNotEmpty;
      bankInfoController.hasLoadedLocalData.value = true;
      bankInfoController.addBankApiCall(fetchFipInfo: false);
    } catch (e) {
      // ignore silently
    }
  }
}
