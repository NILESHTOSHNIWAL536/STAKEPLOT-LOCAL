import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/bank_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finance_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/user_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/insights_data/insights_model.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/transactions_data/transaction.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../bank_bata/bank_account_model.dart';
import '../bank_bata/consent_detail_model.dart';
import '../fip_metric_bata/fips_metric.dart';
import '../user-data/user_model.dart';
import 'fipmetric_apis.dart';
import 'transactions_apis.dart';

Future<void> GetLocalStorage()async
{
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
        await init_user();
        await init_banks();
        await init_fips_metrics();
        await init_Transactions();
        await init_finance();
        await init_insights();
}

Future<void> init_user() async {
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>(HiveStorage.userBoxName);
  if (HiveStorage.isBoxOpen(HiveStorage.userBoxName))
    UserLocalStorage.loadUserFromHive();
}


Future<void> init_banks()async
{
        Hive.registerAdapter(BankAccountModelAdapter());
        Hive.registerAdapter(ConsentDetailModelAdapter());
        await Hive.openBox<BankAccountModel>(HiveStorage.bankAccountsBoxName);
        await Hive.openBox<ConsentDetailModel>(HiveStorage.consentDetailsBoxName);
        if(HiveStorage.isBoxOpen(HiveStorage.consentDetailsBoxName))BankStorage.loadBankDataFromHive();
}

Future<void> init_fips_metrics() async {
  Hive.registerAdapter(FipsMetricsAdapter());
  await Hive.openBox<FipsMetrics>(HiveStorage.fipsMetricBoxName);
  if (HiveStorage.isBoxOpen(HiveStorage.fipsMetricBoxName))
    FipsMetricLocalStorage.loadFipsMetricsFromHive();
}

Future<void> init_Transactions() async
{
  Hive.registerAdapter(TransactionsAdapter());
  await Hive.openBox<Transactions>(HiveStorage.transactionsBoxName);
  if(HiveStorage.isBoxOpen(HiveStorage.transactionsBoxName)) TransactionStorage.loadTransactionsFromHive();
}

Future<void> init_finance() async {
  Hive.registerAdapter(FinanceModelAdapter());
  await Hive.openBox<FinanceModel>('financeBox');
  if (accountId.value.isNotEmpty) {
    await FinanceLocalStorage.loadFinanceFromHive(
        accountId.value, 'Month', getFormattedDate());
  } else {
    print('Skipping finance data load: accountId is empty');
  }
  // BankStorage.loadBankDataFromHive();
}

Future<void> init_insights() async {
 
    print('Starting init_insights');
    Hive.registerAdapter(InsightsModelAdapter());
    print('InsightsModelAdapter registered');
    await Hive.openBox<InsightsModel>('insightsBox');
    print('insightsBox opened');
    if (Hive.isBoxOpen('insightsBox')) {
      print('insightsBox is open, loading data');
     await InsightsLocalStorage.loadInsightsFromHive();
    
    } else {
      print('insightsBox is not open');
    }

}
