import 'package:hive/hive.dart';
part "transactions.g.dart";

@HiveType(typeId: 7) // change if already used
class Transactions {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String mode;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  double? balanceOut;

  @HiveField(5)
  final double currentBalance;

  @HiveField(6)
  final DateTime transactionTimestamp;

  @HiveField(7)
  final String? txnId;

  @HiveField(8)
  final String narration;

  @HiveField(9)
  final String reference;

  @HiveField(10)
  String title;

  @HiveField(11)
  final bool manualTransaction;

  @HiveField(12)
  String category;

  @HiveField(13)
  String subcategory;

  @HiveField(14)
  final bool hidden;

  @HiveField(15)
  final bool isBill;

  @HiveField(16)
  final bool isDebt;

  @HiveField(17)
  final bool isSplit;

  @HiveField(18)
  bool? isBalanceOut;

  @HiveField(19)
  bool? needsReview;

  @HiveField(20)
  final bool? isAutoPay;

  @HiveField(21)
  final String? autoPayId;

  @HiveField(22)
  final String? merchant;

  @HiveField(23)
  final String? expectedFrequency;

  @HiveField(24)
  final String? userId;

  @HiveField(25)
  final String? accountId;

  @HiveField(26)
  final String? bankId;

  @HiveField(27)
  final String? bankName;

  @HiveField(28)
  final String? bankLogo;

  @HiveField(29)
  final int? v;

  @HiveField(30)
  bool? isExcluded;

 

  Transactions({
    required this.id,
    required this.type,
    required this.mode,
    required this.amount,
    required this.currentBalance,
    required this.transactionTimestamp,
    this.txnId,
    required this.narration,
    required this.reference,
    required this.title,
    required this.manualTransaction,
    required this.category,
    required this.subcategory,
    required this.hidden,
    required this.isBill,
    required this.isDebt,
    required this.isSplit,
    this.needsReview,
    this.isAutoPay,
    this.autoPayId,
    this.merchant,
    this.expectedFrequency,
    this.userId,
    this.accountId,
    this.bankId,
    this.bankName,
    this.bankLogo,
    this.v,
    this.isBalanceOut,
    this.balanceOut,
    this.isExcluded,
  });
}
