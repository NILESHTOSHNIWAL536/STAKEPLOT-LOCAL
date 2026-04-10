// ─── models/models.dart ───────────────────────────────────────────────────────
import 'package:flutter/material.dart' show Color;
import 'package:flutter_application_code_stakeplot/model/collections_model.dart';

// class TripMember {
//   final String id;
//   final String name;
//   final String avatarInitial;
//   final Color avatarColor;
//   final double spent;
//   final double budget;

//   const TripMember({
//     required this.id,
//     required this.name,
//     required this.avatarInitial,
//     required this.avatarColor,
//     required this.spent,
//     required this.budget,
//   });
// }

class BalanceEntry {
  final MemberModel member;
  final double amount;
  final BalanceType type;

  const BalanceEntry({
    required this.member,
    required this.amount,
    required this.type,
  });
}

enum BalanceType { toPay, toReceive }

class FixedBill {
  final String id;
  final String title;
  final String iconKey;
  final double amount;
  final String dueDate;
  final BillStatus status;

  const FixedBill({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.amount,
    required this.dueDate,
    required this.status,
  });
}

enum BillStatus { paid, pending }

class TransactionForCollections {
  final String id;
  final String title;
  final String date;
  final double amount;
  final String category;
  final String addedBy;
  final String? taggedMemberId;
  bool isSelected;
  final List<SplitEntry>? splits;

  TransactionForCollections({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
    required this.addedBy,
    this.taggedMemberId,
    this.isSelected = false,
    this.splits,
  });
}

class SplitEntry {
  final MemberModel member;
  double amount;
  bool isManuallyEdited;

  SplitEntry({
    required this.member,
    required this.amount,
    this.isManuallyEdited = false,
  });
}
