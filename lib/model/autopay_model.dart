import 'package:flutter/material.dart';

import '../components/shared_utils.dart';

class AutoPayTransactionData {
  final String id;
  final String title;
  final String amount;
  final DateTime? transactionTimestamp;
  final String date;
  final String narration;
  final String mode;
  final String type;

  const AutoPayTransactionData({
    required this.id,
    required this.title,
    required this.amount,
    required this.transactionTimestamp,
    required this.date,
    required this.narration,
    required this.mode,
    required this.type,
  });

  factory AutoPayTransactionData.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'];
    final rawTimestamp = json['transactionTimestamp'] is Map
        ? json['transactionTimestamp']['\$date']
        : json['transactionTimestamp'];
    final parsedDate = rawTimestamp != null
        ? DateTime.tryParse(rawTimestamp.toString())
        : null;
    final rawAmount = json['amount'] ?? 0;

    return AutoPayTransactionData(
      id: rawId?.toString() ?? '',
      title: (json['merchant'] ??
              json['title'] ??
              json['name'] ??
              json['narration'] ??
              'Transaction')
          .toString(),
      amount: "₹ ${formatMoneyIndian(rawAmount.toString())}",
      transactionTimestamp: parsedDate,
      date: parsedDate != null ? formatWhatsAppDate(parsedDate) : '',
      narration: (json['narration'] ?? '').toString(),
      mode: (json['mode'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
    );
  }
}

class CardData {
  final String id; // Add _id for unique identification
  final String title; // Maps to merchant
  final String amount; // Formatted amount
  final String date; // Maps to recentMostTransactionTimestamp
  final List<String> occuranceDate; // Maps to recentMostTransactionTimestamp
  final List<String> transactionIds;
  final List<AutoPayTransactionData> transactions;
  final String frequency;
  final String narration;
  final LinearGradient gradient;
  final DateTime? nextReminderAt;
  final bool isActive;
  final bool isDaily;
  final int occurrencesCount;
  final double confidenceScore;
  final String confidenceLabel;
  final String detectionMethod;
  final bool isUserDefined;
  CardData({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.occuranceDate,
    this.transactionIds = const [],
    this.transactions = const [],
    required this.frequency,
    required this.narration,
    required this.gradient,
    this.nextReminderAt,
    required this.isActive,
    required this.isDaily,
    this.occurrencesCount = 1,
    this.confidenceScore = 0,
    this.confidenceLabel = '',
    this.detectionMethod = '',
    this.isUserDefined = false,
  });

  // Factory constructor to create CardData from JSON
  factory CardData.fromJson(Map<String, dynamic> json) {
    // Define gradients for cards (cycle through a list for variety)
    const gradients = [
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8B7ED8), Color(0xFF4A90E2)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF8A80), Color(0xFFFF7043)],
      ),
    ];
    // Choose gradient based on index or randomly
    final gradientIndex =
        json['index'] != null ? json['index'] % gradients.length : 0;
    final List<String> occuranceDates = (json['recentMostTwoOccurrences']
                as List<dynamic>?)
            ?.map((date) => formatWhatsAppDate(convertStringToDateTime(date)))
            .toList() ??
        [];
    final transactionSource = (json['transactions'] as List<dynamic>?) ??
        (json['transactionIds'] as List<dynamic>?) ??
        [];
    final transactions = transactionSource
        .whereType<Map<String, dynamic>>()
        .map(AutoPayTransactionData.fromJson)
        .where((transaction) => transaction.id.isNotEmpty)
        .toList()
      ..sort((a, b) {
        final aDate = a.transactionTimestamp;
        final bDate = b.transactionTimestamp;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    final transactionIds = transactionSource
        .map((transaction) {
          if (transaction is Map<String, dynamic>) {
            final rawId = transaction['_id'] is Map
                ? transaction['_id']['\$oid']
                : transaction['_id'];
            return rawId?.toString() ?? '';
          }
          return transaction?.toString() ?? '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
    return CardData(
      id: json['_id'] as String,
      title: (json['merchant'] ?? 'Recurring payment') as String,
      amount: "₹ ${formatMoneyIndian(json['amount'].toString())}",

      // amount:
      //     "₹ ${json['amount'].toString()}", // Format amount with currency symbol
      date: _formatDate(json['recentMostTransactionTimestamp'] as String),
      occuranceDate: occuranceDates,
      transactionIds: transactionIds,
      transactions: transactions,
      frequency: (json['frequency'] ?? 'monthly') as String,
      narration: (json['narration'] ?? '') as String,
      gradient: gradients[gradientIndex],
      nextReminderAt: json['nextReminderAt'] != null
          ? DateTime.parse(json['nextReminderAt'] as String)
          : null,
      isActive: json['isActive'] ?? false,
      isDaily: json['isDaily'] ?? false,
      occurrencesCount: json['occurrencesCount'] ?? 1,
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      confidenceLabel: json['confidenceLabel'] ?? '',
      detectionMethod: json['detectionMethod'] ?? json['source'] ?? '',
      isUserDefined: json['isUserDefined'] ?? false,
    );
  }

  // Helper method to format date
  static String _formatDate(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }
}
