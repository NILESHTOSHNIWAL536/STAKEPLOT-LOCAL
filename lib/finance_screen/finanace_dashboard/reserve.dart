import 'package:flutter/material.dart';
import '../../Constants/colors.dart';

class AppColors2 {
  AppColors2._();

  static const Color header = AppColors.primaryColor;
  static const Color cream = Color(0xFFF5F0E8);
  static const Color navyBtn = AppColors.primaryColor;
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMid = Color(0xFF6B6B8A);
  static const Color textLight = Color(0xFF9999AA);
  static const Color inputBorder = Color(0xFFE0D9CC);
  static const Color accent = Color(0xFF4A4580);
  static const Color sliderTrack = Color(0xFFE0DCF0);
  static const Color toggleOn = Color(0xFF4A4580);
  static const Color toggleOff = Color(0xFFCCCCDD);
  static const Color divider = Color(0xFFF0EDE6);
}

class ReserveCategory {
  final String name;
  final String subtitle;
  final IconData icon;

  const ReserveCategory({
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}

/// All available spending categories — single source of truth.
const List<ReserveCategory> kReserveCategories = [
  ReserveCategory(
    name: 'Transport',
    subtitle: 'Daily commute & fuel',
    icon: Icons.directions_bus_outlined,
  ),
  ReserveCategory(
    name: 'Dining out',
    subtitle: 'Cafe & restaurants',
    icon: Icons.restaurant_outlined,
  ),
  ReserveCategory(
    name: 'Shopping',
    subtitle: 'Fashion & purchases',
    icon: Icons.shopping_bag_outlined,
  ),
  ReserveCategory(
    name: 'Groceries',
    subtitle: 'Daily needs',
    icon: Icons.local_grocery_store_outlined,
  ),
  ReserveCategory(
    name: 'Overall spend',
    subtitle: 'Covers everything',
    icon: Icons.bar_chart_outlined,
  ),
];

class ReserveState {
  final Set<int> selectedCategories;

  double amount;
  // int selectedDay;
  DateTime? startDate;
  DateTime? endDate;

  double notifyPercent; // 0.1 – 1.0
  int reminderHour; // 1 – 12
  int reminderMinute; // 0, 5, 10 … 55
  String reminderPeriod; // 'AM' | 'PM'
  bool partnerReserve;
  bool reserveWidget;
  ReserveState({
    Set<int>? selectedCategories,
    this.amount = 0,
    DateTime? startDate,
    DateTime? endDate,
    this.notifyPercent = 0.8,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.reminderPeriod = 'PM',
    this.partnerReserve = true,
    this.reserveWidget = false,
  })  : selectedCategories = selectedCategories ?? {},
        startDate = startDate,
        endDate = endDate;
  // ── Derived helpers ──────────────────────────────────────────────────────

  /// Human-readable time string, e.g. "08:00 PM"
  String get reminderTimeLabel {
    final h = reminderHour.toString().padLeft(2, '0');
    final m = reminderMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  int get selectedDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  /// Notify percent as an integer label, e.g. "80%"
  String get notifyLabel => '${(notifyPercent * 100).toInt()}%';

  Map<String, dynamic> toJson() => {
        'categories':
            selectedCategories.map((i) => kReserveCategories[i].name).toList(),
        'amount': amount,
        'duration_days': selectedDays,
        'startDate': startDate?.toUtc().toIso8601String(),
        'endDate': endDate?.toUtc().toIso8601String(),
        'notify_at_percent': (notifyPercent * 100).toInt(),
        'reminder_time': reminderTimeLabel,
        'partner_reserve': partnerReserve,
        'reserve_widget': reserveWidget,
      };
}
