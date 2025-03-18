// import 'dart:convert';

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/MyBudget.dart';

// import 'package:get/get.dart';

// class BudgetDisplay extends StatefulWidget {
//   const BudgetDisplay({Key? key}) : super(key: key);

//   @override
//   State<BudgetDisplay> createState() => _BudgetDisplayState();
// }

// class _BudgetDisplayState extends State<BudgetDisplay> {
//   @override
//   void initState() {
//     super.initState();
//     getBudget();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;

//     return SafeArea(
//       child: Scaffold(
//         body: getBudgetUiScreen(height, width, context),
//         bottomNavigationBar: BottomNavigations(data: 1),
//       ),
//     );
//   }

//   Widget getBudgetUiScreen(height, width, BuildContext context) {
//     return Container(
//       width: width,
//       height: height / 1.1,
//       padding: EdgeInsets.symmetric(
//         horizontal: 20,
//       ),
//       decoration: BoxDecoration(color: AppColors.backgroundColor),
//       child: SingleChildScrollView(
//         child: Expanded(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 height: Colorcodes.paddingSize / 1,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   textStyle(
//                       context: context,
//                       text: "Budgets",
//                       fontsize: 20,
//                       fontWeight: FontWeight.bold),
//                   // IconButton(
//                   //     onPressed: () {
//                   //       Navigator.pushNamed(context, "/Budget");
//                   //     },
//                   //     icon: Icon(
//                   //       Icons.add,
//                   //       size: 30,
//                   //       color: AppColors.primaryColor,
//                   //     ))
//                 ],
//               ),
//               SizedBox(
//                 height: Colorcodes.paddingSize / 1,
//               ),
//               InkWell(
//                 onTap: () {
//                   Navigator.pushNamed(context, "/Budget");
//                 },
//                 child: Container(
//                   height: Colorcodes.paddingSize * 2,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: AppColors.button),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.add,
//                         size: 30,
//                         color: AppColors.primaryColor,
//                       ),
//                       Text("Create new budget")
//                     ],
//                   ),
//                 ),
//               ),
//               budgetContainerList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget budgetContainerList() {
//     return Obx(() => Column(
//           children: budgetList.map((data) {
//             return containerCardBudget(data);
//           }).toList(),
//         ));
//   }

//   Widget containerCardBudget(data) {
//     return GestureDetector(
//       onTap: () {
//         // print("data....////////////////////////////////////////");
//         // print(data);
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => MyBudgetScreen(data: data)),
//         );
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width / 1.1,
//         height: MediaQuery.of(context).size.height / 6.6,
//         decoration: BoxDecoration(
//           color: AppColors.mt,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         padding: const EdgeInsets.fromLTRB(10, 7, 0, 10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(bottom: Colorcodes.paddingSize / 2),
//                   child: Expanded(
//                     child: textStyle(
//                         context: context,
//                         text: data['name'],
//                         fontWeight: FontWeight.w500,

//                         fontsize: 16),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                       vertical: Colorcodes.paddingSize / 2),
//                   child: textStyle(
//                       context: context,
//                       text: data['budgetPeriod'],
//                       fontWeight: FontWeight.w500,
//                       fontsize: 16),
//                 ),
//                 textStyle(
//                     context: context,
//                     text: 'Amount',
//                     fontWeight: FontWeight.w300,
//                     fontsize: 14),
//                 textStyle(
//                     context: context,
//                     text: "₹${data['amount']}",
//                     fontWeight: FontWeight.w600,
//                     fontsize: 20),
//               ],
//             ),
//             AvatarProfileImage(
//               url: Finance.addBudget,
//               height: 10,
//               width: 12,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/MyBudget.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: AppColors.backgroundColor),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Colorcodes.paddingSize),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                globalText(
                  context: context,
                  text: "Budgets",
                  fontsize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(height: Colorcodes.paddingSize),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/Budget");
              },
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
                    Text("Create new budget"),
                  ],
                ),
              ),
            ),
            budgetContainerList(),
          ],
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
          MaterialPageRoute(builder: (context) => MyBudgetScreen(data: data)),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        height: MediaQuery.of(context).size.height / 6.4,
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Constrain the text column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: Colorcodes.paddingSize / 2),
                  child: globalText(
                    context: context,
                    text: data['name'],
                    fontWeight: FontWeight.w500,
                    fontsize: 16,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Colorcodes.paddingSize / 3),
                  child: globalText(
                    context: context,
                    text: data['budgetPeriod'],
                    fontWeight: FontWeight.w500,
                    fontsize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                globalText(
                  context: context,
                  text: 'Amount',
                  fontWeight: FontWeight.w300,
                  fontsize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
                globalText(
                  context: context,
                  text: "₹${data['amount']}",
                  fontWeight: FontWeight.w600,
                  fontsize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            // Fixed-size avatar
            AvatarProfileImage(
              url: Finance.addBudget,
              height: 10,
              width: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Global textStyle function (assuming this is in app_styles.dart)
TextStyle textStyle4({
  required BuildContext context,
  required String text,
  double fontsize = 14.0,
  FontWeight fontWeight = FontWeight.normal,
  Color? color,
  TextOverflow? overflow,
  TextDecoration? decoration,
  String? fontFamily,
}) {
  return FontManager()
      .getTextStyle(
        context,
        lWeight: fontWeight,
        fontSize: fontsize,
        color: color ?? Colors.black,
      )
      .copyWith(
        overflow: overflow ?? TextOverflow.clip,
        decoration: decoration,
        fontFamily: fontFamily,
      );
}

Widget globalText({
  required BuildContext context,
  required String text,
  double fontsize = 14.0,
  FontWeight fontWeight = FontWeight.normal,
  Color? color,
  TextOverflow? overflow,
  int? maxLines,
  TextDecoration? decoration,
  String? fontFamily,
}) {
  return Text(
    text,
    style: textStyle4(
      context: context,
      text: text,
      fontsize: fontsize,
      fontWeight: fontWeight,
      color: color,
      overflow: overflow,
      decoration: decoration,
      fontFamily: fontFamily,
    ),
    maxLines: maxLines,
    overflow: overflow ?? TextOverflow.clip,
  );
}
