import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

class BudgetOverView extends StatefulWidget {
  final String amount;
  final String name;
  final String period;
  List categoryList;

  BudgetOverView({
    Key? key,
    required this.amount,
    required this.name,
    required this.period,
    required this.categoryList,
  }) : super(key: key);

  @override
  _BudgetOverViewState createState() => _BudgetOverViewState();
}

class _BudgetOverViewState extends State<BudgetOverView> {
  Map<String, double> updatedAmounts = {};
  bool _isProcessing = false;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
     createBudget.value = false;
    // Initialize controllers and focus nodes for each category
    for (var category in widget.categoryList) {
      _controllers.add(TextEditingController(
          text: category['amount']?.toString() ?? '0'));
      _focusNodes.add(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: getBudgetUiScreen(height, width),
        // bottomNavigationBar: BottomNavigations(data: 1),
      ),
    );
  }

  bool _validateAmount(String value, String totalBudget) {
    double enteredAmount = double.tryParse(value) ?? 0;
    double budgetAmount = double.tryParse(totalBudget) ?? 0;
    return enteredAmount <= budgetAmount;
  }

  bool _isAmountExceeded(int index) {
    double enteredAmount =
        double.tryParse(categoriesDividedList[index]['amount'].toString()) ?? 0;
    double budgetAmount = double.tryParse(widget.amount) ?? 0;
    return enteredAmount > budgetAmount;
  }

  Widget getBudgetUiScreen(double height, double width) {
    return Container(
      width: width,
      height: height,
      padding:const  EdgeInsets.symmetric(horizontal: 20),
      decoration:const  BoxDecoration(color: AppColors.backgroundColor),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Colorcodes.paddingSize),
            textStyle(
                context: context,
                text: PlotFinanceStaticData().budgetOverviewTitle,
                fontsize: 18,
                fontWeight: FontWeight.w500),
            SizedBox(height: Colorcodes.paddingSize),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding:
                         const  EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(10)),
                      child: textStyle(
                          context: context,
                          text: PlotFinanceStaticData().totalAmountLabel,
                          fontsize: 14,
                          fontWeight: FontWeight.w600)),
                  textStyle(
                      context: context,
                      text: "₹" + widget.amount,
                      fontsize: 16,
                      c: AppColors.primaryColor,
                      fontWeight: FontWeight.bold),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: Colorcodes.paddingSize),
            ),
            Row(
              children: [
                textStyle(
                    context: context,
                    text: "${widget.period}",
                    fontsize: 16,
                    fontWeight: FontWeight.w500,
                    c: AppColors.accentColor),
                    SizedBox(width:10),
                textStyle(
                    context: context,
                    text: PlotFinanceStaticData().totalAmountLabel,
                    fontsize: 16,
                    fontWeight: FontWeight.w500),
              ],
            ),
            SizedBox(
              height: Colorcodes.paddingCard / 2,
            ),
            Obx(() => categoryList()),
            SizedBox(
              height: Colorcodes.paddingCard / 2,
            ),
            InkWell(
                onTap: () async {
                  if (createBudget.value) return;
                  // Show loader
                  createBudget.value = true;
                   // Check if the sum of category amounts equals the total budget
                  double totalCategoryAmount = categoriesDividedList.fold(0, (sum, item) {
                    return sum + (double.tryParse(item['amount'].toString()) ?? 0);
                  });

                  if (totalCategoryAmount != double.tryParse(widget.amount)!) {
                    // Show error message if amounts do not match
                    snackBarCalledfail(context, SnackbarData().budgetAmountMismatch);
                    createBudget.value = false; // Dismiss loader
                    return;
                  }

                  // Add budget
                  addBudget(context, widget.name, widget.amount,
                      categoriesDividedList, widget.period);

                  // Dismiss loader
                },
                child: Obx(()=>createBudget.value?getspinner(context):getButton(
                    context, PlotFinanceStaticData().addBudgetButton))),
          ],
        ),
      ),
    );
  }

  Widget categoryList() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.55,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(categoriesDividedList.length, (index) {
            String urlAvatar = "";
            try {
              urlAvatar = Categories.link +
                  BudgetCategories2.listofCategories[
                      categoriesDividedList[index]['category']];
            } catch (e) {
              urlAvatar = Categories.link +
                  BudgetCategories2.listofCategories['Entertainment'];
            }

            return Column(
              children: [
                Container(
                  //padding: EdgeInsets.symmetric(horizontal: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: AvatarProfileImage(
                          url: urlAvatar,
                          width: 26,
                          height: 28,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          categoriesDividedList[index]['category']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                         
                           controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          
                          inputFormatters: allowDecimalInput(),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 4), 
                            isDense: true,
                            hintText: PlotFinanceStaticData().enterAmountHint,
                            hintStyle: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w400,
                                fontSize: 12,
                                color: AppColors.accentColor),
                            errorText: _isAmountExceeded(index)
                                ? PlotFinanceStaticData().amountExceedsBudget
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) {
                            if (_validateAmount(value, widget.amount)) {
                              onsubmit(index, value);
                               setState(() {});
                            } else {
                              snackBarCalled(context, SnackbarData().amountExceed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10), // Adds space between rows
              ],
            );
          }),
        ),
      ),
    );
  }

