import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
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
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            double width = constraints.maxWidth;
            return getBudgetUiScreen(height, width, context);
          },
        ),
      ),
     // bottomNavigationBar: BottomNavigations(data: 1),
    );
  }

  Widget getBudgetUiScreen(double height, double width, BuildContext context) {
    double responsivePadding =
        width > 600 ? 32 : 24; // Larger padding for tablets
    double fontScale =
        width > 600 ? 1.2 : 1.0; // Scale fonts for larger screens

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundColor,
            AppColors.accentColor.withOpacity(0.1),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: responsivePadding, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.account_balance_wallet,
                      color: AppColors.primaryColor, size: 22 * fontScale),
                  SizedBox(width: 12),
                  textStyle(
                    context: context,
                    text:  PlotFinanceStaticData().budgetPlannerTitle,
                    fontsize: 20 * fontScale,
                    fontWeight: FontWeight.bold,
                    c: AppColors.accentColor,
                  ),
                ],
              ),
              SizedBox(height: 8),
              textStyle(
                context: context,
                text: PlotFinanceStaticData().budgetPlannerDescription,
                fontsize: 14 * fontScale,
                fontWeight: FontWeight.w300,
                c: Colors.grey[600]!,
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(responsivePadding * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFeildWidgetCustom(
                      textEditingController: nameController,
                      heading: PlotFinanceStaticData().nameLabel, // Updated
                      keyBoard: TextInputType.emailAddress,
                      lableText: PlotFinanceStaticData().enterBudgetNameHint, // Updated
                      icon: Icons.person,
                    ),
                    SizedBox(height: 20),
                    TextFeildWidgetCustom(
                      textEditingController: amountController,
                      heading: PlotFinanceStaticData().amountLabelBudget, // Updated
                      keyBoard: TextInputType.number,
                      lableText: PlotFinanceStaticData().enterAmountHintBudget, // Updated
                      icon: Icons.currency_rupee_rounded,
                      needAmountFormat: true,
                    ),
                    SizedBox(height: 24),
                    textStyle(
                      context: context,
                      text: PlotFinanceStaticData().durationLabel, // Updated
                      fontsize: 16 * fontScale,
                      fontWeight: FontWeight.bold,
                      c: AppColors.accentColor,
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: boolFlag.value ? rowPer(width) : rowPer(width),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              InkWell(
                onTap: () {
                  bedgetCalculator();
                },
                 child: getButton(context, PlotFinanceStaticData().continueButton),
              ),
              SizedBox(height: 20), // Extra padding at bottom for scroll
            ],
          ),
        ),
      ),
    );
  }

  Widget rowPer(double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
       getPeriod(PlotFinanceStaticData().weeklyPeriod, width), // Updated
        getPeriod(PlotFinanceStaticData().monthlyPeriod, width), // Updated
        getPeriod(PlotFinanceStaticData().yearlyPeriod, width), 
      ],
    );
  }

  Widget getPeriod(String text, double width) {
    double buttonWidth =
        width > 400 ? width * 0.12 : width * 0.15; // Adjusted responsive width
    return Obx(() => GestureDetector(
          onTap: () {
            period.value = text;
            boolFlag.value = !boolFlag.value;
            period.refresh();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: buttonWidth.clamp(80, 120), // Min 80, max 120
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10), // Adjusted padding
            decoration: BoxDecoration(
              color:
                  period.value == text ? AppColors.accentColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: period.value == text
                  ? [
                      BoxShadow(
                        color: AppColors.accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: textStyle(
                context: context,
                text: text,
                fontWeight: FontWeight.w600,
                fontsize: 10, // Decreased font size
                c: period.value == text ? Colors.white : AppColors.bg3,
              ),
            ),
          ),
        ));
  }

  void bedgetCalculator() {
    if (nameController.text == "" ||
        amountController.text == "" ||
        period.value == "") {
      snackBarCalledfail(context,SnackbarData().fillAllRequiredFields, Colorcodes.red);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetSearch(
          amount: amountController.text,
          name: nameController.text,
          period: period.value,
        ),
      ),
    );
  }
}

Widget textStyle({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color c = AppColors.bg1,
  FontWeight fontWeight = FontWeight.w500,
  bool iswrap = false,
  double lineHeight=1.0 ,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: 7),
      Text(
        text.toString(),
        style: FontManager().getTextStyle(
              context,
              lWeight: fontWeight, fontSize: fontsize, color: c,
              lineHeight: lineHeight
            ),
        overflow: iswrap? TextOverflow.visible:TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget textStyleImage({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color c = AppColors.bg1,
  FontWeight fontWeight = FontWeight.w500,
  bool iswrap = false,
  double lineHeight=1.0 ,
}) {
  return Text(
    text.toString(),
    style: FontManager().getTextStyle(
          context,
          lWeight: fontWeight, fontSize: fontsize, color: c,
          lineHeight: lineHeight
        ),
    overflow: iswrap? TextOverflow.visible:TextOverflow.ellipsis,
  );
}

Widget textStyleAnimated({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color c = AppColors.bg1,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: 7),
      Text(
        text.toString(),
        style: FontManager().getTextStyle(context,
            lWeight: fontWeight, fontSize: fontsize, color: c),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget textStyleOnly({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color c = AppColors.bg1,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return Text(
    text.toString(),
    style: FontManager().getTextStyle(context,
        lWeight: fontWeight, fontSize: fontsize, color: c),
    overflow: TextOverflow.ellipsis,
  );
}

Widget textStyleOnly2({
  required BuildContext context,
  required String text,
  required double fontsize,
  required Color color,
  required FontWeight fontWeight,
}) {
  return Text(
    text,
    style: FontManager().getTextStyle(
      context,
      lWeight: fontWeight,
      fontSize: fontsize,
      color: color,
    ),
    overflow: TextOverflow.visible,
  );
}
