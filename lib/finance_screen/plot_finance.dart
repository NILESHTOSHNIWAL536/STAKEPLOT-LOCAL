
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/cardBuilders.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/financeWidgets.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';


class PlotFinance extends StatefulWidget {
  const PlotFinance({super.key});

  @override
  State<PlotFinance> createState() => _PlotFinanceState();
}

class _PlotFinanceState extends State<PlotFinance> {
  


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

   final CommunityScreenStrings strings = CommunityScreenStrings();

  @override
  void initState() {
    super.initState();
    getBudget();
    fetchDebts();
    getRemainders(context);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 1)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 12, left: 0, right: 0, bottom: 0),
            child:  Column(
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
               
                getSearch(w,h),
               
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
                    text:  PlotFinanceStaticData().calculatorsTitle,
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

  Widget getSearch(double w,double h){
   
  
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
           Material(
              color: Colors.transparent,
             child: InkWell(
               onTap: () {
                 Navigator.pushNamed(context, '/TribeSearch');
               },
               child: Container(
                 width: MediaQuery.sizeOf(context).width / 1.26,
                 height: MediaQuery.sizeOf(context).height / 20,
                 child: TextField(
                   decoration: InputDecoration(
                     contentPadding:
                         EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                     filled: true,
                     enabled: false,
                     hintText: strings.searchHint,
                     fillColor: AppColors.button,
                     hintStyle: FontManager().getTextStyle(context,
                         lWeight: FontWeight.normal,
                         fontSize: 14,
                         color: Colors.black),
                     prefixIcon: Icon(Icons.search),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(24.0),
                     ),
                   ),
                 ),
               ),
             ),
           ),
           InkWell(
               onTap: () {
                ismaskedUsers.value=false;
                 Navigator.pushNamed(context, '/TribeChats');
               },
               child: AvatarProfileImage(
                 url: LikeComment.message,
                 height: 26,
                 width: 26,
                 
               
               ),
            ),
          
        ],
      ),
    );
  }
}
