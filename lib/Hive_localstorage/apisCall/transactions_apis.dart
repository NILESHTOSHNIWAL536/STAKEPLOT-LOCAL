import 'package:flutter_application_code_stakeplot/Hive_localstorage/transactions_data/transaction.dart';
import '../../backed_connections/apis_connect.dart';
import '../../model/TransactionModel.dart';
import '../hive_storage.dart';

class TransactionStorage {

  /// Save current transactions to Hive
  static Future<void> cacheTransactionsLocally() async {
    try {
    final transactionBox = await HiveStorage.transactionsBox;
    await transactionBox.clear(); // Remove old data
      transactionsHistory.forEach((txn) {
        transactionBox.add(
          Transactions(
            id: txn.id,
            type: txn.type,
            mode: txn.mode,
            amount: txn.amount,
            balanceOut: txn.balanceOut,
            currentBalance: txn.currentBalance,
            reference: txn.reference,
            category: txn.category,
            isBill: txn.isBill,
            userId: txn.userId,
            hidden: txn.hidden,
            isDebt: txn.isDebt,
            accountId: txn.accountId,
            isSplit: txn.isSplit,
            bankId: txn.bankId,
            bankLogo: txn.bankLogo,
            manualTransaction: txn.manualTransaction,
            title: txn.title,
            narration: txn.narration,
            subcategory: txn.subcategory,
            bankName: txn.bankName,
            transactionTimestamp: txn.transactionTimestamp,
            autoPayId: txn.autoPayId,
            needsReview: txn.needsReview,
            txnId: txn.txnId,
            expectedFrequency: txn.expectedFrequency,
            isAutoPay: txn.isAutoPay,
            isBalanceOut: txn.isBalanceOut,
            isExcluded: txn.isExcluded,
            merchant: txn.merchant,
  
            // predictions: txn.predictions,
          ),
        );
      });
    } catch (e) {
   
    }
  }

  /// Load transactions from Hive into memory
  static Future<void> loadTransactionsFromHive() async {

    try {
      final transactionBox = await HiveStorage.transactionsBox;
      transactionsHistory.clear();
      // transactionBox.values.forEach((txn) {
      transactionBox.values.forEach((txn) {
        transactionsHistory.add(
          TransactionModel(
            id: txn.id,
            type: txn.type,
            mode: txn.mode,
            amount: txn.amount,
            balanceOut: txn.balanceOut,
            currentBalance: txn.currentBalance,
            reference: txn.reference,
            category: txn.category,
            isBill: txn.isBill,
            userId: txn.userId,
            hidden: txn.hidden,
            isDebt: txn.isDebt,
            accountId: txn.accountId,
            isSplit: txn.isSplit,
            bankId: txn.bankId,
            bankLogo: txn.bankLogo,
            manualTransaction: txn.manualTransaction,
            title: txn.title,
            narration: txn.narration,
            subcategory: txn.subcategory,
            bankName: txn.bankName,
            transactionTimestamp: txn.transactionTimestamp,
            autoPayId: txn.autoPayId,
            needsReview: txn.needsReview,
            txnId: txn.txnId,
            expectedFrequency: txn.expectedFrequency,
            isAutoPay: txn.isAutoPay,
            isBalanceOut: txn.isBalanceOut,
            isExcluded: txn.isExcluded,
            merchant: txn.merchant,
          ),
        );
      });
    } catch (e) {
    }
  }
}