//   void onsubmit(index, value) async {
//     categoriesDividedList[index]['amount'] = double.tryParse(value) ?? 0;
// _controllers[index].text = value;
//     var d = await adjustBudget(double.parse(widget.amount),
//         categoriesDividedList[index]['category'], double.parse(value), cat);
//     // {Bills: 1500.67, Insurance: 1791.39, Travel: 2507.94}
//     List categoryList = [];
//     categoriesDividedList.forEach((e) {
//       String name = e['category'];
//       double amount = d[name]!;
//       categoryList
//           .add({'category': e['category'], 'amount': amount.toString()});
//     });

//     categoriesDividedList.clear();
//     categoriesDividedList.addAll(List.from(categoryList));
//   }
void onsubmit(int index, String value) async {
  double parsedValue = double.tryParse(value) ?? 0;
  if (!_validateAmount(value, widget.amount)) {
    snackBarCalled(context, SnackbarData().amountExceed);
    return;
  }

  // Update the current category's amount
  categoriesDividedList[index]['amount'] = parsedValue;
  _controllers[index].text = parsedValue.toString();

  // Call adjustBudget to redistribute the remaining budget
  var adjustedBudgets = await adjustBudget(
    double.parse(widget.amount),
    categoriesDividedList[index]['category'],
    parsedValue,
    widget.categoryList.map((e) => e['category'] as String).toList(),
  );

  // Update categoriesDividedList and controllers with new amounts
  setState(() {
    for (int i = 0; i < categoriesDividedList.length; i++) {
      String category = categoriesDividedList[i]['category'];
      if (adjustedBudgets.containsKey(category)) {
        categoriesDividedList[i]['amount'] = adjustedBudgets[category]!;
        _controllers[i].text = adjustedBudgets[category]!.toStringAsFixed(2);
      }
    }
  });
}
  Future<Map<String, double>> adjustBudget(
    double totalAmount,
    String updatedCategory,
    double updatedAmount,
    List<String> selectedCategories,
  ) async {
    updatedAmounts[updatedCategory] = updatedAmount;
    // Step 1: Calculate the total weight of selected categories
    Map<String, double> subcategoryWeights = {};
    categoryWeights.forEach((mainCategory, data) {
      data["subcategories"].forEach((subCategory, weight) {
        subcategoryWeights[subCategory] = weight.toDouble();
      });
    });

    Map<String, double> selectedWeights = {
      for (var category in selectedCategories)
        if (subcategoryWeights.containsKey(category))
          category: subcategoryWeights[category]!
    };

    // //updatedAmounts[updatedCategory]=updatedAmount;
    // double totalSelectedWeight = selectedWeights.values.fold(0, (a, b) => (a + b));

    double totalSelectedWeight = selectedWeights.entries
        .where((entry) => !updatedAmounts.containsKey(entry.key))
        .fold(0, (sum, entry) => sum + entry.value);

    // Step 2: Calculate the remaining budget after updated values
    double usedBudget = updatedAmounts.values.fold(0, (a, b) => a + b);
    double remainingBudget = totalAmount - usedBudget;

    // Step 3: Distribute remaining budget proportionally based on category weights
    Map<String, double> finalBudgets = {};
    selectedWeights.forEach((subCategory, weight) {
      if (!updatedAmounts.containsKey(subCategory)) {
        finalBudgets[subCategory] =
            ((remainingBudget * weight) / totalSelectedWeight)
                .clamp(0, double.infinity);
      } else {
        finalBudgets[subCategory] =
            updatedAmounts[subCategory]!; // Keep previous updates
      }
    });

    // Step 4: Round all amounts to 2 decimal places
    finalBudgets.updateAll((key, value) => (value * 100).roundToDouble() / 100);

    return finalBudgets;
  }

  Future<Map<String, double>> adjustBudget2(
      double totalAmount,
      String updatedCategory,
      double updatedAmount,
      List<String> selectedCategories) async {
    updatedAmounts['updatedCategory'] = updatedAmount;

    // Flatten the subcategories and calculate total weights
    Map<String, double> subcategoryWeights = {};
    categoryWeights.forEach((mainCategory, data) {
      (data["subcategories"] as Map<String, dynamic>)
          .forEach((subCategory, weight) {
        subcategoryWeights[subCategory] = weight.toDouble();
      });
    });

    // Filter only selected categories and calculate total weight
    Map<String, double> selectedWeights = {
      for (var category in selectedCategories)
        if (subcategoryWeights.containsKey(category))
          category: subcategoryWeights[category]!
    };

    double totalSelectedWeight = selectedWeights.values.reduce((a, b) => a + b);

    // Calculate the initial budget for selected subcategories
    Map<String, double> initialBudgets = {};
    selectedWeights.forEach((subCategory, weight) {
      initialBudgets[subCategory] =
          (totalAmount * weight) / totalSelectedWeight;
    });

    // Adjust the budget for the updated category
    double difference = updatedAmount - (initialBudgets[updatedCategory] ?? 0);
    initialBudgets[updatedCategory] = updatedAmount;

    // Redistribute the difference proportionally among other selected categories
    double remainingWeight =
        totalSelectedWeight - (selectedWeights[updatedCategory] ?? 0);
    if (remainingWeight > 0) {
      selectedWeights.forEach((subCategory, weight) {
        if (subCategory != updatedCategory) {
          double adjustment = (weight / remainingWeight) * difference;
          initialBudgets[subCategory] =
              ((initialBudgets[subCategory] ?? 0) - adjustment)
                  .clamp(0, double.infinity);
        }
      });
    }

    // Round to 2 decimal places for each budget
    initialBudgets
        .updateAll((key, value) => (value * 100).roundToDouble() / 100);

    return initialBudgets;
  }
}
