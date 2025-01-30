
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/MyBudget.dart';
import 'package:get/get.dart';

class BudgetDisplay extends StatefulWidget {
  const BudgetDisplay({Key? key}) : super(key: key);

  @override
  State<BudgetDisplay> createState() => _BudgetDisplayState();
}

class _BudgetDisplayState extends State<BudgetDisplay> {
  @override
  void initState() {
    super.initState();
    getBudget();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: getBudgetUiScreen(height, width, context),
        bottomNavigationBar: BottomNavigations(data: 1),
      ),
    );
  }

  Widget getBudgetUiScreen(height, width, BuildContext context) {
    return Container(
      width: width,
      height: height / 1.1,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(color: AppColors.backgroundColor),
      child: SingleChildScrollView(
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Colorcodes.paddingSize / 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textStyle(
                      context: context,
                      text: "Budgets",
                      fontsize: 20,
                      fontWeight: FontWeight.bold),
                  // IconButton(
                  //     onPressed: () {
                  //       Navigator.pushNamed(context, "/Budget");
                  //     },
                  //     icon: Icon(
                  //       Icons.add,
                  //       size: 30,
                  //       color: AppColors.primaryColor,
                  //     ))
                ],
              ),
              SizedBox(
                height: Colorcodes.paddingSize / 1,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/Budget");
                },
                child: Container(
                  height: Colorcodes.paddingSize * 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.button),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 30,
                        color: AppColors.primaryColor,
                      ),
                      Text("Create new budget")
                    ],
                  ),
                ),
              ),
              budgetContainerList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget budgetContainerList() {
    return Obx(() => Column(
          children: budgetList.map((data) {
            return containerCardBudget(data);
          }).toList(),
        ));
  }

  Widget containerCardBudget(data) {
    return GestureDetector(
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MyBudgetScreen.example()),
  );
},

      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: Colorcodes.paddingSize / 2),
                    child: Row(
                      children: [
                        textStyle(
                            context: context,
                            text: data['name'],
                            fontWeight: FontWeight.w500,
                            fontsize: 16),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: Colorcodes.paddingSize / 2),
                    child: textStyle(
                        context: context,
                        text: data['budgetPeriod'],
                        fontWeight: FontWeight.w500,
                        fontsize: 16),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: Colorcodes.paddingSize / 2),
                    child: textStyle(
                        context: context,
                        text: 'Amount spent',
                        fontWeight: FontWeight.w300,
                        fontsize: 14),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: Colorcodes.paddingSize / 2),
                    child: textStyle(
                        context: context,
                        text: "₹${data['amount']}",
                        fontWeight: FontWeight.w500,
                        fontsize: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: AvatarProfileImage(
                url: Finance.addBudget,
                height: 10,
                width: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
