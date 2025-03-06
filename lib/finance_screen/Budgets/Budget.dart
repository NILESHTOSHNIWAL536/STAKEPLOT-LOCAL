import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/BudgetSearch.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:get/get.dart';

RxList categoriesSeleted = [].obs;
RxList categoriesDividedList = [].obs;

RxList<String> cat = <String>[].obs;
RxBool getCategories = false.obs;
Map<String, dynamic> categoryWeights = {
  "Essentials": {
    "percentage": 50.0,
    "subcategories": {
      "Food": 15.0,
      "Health": 8.0,
      "Bills": 10.0,
      "Education": 7.0,
      "Insurance": 5.0,
      "Personal Care": 3.0,
      "Pet Care": 2.0
    }
  },
  "Lifestyle": {
    "percentage": 30.0,
    "subcategories": {
      "Snacks": 3.0,
      "Travel": 7.0,
      "Entertainment": 5.0,
      "Shopping": 5.0,
      "Services": 2.0,
      "Events": 2.0,
      "Sports": 3.0,
      "Alcohol": 3.0
    }
  },
  "Savings": {
    "percentage": 20.0,
    "subcategories": {"Investments": 10.0, "Emi": 8.0, "Hobbies": 2.0}
  }
};

class Budget extends StatefulWidget {
  const Budget({Key? key}) : super(key: key);

  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController amountController = TextEditingController(text: "");
  RxString period = "".obs;
  RxBool boolFlag = false.obs;

  @override
  void initState() {
    super.initState();
    getTopFiveCater();
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: Colorcodes.paddingSize,
          ),
          textStyle(
              context: context,
              text: "Budget Calculator",
              fontsize: 20,
              fontWeight: FontWeight.bold),
          SizedBox(
            height: Colorcodes.paddingSize / 2,
          ),
          SizedBox(
            height: Colorcodes.paddingSize / 2,
          ),
          TextFeildWidgetCustom(
            textEditingController: nameController,
            heading: "Name",
            keyBoard: TextInputType.emailAddress,
            lableText: "Enter budget name",
            icon: Finance.user,
          ),
          TextFeildWidgetCustom(
            textEditingController: amountController,
            heading: "Amount",
            keyBoard: TextInputType.number,
            lableText: "Enter amount",
            icon: Finance.amt,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize),
            child: textStyle(
                context: context,
                text: "Duration",
                fontsize: 20,
                fontWeight: FontWeight.bold),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colorcodes.white,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(vertical: 3),
            child: Center(
              child: boolFlag.value ? rowPer() : rowPer(),
            ),
          ),
          SizedBox(
            height: Colorcodes.paddingSize,
          ),
          InkWell(
              onTap: () {
                bedgetCalculator();
              },
              child: getButton(context, "Continue")),
        ],
      ),
    );
  }

  Widget rowPer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        getPeriod("Weekly"),
        getPeriod("Monthly"),
        getPeriod("Yearly"),
      ],
    );
  }

  Widget getPeriod(text) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              color: period.value == text
                  ? Colorcodes.greyLight
                  : Colorcodes.white,
              borderRadius: BorderRadius.circular(20)),
          child: InkWell(
              onTap: () {
                period.value = text;
                boolFlag.value = !boolFlag.value;
                period.refresh();
              },
              child: textStyle(
                  context: context,
                  text: text,
                  fontWeight: FontWeight.w300,
                  //  c: period.value != text ? Colorcodes.greyLight : Colorcodes.white,
                  fontsize: 14)),
        ));
  }

  void bedgetCalculator() {
    if (nameController.text == "" ||
        amountController.text == "" ||
        period.value == "") {
      snackBarCalled(context, "Please Enter All Fields", Colorcodes.red);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetSearch(
            amount: amountController.text,
            name: nameController.text,
            period: period.value),
      ),
    );
  }
}

Widget textStyle(
    {required BuildContext context,
    text,
    double fontsize = 12,
    Color c = AppColors.bg1,
    FontWeight fontWeight = FontWeight.w500}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(
        width: 7,
      ),
      Text(
        text.toString(),
        style: FontManager().getTextStyle(context,
            lWeight: fontWeight, fontSize: fontsize, color: c),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget textStyleOnly(
    {required BuildContext context,
    text,
    double fontsize = 12,
    Color c = AppColors.bg1,
    FontWeight fontWeight = FontWeight.w500}) {
  return Text(
    text.toString(),
    style: FontManager().getTextStyle(context,
        lWeight: fontWeight, fontSize: fontsize, color: c),
    overflow: TextOverflow.ellipsis,
  );
}
// Create a new file, e.g., `lib/utils/text_utils.dart`

 Widget textStyleOnly2({
    required BuildContext context,
    required String text, // Made text required and explicitly typed
    required double fontsize, // No default, must be specified
    required Color color, // No default, must be specified
   required FontWeight fontWeight, // Keep default for fontWeight
  }) {
    return Text(
      text,
      style: FontManager().getTextStyle(
        context,
        lWeight: fontWeight,
        fontSize: fontsize,
        color: color,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
