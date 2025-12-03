import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';

import '../components/shared_utils.dart';

class CardData {
  final String id; // Add _id for unique identification
  final String title; // Maps to merchant
  final String amount; // Formatted amount
  final String date; // Maps to recentMostTransactionTimestamp
  final List<String> occuranceDate; // Maps to recentMostTransactionTimestamp
  final String frequency;
  final String narration;
  final LinearGradient gradient;
  final DateTime? nextReminderAt;
  final bool isActive;
  final bool isDaily;
  CardData({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.occuranceDate,
    required this.frequency,
    required this.narration,
    required this.gradient,
    this.nextReminderAt,
    required this.isActive,
    required this.isDaily,
  });

  // Factory constructor to create CardData from JSON
  factory CardData.fromJson(Map<String, dynamic> json) {
    // Define gradients for cards (cycle through a list for variety)
    final gradients = const [
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
            ?.map((date) =>
                formatWhatsAppDateWithoutTime(convertStringToDateTime(date)))
            .toList() ??
        [];
    return CardData(
      id: json['_id'] as String,
      title: json['merchant'] as String,
      amount: "₹ ${formatMoneyIndian(json['amount'].toString())}",

      // amount:
      //     "₹ ${json['amount'].toString()}", // Format amount with currency symbol
      date: _formatDate(json['recentMostTransactionTimestamp'] as String),
      occuranceDate: occuranceDates,
      frequency: json['frequency'] as String,
      narration: json['narration'] as String,
      gradient: gradients[gradientIndex],
       nextReminderAt: json['nextReminderAt'] != null
          ? DateTime.parse(json['nextReminderAt'] as String)
          : null,
          isActive: json['isActive'],
          isDaily: json['isDaily'] ,

    );
  }

  // Helper method to format date
  static String _formatDate(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }
}
