import 'package:hive/hive.dart';

part 'bank_account_model.g.dart';

@HiveType(typeId: 1)
class BankAccountModel extends HiveObject {
  @HiveField(0)
  String bankId;
  @HiveField(1)
  String bankName;
  @HiveField(2)
  String bankLogo;
  @HiveField(3)
  String fipId;
  @HiveField(4)
  String accountId;
  @HiveField(5)
  String maskedAccNumber;
  @HiveField(6)
  String type;
  @HiveField(7)
  String currentBalance;
  @HiveField(8)
  String lastFetch;
  @HiveField(9)
  String nextFetch;
  @HiveField(10)
  String fetchCount;
  @HiveField(11)
  String consentId;
  @HiveField(12)
  String consendHandleId;
  @HiveField(13)
  String sessionId;
  @HiveField(14)
  String custId;

  BankAccountModel({
    required this.bankId,
    required this.bankName,
    required this.bankLogo,
    required this.fipId,
    required this.accountId,
    required this.maskedAccNumber,
    required this.type,
    required this.currentBalance,
    required this.lastFetch,
    required this.nextFetch,
    required this.fetchCount,
    required this.consentId,
    required this.consendHandleId,
    required this.sessionId,
    required this.custId,
  });
}
