class BalanceModel {
  String userId;
  double balance;
  String type;

  BalanceModel({
    required this.userId,
    required this.balance,
    required this.type,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      userId: json['userId'],
      balance: (json['balance'] ?? 0).toDouble(),
      type: json['type'],
    );
  }
}

class SplitItemModel {
  String userId;
  double amount;

  SplitItemModel({
    required this.userId,
    required this.amount,
  });

  factory SplitItemModel.fromJson(Map<String, dynamic> json) {
    return SplitItemModel(
      userId: json['userId'],
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class SplitModel {
  String id;
  String collectionId;
  String paidBy;
  String splitType;
  List<String> transactionIds;
  List<SplitItemModel> splits;

  SplitModel({
    required this.id,
    required this.collectionId,
    required this.paidBy,
    required this.splitType,
    required this.transactionIds,
    required this.splits,
  });

  factory SplitModel.fromJson(Map<String, dynamic> json) {
    return SplitModel(
      id: json['_id'],
      collectionId: json['collectionId'],
      paidBy: json['paidBy'],
      splitType: json['splitType'],
      transactionIds: List<String>.from(json['transactionIds'] ?? []),
      splits: (json['splits'] as List? ?? [])
          .map((e) => SplitItemModel.fromJson(e))
          .toList(),
    );
  }
}

class CollectionTransactionModel {
  String id;
  String transactionId;
  double amount;

  CollectionTransactionModel({
    required this.id,
    required this.transactionId,
    required this.amount,
  });

  factory CollectionTransactionModel.fromJson(Map<String, dynamic> json) {
    return CollectionTransactionModel(
      id: json['_id'],
      transactionId: json['transactionId'],
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class CollectionMemberModel {
  String userId;
  String role;

  CollectionMemberModel({
    required this.userId,
    required this.role,
  });

  factory CollectionMemberModel.fromJson(Map<String, dynamic> json) {
    return CollectionMemberModel(
      userId: json['userId'],
      role: json['role'] ?? 'VIEW',
    );
  }
}

class CollectionModel {
  String id;
  String name;
  String type;
  String ownerId;
  String description;
  String status;
  DateTime? expiryAt;
  double totalAmount;

  CollectionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerId,
    required this.description,
    required this.expiryAt,
    required this.status,
    required this.totalAmount,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['_id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      ownerId: json['ownerId'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      expiryAt:
          json['expiryAt'] != null ? DateTime.parse(json['expiryAt']) : null,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class MemberModel {
  String id;
  String collectionId;
  String userId;
  String role;
  String name;

  MemberModel({
    required this.id,
    required this.collectionId,
    required this.userId,
    required this.name,
    required this.role,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'].toString(),
      collectionId: json['collectionId'].toString(),
      userId: json['userId'].toString(),
      name: json['name'].toString(),
      role: json['role'] ?? 'VIEW',
    );
  }
}

class CollectionDetailsModel {
  CollectionModel collection;
  List<MemberModel> members;
  List<CollectionTransactionModel> transactions;
  List<SplitModel> splits;

  CollectionDetailsModel({
    required this.collection,
    required this.members,
    required this.transactions,
    required this.splits,
  });

  factory CollectionDetailsModel.fromJson(Map<String, dynamic> json) {
    return CollectionDetailsModel(
      // ✅ COLLECTION
      collection: CollectionModel.fromJson(json['collection'] ?? {}),

      // ✅ MEMBERS
      members: (json['members'] as List? ?? [])
          .map((e) => MemberModel.fromJson(e))
          .toList(),

      // ✅ TRANSACTIONS
      transactions: (json['transactions'] as List? ?? [])
          .map((e) => CollectionTransactionModel.fromJson(e))
          .toList(),

      // ✅ SPLITS
      splits: (json['splits'] as List? ?? [])
          .map((e) => SplitModel.fromJson(e))
          .toList(),
    );
  }
}
