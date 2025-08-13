import 'package:flutter_application_code_stakeplot/Hive_localstorage/card_swipe_data/card_insights_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora/chart_data_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora_prev_months/finora_last_two_months_model.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'package:hive/hive.dart';

import 'bank_bata/bank_account_model.dart';
import 'bank_bata/consent_detail_model.dart';
import 'fip_metric_bata/fips_metric.dart';
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
  static const String finoraBoxName = 'chartDataBox';
  static const String cardInsightsBoxName = 'cardInsightsBox';
  static const String finoraLastTwoMonthsBoxName = 'finoraLastTwoMonthsBox';

  /// ------------------ BOX GETTERS ------------------

  static Box<FipsMetrics> get fipsMetricBox => Hive.box<FipsMetrics>(fipsMetricBoxName);

  static Box<BankAccountModel> get bankAccountsBox => Hive.box<BankAccountModel>(bankAccountsBoxName);

  static Box<ConsentDetailModel> get consentDetailsBox => Hive.box<ConsentDetailModel>(consentDetailsBoxName);

  static Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  static Box<Transactions> get transactionsBox => Hive.box<Transactions>(transactionsBoxName);
  static Box<FinanceModel> get financeBox => Hive.box<FinanceModel>(financeBoxName);
  static Box<ChartDataModel> get finoraBox => Hive.box<ChartDataModel>(finoraBoxName);
  static Box<CardInsightsModel> get cardInsightsBox => Hive.box<CardInsightsModel>(cardInsightsBoxName);
    static Box<FinoraLastTwoMonthsModel> get finoraLastTwoMonthsBox =>
      Hive.box<FinoraLastTwoMonthsModel>(finoraLastTwoMonthsBoxName);
  

  /// ------------------ COMMON HELPERS ------------------

  /// Check if any box is open
  static bool isBoxOpen(String name) => Hive.isBoxOpen(name);

  /// Close all boxes
  static Future<void> closeAllBoxes() async
  {
    await Hive.deleteFromDisk();
  }
}
