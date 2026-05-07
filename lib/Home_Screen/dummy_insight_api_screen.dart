import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/controllers/insight_controller.dart';
import 'package:get/get.dart';

class DummyInsightApiScreen extends StatefulWidget {
  const DummyInsightApiScreen({super.key});

  @override
  State<DummyInsightApiScreen> createState() => _DummyInsightApiScreenState();
}

class _DummyInsightApiScreenState extends State<DummyInsightApiScreen> {
  late final UserInsightController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<UserInsightController>()
        ? Get.find<UserInsightController>()
        : Get.put(UserInsightController());
    if (controller.data.isEmpty && !controller.isLoading.value) {
      controller.fetchInsights();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.appBarBackground,
        foregroundColor: colors.onBackground,
        elevation: 0,
        title: const Text(
          "Spending insights",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Obx(
            () => IconButton(
              tooltip: "Refresh",
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.fetchInsights(),
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final summary = controller.map("summary");
        final current = summary["current"] is Map
            ? Map<String, dynamic>.from(summary["current"])
            : <String, dynamic>{};
        final comparison = summary["comparison"] is Map
            ? Map<String, dynamic>.from(summary["comparison"])
            : <String, dynamic>{};
        final velocity = controller.map("spendVelocity");

        return RefreshIndicator(
          onRefresh: controller.fetchInsights,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.isLoading.value)
                const LinearProgressIndicator(minHeight: 3),
              if (controller.error.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoCard(
                  title: "API Error",
                  child: Text(
                    controller.error.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
              if (controller.endpointErrors.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoCard(
                  title: "Some APIs need checking",
                  child: Text(
                    controller.endpointErrors.entries
                        .map((item) => "${item.key}: ${item.value}")
                        .join("\n"),
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ],
              if (!controller.isLoading.value && controller.data.isEmpty)
                const _EmptyInsightState(),
              _HeroInsightCard(
                totalSpend: controller.money(current["totalDebit"]),
                income: controller.money(current["totalCredit"]),
                netFlow: controller.money(current["netCashFlow"]),
                spendChange:
                    controller.numValue(comparison["debitChangePercentage"]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: "Transactions",
                      value: "${current["transactionCount"] ?? 0}",
                      icon: Icons.receipt_long,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: "Avg spend",
                      value: controller.money(current["averageDebit"]),
                      icon: Icons.speed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SpendVelocityCard(
                data: velocity,
                money: controller.money,
                numValue: controller.numValue,
              ),
              const SizedBox(height: 12),
              _UpcomingExpensePredictionCard(
                data: controller.map("upcomingExpensePrediction"),
                money: controller.money,
                numValue: controller.numValue,
              ),
              const SizedBox(height: 12),
              _CategoryProgressSection(
                items: controller.list("categoryHealth"),
                money: controller.money,
                numValue: controller.numValue,
              ),
              const SizedBox(height: 12),
              _DailyTrendChart(
                items: controller.list("dailyTrend"),
                numValue: controller.numValue,
                money: controller.money,
              ),
              const SizedBox(height: 12),
              _PaymentModePie(
                items: controller.list("paymentModes"),
                numValue: controller.numValue,
                money: controller.money,
              ),
              const SizedBox(height: 12),
              _CashVsBankSection(
                items: controller.list("cashVsBank"),
                money: controller.money,
                numValue: controller.numValue,
              ),
              const SizedBox(height: 12),
              _BalanceTrendChart(
                items: controller.list("balanceTrend"),
                numValue: controller.numValue,
                money: controller.money,
              ),
              const SizedBox(height: 12),
              _SimpleListSection(
                title: "Top merchants",
                description:
                    "Where most of your debit amount went in this period.",
                items: controller.list("merchants"),
                titleKey: "name",
                amountKey: "amount",
                money: controller.money,
              ),
              const SizedBox(height: 12),
              _SimpleListSection(
                title: "Income sources",
                description:
                    "Frequent or high-value credit sources found in bank data.",
                items: controller.list("incomeSources"),
                titleKey: "name",
                amountKey: "amount",
                money: controller.money,
              ),
              const SizedBox(height: 12),
              _TimePatternSection(
                data: controller.map("timePatterns"),
                money: controller.money,
              ),
              const SizedBox(height: 12),
              _SimpleListSection(
                title: "Largest debits",
                description:
                    "Your biggest outgoing transactions, sorted by amount.",
                items: controller.list("largestTransactions"),
                titleKey: "merchant",
                fallbackTitleKey: "name",
                amountKey: "amount",
                money: controller.money,
              ),
              const SizedBox(height: 12),
              _SimpleListSection(
                title: "Unusual high spends",
                description:
                    "Debits much higher than your normal spend in that category.",
                items: controller.list("anomalies"),
                titleKey: "merchant",
                fallbackTitleKey: "name",
                amountKey: "amount",
                money: controller.money,
              ),
              const SizedBox(height: 12),
              _ActionItemsCard(data: controller.map("actionItems")),
              const SizedBox(height: 28),
            ],
          ),
        );
      }),
    );
  }
}

class _HeroInsightCard extends StatelessWidget {
  const _HeroInsightCard({
    required this.totalSpend,
    required this.income,
    required this.netFlow,
    required this.spendChange,
  });

  final String totalSpend;
  final String income;
  final String netFlow;
  final double spendChange;

  @override
  Widget build(BuildContext context) {
    final isHigher = spendChange > 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Last 30 days",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            totalSpend,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${isHigher ? "Up" : "Down"} ${spendChange.abs().toStringAsFixed(1)}% vs previous period",
            style: TextStyle(
              color:
                  isHigher ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _DarkMiniMetric(label: "Income", value: income)),
              const SizedBox(width: 10),
              Expanded(
                child: _DarkMiniMetric(label: "Net flow", value: netFlow),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _DarkMiniMetric extends StatelessWidget {
  const _DarkMiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: title,
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

// class _SpendVelocityCard extends StatelessWidget {
//   const _SpendVelocityCard({
//     required this.data,
//     required this.money,
//     required this.numValue,
//   });

//   final Map<String, dynamic> data;
//   final String Function(dynamic) money;
//   final double Function(dynamic) numValue;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appColors;
//     final risk = (data["riskLevel"] ?? "LOW").toString().toUpperCase();
//     final riskColor = risk == "HIGH"
//         ? colors.error
//         : risk == "MEDIUM"
//             ? const Color(0xFFF59E0B)
//             : colors.credit;
//     final dailySpend = numValue(data["dailySpendVelocity"]);
//     final safeDailySpend = numValue(data["safeDailySpendForRemainingDays"]);
//     final remainingDays = numValue(data["remainingDays"]).round();
//     final progress = safeDailySpend <= 0
//         ? 1.0
//         : (dailySpend / safeDailySpend).clamp(0.0, 1.0);

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: colors.border),
//         boxShadow: [
//           BoxShadow(
//             color: colors.onBackground.withValues(alpha: 0.04),
//             blurRadius: 16,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 42,
//                 width: 42,
//                 decoration: BoxDecoration(
//                   color: colors.primary.withValues(alpha: 0.10),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.speed_outlined,
//                   color: colors.primary,
//                   size: 22,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Spend Velocity",
//                       style: TextStyle(
//                         color: colors.onSurface,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       remainingDays > 0
//                           ? "$remainingDays days left to adjust this month's pace."
//                           : "Month-end pace is locked for this period.",
//                       style: TextStyle(
//                         color: colors.secondaryText,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               _RiskBadge(label: risk, color: riskColor),
//             ],
//           ),
//           const SizedBox(height: 18),
//           Row(
//             children: [
//               Expanded(
//                 child: _VelocityMetric(
//                   label: "Daily spend",
//                   value: money(dailySpend),
//                   icon: Icons.bolt_outlined,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _VelocityMetric(
//                   label: "Safe/day",
//                   value: money(safeDailySpend),
//                   icon: Icons.shield_outlined,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           _VelocityMetric(
//             label: "Projected month spend",
//             value: money(data["projectedSpend"]),
//             icon: Icons.trending_up,
//             fullWidth: true,
//           ),
//           const SizedBox(height: 14),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: LinearProgressIndicator(
//               value: progress,
//               minHeight: 8,
//               backgroundColor: colors.surfaceVariant,
//               color: riskColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _velocityAdvice(risk, dailySpend, safeDailySpend, money),
//             style: TextStyle(
//               color: colors.secondaryText,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _SpendVelocityCard extends StatelessWidget {
  const _SpendVelocityCard({
    required this.data,
    required this.money,
    required this.numValue,
  });

  final Map<String, dynamic> data;
  final String Function(dynamic) money;
  final double Function(dynamic) numValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final risk = (data["riskLevel"] ?? "LOW").toString().toUpperCase();

    final riskColor = risk == "HIGH"
        ? colors.error
        : risk == "MEDIUM"
            ? const Color(0xFFF59E0B)
            : colors.credit;

    final dailySpend = numValue(data["dailySpendVelocity"]);
    final safeDailySpend = numValue(data["safeDailySpendForRemainingDays"]);

    final projectedSpend = numValue(data["projectedSpend"]);

    final currentSpend = numValue(data["currentSpend"]);

    final currentBalance = numValue(data["currentBalance"]);

    final budget = numValue(data["monthlyBudget"]);

    final remainingDays = numValue(data["remainingDays"]).round();

    final percentageChange = numValue(data["percentageChangeVsPreviousMonth"]);

    final burnRate = (data["burnRate"] ?? "NORMAL").toString();

    final balanceDays = numValue(data["daysUntilBalanceExhausted"]).round();

    final progress =
        budget <= 0 ? 0.0 : (currentSpend / budget).clamp(0.0, 1.0);

    final weekendPlan = Map<String, dynamic>.from(data["weekendPlan"] ?? {});

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.onBackground.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: riskColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.speed_rounded,
                  color: riskColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Spend Velocity",
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      remainingDays > 0
                          ? "$remainingDays days left this month"
                          : "Month completed",
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _RiskBadge(
                label: risk,
                color: riskColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _VelocityMetric(
                  label: "Daily spend",
                  value: money(dailySpend),
                  icon: Icons.bolt_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VelocityMetric(
                  label: "Safe/day",
                  value: money(safeDailySpend),
                  icon: Icons.shield_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _VelocityMetric(
                  label: "Projected",
                  value: money(projectedSpend),
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VelocityMetric(
                  label: "Balance left",
                  value: money(currentBalance),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Budget used",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      "${progress * 100 > 100 ? 100 : (progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor:
                        colors.surfaceVariant.withValues(alpha: .9),
                    color: riskColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Spent ${money(currentSpend)}",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "Budget ${money(budget)}",
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: riskColor.withValues(alpha: 0.08),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: riskColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _velocityAdvice(
                      risk,
                      dailySpend,
                      safeDailySpend,
                      money,
                    ),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InsightChip(
                label:
                    "${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}% vs last month",
                color: percentageChange >= 0 ? colors.error : colors.credit,
              ),
              _InsightChip(
                label: "Burn rate: $burnRate",
                color: burnRate == "FAST"
                    ? colors.error
                    : burnRate == "NORMAL"
                        ? const Color(0xFFF59E0B)
                        : colors.credit,
              ),
              _InsightChip(
                label:
                    "Balance survives ~$balanceDays day${balanceDays == 1 ? '' : 's'}",
                color:
                    balanceDays <= 3 ? colors.error : const Color(0xFFF59E0B),
              ),
            ],
          ),
          if (weekendPlan.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              "Weekend spending plan",
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _VelocityMetric(
                    label: "Weekday safe/day",
                    value: money(
                      weekendPlan["weekdaySafeDailySpend"],
                    ),
                    icon: Icons.calendar_view_week_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _VelocityMetric(
                    label: "Weekend safe/day",
                    value: money(
                      weekendPlan["weekendSafeDailySpend"],
                    ),
                    icon: Icons.weekend_outlined,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withValues(alpha: 0.10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VelocityMetric extends StatelessWidget {
  const _VelocityMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 1 : 0.7,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategoryProgressSection extends StatelessWidget {
  const _CategoryProgressSection({
    required this.items,
    required this.money,
    required this.numValue,
  });

  final List<dynamic> items;
  final String Function(dynamic) money;
  final double Function(dynamic) numValue;

  @override
  Widget build(BuildContext context) {
    final top = items.take(6).toList();
    if (top.isEmpty) {
      return const _InfoCard(
        title: "Category health",
        child: _NoDataText(),
      );
    }

    return _InfoCard(
      title: "Category health",
      description:
          "Shows each category's share of total spend and flags fast growth as risk.",
      child: Column(
        children: top.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final share = numValue(map["sharePercentage"]).clamp(0, 100);
          final change = numValue(map["changePercentage"]);
          final risk = map["riskLevel"]?.toString() ?? "LOW";
          final color = risk == "HIGH"
              ? const Color(0xFFCF7671)
              : risk == "MEDIUM"
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF2E7D32);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        map["category"]?.toString() ?? "Category",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      "${money(map["amount"])} | $risk",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (share / 100).toDouble(),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE5E7EB),
                  color: color,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "${share.toStringAsFixed(1)}% of spend",
                      style: TextStyle(
                          color: context.appColors.secondaryText, fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      "${change >= 0 ? "+" : ""}${change.toStringAsFixed(1)}% vs previous",
                      style: TextStyle(
                          color: context.appColors.secondaryText, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DailyTrendChart extends StatelessWidget {
  const _DailyTrendChart({
    required this.items,
    required this.numValue,
    required this.money,
  });

  final List<dynamic> items;
  final double Function(dynamic) numValue;
  final String Function(dynamic) money;

  @override
  Widget build(BuildContext context) {
    final last = items.length > 7 ? items.sublist(items.length - 7) : items;
    if (last.isEmpty) {
      return const _InfoCard(title: "Daily spend trend", child: _NoDataText());
    }

    final maxY = max(
        1.0,
        last.fold<double>(0, (m, e) {
          final map = Map<String, dynamic>.from(e as Map);
          return max(m, max(numValue(map["debit"]), numValue(map["credit"])));
        }));
    final totalDebit = last.fold<double>(
      0,
      (sum, e) => sum + numValue((e as Map)["debit"]),
    );
    final totalCredit = last.fold<double>(
      0,
      (sum, e) => sum + numValue((e as Map)["credit"]),
    );

    return _InfoCard(
      title: "Daily spend trend",
      description:
          "Day by day outgoing and incoming money. Red is spend, green is income.",
      child: Column(
        children: [
          _ChartLegend(items: [
            _LegendItem("Debit", const Color(0xFFCF7671), money(totalDebit)),
            _LegendItem("Credit", const Color(0xFF2E7D32), money(totalCredit)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.25,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE5E7EB),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        _compactAmount(value),
                        style: TextStyle(
                          color: context.appColors.secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: max(1, (last.length / 4).floor()).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= last.length) {
                          return const SizedBox.shrink();
                        }
                        final item =
                            Map<String, dynamic>.from(last[index] as Map);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _shortDate(item["date"]),
                            style: TextStyle(
                              color: context.appColors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(last.length, (index) {
                  final item = Map<String, dynamic>.from(last[index] as Map);
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: numValue(item["debit"]),
                        color: const Color(0xFFCF7671),
                        width: 7,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: numValue(item["credit"]),
                        color: const Color(0xFF2E7D32),
                        width: 7,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentModePie extends StatelessWidget {
  const _PaymentModePie({
    required this.items,
    required this.numValue,
    required this.money,
  });

  final List<dynamic> items;
  final double Function(dynamic) numValue;
  final String Function(dynamic) money;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF16A34A),
      const Color(0xFFF59E0B),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
    ];
    final top = items.take(5).toList();
    final total = top.fold<double>(
      0,
      (sum, e) => sum + numValue((e as Map)["amount"]),
    );

    if (top.isEmpty) {
      return const _InfoCard(title: "Payment mode mix", child: _NoDataText());
    }

    return _InfoCard(
      title: "Payment mode mix",
      description:
          "How your debit spend is split across UPI, card, cash, transfer and other modes.",
      child: Row(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 34,
                sections: List.generate(top.length, (index) {
                  final item = Map<String, dynamic>.from(top[index] as Map);
                  final amount = numValue(item["amount"]);
                  final share = total == 0 ? 0 : (amount / total) * 100;
                  return PieChartSectionData(
                    value: amount,
                    color: colors[index % colors.length],
                    title: share >= 8 ? "${share.toStringAsFixed(0)}%" : "",
                    radius: 42,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: List.generate(top.length, (index) {
                final item = Map<String, dynamic>.from(top[index] as Map);
                final amount = numValue(item["amount"]);
                final share = total == 0 ? 0 : (amount / total) * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: colors[index % colors.length],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _modeLabel(item["mode"]),
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              "${money(amount)} | ${item["count"] ?? 0} txns | ${share.toStringAsFixed(1)}%",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.appColors.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}

class _BalanceTrendChart extends StatelessWidget {
  const _BalanceTrendChart({
    required this.items,
    required this.numValue,
    required this.money,
  });

  final List<dynamic> items;
  final double Function(dynamic) numValue;
  final String Function(dynamic) money;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _InfoCard(title: "Balance trend", child: _NoDataText());
    }

    final spots = List.generate(
      items.length,
      (index) => FlSpot(
        index.toDouble(),
        numValue((items[index] as Map)["closingBalance"]),
      ),
    );
    final minValue = spots.fold<double>(spots.first.y, (m, e) => min(m, e.y));
    final maxValue = spots.fold<double>(spots.first.y, (m, e) => max(m, e.y));
    final padding = max(1.0, (maxValue - minValue) * 0.18);
    final current = spots.last.y;

    return _InfoCard(
      title: "Balance trend",
      description:
          "Closing bank balance by date. Cash/manual entries are not included.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartLegend(items: [
            _LegendItem("Latest", const Color(0xFF4B4D73), money(current)),
            _LegendItem("Low", const Color(0xFFCF7671), money(minValue)),
            _LegendItem("High", const Color(0xFF2E7D32), money(maxValue)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: max(0.0, minValue - padding),
                maxY: maxValue + padding,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: max(1.0, (maxValue - minValue) / 3),
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE5E7EB),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        _compactAmount(value),
                        style: TextStyle(
                          color: context.appColors.secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: max(1, (items.length / 4).floor()).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= items.length) {
                          return const SizedBox.shrink();
                        }
                        final item =
                            Map<String, dynamic>.from(items[index] as Map);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _shortDate(item["date"]),
                            style: TextStyle(
                              color: context.appColors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF4B4D73),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4B4D73).withValues(alpha: 0.10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashVsBankSection extends StatelessWidget {
  const _CashVsBankSection({
    required this.items,
    required this.money,
    required this.numValue,
  });

  final List<dynamic> items;
  final String Function(dynamic) money;
  final double Function(dynamic) numValue;

  @override
  Widget build(BuildContext context) {
    final debitItems =
        items.where((e) => (e as Map)["type"] == "DEBIT").toList();
    final total = debitItems.fold<double>(
      0,
      (sum, e) => sum + numValue((e as Map)["amount"]),
    );

    if (debitItems.isEmpty) {
      return const _InfoCard(title: "Cash vs bank", child: _NoDataText());
    }

    return _InfoCard(
      title: "Cash vs bank",
      description:
          "Compares manually added cash debits with bank or UPI debits.",
      child: Column(
        children: debitItems.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final amount = numValue(map["amount"]);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        map["source"]?.toString() ?? "Source",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      money(amount),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : amount / total,
                  minHeight: 8,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimePatternSection extends StatelessWidget {
  const _TimePatternSection({required this.data, required this.money});

  final Map<String, dynamic> data;
  final String Function(dynamic) money;

  @override
  Widget build(BuildContext context) {
    final dates =
        data["highestDates"] is List ? data["highestDates"] as List : [];
    return _SimpleListSection(
      title: "Highest spend dates",
      items: dates,
      titleKey: "_id",
      amountKey: "amount",
      money: money,
    );
  }
}

class _SimpleListSection extends StatelessWidget {
  const _SimpleListSection({
    required this.title,
    this.description,
    required this.items,
    required this.titleKey,
    required this.amountKey,
    required this.money,
    this.fallbackTitleKey,
  });

  final String title;
  final String? description;
  final List<dynamic> items;
  final String titleKey;
  final String? fallbackTitleKey;
  final String amountKey;
  final String Function(dynamic) money;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (items.isEmpty) {
      return _InfoCard(
        title: title,
        child: const _NoDataText(),
      );
    }

    return _InfoCard(
      title: title,
      description: description,
      child: Column(
        children: items.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          final map = Map<String, dynamic>.from(item as Map);

          final name = map[titleKey]?.toString().isNotEmpty == true
              ? map[titleKey].toString()
              : map[fallbackTitleKey]?.toString() ??
                  map["narration"]?.toString() ??
                  "Unknown";

          final amount = money(map[amountKey]);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(
              bottom: index == items.take(5).length - 1 ? 0 : 14,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.onBackground.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Container(
                //   height: 48,
                //   width: 48,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(14),
                //     gradient: LinearGradient(
                //       colors: [
                //         colors.primary.withValues(alpha: 0.18),
                //         colors.primary.withValues(alpha: 0.08),
                //       ],
                //     ),
                //   ),
                //   child: Center(
                //     child: Text(
                //       name.isNotEmpty ? name[0].toUpperCase() : "?",
                //       style: TextStyle(
                //         color: colors.primary,
                //         fontWeight: FontWeight.w900,
                //         fontSize: 18,
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _listSubtitle(map),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: colors.primary.withValues(alpha: 0.10),
                      ),
                      child: Text(
                        "Insight",
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionItemsCard extends StatelessWidget {
  const _ActionItemsCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: "Action items",
      description:
          "Quick work queue for transactions that need cleanup or confirmation.",
      child: Column(
        children: [
          _ActionRow(
            icon: Icons.rate_review_outlined,
            label: "Needs review",
            value: data["needsReviewCount"] ?? 0,
            helper: "Transactions marked for user confirmation.",
          ),
          _ActionRow(
            icon: Icons.sell_outlined,
            label: "Untagged",
            value: data["untaggedCount"] ?? 0,
            helper: "Transactions without a usable category.",
          ),
          _ActionRow(
            icon: Icons.repeat,
            label: "Recurring",
            value: data["activeRecurringCount"] ?? 0,
            helper: "Active subscriptions or repeated payments.",
          ),
          _ActionRow(
            icon: Icons.visibility_off_outlined,
            label: "Hidden",
            value: data["hiddenCount"] ?? 0,
            helper: "Hidden transactions excluded from insights.",
          ),
        ],
      ),
    );
  }
}

class _UpcomingExpensePredictionCard extends StatelessWidget {
  const _UpcomingExpensePredictionCard({
    required this.data,
    required this.money,
    required this.numValue,
  });

  final Map<String, dynamic> data;
  final String Function(dynamic) money;
  final double Function(dynamic) numValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final items = data["items"] is List ? data["items"] as List : [];

    if (items.isEmpty) {
      return const _InfoCard(
        title: "Upcoming Expense Prediction",
        child: _NoDataText(),
      );
    }

    return _InfoCard(
      title: "Upcoming Expense Prediction",
      description:
          "Expected recurring debits due soon, cleaned up from bank narrations.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _PredictionSummaryPill(
                  label: "Predicted",
                  value: money(data["totalPredictedAmount"]),
                  icon: Icons.event_available_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PredictionSummaryPill(
                  label: "Next ${data["days"] ?? 60} days",
                  value: "${data["predictedCount"] ?? items.length} items",
                  icon: Icons.repeat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.take(5).map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            final title = map["title"]?.toString().isNotEmpty == true
                ? map["title"].toString()
                : map["merchant"]?.toString() ?? "Upcoming expense";
            final dueInDays = numValue(map["dueInDays"]).round();
            final dueLabel = dueInDays == 0
                ? "Due today"
                : dueInDays == 1
                    ? "Due tomorrow"
                    : "Due in $dueInDays days";

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFFF97316),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "$dueLabel | ${_modeLabel(map["frequency"])}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    money(map["amount"]),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PredictionSummaryPill extends StatelessWidget {
  const _PredictionSummaryPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF97316), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
  });

  final IconData icon;
  final String label;
  final dynamic value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4B4D73), size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  helper,
                  style: TextStyle(
                      color: context.appColors.secondaryText, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            "$value",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _EmptyInsightState extends StatelessWidget {
  const _EmptyInsightState();

  @override
  Widget build(BuildContext context) {
    return const _InfoCard(
      title: "No insight data",
      child: Text(
        "No bank transaction insights were loaded yet. Pull to refresh or check the API errors above.",
      ),
    );
  }
}

class _NoDataText extends StatelessWidget {
  const _NoDataText();

  @override
  Widget build(BuildContext context) {
    return Text(
      "No data available for this insight.",
      style: TextStyle(
          color: context.appColors.secondaryText, fontStyle: FontStyle.italic),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.child,
    this.description,
  });

  final String title;
  final Widget child;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(color: colors.secondaryText, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LegendItem {
  const _LegendItem(this.label, this.color, this.value);

  final String label;
  final Color color;
  final String value;
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.items});

  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "${item.label}: ${item.value}",
                style: TextStyle(
                  color: item.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

String _compactAmount(num value) {
  final abs = value.abs();
  if (abs >= 100000) return "${(value / 100000).toStringAsFixed(1)}L";
  if (abs >= 1000) return "${(value / 1000).toStringAsFixed(0)}K";
  return value.toStringAsFixed(0);
}

String _shortDate(dynamic value) {
  final raw = value?.toString() ?? "";
  if (raw.length >= 10) {
    final month = raw.substring(5, 7);
    final day = raw.substring(8, 10);
    return "$day/$month";
  }
  return raw;
}

String _modeLabel(dynamic value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty || raw == "UNKNOWN") return "Unknown mode";
  return raw
      .split(RegExp(r'[_\s-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) =>
          part.substring(0, 1).toUpperCase() + part.substring(1).toLowerCase())
      .join(" ");
}

String _velocityAdvice(
  String risk,
  double dailySpend,
  double safeDailySpend,
  String Function(dynamic) money,
) {
  if (risk == "HIGH") {
    return "You are running hot. Try keeping daily debits near ${money(safeDailySpend)} for the rest of the month.";
  }
  if (risk == "MEDIUM") {
    return "Spend is slightly above normal. A daily target of ${money(safeDailySpend)} keeps the month under control.";
  }
  return "Your pace is healthy. Current daily spend is around ${money(dailySpend)}.";
}

String _listSubtitle(Map<String, dynamic> map) {
  final parts = <String>[];
  if (map["date"] != null || map["_id"] != null) {
    parts.add("Date ${_shortDate(map["date"] ?? map["_id"])}");
  }
  if (map["mode"] != null) parts.add(_modeLabel(map["mode"]));
  if (map["category"] != null) parts.add(map["category"].toString());
  if (map["count"] != null) parts.add("${map["count"]} txns");
  if (map["average"] != null) parts.add("avg INR ${map["average"]}");
  return parts.isEmpty ? "Transaction insight" : parts.join(" | ");
}
