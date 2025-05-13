
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/cardBuilders.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/financeWidgets.dart';
import 'package:get/get.dart';

class PlotFinance extends StatefulWidget {
  const PlotFinance({super.key});

  @override
  State<PlotFinance> createState() => _PlotFinanceState();
}

class _PlotFinanceState extends State<PlotFinance> {
  final RxList<Debt> debts = <Debt>[].obs;

  Future<void> _fetchDebts() async {
    try {
      var fetchedDebts = await DebtService.fetchDebts();
      if (fetchedDebts != null && fetchedDebts.isNotEmpty) {
        debts.assignAll(fetchedDebts);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch debts: $e');
    }
  }

  Future<void> _navigateToCreateDebtScreen() async {
    final newDebt = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateDebtScreen()),
    );

    if (newDebt != null && newDebt is Debt) {
      debts.insert(0, newDebt);
    }
  }

  void _navigateToDebtDetailsScreen(Debt debt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DebtDetailsScreen(debt: debt)),
    );
  }

  @override
  void initState() {
    super.initState();
    getBudget();
    _fetchDebts();
    getRemainders(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 1)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 12, left: 0, right: 0, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                AvatarProfileImage(
                  url: Finance.plot,
                  height: 6,
                  width: 1,
                ),
                // Budget List
                FinanceWidgets.budgetHorizontalList(context),
                // const SizedBox(height: 10),
                // Budget and Debt Calculator
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FinanceWidgets.additionWidgets(
                    context,
                    _navigateToCreateDebtScreen,
                  ),
                ),
                // const SizedBox(height: 10),
                // Debts List
                FinanceWidgets.debtsPicture(
                    context, debts, _navigateToDebtDetailsScreen),
                // Calculators Header
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CardBuilders.globalText(
                    context: context,
                    text: "Calculators",
                    fontsize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                //  const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FinanceWidgets.calculatorList(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
