
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:get/get.dart';

import '../../Constants/app_assets.dart';
import '../../Constants/app_svgs.dart';
import '../../Constants/font_manager.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/shared_utils.dart';
import '../../controllers/finora_controller.dart';

class FinanceSummaryDashboard extends StatefulWidget {
  const FinanceSummaryDashboard({super.key});

  @override
  State<FinanceSummaryDashboard> createState() =>
      _FinanceSummaryDashboardState();
}

class _FinanceSummaryDashboardState extends State<FinanceSummaryDashboard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final controller = Get.find<FinoraController>();

    return Obx(() {
      final totalSpend = controller.totalDebitThisMonth.value;
      final autopayCount = allAutoPayData.length;

      final monthly = controller.overviewMonthlySpending.value;
      final avgDay = controller.overviewAveragePerDay.value;
      final weeklyTrendData = controller.overviewWeeklyTrend.value;
      final freqPayment = controller.overviewMostFrequentPayment.value;
      final mostExpensive = controller.overviewMostExpensiveTransaction.value;

      final cards = <Widget>[

        _MonthlySummaryCard(data: monthly),
         _MostExpensiveCard(data: mostExpensive),
        _WeeklyTrendCard(data: weeklyTrendData),
        _AvgPerDayCard(data: avgDay),
        _FrequentPaymentCard(data: freqPayment),

      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top two summary tiles ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  image: HomeSvgs.mySpendings,
                  label: 'My spendings',
                  value: totalSpend > 0
                      ? '₹${formatMoneyIndian(totalSpend.toStringAsFixed(0))}'
                      : '—',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  image: HomeSvgs.autopaysIcon,
                  label: 'Autopays',
                  value: '$autopayCount',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Finora swipeable card ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.bottomText),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Finora',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 16,
                        lWeight: FontWeight.w700,
                        color: colors.blackColor,
                      ),
                    ),
                    Text(
                      '${_currentPage + 1}/${cards.length}',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 13,
                        lWeight: FontWeight.w500,
                        color: colors.blackColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: cards.length,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    itemBuilder: (context, index) => cards[index],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}


