import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/bank_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finance_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_last_two_months_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/insights_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/post_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/user_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/card_swipe_data/card_insights_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora/chart_data_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora_prev_months/finora_last_two_months_model.dart';
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
import '../post_data.dart/post_hive_storage.dart';
import '../user-data/user_model.dart';
import 'fipmetric_apis.dart';
import 'transactions_apis.dart';

Future<void> GetLocalStorage() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await init_user();
  await init_banks();
  await init_fips_metrics();
  await init_Transactions();
  await init_finance();
  await init_insights();
  await initChartData();
  await initCardInsightsData();
  await initFinoraLastTwoMonthsData();
    await init_post();
}

Future<void> init_user() async {
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>(HiveStorage.userBoxName);
  if (HiveStorage.isBoxOpen(HiveStorage.userBoxName))
    UserLocalStorage.loadUserFromHive();
}

Future<void> init_banks() async {
  Hive.registerAdapter(BankAccountModelAdapter());
  Hive.registerAdapter(ConsentDetailModelAdapter());
  await Hive.openBox<BankAccountModel>(HiveStorage.bankAccountsBoxName);
  await Hive.openBox<ConsentDetailModel>(HiveStorage.consentDetailsBoxName);
  if (HiveStorage.isBoxOpen(HiveStorage.consentDetailsBoxName))
    BankStorage.loadBankDataFromHive();
}

Future<void> init_fips_metrics() async {
  Hive.registerAdapter(FipsMetricsAdapter());
  await Hive.openBox<FipsMetrics>(HiveStorage.fipsMetricBoxName);
  if (HiveStorage.isBoxOpen(HiveStorage.fipsMetricBoxName))
    FipsMetricLocalStorage.loadFipsMetricsFromHive();
}

Future<void> init_Transactions() async {
  Hive.registerAdapter(TransactionsAdapter());
  await Hive.openBox<Transactions>(HiveStorage.transactionsBoxName);
  if (HiveStorage.isBoxOpen(HiveStorage.transactionsBoxName))
    TransactionStorage.loadTransactionsFromHive();
}

Future<void> init_finance() async {
  Hive.registerAdapter(FinanceModelAdapter());
  await Hive.openBox<FinanceModel>(HiveStorage.financeBoxName);
  if (accountId.value.isNotEmpty){
    await FinanceLocalStorage.loadFinanceFromHive(accountId.value, 'Month', getFormattedDate());
  }
}

Future<void> init_insights() async {
  Hive.registerAdapter(InsightsModelAdapter());

  await Hive.openBox<InsightsModel>('insightsBox');
  print('insightsBox opened');
  if (Hive.isBoxOpen('insightsBox')) {
    print('insightsBox is open, loading data');
    await InsightsLocalStorage.loadInsightsFromHive();
  } else {
    print('insightsBox is not open');
  }
}

Future<void> initChartData() async {
  Hive.registerAdapter(ChartDataModelAdapter());
  await Hive.openBox<ChartDataModel>(HiveStorage.finoraBoxName);
  if (Hive.isBoxOpen(HiveStorage.finoraBoxName)) {
    await CategoryStorage.loadChartDataFromHive();
  }
}

Future<void> initCardInsightsData() async {
  Hive.registerAdapter(CardInsightsModelAdapter());
  await Hive.openBox<CardInsightsModel>(HiveStorage.cardInsightsBoxName);
  if (Hive.isBoxOpen(HiveStorage.cardInsightsBoxName)) {
    await CategoryStorage.loadCardInsightsDataFromHive();
  } else {}
}

Future<void> initFinoraLastTwoMonthsData() async {
  print('Starting initFinoraLastTwoMonthsData');
  Hive.registerAdapter(FinoraLastTwoMonthsModelAdapter());
  await Hive.openBox<FinoraLastTwoMonthsModel>(
      HiveStorage.finoraLastTwoMonthsBoxName);
  print('finoraLastTwoMonthsBox opened');
  if (Hive.isBoxOpen(HiveStorage.finoraLastTwoMonthsBoxName)) {
    print('finoraLastTwoMonthsBox is open, loading data');
    await FinoraLastTwoMonthsStorage.loadFinoraLastTwoMonthsDataFromHive();
  } else {
    print('finoraLastTwoMonthsBox is not open');
  }
}

   Future<void> init_post() async
  {
    Hive.registerAdapter(PostTypeAdapter());
    Hive.registerAdapter(PollOptionModelAdapter());
    Hive.registerAdapter(PollModelAdapter());
    Hive.registerAdapter(AuthorModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(PostModelAdapter());
    await Hive.openBox<PostModels>(HiveStorage.postBoxTrandingName);
    await Hive.openBox<PostModels>(HiveStorage.postBoxFeedName);
    await Hive.openBox<PostModels>(HiveStorage.savedPostName);
    if(HiveStorage.isBoxOpen(HiveStorage.postBoxTrandingName)) PostLocalStorage.loadPostsFromHive(isPostTranding: true);
    if(HiveStorage.isBoxOpen(HiveStorage.postBoxFeedName)) PostLocalStorage.loadPostsFromHive(isPostTranding: false);
    if(HiveStorage.isBoxOpen(HiveStorage.savedPostName)) PostLocalStorage.loadPostsFromHive(isPostTranding: true,isSavedPost: true);

  }