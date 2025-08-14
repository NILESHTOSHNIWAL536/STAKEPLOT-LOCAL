import 'package:flutter_application_code_stakeplot/Hive_localstorage/card_swipe_data/card_insights_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora/chart_data_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora_prev_months/finora_last_two_months_model.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'package:hive/hive.dart';

import 'autopays_data/cards_data.dart';
import 'bank_bata/bank_account_model.dart';
import 'bank_bata/consent_detail_model.dart';
import 'fip_metric_bata/fips_metric.dart';
import 'post_data.dart/post_hive_storage.dart';
import 'transactions_data/transaction.dart';
import 'user-data/user_model.dart';

class HiveStorage {
  // Box names
  static const String fipsMetricBoxName = 'fipsMetricBox';
  static const String bankAccountsBoxName = 'bankAccountsBox';
  static const String consentDetailsBoxName = 'consentDetailsBox';
  static const String userBoxName = 'userBox';
  static const String transactionsBoxName = 'transactionsBox';
  static const String financeBoxName = 'financeBox';
  
  static const String categoryDataBoxName = 'categoryDataBoxName';
  static const String cardInsightsBoxName = 'cardInsightsBox';
  static const String finoraLastTwoMonthsBoxName = 'finoraLastTwoMonthsBox';
  static const String postBoxTrandingName = 'postBoxTranding';
  static const String postBoxFeedName = 'postBoxFeed';
  static const String savedPostName = 'savedPost';
  static const String insightsBoxName = 'insightsBox';
  static const String autoPayBoxName = 'cardsBox';

  /// ------------------ BOX GETTERS ------------------

  static Box<FipsMetrics> get fipsMetricBox =>
      Hive.box<FipsMetrics>(fipsMetricBoxName);

  static Box<BankAccountModel> get bankAccountsBox =>
      Hive.box<BankAccountModel>(bankAccountsBoxName);

  static Box<ConsentDetailModel> get consentDetailsBox =>
      Hive.box<ConsentDetailModel>(consentDetailsBoxName);

  static Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  static Box<Transactions> get transactionsBox => Hive.box<Transactions>(transactionsBoxName);
  static Box<FinanceModel> get financeBox => Hive.box<FinanceModel>(financeBoxName);
  static Box<ChartDataModel> get categoryBox => Hive.box<ChartDataModel>(categoryDataBoxName);
 
  static Box<CardInsightsModel> get cardInsightsBox => Hive.box<CardInsightsModel>(cardInsightsBoxName);
    static Box<FinoraLastTwoMonthsModel> get finoraLastTwoMonthsBox =>
      Hive.box<FinoraLastTwoMonthsModel>(finoraLastTwoMonthsBoxName);
  
  static Box<PostModels> get postBoxTranding => Hive.box<PostModels>(postBoxTrandingName);
  static Box<PostModels> get postBoxFeed => Hive.box<PostModels>(postBoxFeedName);
  static Box<PostModels> get savedPost => Hive.box<PostModels>(savedPostName);
  static Box<CardsData> get autoPays => Hive.box<CardsData>(autoPayBoxName);

  /// ------------------ COMMON HELPERS ------------------

  /// Check if any box is open
  static bool isBoxOpen(String name) => Hive.isBoxOpen(name);

  /// Close all boxes
  static Future<void> closeAllBoxes() async 
  {
    await Hive.deleteFromDisk();
  }
}
