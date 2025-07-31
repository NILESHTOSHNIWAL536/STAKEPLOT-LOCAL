import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/bank_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/user_apis.dart';
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
}

Future<void> init_user()async
{
   Hive.registerAdapter(UserModelAdapter());
   await Hive.openBox<UserModel>('userBox');
   loadUserFromHive();     
}


Future<void> init_banks()async
{
        Hive.registerAdapter(BankAccountModelAdapter());
        Hive.registerAdapter(ConsentDetailModelAdapter());
        await Hive.openBox<BankAccountModel>('bankAccountsBox');
        await Hive.openBox<ConsentDetailModel>('consentDetailsBox');
        loadBankDataFromHive();
}


