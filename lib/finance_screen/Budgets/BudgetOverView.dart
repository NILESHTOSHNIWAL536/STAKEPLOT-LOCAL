
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/repository/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';

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
  List<bool> _isEditing = []; // Tracks editing state for each category
  List<double> _initialAmounts = []; // Stores initial amounts for each category
final budgetController = Get.find<BudgetController>();
  @override
  void initState() {
    super.initState();
    createBudget.value = false;

    // Initialize controllers, focus nodes, editing state, and initial amounts
    for (var category in widget.categoryList) {
      double initialAmount =
          double.tryParse(category['amount']?.toString() ?? '0') ?? 0;
      _controllers
          .add(TextEditingController(text: initialAmount.toStringAsFixed(2)));
      _focusNodes.add(FocusNode());
      _isEditing.add(true); // Start in editing mode (TextField)
      _initialAmounts.add(initialAmount);
    }

    // Pre-populate amounts by distributing the total budget
    _initializeBudgetDistribution();
  }

  Future<void> _initializeBudgetDistribution() async {
    var adjustedBudgets = await adjustBudget(
      double.parse(widget.amount),
      widget.categoryList.isNotEmpty ? widget.categoryList[0]['category'] : '',
      widget.categoryList.isNotEmpty
          ? double.parse(widget.categoryList[0]['amount']?.toString() ?? '0')
          : 0,
      widget.categoryList.map((e) => e['category'] as String).toList(),
    );

    setState(() {
      for (int i = 0; i < categoriesDividedList.length; i++) {
        String category = categoriesDividedList[i]['category'];
        if (adjustedBudgets.containsKey(category)) {
          categoriesDividedList[i]['amount'] = adjustedBudgets[category]!;
          _controllers[i].text = adjustedBudgets[category]!.toStringAsFixed(2);
          _initialAmounts[i] =
              adjustedBudgets[category]!; // Store initial amount
        }
      }
      // Set all categories to display mode after initial distribution
      for (int i = 0; i < _isEditing.length; i++) {
        _isEditing[i] = false;
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
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
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child: getBudgetUiScreen(height, width)),
    );
  }

  bool _validateAmount(String value, String totalBudget) {
    double enteredAmount = double.tryParse(value) ?? 0;
    double budgetAmount = double.tryParse(totalBudget) ?? 0;
    return enteredAmount <= budgetAmount;
  }

  void _onFocusLost(int index, String value) async {
    double parsedValue = double.tryParse(value) ?? 0;
    if (!_validateAmount(value, widget.amount)) {
      snackBarCalledfail(context, SnackbarData().amountExceed);
      return;
    }

    // Update the current category's amount
    categoriesDividedList[index]['amount'] = parsedValue;
    _controllers[index].text = parsedValue.toStringAsFixed(2);

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
      _isEditing[index] = false; // Switch to display mode after submit
    });
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
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
      decoration: const BoxDecoration(color: AppColors.backgroundColor),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSizes.h20),
            textStyle(
                context: context,
                text: PlotFinanceStaticData().budgetOverviewTitle,
                fontsize: 18,
                fontWeight: FontWeight.w500),
            SizedBox(height: AppSizes.h20),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textStyle(
                      context: context,
                      text: PlotFinanceStaticData().totalAmountLabel,
                      fontsize: 14,
                      fontWeight: FontWeight.w400),
                  textStyle(
                      context: context,
                      text: "₹" + widget.amount,
                      fontsize: 16,
                      c: AppColors.primaryColor,
                      fontWeight: FontWeight.w500),
                ],
              ),
            ),
            SizedBox(
              height: AppSizes.h20,
            ),
            Obx(() => categoryList()),
            SizedBox(
              height: AppSizes.h10,
            ),
            InkWell(
                onTap: () async {
                  if (createBudget.value) return;
                  // Show loader
                  createBudget.value = true;
                  // Check if the sum of category amounts equals the total budget
                  double totalCategoryAmount =
                      categoriesDividedList.fold(0, (sum, item) {
                    return sum +
                        (double.tryParse(item['amount'].toString()) ?? 0);
                  });

                  if (totalCategoryAmount != double.tryParse(widget.amount)!) {
                    // Show error message if amounts do not match
                    snackBarCalledfail(
                        context, SnackbarData().budgetAmountMismatch);
                    createBudget.value = false; // Dismiss loader
                    return;
                  }

                  // Add budget
                  budgetController.addBudget(context, widget.name, widget.amount,
                      categoriesDividedList, widget.period);

                  // Dismiss loader
                },
                child: Obx(() => createBudget.value
                    ? getspinner(context)
                    : getButton(
                        context, PlotFinanceStaticData().addBudgetButton))),
          ],
        ),
      ),
    );
  }

  Widget categoryList() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.65,
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
                  padding: EdgeInsets.all(13),
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                         width: MediaQuery.sizeOf(context).width/8.4,
                        //  color: Colors.amber,
                        child: AvatarProfileImage(
                          url: urlAvatar,
                          width: 26,
                          height: 28,
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width/3.4,
                       
                        child: Text(
                          categoriesDividedList[index]['category']!,
                          style:  FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: AppColors.accentColor,
                                  ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _isEditing[index]
                            ? TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                inputFormatters: allowDecimalInput(),
                                // keyboardType: TextInputType.,
                                decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 4,
                                  ),
                                  isDense: true,
                                  hintText:
                                      PlotFinanceStaticData().enterAmountHint,
                                  hintStyle: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: AppColors.accentColor,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorText: _isAmountExceeded(index)
                                      ? PlotFinanceStaticData()
                                          .amountExceedsBudget
                                      : null,
                                ),
                                onSubmitted: (value) {
                                  if (_validateAmount(value, widget.amount)) {
                                    onsubmit(index, value);
                                  } else {
                                    snackBarCalledfail(
                                        context, SnackbarData().amountExceed);
                                  }
                                },
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditing[index] =
                                        true; // Switch to edit mode
                                    _focusNodes[index]
                                        .requestFocus(); // Focus the TextField
                                  });
                                },
                                child: Text(
                                  "₹${categoriesDividedList[index]['amount'].toStringAsFixed(2)}/₹${_initialAmounts[index].toStringAsFixed(2)}",
                                  style:  FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.grey,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.h10), // Adds space between rows
              ],
            );
          }),
        ),
      ),
    );
  }

  void onsubmit(int index, String value) async {
    double parsedValue = double.tryParse(value) ?? 0;
    if (!_validateAmount(value, widget.amount)) {
      snackBarCalledfail(context, SnackbarData().amountExceed);
      return;
    }

    // Update the current category's amount
    categoriesDividedList[index]['amount'] = parsedValue;
    _controllers[index].text = parsedValue.toStringAsFixed(2);

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
      _isEditing[index] = false; // Switch to display mode after submit
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
