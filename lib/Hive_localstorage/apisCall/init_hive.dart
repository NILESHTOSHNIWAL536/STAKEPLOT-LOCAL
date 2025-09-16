import 'dart:async';
import 'package:flutter/material.dart';
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

part 'hive_helper.dart';

/// ---------------------------------------------------------
/// Main Hive Init Entry Point
/// ---------------------------------------------------------
Future<void> initAllHive() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await init_user();
  await init_banks();
  await init_fips_metrics();
  await initCardsData();
  await init_Transactions();
  await init_finance();
  await init_post();
  await initCardInsightsData();
  await initFinoraLastTwoMonthsData();
  await init_insights();
}

Future<void> init_user() async {
  await HiveHelper.initHiveBox<UserModel>(
    adapter: UserModelAdapter(),
    boxName: HiveStorage.userBoxName,
    onLoaded: () => UserLocalStorage.loadUserFromHive(),
  );
}

Future<void> init_banks() async {
  await HiveHelper.initHiveBox<BankAccountModel>(
    adapter: BankAccountModelAdapter(),
    boxName: HiveStorage.bankAccountsBoxName,
  );

  await HiveHelper.initHiveBox<ConsentDetailModel>(
    adapter: ConsentDetailModelAdapter(),
    boxName: HiveStorage.consentDetailsBoxName,
    onLoaded: () => BankStorage.loadBankDataFromHive(),
  );
}

Future<void> init_fips_metrics() async {
  await HiveHelper.initHiveBox<FipsMetrics>(
    adapter: FipsMetricsAdapter(),
    boxName: HiveStorage.fipsMetricBoxName,
    onLoaded: () => FipsMetricLocalStorage.loadFipsMetricsFromHive(),
  );
}

Future<void> init_Transactions() async {
  await HiveHelper.initHiveBox<Transactions>(
    adapter: TransactionsAdapter(),
    boxName: HiveStorage.transactionsBoxName,
    onLoaded: () => TransactionStorage.loadTransactionsFromHive(),
  );
}

Future<void> init_finance() async {
  await HiveHelper.initHiveBox<FinanceModel>(
    adapter: FinanceModelAdapter(),
    boxName: HiveStorage.financeBoxName,
    onLoaded: () async {
      if (accountId.value.isNotEmpty) {
        await FinanceLocalStorage.loadFinanceFromHive(
          accountId.value,
          'Month',
          getFormattedDate(),
        );
         getGraphData.value = true;
      }
    },
  );
}

Future<void> init_insights() async {
  await HiveHelper.initHiveBox<InsightsModel>(
    adapter: InsightsModelAdapter(),
    boxName: 'insightsBox',
    onLoaded: () => InsightsLocalStorage.loadInsightsFromHive(),
  );
}

Future<void> initCardInsightsData() async {
  await HiveHelper.initHiveBox<CardInsightsModel>(
    adapter: CardInsightsModelAdapter(),
    boxName: HiveStorage.cardInsightsBoxName,
    onLoaded: () => CategoryStorage.loadCardInsightsDataFromHive(),
  );
}

Future<void> initFinoraLastTwoMonthsData() async {
  await HiveHelper.initHiveBox<FinoraLastTwoMonthsModel>(
    adapter: FinoraLastTwoMonthsModelAdapter(),
    boxName: HiveStorage.finoraLastTwoMonthsBoxName,
    onLoaded: () => FinoraLastTwoMonthsStorage.loadFinoraLastTwoMonthsDataFromHive(),
  );
}

Future<void> initCardsData() async {
  await HiveHelper.initHiveBox<CardsData>(
    adapter: CardsDataAdapter(),
    boxName: HiveStorage.autoPayBoxName,
    onLoaded: () => CardsLocalStorage.loadCardsFromHive(),
  );
}
  
Future<void> init_post() async {
  try {
    // Register all post-related adapters
     HiveHelper.registerAdapterSafe(PostTypesAdapter());
     HiveHelper.registerAdapterSafe(PollOptionModelsAdapter());
     HiveHelper.registerAdapterSafe(PollModelsAdapter());
     HiveHelper.registerAdapterSafe(AuthorModelsAdapter());
     HiveHelper.registerAdapterSafe(BudgetModelsAdapter());
     HiveHelper.registerAdapterSafe(PostModelsAdapter());

    // Open + Load Trending
    await HiveHelper.initHiveBox<PostModels>(
      adapter: PostModelsAdapter(),
      boxName: HiveStorage.postBoxTrandingName,
      onLoaded: () => PostLocalStorage.loadPostsFromHive(isPostTranding: true),
    );

    // Open + Load Feed
    await HiveHelper.initHiveBox<PostModels>(
      adapter: PostModelsAdapter(),
      boxName: HiveStorage.postBoxFeedName,
      onLoaded: () => PostLocalStorage.loadPostsFromHive(isPostTranding: false),
    );

    await HiveHelper.initHiveBox<PostModels>(
      adapter: PostModelsAdapter(),
      boxName: HiveStorage.userPostName,
      onLoaded: () => PostLocalStorage.loadPostsFromHive(isPostTranding: false,isUserPost: true),
    );

    // Open + Load Saved
    await HiveHelper.initHiveBox<PostModels>(
      adapter: PostModelsAdapter(),
      boxName: HiveStorage.savedPostName,
      onLoaded: () =>
          PostLocalStorage.loadPostsFromHive(isPostTranding: true, isSavedPost: true),
    );
  } catch (e)
  {
  }
}



