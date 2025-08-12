import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
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

  /// ------------------ BOX GETTERS ------------------

  static Box<FipsMetrics> get fipsMetricBox => Hive.box<FipsMetrics>(fipsMetricBoxName);

  static Box<BankAccountModel> get bankAccountsBox => Hive.box<BankAccountModel>(bankAccountsBoxName);

  static Box<ConsentDetailModel> get consentDetailsBox => Hive.box<ConsentDetailModel>(consentDetailsBoxName);

  static Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  static Box<Transactions> get transactionsBox => Hive.box<Transactions>(transactionsBoxName);

  /// ------------------ COMMON HELPERS ------------------

  /// Check if any box is open
  static bool isBoxOpen(String name) => Hive.isBoxOpen(name);

  /// Close all boxes
  static Future<void> closeAllBoxes() async
  {
    await Hive.deleteFromDisk();
  }
}
