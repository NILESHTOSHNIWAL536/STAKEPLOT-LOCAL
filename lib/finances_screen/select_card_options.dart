import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/email_sync/custom_steps.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Constants/colors.dart';
import '../Utils/credit_card.dart';
import '../colorcodes.dart';

class SelectAnyOptionScreen extends StatefulWidget {
  const SelectAnyOptionScreen({Key? key}) : super(key: key);

  @override
  State<SelectAnyOptionScreen> createState() => _SelectAnyOptionScreenState();
}

class _SelectAnyOptionScreenState extends State<SelectAnyOptionScreen> {
  int selectedIndex = 0;

  final List<String> titles = [
    "Add Credit Card",
    "Create Budget",
    "Add Debt",
  ];
  final List<String> subtitles = [
    "Securely link your card to track expenses with ease.",
    "Set spending limits and track your financial goals.",
    "Manage and track your outstanding debts and loans.",
  ];
  final List<String> svgs = [
    svgIconPath.dio1,
    svgIconPath.dio2,
    svgIconPath.dio3,
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: leadIcon(context),
          title: textStyleImage(
              context: context,
              text: "Get Started",
              c: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
              fontsize: 20),
          centerTitle: true,
          actions: [SizedBox(width: 38)], // for symmetry
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.07),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Option Buttons
            for (int i = CreditCardScreenStrings().showCreditCard.value? 0:1; i < 3; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () {
                  setState(() => selectedIndex = i);
                  String options = "";
                  if (i == 0) {
                    options = "/addcreditCard";
                  } else if (i == 1) {
                    options = "/Budget";
                  } else {
                    options = "/debt";
                  }
                  // Navigator.of(context).pop();
                  // Navigator.pushNamed(context2, "/FinanceDashboard");
                  Navigator.pushNamed(context, options);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFFF3F4F6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          offset: Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    // margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          svgs[i],
                          width: 32,
                          height: 32,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(height: 12),
                        textStyleImage(
                            context: context,
                            text: titles[i],
                            c: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontsize: 18),
                        SizedBox(height: 12),
                        textStyleImage(
                            context: context,
                            text: subtitles[i],
                            c: AppColors.grey,
                            fontWeight: FontWeight.w400,
                            fontsize: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
