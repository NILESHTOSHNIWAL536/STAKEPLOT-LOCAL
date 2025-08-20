import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/currency_convert.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/cardBuilders.dart';
import 'package:get/get.dart';

// Import CardBuilders for debtCard, budgetCard, etc.

class FinanceWidgets {
  static Widget additionWidgets(BuildContext context, VoidCallback onAddDebt) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/Budget");
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.button,
                   
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 12,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      CardBuilders.globalText(
                        context: context,
                        text:  PlotFinanceStaticData().addBudget,
                        fontsize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: onAddDebt,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.button,
                    
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 12,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      CardBuilders.globalText(
                        context: context,
                        text:  PlotFinanceStaticData().addDebt, 
                        fontsize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/VegNonveg");
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.button,
                   
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 12,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      CardBuilders.globalText(
                        context: context,
                        text: PlotFinanceStaticData().foodieFunds,
                        fontsize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListScreen(isPayable: false),
                    ),
                  );
                },
                child: Obx(() => CardBuilders.buildSummaryCard(
                      context,
                      PlotFinanceStaticData().toReceive,
                      lendAmountRemainders,
                      AppColors.primaryColor,
                    )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListScreen(isPayable: true),
                    ),
                  );
                },
                child: Obx(() => CardBuilders.buildSummaryCard(
                      context,
                     PlotFinanceStaticData().toPay,
                      dueAmountRemainders,
                      const Color.fromARGB(255, 186, 69, 63),
                    )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget debtsPicture(
      BuildContext context, RxList<Debt> debts, Function(Debt) onDebtTap) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSingleDebt = debts.length == 1;

    return  Obx(() => debts.isEmpty?SizedBox.shrink()
    :Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        child:
            ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: debts.length,
                itemBuilder: (context, index) {
                  final debt = debts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                       width: isSingleDebt ? screenWidth * 0.9 : screenWidth * 0.8,
                      child: CardBuilders.debtCard(context, debt, onDebtTap),
                    ),
                  );
                },
              )
      ),
    ));
  }

  static Widget budgetHorizontalList(BuildContext context) {
    return Obx(() {
      final sortedBudgets = budgetList.toList()
        ..sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
        final isSingleBudget = sortedBudgets.length == 1;
        final screenWidth = MediaQuery.of(context).size.width;
       return sortedBudgets.isEmpty
            ?SizedBox.shrink()
            : SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        
        child:  Center(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedBudgets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                       width: isSingleBudget ? screenWidth * 0.9 : screenWidth * 0.8,
                        child: CardBuilders.budgetCard(context, sortedBudgets[index]),
                      ),
                    );
                  },
                ),
            ),
      );
    });
  }

  static Widget calculatorList(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          CardBuilders.buildCalculatorTile(
            context,
             PlotFinanceStaticData().creditCardPayoff, // Updated
            PlotFinanceStaticData().calculatorSubtitle,
            url: Finance.credit,
            path: "/CreditCard",
          ),
          CardBuilders.buildCalculatorTile(
            context,
            PlotFinanceStaticData().emiCalculator, // Updated
            PlotFinanceStaticData().calculatorSubtitle, 
            url: Finance.emi,
            path: "/emi",
          ),
           CardBuilders.buildCalculatorTile(
            context,
            PlotFinanceStaticData().rentVsBuy, // Updated
            PlotFinanceStaticData().calculatorSubtitle, // Updated
            url: Finance.key,
            path: "/rent_buy",
          ),
          CardBuilders.buildCalculatorTile(
            context,
            PlotFinanceStaticData().savingsGoal, // Updated
            PlotFinanceStaticData().calculatorSubtitle, // Updated
            url: Finance.savings,
            path: "/Savings",
          ),
          CardBuilders.buildCalculatorTile(
            context,
            PlotFinanceStaticData().autoLoan, // Updated
            PlotFinanceStaticData().calculatorSubtitle, // Updated
            url: Finance.auto,
            path: "/autoLoan",
          ),
          CardBuilders.buildCalculatorTile(
            context,
            PlotFinanceStaticData().tripCost, // Updated
            PlotFinanceStaticData().calculatorSubtitle, // Updated
            url: Finance.location,
            path: "/TripCost",
          ),
          GestureDetector(
           onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CurrencyConverterScreen()),
  );
}
,
            child: Text("currency")
          ),
        ],
      ),
    );
  }
}

