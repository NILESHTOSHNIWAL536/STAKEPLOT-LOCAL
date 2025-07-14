// class TransactionModel {
//   final String id;
//   final String type;
//   final String mode;
//   final double amount;
//   double? balanceOut;
//   final double currentBalance;
//   final DateTime transactionTimestamp;
//   final String? txnId;
//   final String narration;
//   final String reference;
//   String title;
//   final bool manualTransaction;
//   String category;
//   String subcategory;
//   final bool hidden;
//   final bool isBill;
//   final bool isDebt;
//   final bool isSplit;
//    bool? isBalanceOut;
//   bool? needsReview;
//   final bool? isAutoPay;
//   final String? autoPayId;
//   final String? merchant;
//   final String? expectedFrequency;
//   final String? userId;
//   final String? accountId;
//   final String? bankId;
//   final String? bankName;
//   final String? bankLogo;
//   final int? v;
//    bool? isExcluded;
//   TransactionModel({
//     required this.id,
//     required this.type,
//     required this.mode,
//     required this.amount,
//     required this.currentBalance,
//     required this.transactionTimestamp,
//     this.txnId,
//     required this.narration,
//     required this.reference,
//     required this.title,
//     required this.manualTransaction,
//     required this.category,
//     required this.subcategory,
//     required this.hidden,
//     required this.isBill,
//     required this.isDebt,
//     required this.isSplit,
//     this.needsReview,
//     this.isAutoPay,
//     this.autoPayId,
//     this.merchant,
//     this.expectedFrequency,
//     this.userId,
//     this.accountId,
//     this.bankId,
//     this.bankName,
//     this.bankLogo,
//     this.v,
//     this.isBalanceOut,
//     this.balanceOut,
//     this.isExcluded,
//   });
//   factory TransactionModel.fromJson(Map<String, dynamic> json) {
//     final id = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'];
//     final accountId = json['accountId'] is Map ? json['accountId']['\$oid'] : json['accountId'];
//     final userId = json['userId'] is Map ? json['userId']['\$oid'] : json['userId'];
//     final ts = json['transactionTimestamp'] is Map ? json['transactionTimestamp']['\$date'] : json['transactionTimestamp'];

//     return TransactionModel(
//       id: id,
//       type: json['type'] ?? '',
//       mode: json['mode'] ?? '',
//       amount: (json['amount'] ?? 0).toDouble(),
//       currentBalance: (json['currentBalance'] ?? 0).toDouble(),
//       transactionTimestamp: DateTime.parse(ts),
//       txnId: json['txnId'] ?? '',
//       narration: json['narration'] ?? '',
//       reference: json['reference'] ?? '',
//       title: json['title'] ?? '',
//       manualTransaction: json['manualTransaction'] ?? false,
//       category: json['category'] ?? '',
//       subcategory: json['subcategory'] ?? '',
//       hidden: json['Hidden'] ?? false,
//       isBill: json['isBill'] ?? false,
//       isDebt: json['isDebt'] ?? false,
//       isSplit: json['isSplit'] ?? false,
//       needsReview: json['needsReview'] ?? '',
//       isAutoPay: json['isAutoPay'] ?? '',
//       autoPayId: json['autoPayId'] ?? '',
//       merchant: json['merchant'] ?? '',
//       expectedFrequency: json['expectedFrequency']?? '',
//       userId: userId,
//       accountId: accountId,
//       bankId: json['bankId'] ?? '',
//       bankName: json['bankName'] ?? '',
//       bankLogo: json['bankLogo'] ?? '',
//       v: json['__v'],
//       isBalanceOut: json['isBalanceOut'] ?? false,
//        balanceOut:( ((json['isBalanceOut'] ?? false) && json['balanceOut'].toString() != '' ) ?json['balanceOut'] ?? 0.0:0.0).toDouble() ,
//       isExcluded: json['isExcluded']
//     );
//   }

  
//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "type": type,
//       "mode": mode,
//       "amount": amount,
//       "currentBalance": currentBalance,
//       "transactionTimestamp": transactionTimestamp.toIso8601String(),
//       "txnId": txnId,
//       "narration": narration,
//       "reference": reference,
//       "title": title,
//       "manualTransaction": manualTransaction,
//       "category": category,
//       "subcategory": subcategory,
//       "Hidden": hidden,
//       "isBill": isBill,
//       "isDebt": isDebt,
//       "isSplit": isSplit,
//       "needsReview": needsReview,
//       "isAutoPay": isAutoPay,
//       "autoPayId": autoPayId,
//       "merchant": merchant,
//       "expectedFrequency": expectedFrequency,
//       "userId": userId,
//       "accountId": accountId,
//       "bankId": bankId,
//       "bankName": bankName,
//       "bankLogo": bankLogo,
//       "balanceOut": bankLogo,
//       "isBalanceOut": isBalanceOut,
//       "__v": v,
//       "isExcluded":isExcluded
//     };
//   }

