import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/finanace_dashboard/financeWidgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../Utils/credit_card.dart';
import '../../Constants/colorcodes.dart';
import 'creditCard_slider.dart';

class ShowCompleteInfo extends StatefulWidget {
  int index = 0;
  ShowCompleteInfo({Key? key, this.index = 0}) : super(key: key);

  @override
  State<ShowCompleteInfo> createState() => _ShowCompleteInfoState();
}

class _ShowCompleteInfoState extends State<ShowCompleteInfo> {
  final List<String> titles = [
    "Credit Card",
    "Budget",
    "Debt",
  ];

  final List<String> routes = [
    "/addcreditCard",
    "/Budget",
    "/debt",
  ];

  final List<String> svgs = [
    svgIconPath.dio1,
    svgIconPath.dio2,
    svgIconPath.dio3,
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex =
        CreditCardScreenStrings().showCreditCard.value ? widget.index : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.backgroundColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Complete Info",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 18,
              overflow: TextOverflow.ellipsis,
              color: AppColors.backgroundColor,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.1,
          child: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              getTabs(context),
              getCardContent()
            ],
          ),
        ));
  }

  void _navigateToDebtDetailsScreen(Debt debt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DebtDetailsScreen(debt: debt)),
    );
  }

  Widget getCardContent() {
    switch (selectedIndex) {
      case 0:
        return Expanded(
            child: CardDueCarousel(
          flag: false,
        ));
      case 1:
        return Center(
          child: FinanceWidgets.budgetHorizontalList2(context),
        );
      case 2:
        return Center(
          child: FinanceWidgets.debtsPicture2(
              context, debts, _navigateToDebtDetailsScreen),
        );
      default:
        return Center(child: Text("Unknown Content"));
    }
  }

  Widget getTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // const SizedBox(height: 22),
        // Option Buttons
        for (int i = CreditCardScreenStrings().showCreditCard.value ? 0 : 1;
            i < routes.length;
            i++) ...[
          InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () {
              setState(() => selectedIndex = i);  
              // Navigator.pushNamed(context, routes[i]);
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 3.4,
              height: MediaQuery.sizeOf(context).height / 9,
              decoration: BoxDecoration(
                color:
                    selectedIndex == i ? const Color(0xFF635D8F) : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFFF3F4F6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              // decoration: BoxDecoration(
              //   color:
              //       selectedIndex == i ? const Color(0xFF635D8F) : AppColors.backgroundColor,
              //   borderRadius: BorderRadius.circular(9),
              //   border: selectedIndex == i
              //       ? null
              //       : Border.all(color: const Color(0xFF635D8F), width: 1),
              // ),
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16, horizontal: 10),
              margin: const EdgeInsets.all(5),
              child: Column(
                children: [
                  SvgPicture.asset(
                    svgs[i],
                    width: 32,
                    height: 32,
                    color: selectedIndex == i
                        ? AppColors.backgroundColor
                        : const Color(0xFF635D8F),
                  ),
                  SizedBox(height: AppSizes.h4),
                  Text(
                    titles[i],
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      color: selectedIndex == i
                          ? AppColors.backgroundColor
                          : AppColors.primaryColor,
                    ),
                    // style: TextStyle(
                    //   fontSize: 15.5,
                    //   fontWeight: FontWeight.w500,
                    //   color: selectedIndex == i
                    //       ? AppColors.backgroundColor
                    //       : const Color(0xFF37344F),
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
