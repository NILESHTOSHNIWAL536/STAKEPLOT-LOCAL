import 'package:intl/intl.dart';

class UserActivity {
  final String id;
  final String userId;
  final int score;
  final int unclaimedCount;
  final List<String> transactionIdList;
  final List<DailyTransaction> dailyTransaction;
  final List<DailyTag> dailyTags;
  final List<DailyBillClear> dailyBillClears;
  final List<String> pendingPosts;
  final List<DailyClaimCount> dailyClaimCount;
  final String lastActivityDate;

  UserActivity({
    required this.id,
    required this.userId,
    required this.score,
    required this.unclaimedCount,
    required this.transactionIdList,
    required this.dailyTransaction,
    required this.dailyTags,
    required this.dailyBillClears,
    required this.pendingPosts,
    required this.dailyClaimCount,
    required this.lastActivityDate,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      score: json['score'] ?? 0,
      unclaimedCount: json['unclaimedCount'] ?? 0,
      transactionIdList: List<String>.from(json['transactionIdList'] ?? []),
      dailyTransaction: (json['dailyTransaction'] as List<dynamic>?)
              ?.map((e) => DailyTransaction.fromJson(e))
              .toList() ??
          [],
      dailyTags: (json['dailyTags'] as List<dynamic>?)
              ?.map((e) => DailyTag.fromJson(e))
              .toList() ??
          [],
      dailyBillClears: (json['dailyBillClears'] as List<dynamic>?)
              ?.map((e) => DailyBillClear.fromJson(e))
              .toList() ??
          [],
      pendingPosts: List<String>.from(json['pendingPosts'] ?? []),
      dailyClaimCount: (json['dailyClaimCount'] as List<dynamic>?)
              ?.map((e) => DailyClaimCount.fromJson(e))
              .toList() ??
          [],
      lastActivityDate: json['lastActivityDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'score': score,
      'unclaimedCount': unclaimedCount,
      'transactionIdList': transactionIdList,
      'dailyTransaction': dailyTransaction.map((e) => e.toJson()).toList(),
      'dailyTags': dailyTags.map((e) => e.toJson()).toList(),
      'dailyBillClears': dailyBillClears.map((e) => e.toJson()).toList(),
      'pendingPosts': pendingPosts,
      'dailyClaimCount': dailyClaimCount.map((e) => e.toJson()).toList(),
      'lastActivityDate': lastActivityDate,
    };
  }

  /// ✅ Get today's transaction count (if exists)
  DailyTransaction? get todaysTransaction {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return dailyTransaction.firstWhere(
      (e) => e.date == today,
      orElse: () => DailyTransaction.empty(),
    );
  }

  /// ✅ Get today's claim count (if exists)
  DailyClaimCount? get todaysClaimCount {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return dailyClaimCount.firstWhere(
      (e) => e.date == today,
      orElse: () => DailyClaimCount.empty(),
    );
  }
}

class DailyTransaction {
  final String date;
  final int count;
  final String id;
  final String expiresAt;

  DailyTransaction({
    required this.date,
    required this.count,
    required this.id,
    required this.expiresAt,
  });

  factory DailyTransaction.fromJson(Map<String, dynamic> json) {
    return DailyTransaction(
      date: json['date'] as String,
      count: json['count'] ?? 0,
      id: json['_id'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }

  factory DailyTransaction.empty() => DailyTransaction(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        count: 0,
        id: '',
        expiresAt: '',
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'count': count,
        '_id': id,
        'expiresAt': expiresAt,
      };
}

class DailyClaimCount {
  final String date;
  final int count;
  final String id;
  final String expiresAt;

  DailyClaimCount({
    required this.date,
    required this.count,
    required this.id,
    required this.expiresAt,
  });

  factory DailyClaimCount.fromJson(Map<String, dynamic> json) {
    return DailyClaimCount(
      date: json['date'] as String,
      count: json['count'] ?? 0,
      id: json['_id'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }

  factory DailyClaimCount.empty() => DailyClaimCount(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        count: 0,
        id: '',
        expiresAt: '',
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'count': count,
        '_id': id,
        'expiresAt': expiresAt,
      };
}

class DailyTag {
  // Structure not provided; define when available
  DailyTag();

  factory DailyTag.fromJson(Map<String, dynamic> json) {
    return DailyTag();
  }

  Map<String, dynamic> toJson() => {};
}

class DailyBillClear {
  // Structure not provided; define when available
  DailyBillClear();

  factory DailyBillClear.fromJson(Map<String, dynamic> json) {
    return DailyBillClear();
  }

  Map<String, dynamic> toJson() => {};
}
