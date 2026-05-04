import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Hive_localstorage/apisCall/bank_apis.dart';
import '../../Hive_localstorage/apisCall/finance_apis.dart';
import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/core/app_shadows.dart';
import '../../Constants/font_manager.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/shared_utils.dart';
import '../../repository/bankinfo.dart';
import '../../repository/finance_repository.dart';
import '../finance_analytics/expanded_finance.dart';

class SpendingCardTwoPanels extends StatefulWidget {
  const SpendingCardTwoPanels({super.key});

  @override
  State<SpendingCardTwoPanels> createState() => _SpendingCardTwoPanelsState();
}

class ChartData {
  ChartData(this.label, this.credit, this.debit);
  final String label;
  final double credit;
  final double debit;
}

class _SpendingCardTwoPanelsState extends State<SpendingCardTwoPanels> {
  int selectedIndex = 0;
  bool _isInitialSelectionSet = false;
  bool _hasPaintedChart = false;
  String _lastAccountId = '';
  String _lastRequestedAccountId = '';

  final double chartMaxHeight = 180.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadActiveBankChart(cacheFirst: true));
    });
  }

  Future<void> _loadActiveBankChart({bool cacheFirst = false}) async {
    if (accountId.value.isEmpty &&
        bankAccountLinkedList.isEmpty &&
        !bankInfoController.hasLoadedLocalData.value) {
      await BankStorage.loadBankDataFromHive();
    }

    if (!mounted || accountId.value.isEmpty) return;

    final currentAccountId = accountId.value;
    if (cacheFirst) {
      final cached = await FinanceLocalStorage.loadFinanceFromHive(
        currentAccountId,
        'Month',
        getFormattedDate(),
        null,
        false,
      );
      if (cached == null && mounted && labels.isEmpty) {
        final today = DateTime.now();
        final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
        final monthLabels = List<String>.generate(
          daysInMonth,
          (index) => (index + 1).toString().padLeft(2, '0'),
        );
        labels.assignAll(monthLabels);
        transactionChatGraph['credited'] = List<double>.filled(daysInMonth, 0);
        transactionChatGraph['debited'] = List<double>.filled(daysInMonth, 0);
        getGraphData.value = true;
      }
    }

    if (!mounted ||
        currentAccountId.isEmpty ||
        currentAccountId == _lastRequestedAccountId) {
      return;
    }

    final requestedAccountId = currentAccountId;
    _lastRequestedAccountId = requestedAccountId;
    await getWeeklyGraphAndCustomDateGraph(
      getFormattedDate(),
      context,
      weekORmonth: 'Month',
      isSplashScreen: true,
    );

    if (_lastRequestedAccountId == requestedAccountId) {
      _lastRequestedAccountId = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<double> credited =
          List<double>.from(transactionChatGraph['credited'] ?? []);
      final List<double> debited =
          List<double>.from(transactionChatGraph['debited'] ?? []);
      final List<String> dayLabels = labels.map((e) => e.toString()).toList();
      final currentAccountId = accountId.value;

      if (_lastAccountId != currentAccountId) {
        _lastAccountId = currentAccountId;
        _isInitialSelectionSet = false;
        _hasPaintedChart = false;
        selectedIndex = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_loadActiveBankChart(cacheFirst: true));
        });
      }

      if (credited.isEmpty || debited.isEmpty || dayLabels.isEmpty) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.25,
          child: const Center(child: Text('No data available')),
        );
      }

      /// 🔥 LAST 7 DAYS ENDING AT TODAY
      final String today = DateTime.now().day.toString().padLeft(2, '0');

      int todayIndex = dayLabels.lastIndexWhere((e) => e == today);

      if (todayIndex == -1) {
        todayIndex = dayLabels.length - 1;
      }

      final int startIndex = max(0, todayIndex - 6);

      final List<double> visibleCredited =
          credited.sublist(startIndex, todayIndex + 1);
      final List<double> visibleDebited =
          debited.sublist(startIndex, todayIndex + 1);
      final List<String> visibleLabels =
          dayLabels.sublist(startIndex, todayIndex + 1);

      /// ✅ Set default selection ONLY ONCE
      if (!_isInitialSelectionSet) {
        selectedIndex = visibleLabels.length - 1;
        _isInitialSelectionSet = true;
      }
      if (selectedIndex >= visibleLabels.length) {
        selectedIndex = visibleLabels.length - 1;
      }
      if (selectedIndex < 0) selectedIndex = 0;

      return _buildCard(
        context,
        visibleCredited,
        visibleDebited,
        visibleLabels,
      );
    });
  }

  Widget _buildCard(
    BuildContext context,
    List<double> credited,
    List<double> debited,
    List<String> labels,
  ) {
    final int count = min(7, labels.length);

    final List<ChartData> data = List.generate(count, (i) {
      return ChartData(labels[i], credited[i], debited[i]);
    });

    final List<double> totals = data.map((e) => e.credit + e.debit).toList();

    final double maxTotal = totals.isEmpty ? 1.0 : totals.reduce(max);

    final double yMax = maxTotal == 0 ? 1.0 : (maxTotal * 1.2).ceilToDouble();

    final double maxBarH = chartMaxHeight - 40;

    final double screenWidth = MediaQuery.of(context).size.width;

    double rightVisible = screenWidth / 2;
    rightVisible = max(rightVisible, 120);
    rightVisible = min(rightVisible, screenWidth * 0.64);

    final double selCred = data[selectedIndex].credit;
    final double selDeb = data[selectedIndex].debit;
    final bool animateBars = _hasPaintedChart;
    _hasPaintedChart = true;

    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.financeChartBorder),
        boxShadow: [AppShadows.tabs],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p10, horizontal: AppSizes.p8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------------- LEFT PANEL ----------------
            Material(
              color: AppColors.transparentColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpandedChartView(
                        chartData: {
                          'credited': credited,
                          'debited': debited,
                        },
                        days: labels,
                        selectedButton: 'Month',
                        selectedYear: DateTime.now().year,
                        selectedMonth: DateTime.now().month,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth / 3.5,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.p20, horizontal: AppSizes.p4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Spending',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Wrap(
                        spacing: AppSizes.w8,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '₹ ${formatNumber(selCred)}',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            'Credited',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 12,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: AppSizes.w8,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '₹ ${formatNumber(selDeb)}',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.debitedAmount,
                            ),
                          ),
                          Text(
                            'Debited',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 12,
                              color: AppColors.debitedAmount,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),

            /// ---------------- RIGHT BAR CHART ----------------
            SizedBox(
              height: chartMaxHeight,
              width: rightVisible,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(data.length, (i) {
                  final d = data[i];
                  final bool isSel = i == selectedIndex;

                  final double creditH =
                      ((d.credit / yMax) * maxBarH).clamp(0.0, maxBarH);
                  final double debitH =
                      ((d.debit / yMax) * maxBarH).clamp(0.0, maxBarH);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: AppColors.transparentColor,
                        child: InkWell(
                          onTap: () {
                            setState(() => selectedIndex = i);
                          },
                          child: Container(
                            width: rightVisible / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.financeChartBarBorder,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: animateBars
                                      ? const Duration(milliseconds: 90)
                                      : Duration.zero,
                                  curve: Curves.easeOutCubic,
                                  height: creditH,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? AppColors.primaryColor
                                        : AppColors.primaryColor
                                            .withValues(alpha: 0.22),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: animateBars
                                      ? const Duration(milliseconds: 90)
                                      : Duration.zero,
                                  curve: Curves.easeOutCubic,
                                  height: debitH,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? AppColors.debitedAmount
                                        : AppColors.debitedAmount
                                            .withValues(alpha: 0.22),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.h8),
                      SizedBox(
                        width: rightVisible / 8,
                        child: Text(
                          d.label,
                          textAlign: TextAlign.center,
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 11,
                            color: AppColors.debitedAmount,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
