import 'dart:async';

import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/bank_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finance_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_last_two_months_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/insights_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/post_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/user_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/card_swipe_data/card_insights_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora_prev_months/finora_last_two_months_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/insights_data/insights_model.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/transactions_data/transaction.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../autopays_data/cards_data.dart';
import '../bank_bata/bank_account_model.dart';
import '../bank_bata/consent_detail_model.dart';
import '../fip_metric_bata/fips_metric.dart';
import '../post_data.dart/post_hive_storage.dart';
import '../user-data/user_model.dart';
import 'autopays_apis.dart';
import 'finora_apis.dart';
import 'fipmetric_apis.dart';
import 'transactions_apis.dart';

Future<void> GetLocalStorage() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await init_user();
  await init_banks();
  await init_fips_metrics();
  await initCardsData();
  await init_Transactions();
  await init_finance();
  await initCardInsightsData(); // finora
  await initFinoraLastTwoMonthsData(); // finora last 2 months
  await init_insights();

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
  if (accountId.value.isNotEmpty) {
    await FinanceLocalStorage.loadFinanceFromHive(
        accountId.value, 'Month', getFormattedDate());
  }
}

Future<void> init_insights() async {
  // headsup
  Hive.registerAdapter(InsightsModelAdapter());

  await Hive.openBox<InsightsModel>('insightsBox');
  if (Hive.isBoxOpen('insightsBox')) {
    await InsightsLocalStorage.loadInsightsFromHive();
  } else {
  }
}

Future<void> initCardInsightsData() async {
  //finora
  Hive.registerAdapter(CardInsightsModelAdapter());
  await Hive.openBox<CardInsightsModel>(HiveStorage.cardInsightsBoxName);
  if (Hive.isBoxOpen(HiveStorage.cardInsightsBoxName)) {
    await CategoryStorage.loadCardInsightsDataFromHive();
  }
}

Future<void> initFinoraLastTwoMonthsData() async {
  Hive.registerAdapter(FinoraLastTwoMonthsModelAdapter());
  await Hive.openBox<FinoraLastTwoMonthsModel>(
      HiveStorage.finoraLastTwoMonthsBoxName);
  if (Hive.isBoxOpen(HiveStorage.finoraLastTwoMonthsBoxName)) {
    await FinoraLastTwoMonthsStorage.loadFinoraLastTwoMonthsDataFromHive();
  } else {
  }
}

   Future<void> init_post() async
  {
    Hive.registerAdapter(PostTypesAdapter());
    Hive.registerAdapter(PollOptionModelsAdapter());
    Hive.registerAdapter(PollModelsAdapter());
    Hive.registerAdapter(AuthorModelsAdapter());
    Hive.registerAdapter(BudgetModelsAdapter());
    Hive.registerAdapter(PostModelsAdapter());
    await Hive.openBox<PostModels>(HiveStorage.postBoxTrandingName);
    await Hive.openBox<PostModels>(HiveStorage.postBoxFeedName);
    await Hive.openBox<PostModels>(HiveStorage.savedPostName);
    if(HiveStorage.isBoxOpen(HiveStorage.postBoxTrandingName)) PostLocalStorage.loadPostsFromHive(isPostTranding: true);
    if(HiveStorage.isBoxOpen(HiveStorage.postBoxFeedName)) PostLocalStorage.loadPostsFromHive(isPostTranding: false);
    if(HiveStorage.isBoxOpen(HiveStorage.savedPostName)) PostLocalStorage.loadPostsFromHive(isPostTranding: true,isSavedPost: true);

  }


  Future<void> initCardsData() async
  {
    Hive.registerAdapter(CardsDataAdapter());
    await Hive.openBox<CardsData>(HiveStorage.autoPayBoxName);
    if (HiveStorage.isBoxOpen(HiveStorage.autoPayBoxName))
    CardsLocalStorage.loadCardsFromHive();
  }
