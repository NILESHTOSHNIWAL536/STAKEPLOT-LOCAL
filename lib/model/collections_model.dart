import 'TransactionModel.dart';

class BalanceModel {
  double amount;
  String type; // toPay / toReceive
  UserModel? user;

  BalanceModel({
    required this.amount,
    required this.type,
    this.user,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json, String type) {
    return BalanceModel(
      amount: (json['amount'] ?? 0).toDouble(),
      type: type,
      user: json['friend'] != null ? UserModel.fromJson(json['friend']) : null,
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
  double totalCredit;
  double totalDebit;
  double outStandingAmount;
  List<String> members;

  CollectionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerId,
    required this.description,
    required this.expiryAt,
    required this.status,
    required this.totalAmount,
    this.totalCredit = 0,
    this.totalDebit = 0,
    this.outStandingAmount = 0,
    required this.members,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json, objjson) {
    return CollectionModel(
      id: json['_id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      ownerId: json['ownerId'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      expiryAt:json['expiryAt'] != null ? DateTime.parse(json['expiryAt']) : null,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      totalCredit: (objjson['totalCredit'] ?? 0).toDouble(),
      totalDebit: (objjson['totalDebit'] ?? 0).toDouble(),
      outStandingAmount: (objjson['outStandingAmount'] ?? 0).toDouble(),
      members: (json['members'] as List? ?? []).cast<String>(),
    );
  }
}

class MemberModel {
  String id;
  String collectionId;
  String userId;
  String role;
  String name;
  String setAmount;
  String amountSpend;

  MemberModel({
    required this.id,
    required this.collectionId,
    required this.userId,
    required this.name,
    required this.role,
    required this.setAmount,
    required this.amountSpend,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'].toString(),
      collectionId: json['collectionId'].toString(),
      userId: json['userId'].toString(),
      name: json["user"]['name'].toString(),
      role: json['role'] ?? 'VIEW',
      setAmount: (json['limitAmount'] ?? '500.0').toString(),
      amountSpend: (json['amountSpent'] ?? '200.0').toString(),
    );
  }
}

class CollectionDetailsModel {
  CollectionModel collection;
  List<MemberModel> members;
  List<TransactionModel> transactions;
  // List<SplitModel> splits;

  CollectionDetailsModel({
    required this.collection,
    required this.members,
    required this.transactions,
    // required this.splits,
  });

  factory CollectionDetailsModel.fromJson(Map<String, dynamic> json) {
    print("👉 FULL JSON: $json");
    try {
      print("👉 FULL JSON: $json");

      print("👉 COLLECTION: ${json['collection']}");
      print("👉 MEMBERS: ${json['members']}");
      print("👉 TRANSACTIONS: ${json['transactions']}");

      return CollectionDetailsModel(
        collection: CollectionModel.fromJson(json['collection'] ?? {}, json),
        members: (json['members'] as List? ?? [])
            .map((e) => MemberModel.fromJson(e))
            .toList(),
        transactions: (json['transactions'] as List? ?? [])
            .map((e) => TransactionModel.fromJson(e["transactionId"] ?? {}))
            .toList(),
      );
    } catch (e, stack) {
      print("❌ ERROR INSIDE fromJson: $e");
      print(stack);
      rethrow;
    }
  }
}

// split_model.dart

class SplitModel {
  String id;
  String collectionId;
  String paidBy;
  String splitType;
  List<TransactionModel> transactionIds;
  List<SplitItemModel> splits;
  UserModel? paidByUser;
  DateTime? createdAt;
  DateTime? updatedAt;

  SplitModel({
    required this.id,
    required this.collectionId,
    required this.paidBy,
    required this.splitType,
    required this.transactionIds,
    required this.splits,
    this.paidByUser,
    this.createdAt,
    this.updatedAt,
  });

  factory SplitModel.fromJson(Map<String, dynamic> json) {
    return SplitModel(
      id: json['_id'] ?? '',
      collectionId: json['collectionId'] ?? '',
      paidBy: json['paidBy'] ?? '',
      splitType: json['splitType'] ?? '',
      transactionIds: (json['transactionIds'] as List? ?? [])
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
      splits: (json['splits'] as List? ?? [])
          .map((e) => SplitItemModel.fromJson(e))
          .toList(),
      paidByUser: json['paidByUser'] != null
          ? UserModel.fromJson(json['paidByUser'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

class SplitItemModel {
  String userId;
  double amount;
  UserModel? user;

  SplitItemModel({
    required this.userId,
    required this.amount,
    this.user,
  });

  factory SplitItemModel.fromJson(Map<String, dynamic> json) {
    return SplitItemModel(
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}

class UserModel {
  String id;
  String name;
  String email;
  String avatarType;
  String avatarBackGround;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarType,
    required this.avatarBackGround,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarType: json['avatarType'] ?? '',
      avatarBackGround: json['avatarBackGround'] ?? '',
    );
  }
}

class InvitationModel {
  String id;
  String invitedEmail;
  String role;
  String status;
  DateTime? expiresAt;
  DateTime? createdAt;

  CollectionModel? collection;
  UserModel? invitedBy;

  InvitationModel({
    required this.id,
    required this.invitedEmail,
    required this.role,
    required this.status,
    this.expiresAt,
    this.createdAt,
    this.collection,
    this.invitedBy,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['_id'] ?? '',
      invitedEmail: json['invitedEmail'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      collection: json['collection'] != null
          ? CollectionModel.fromJson(json['collection'], {})
          : null,
      invitedBy: json['invitedBy'] != null
          ? UserModel.fromJson(json['invitedBy'])
          : null,
    );
  }
}