//   static List<TransactionModel> listFromJson(List<dynamic> jsonList)
//   {
//     // return jsonList.map((json) => TransactionModel.fromJson(json)).toList();

//   return jsonList
//       .map((json) {
//         try {
//           if (json == null) return null;
//           return TransactionModel.fromJson(json);
//         } catch (e) {
//           print(e);
//           print('Invalid TransactionModel object ignored: $json');
//           return null;
//         }
//       })
//       .whereType<TransactionModel>() // removes nulls
//       .toList();
//   }

//   @override
//   String toString() {
//     return 'TransactionModel(id: $id, type: $type, amount: $amount, narration: $narration, bankName: $bankName, )';
//   }
// }


class Predictions {
  final String? top1Category;
  final double? top1Score;
  final String? top2Category;
  final double? top2Score;
  final String? top3Category;
  final double? top3Score;
  final String? top4Category;
  final double? top4Score;
  final String? top5Category;
  final double? top5Score;

  Predictions({
    this.top1Category,
    this.top1Score,
    this.top2Category,
    this.top2Score,
    this.top3Category,
    this.top3Score,
    this.top4Category,
    this.top4Score,
    this.top5Category,
    this.top5Score,
  });

  factory Predictions.fromJson(Map<String, dynamic> json) {
    return Predictions(
      top1Category: json['top1_category'] as String?,
      top1Score: (json['top1_score'] as num?)?.toDouble(),
      top2Category: json['top2_category'] as String?,
      top2Score: (json['top2_score'] as num?)?.toDouble(),
      top3Category: json['top3_category'] as String?,
      top3Score: (json['top3_score'] as num?)?.toDouble(),
      top4Category: json['top4_category'] as String?,
      top4Score: (json['top4_score'] as num?)?.toDouble(),
      top5Category: json['top5_category'] as String?,
      top5Score: (json['top5_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top1_category': top1Category,
      'top1_score': top1Score,
      'top2_category': top2Category,
      'top2_score': top2Score,
      'top3_category': top3Category,
      'top3_score': top3Score,
      'top4_category': top4Category,
      'top4_score': top4Score,
      'top5_category': top5Category,
      'top5_score': top5Score,
    };
  }
}

class TransactionModel {
  final String id;
  final String type;
  final String mode;
  final double amount;
  double? balanceOut;
  final double currentBalance;
  final DateTime transactionTimestamp;
  final String? txnId;
  final String narration;
  final String reference;
  String title;
  final bool manualTransaction;
  String category;
  String subcategory;
  final bool hidden;
  final bool isBill;
  final bool isDebt;
  final bool isSplit;
  bool? isBalanceOut;
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
  bool? isExcluded;
  final Predictions? predictions; // Added predictions field

  TransactionModel({
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
    this.predictions, // Initialize predictions
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'];
    final accountId = json['accountId'] is Map ? json['accountId']['\$oid'] : json['accountId'];
    final userId = json['userId'] is Map ? json['userId']['\$oid'] : json['userId'];
    final ts = json['transactionTimestamp'] is Map ? json['transactionTimestamp']['\$date'] : json['transactionTimestamp'];

    return TransactionModel(
      id: id,
      type: json['type'] ?? '',
      mode: json['mode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      transactionTimestamp: DateTime.parse(ts),
      txnId: json['txnId'] ?? '',
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
      needsReview: json['needsReview'] ?? false,
      isAutoPay: json['isAutoPay'] ?? false,
      autoPayId: json['autoPayId'] ?? '',
      merchant: json['merchant'] ?? '',
      expectedFrequency: json['expectedFrequency'] ?? '',
      userId: userId,
      accountId: accountId,
      bankId: json['bankId'] ?? '',
      bankName: json['bankName'] ?? '',
      bankLogo: json['bankLogo'] ?? '',
      v: json['__v'],
      isBalanceOut: json['isBalanceOut'] ?? false,
      balanceOut: ((json['isBalanceOut'] ?? false) && json['balanceOut'].toString() != '')
          ? (json['balanceOut'] ?? 0.0).toDouble()
          : 0.0,
      isExcluded: json['isExcluded'] ?? false,
      predictions: json['predictions'] != null ? Predictions.fromJson(json['predictions']) : null, // Parse predictions
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
      "balanceOut": balanceOut,
      "isBalanceOut": isBalanceOut,
      "__v": v,
      "isExcluded": isExcluded,
      "predictions": predictions?.toJson(), // Serialize predictions
    };
  }
TransactionModel copyWith({
    String? id,
    String? type,
    String? mode,
    double? amount,
    double? balanceOut,
    double? currentBalance,
    DateTime? transactionTimestamp,
    String? txnId,
    String? narration,
    String? reference,
    String? title,
    bool? manualTransaction,
    String? category,
    String? subcategory,
    bool? hidden,
    bool? isBill,
    bool? isDebt,
    bool? isSplit,
    bool? isBalanceOut,
    bool? needsReview,
    bool? isAutoPay,
    String? autoPayId,
    String? merchant,
    String? expectedFrequency,
    String? userId,
    String? accountId,
    String? bankId,
    String? bankName,
    String? bankLogo,
    int? v,
    bool? isExcluded,
    Predictions? predictions,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      mode: mode ?? this.mode,
      amount: amount ?? this.amount,
      balanceOut: balanceOut ?? this.balanceOut,
      currentBalance: currentBalance ?? this.currentBalance,
      transactionTimestamp: transactionTimestamp ?? this.transactionTimestamp,
      txnId: txnId ?? this.txnId,
      narration: narration ?? this.narration,
      reference: reference ?? this.reference,
      title: title ?? this.title,
      manualTransaction: manualTransaction ?? this.manualTransaction,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      hidden: hidden ?? this.hidden,
      isBill: isBill ?? this.isBill,
      isDebt: isDebt ?? this.isDebt,
      isSplit: isSplit ?? this.isSplit,
      isBalanceOut: isBalanceOut ?? this.isBalanceOut,
      needsReview: needsReview ?? this.needsReview,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      autoPayId: autoPayId ?? this.autoPayId,
      merchant: merchant ?? this.merchant,
      expectedFrequency: expectedFrequency ?? this.expectedFrequency,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      bankId: bankId ?? this.bankId,
      bankName: bankName ?? this.bankName,
      bankLogo: bankLogo ?? this.bankLogo,
      v: v ?? this.v,
      isExcluded: isExcluded ?? this.isExcluded,
      predictions: predictions ?? this.predictions,
    );
  }

 
  static List<TransactionModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) {
          try {
            if (json == null) return null;
            return TransactionModel.fromJson(json);
          } catch (e) {
            print('Error parsing TransactionModel: $e');
            print('Invalid JSON: $json');
            return null;
          }
        })
        .whereType<TransactionModel>()
        .toList();
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, amount: $amount, narration: $narration, bankName: $bankName, predictions: $predictions)';
  }
}