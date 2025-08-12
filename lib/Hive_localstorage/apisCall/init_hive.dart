import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/bank_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finance_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/user_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../bank_bata/bank_account_model.dart';
import '../bank_bata/consent_detail_model.dart';
import '../user-data/user_model.dart';

Future<void> GetLocalStorage()async
{
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
        await init_user();
        await init_banks();
        await init_finance();
}

Future<void> init_user()async
{
   Hive.registerAdapter(UserModelAdapter());
   await Hive.openBox<UserModel>('userBox');
  UserLocalStorage.loadUserFromHive();     
}


Future<void> init_banks()async
{
        Hive.registerAdapter(BankAccountModelAdapter());
        Hive.registerAdapter(ConsentDetailModelAdapter());
        await Hive.openBox<BankAccountModel>('bankAccountsBox');
        await Hive.openBox<ConsentDetailModel>('consentDetailsBox');
        BankStorage.loadBankDataFromHive();
}
Future<void> init_finance()async
{
        Hive.registerAdapter(FinanceModelAdapter());
       
        await Hive.openBox<FinanceModel>('financeBox');
       if (accountId.value.isNotEmpty) {
    await FinanceLocalStorage.loadFinanceFromHive(accountId.value, 'Month', getFormattedDate());
  } else {
    print('Skipping finance data load: accountId is empty');
  }
        // BankStorage.loadBankDataFromHive();
}
