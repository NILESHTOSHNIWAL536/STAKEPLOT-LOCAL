class TransactionModel {
  final String id;
  final String type;
  final String mode;
  final double amount;
  final double currentBalance;
  final DateTime transactionTimestamp;
  final DateTime valueDate;
  final String? txnId;
  final String narration;
  final String reference;
  final String title;
  final bool manualTransaction;
   String category;
   String subcategory;
  final bool hidden;
  final bool isBill;
  final bool isDebt;
  final bool isSplit;
   bool? needsReview;
  final bool? isAutoPay;
  final String? autoPayId;
  final String? merchant;
  final String? expectedFrequency;
  final String? userId;
  final String? accountId;
  final String? bankId;
  final String? bankName;
  final String? bankLogo;
  final int? v;

  TransactionModel({
    required this.id,
    required this.type,
    required this.mode,
    required this.amount,
    required this.currentBalance,
    required this.transactionTimestamp,
    required this.valueDate,
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
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'];
    final accountId = json['accountId'] is Map ? json['accountId']['\$oid'] : json['accountId'];
    final userId = json['userId'] is Map ? json['userId']['\$oid'] : json['userId'];
    final ts = json['transactionTimestamp'] is Map ? json['transactionTimestamp']['\$date'] : json['transactionTimestamp'];
    final vd = json['valueDate'] is Map ? json['valueDate']['\$date'] : json['valueDate'];

    return TransactionModel(
      id: id,
      type: json['type'] ?? '',
      mode: json['mode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      transactionTimestamp: DateTime.parse(ts),
      valueDate: DateTime.parse(vd),
      txnId: json['txnId'],
      narration: json['narration'] ?? '',
      reference: json['reference'] ?? '',
      title: json['title'] ?? '',
      manualTransaction: json['manualTransaction'] ?? false,
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      hidden: json['Hidden'] ?? false,
      isBill: json['isBill'] ?? false,
      isDebt: json['isDebt'] ?? false,
      isSplit: json['isSplit'] ?? false,
      needsReview: json['needsReview'],
      isAutoPay: json['isAutoPay'],
      autoPayId: json['autoPayId'],
      merchant: json['merchant'],
      expectedFrequency: json['expectedFrequency'],
      userId: userId,
      accountId: accountId,
      bankId: json['bankId'],
      bankName: json['bankName'],
      bankLogo: json['bankLogo'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "type": type,
      "mode": mode,
      "amount": amount,
      "currentBalance": currentBalance,
      "transactionTimestamp": transactionTimestamp.toIso8601String(),
      "valueDate": valueDate.toIso8601String(),
      "txnId": txnId,
      "narration": narration,
      "reference": reference,
      "title": title,
      "manualTransaction": manualTransaction,
      "category": category,
      "subcategory": subcategory,
      "Hidden": hidden,
      "isBill": isBill,
      "isDebt": isDebt,
      "isSplit": isSplit,
      "needsReview": needsReview,
      "isAutoPay": isAutoPay,
      "autoPayId": autoPayId,
      "merchant": merchant,
      "expectedFrequency": expectedFrequency,
      "userId": userId,
      "accountId": accountId,
      "bankId": bankId,
      "bankName": bankName,
      "bankLogo": bankLogo,
      "__v": v,
    };
  }

  static List<TransactionModel> listFromJson(List<dynamic> jsonList)
  {
    return jsonList.map((json) => TransactionModel.fromJson(json)).toList();
  }

}