// ── Card 1: Monthly Summary ───────────────────────────────────────────────────
class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final totalSpent = data['totalSpent'] as num? ?? 0;
    final txnCount = data['transactionCount'] as int? ?? 0;
    final month = data['month'] as String? ?? '';
    final amount = totalSpent > 0
        ? '₹${formatMoneyIndian(totalSpent.toStringAsFixed(2))}'
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [

         const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ResponsiveSvg(
              asset: HomeSvgs.monthlySpendingGraph,
              widthFactor: 1.4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(colors, HomeSvgs.monthlySpendingIcon),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly Summary',
                            style: FontManager().getTextStyle(context,
                                fontSize: 13,
                                lWeight: FontWeight.w500,
                                color: colors.blackColor)),
                        const SizedBox(height: 4),
                        if (txnCount > 0)
                          Text('$txnCount transactions · $month',
                              style: FontManager().getTextStyle(context,
                                  fontSize: 11,
                                  lWeight: FontWeight.w400,
                                  color: colors.blackColor)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(amount,
                    style: FontManager().getTextStyle(context,
                        fontSize: 28,
                        lWeight: FontWeight.w700,
                        color: colors.blackColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 2: Weekly Trend ──────────────────────────────────────────────────────
class _WeeklyTrendCard extends StatelessWidget {
  const _WeeklyTrendCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final thisWeek = data['thisWeekSpent'] as num? ?? 0;
    final delta = data['deltaPercentage'] as num? ?? 0;
    final direction = data['direction'] as String? ?? 'up';
    final isUp = direction == 'up';
    final trendColor = isUp ? Colors.red : Colors.green;
    final amount = thisWeek > 0
        ? '₹${formatMoneyIndian(thisWeek.toStringAsFixed(0))}'
        : '—';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(color: colors.whiteColor),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ResponsiveSvg(
              asset: HomeSvgs.expensiveDayGraph,
              widthFactor: 1.4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(colors, HomeSvgs.lastSevenDays),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Trend',
                            style: FontManager().getTextStyle(context,
                                fontSize: 13,
                                lWeight: FontWeight.w500,
                                color: colors.blackColor)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isUp
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 13,
                              color: trendColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${delta.toStringAsFixed(1)}% vs last week',
                              style: FontManager().getTextStyle(context,
                                  fontSize: 11,
                                  lWeight: FontWeight.w400,
                                  color: trendColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(amount,
                    style: FontManager().getTextStyle(context,
                        fontSize: 28,
                        lWeight: FontWeight.w700,
                        color: colors.blackColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 3: Average Per Day ───────────────────────────────────────────────────
class _AvgPerDayCard extends StatelessWidget {
  const _AvgPerDayCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final avg = data['averagePerDay'] as num? ?? 0;
    final days = data['daysElapsed'] as int? ?? 0;
    final amount =
        avg > 0 ? '₹${formatMoneyIndian(avg.toStringAsFixed(0))}' : '—';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(color: colors.whiteColor),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ResponsiveSvg(
              asset: HomeSvgs.monthlySpendingGraph,
              widthFactor: 1.4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(colors, HomeSvgs.historyIcon),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Avg Per Day',
                            style: FontManager().getTextStyle(context,
                                fontSize: 13,
                                lWeight: FontWeight.w500,
                                color: colors.blackColor)),
                        const SizedBox(height: 4),
                        if (days > 0)
                          Text('$days days this month',
                              style: FontManager().getTextStyle(context,
                                  fontSize: 11,
                                  lWeight: FontWeight.w400,
                                  color: colors.blackColor)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(amount,
                    style: FontManager().getTextStyle(context,
                        fontSize: 28,
                        lWeight: FontWeight.w700,
                        color: colors.blackColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 4: Most Frequent Payment ─────────────────────────────────────────────
class _FrequentPaymentCard extends StatelessWidget {
  const _FrequentPaymentCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final most = data['mostFrequent'] as Map<String, dynamic>? ?? {};
    final name = most['displayName'] as String? ?? '—';
    final frequency = most['frequency'] as int? ?? 0;
    final total = most['totalAmount'] as num? ?? 0;
    final amount =
        total > 0 ? '₹${formatMoneyIndian(total.toStringAsFixed(0))}' : '—';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(color: colors.whiteColor),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ResponsiveSvg(
              asset: HomeSvgs.expensiveDayGraph,
              widthFactor: 1.4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(colors, HomeSvgs.autopaysIcon),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Top Payment',
                            style: FontManager().getTextStyle(context,
                                fontSize: 13,
                                lWeight: FontWeight.w500,
                                color: colors.blackColor)),
                        const SizedBox(height: 4),
                        Text(
                          '$name · ${frequency}×',
                          style: FontManager().getTextStyle(context,
                              fontSize: 11,
                              lWeight: FontWeight.w400,
                              color: colors.blackColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(amount,
                    style: FontManager().getTextStyle(context,
                        fontSize: 28,
                        lWeight: FontWeight.w700,
                        color: colors.blackColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 5: Most Expensive Transaction ───────────────────────────────────────
class _MostExpensiveCard extends StatelessWidget {
  const _MostExpensiveCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final txnAmount = data['amount'] as num? ?? 0;
    final txnDate = data['transactionTimestamp'] as String? ?? '';
    final party = data['counterpartyName'] as String? ??
        data['title'] as String? ??
        '—';
    final category = data['category'] as String? ?? '';
    final amount =
        txnAmount > 0 ? '₹${formatMoneyIndian(txnAmount.toStringAsFixed(0))}' : '—';

    return Container(
      decoration: BoxDecoration(
        color: colors.whiteColor,
      borderRadius: BorderRadius.circular(10),),

      child:
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(colors, HomeSvgs.expensiveDayIcon),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Most Expensive Day',
                              style: FontManager().getTextStyle(context,
                                  fontSize: 13,
                                  lWeight: FontWeight.w500,
                                  color: colors.blackColor)),
                          const SizedBox(height: 4),
                          Text(
                            category.isNotEmpty ? '$party · $category' : party,
                            style: FontManager().getTextStyle(context,
                                fontSize: 11,
                                lWeight: FontWeight.w400,
                                color: colors.blackColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
               const SizedBox(height: 16),


                Text(formatWhatsAppDateWithoutTime(convertStringToDateTime(txnDate)),
                    style: FontManager().getTextStyle(context,
                        fontSize: 18,
                        lWeight: FontWeight.w600,
                        color: colors.blackColor)),
                         const SizedBox(height: 10),

                        Divider(color: colors.blackColor.withValues(alpha: 0.1), height: 10),
                         const SizedBox(height: 10),
                Text(amount,
                    style: FontManager().getTextStyle(context,
                        fontSize: 28,
                        lWeight: FontWeight.w600,
                        color: colors.blackColor)),
              ],
            ),
          )
          );

  }
}
Widget _iconBox(dynamic colors, String asset) => Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: ResponsiveSvg(asset: asset, widthFactor: 18),
      ),
    );

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.image,
    required this.label,
    required this.value,
  });

  final String image;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.bottomText),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ResponsiveSvg(
                asset:image,
                // heightFactor: 24,

                widthFactor: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    lWeight: FontWeight.w400,
                    color: colors.blackColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: FontManager().getTextStyle(
              context,
              fontSize: 20,
              lWeight: FontWeight.w400,
              color: colors.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
