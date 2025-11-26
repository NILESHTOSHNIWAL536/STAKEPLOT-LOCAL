import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/BudgetSearch.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/financeWidgets.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/components/textfeild.dart';
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, "/FinanceDashboard");
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              textStyle(
                context: context,
                text: PlotFinanceStaticData().budgetPlannerTitle,
                fontsize: 20,
                fontWeight: FontWeight.w700,
                c: AppColors.primaryColor,
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double height = constraints.maxHeight;
              double width = constraints.maxWidth;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: getBudgetUiScreen(height, width, context),
              );
            },
          ),
        ),
        // bottomNavigationBar: BottomNavigations(data: 1),
      ),
    );
  }

  Widget getBudgetUiScreen(double height, double width, BuildContext context) {
    double responsivePadding =
        width > 600 ? 32 : 24; // Larger padding for tablets
    double fontScale =
        width > 600 ? 1.2 : 1.0; // Scale fonts for larger screens

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent History",
          style: FontManager().getTextStyle(
            context,
            fontSize: 16,
            color: AppColors.grey,
            lWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: FinanceWidgets.budgetHorizontalList(context),
        ),
        Container(
          width: MediaQuery.sizeOf(context).width / 1.2,
          height: MediaQuery.sizeOf(context).height / 1.7,
          // padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFFF3F4F6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: Text(
                      "Add budget",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 18,
                        color: AppColors.accentColor,
                        lWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFeildWidgetCustom(
                          textEditingController: nameController,
                          heading: PlotFinanceStaticData().nameLabel,
                          keyBoard: TextInputType.emailAddress,
                          lableText:
                              PlotFinanceStaticData().enterBudgetNameHint,
                          icon: Icons.person,
                        ),
                        SizedBox(height: 10),
                        TextFeildWidgetCustom(
                          textEditingController: amountController,
                          heading: PlotFinanceStaticData().amountLabelBudget,
                          keyBoard: TextInputType.number,
                          lableText:
                              PlotFinanceStaticData().enterAmountHintBudget,
                          icon: Icons.currency_rupee_rounded,
                          needAmountFormat: true,
                        ),
                        SizedBox(height: 10),
                        textStyle(
                          context: context,
                          text: PlotFinanceStaticData().durationLabel,
                          fontsize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                          c: AppColors.accentColor,
                        ),
                        SizedBox(height: 10),
                        // Improved Dropdown for duration selection
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 1),
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.mt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Obx(() => DropdownButton<String>(
                                value:
                                    period.value.isEmpty ? null : period.value,
                                hint: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: textStyle(
                                      context: context,
                                      text: "Select Duration",
                                      fontsize: 14 * fontScale,
                                      fontWeight: FontWeight.w300,
                                      c: AppColors.bg6,
                                    ),
                                  ),
                                ),
                                isExpanded: true,
                                underline:
                                    SizedBox(), // Remove default underline
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.accentColor,
                                  size: 24 * fontScale,
                                ),
                                dropdownColor: AppColors.backgroundColor,
                                items: [
                                  PlotFinanceStaticData().weeklyPeriod,
                                  PlotFinanceStaticData().monthlyPeriod,
                                  PlotFinanceStaticData().yearlyPeriod,
                                ].map((String periodItem) {
                                  return DropdownMenuItem<String>(
                                    value: periodItem,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: textStyle(
                                          context: context,
                                          text: periodItem,
                                          fontsize: 16 * fontScale,
                                          fontWeight: FontWeight.w500,
                                          c: AppColors.accentColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    period.value = newValue;
                                    boolFlag.value = !boolFlag.value;
                                    period.refresh();
                                  }
                                },
                                style: FontManager().getTextStyle(
                                  context,
                                  fontSize: 14 * fontScale,
                                  lWeight: FontWeight.w500,
                                  color: AppColors.bg3,
                                ),
                                itemHeight: 48, // Consistent item height
                                menuMaxHeight:
                                    200, // Limit dropdown menu height
                              )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      bedgetCalculator();
                    },
                    child: getButton(
                        context, PlotFinanceStaticData().continueButton),
                  ),
                  SizedBox(height: 20), // Extra padding at bottom for scroll
                ],
              ),
            ),
          ),
        ),
      ],
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
                  period.value == text ? AppColors.accentColor : AppColors.backgroundColor,
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
                c: period.value == text ? AppColors.backgroundColor : AppColors.bg3,
              ),
            ),
          ),
        ));
  }

  void bedgetCalculator() {
    if (nameController.text.isEmpty ||
        amountController.text.isEmpty ||
        period.value.isEmpty) {
      snackBarCalledfail(
          context, SnackbarData().fillAllRequiredFields, Colorcodes.red);
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BudgetSearch(
          amount: amountController.text,
          name: nameController.text,
          period: period.value,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // Start from bottom
          const end = Offset.zero; // End at normal position
          const curve = Curves.easeInOut;

          // Animation for the new screen (sliding up from bottom)
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var slideAnimation = animation.drive(tween);

          // Animation for the old screen (sliding up and out)
          var secondaryTween =
              Tween(begin: Offset.zero, end: const Offset(0.0, -1.0))
                  .chain(CurveTween(curve: curve));
          var secondarySlideAnimation =
              secondaryAnimation.drive(secondaryTween);

          return Stack(
            children: [
              SlideTransition(
                position: secondarySlideAnimation,
                child: Container(
                  color: AppColors
                      .backgroundColor, // Match your screen's background
                  child: const Budget(), // Current screen sliding out
                ),
              ),
              SlideTransition(
                position: slideAnimation,
                child: child, // New screen sliding in
              ),
            ],
          );
        },
        transitionDuration:
            const Duration(milliseconds: 300), // Animation duration
      ),
    );
  
  }
  // void bedgetCalculator() {
  //   if (nameController.text == "" ||
  //       amountController.text == "" ||
  //       period.value == "") {
  //     snackBarCalledfail(
  //         context, SnackbarData().fillAllRequiredFields, Colorcodes.red);
  //     return;
  //   }
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BudgetSearch(
  //         amount: amountController.text,
  //         name: nameController.text,
  //         period: period.value,
  //       ),
  //     ),
  //   );
  // }
}

Widget textStyle({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color c = AppColors.bg1,
  FontWeight fontWeight = FontWeight.w500,
  bool iswrap = false,
  double lineHeight = 1.0,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: 7),
      Text(
        text.toString(),
        style: FontManager().getTextStyle(context,
            lWeight: fontWeight,
            fontSize: fontsize,
            color: c,
            lineHeight: lineHeight),
        overflow: iswrap ? TextOverflow.visible : TextOverflow.ellipsis,
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
  bool isCenter = false,
  double lineHeight = 1.0,
}) {
  return Text(
    text.toString(),
    style: FontManager().getTextStyle(context,
        lWeight: fontWeight,
        fontSize: fontsize,
        color: c,
        lineHeight: lineHeight,
        textAlign: isCenter ? TextAlign.center : TextAlign.start),
    overflow: iswrap ? TextOverflow.visible : TextOverflow.ellipsis,
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
