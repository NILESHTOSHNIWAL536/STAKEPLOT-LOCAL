import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';


class DebtCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DebtListScreen();
  }
}

// Screen 1: Debt List Screen
class DebtListScreen extends StatefulWidget {
  @override
  _DebtListScreenState createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  List<Debt> debts = [];
  void initState() {
    super.initState();
    _fetchDebts();
  }

  Future<void> _fetchDebts() async {
    try {
      var fetchedDebts = await DebtService.fetchDebts();
      if (fetchedDebts != null) {
        setState(() {
          debts = fetchedDebts;
        });
      }
    } catch (e) {
      print('Failed to fetch debts: $e');
    }
  }

  Future<void> _navigateToCreateDebtScreen() async {
    final newDebt = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateDebtScreen()),
    );

    if (newDebt != null) {
      setState(() {
         debts.insert(0, newDebt);
      });
    }
  }
 void _navigateToDebtDetailsScreen(Debt debt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DebtDetailsScreen(debt: debt)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Debt List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: _navigateToCreateDebtScreen,
              child: Container(
                height: Colorcodes.paddingSize * 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.button,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 30,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 8), // Adds some space between icon and text
                    Text("Create new Debt"),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: debts.length,
              itemBuilder: (context, index) {
                final debt = debts[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to the debt details screen when a debt item is tapped
                    _navigateToDebtDetailsScreen(debt);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                      color: AppColors.mt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                    
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(debt.name),SizedBox(
                                height: Colorcodes.paddingSize / 2,
                              ),
                              Text(
                                'Amount',
                                style: FontManager().getTextStyle(context,
                                    fontSize: 14,
                                    color: AppColors.bg1,
                                    lWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                height: Colorcodes.paddingSize / 3,
                              ),
                              Text(
                                '\₹${debt.amount.toStringAsFixed(2)}',
                                style: FontManager().getTextStyle(context,
                                    fontSize: 20,
                                    color: AppColors.bg1,
                                    lWeight: FontWeight.bold),
                              ),
                              
                        
                          ],
                        ),
                        AvatarProfileImage(
                  url: Finance.addBudget,
                  height: 10,
                  width: 12,
                                ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
