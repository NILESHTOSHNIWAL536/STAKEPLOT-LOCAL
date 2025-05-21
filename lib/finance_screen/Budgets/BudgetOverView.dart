import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  @override
  void initState() {
    super.initState();
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: AppColors.backgroundColor),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Colorcodes.paddingSize),
            textStyle(
                context: context,
                text: "Budget Overview",
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
                          EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(10)),
                      child: textStyle(
                          context: context,
                          text: "Total Amount",
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
                textStyle(
                    context: context,
                    text: " Estimation",
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
                  // Show loader
                
                  // Add budget
                   addBudget(context, widget.name, widget.amount,
                      categoriesDividedList, widget.period);

                  // Dismiss loader
                 
                },
                child: getButton(context, "Add Budget")),
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
                          controller: TextEditingController(
                            text: categoriesDividedList[index]['amount']
                                .toString(),
                          ),
                          decoration: InputDecoration(
                            //  prefixIcon: Icon(Icons.currency_rupee),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 4), // Removes extra spacing
                            isDense: true, // Reduces extra height
                            hintText: "Enter amount",
                            hintStyle: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w400,
                                fontSize: 12,
                                color: AppColors.accentColor),
                            errorText: _isAmountExceeded(index)
                                ? "Amount exceeds budget"
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) {
                            if (_validateAmount(value, widget.amount)) {
                              onsubmit(index, value);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Amount exceeds the total budget!"),
                                  backgroundColor: Colors.red,
                                ),
                              );
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

  void onsubmit(index, value) async {
    categoriesDividedList[index]['amount'] = double.tryParse(value) ?? 0;

    var d = await adjustBudget(double.parse(widget.amount),
        categoriesDividedList[index]['category'], double.parse(value), cat);
    // {Bills: 1500.67, Insurance: 1791.39, Travel: 2507.94}
    List categoryList = [];
    categoriesDividedList.forEach((e) {
      String name = e['category'];
      double amount = d[name]!;
      categoryList
          .add({'category': e['category'], 'amount': amount.toString()});
    });

    categoriesDividedList.clear();
    categoriesDividedList.addAll(List.from(categoryList));
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
