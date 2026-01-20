import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/BudgetOverView.dart';
import 'package:flutter_application_code_stakeplot/repository/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/components/textfeild.dart';
import 'package:get/get.dart';

import '../../Constants/core/app_padding_sizes.dart';

class BudgetSearch extends StatefulWidget {
  String amount;
  String name;
  String period;
  BudgetSearch(
      {Key? key,
      required this.amount,
      required this.name,
      required this.period})
      : super(key: key);

  @override
  _BudgetSearchState createState() => _BudgetSearchState();
}

class _BudgetSearchState extends State<BudgetSearch> {
  TextEditingController nameController = TextEditingController(text: "");
  String selectedValue =
      categoriesSeleted.length > 0 ? categoriesSeleted[0] : "";
  RxList<String> filteredCategories = <String>[].obs;
  RxBool isCategoriesUpdated = false.obs;
  final FocusNode _searchFocusNode = FocusNode(); // FocusNode for search field
  bool _isSearchFocused = false;
  // Declare a Map to track the deletion state for each category
  Map<String, bool> _isDeletingMap = {};

  @override
  void initState() {
    super.initState();
    getTopFiveCater();

    filteredCategories.assignAll(BudgetCategories2.categories);

    // Listen for search input changes
    nameController.addListener(() {
      filterCategories();
    });
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    // Initialize the deletion state for each category
    for (var category in categoriesSeleted) {
      _isDeletingMap[category] = false;
    }
  }

  // Filter categories based on the search query
  void filterCategories() {
    String query = nameController.text.toLowerCase();
    filteredCategories.value = BudgetCategories2.categories.where((category) {
      return category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
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

      body: GestureDetector(
        onTap: () {
          // Unfocus the search field when tapping outside
          if (_isSearchFocused) {
            _searchFocusNode.unfocus();
          }
        },
        // Prevent taps inside the search bar or container from unfocusing
        behavior: HitTestBehavior.opaque,
        child: SafeArea(child: getBudgetUiScreen(height, width)),
      ),

      // bottomNavigationBar: BottomNavigations(data: 1),
    );
  }

  Widget getBudgetUiScreen(height, width) {
    return Container(
      width: width,
      height: height / 1.1,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.2),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //   ),
        // ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Ensures bottom alignment
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textStyle(
                    context: context,
                    text: PlotFinanceStaticData().chooseCategoryTitle,
                    fontsize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: AppSizes.h10),
                  searchList(width, height),
                  SizedBox(height: AppSizes.h16),
                  Text(
                    PlotFinanceStaticData().curatedCategoriesText,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w300,
                        fontSize: 14,
                        color: AppColors.bg1),
                  ),
                  SizedBox(height: AppSizes.h16),
                  Obx(() => getListOfCat()),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: InkWell(
                onTap: () {
                  if (categoriesSeleted.isEmpty) {
                    // Show Snackbar if no category is selected
                    snackBarCalledfail(
                        context, SnackbarData().emptycategoryList);
                  } else {
                    calculateBudget(widget.amount, widget.name, widget.period);
                  }
                },
                child:
                    getButton(context, PlotFinanceStaticData().continueButton),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getListOfCat() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        spacing: 8.0, // Adjust spacing between items
        runSpacing: 8.0, // Adjust spacing between lines
        children: categoriesSeleted.map((name) {
          return getUipartOfCatero(context, name.toString());
        }).toList(),
      ),
    );
  }

  Widget getUipartOfCatero(BuildContext context, String name) {
    return Material(
      elevation: 1, // Adds a slight shadow effect
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.backgroundColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            textStyle(
              context: context,
              text: toUpperCase(name.toString()),
              fontsize: 14,
              fontWeight: FontWeight.w500,
            ),
             SizedBox(width: AppSizes.w8),
            AnimatedContainer(
              duration:
                  Duration(milliseconds: 200), // Duration of the animation
              transform: Matrix4.translationValues(
                  _isDeletingMap[name] == true ? 5.0 : 0.0,
                  0.0,
                  0.0), // Move slightly to the right
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isDeletingMap[name] =
                        true; // Trigger the animation for this specific category
                  });
                  // Vibration.vibrate(); // Vibrate on tap
                  Future.delayed(Duration(milliseconds: 200), () {
                    categoriesSeleted.remove(name);
                    getCategories.value = !getCategories.value;
                    setState(() {
                      _isDeletingMap[name] =
                          false; // Reset the animation state for this specific category
                    });
                  });
                },
                child: Icon(
                  Icons.delete,
                  color: const Color.fromARGB(255, 207, 118, 113),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchList(double width, double height) {
    return Container(
      width: width / 1.1,
      child: Column(
        children: [
          TextFeildWidgetCustom2(
            textEditingController: nameController,
            keyBoard: TextInputType.emailAddress,
            lableText: PlotFinanceStaticData().searchCategoryHint,
            icon: ProfileIcons.friends,
            flag: false,
            focusNode: _searchFocusNode,
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 250), // Smooth transition
            curve: Curves.fastOutSlowIn, // Natural curve for expansion
            child: _isSearchFocused
                ? Container(
                    width: width,
                    height: height / 3,
                    decoration: BoxDecoration(
                      color: Colorcodes.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Obx(() => getSearchBox()),
                    ),
                  )
                : SizedBox(), // Avoid unnecessary height when collapsed
          ),
        ],
      ),
    );
  }

  Widget getSearchBox() {
    return filteredCategories.isNotEmpty
        ? Column(
            children: filteredCategories.map((categorie) {
              return listViewOfcategorie(categorie);
            }).toList(),
          )
        : Center(
            child: Text(PlotFinanceStaticData().noCategoriesFound,
                style: TextStyle(color: Colors.grey)),
          );
  }

  Widget listViewOfcategorie(String categorie) {
    if (categoriesSeleted.contains(categorie)) return SizedBox.shrink();
    return InkWell(
      onTap: () {
        categoriesSeleted.add(categorie);
        getCategories.value = !getCategories.value;
        getCategories.refresh();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            AvatarProfileImage(
                url: Categories.link +
                    BudgetCategories2.listofCategories[categorie],
                width: 32,
                height: 34),
            SizedBox(width: AppSizes.w2),
            textStyle(
                context: context,
                text: categorie,
                fontsize: 14,
                fontWeight: FontWeight.w400)
          ],
        ),
      ),
    );
  }

  void calculateBudget(String amount, String name, String period) async {
    try {
      var categoryList = await getBudgetForCategoriesList(
          double.parse(amount.toString()), categoriesSeleted);
      cat.clear();
      categoriesDividedList.clear();
      categoriesDividedList.addAll(categoryList);
      categoriesDividedList.forEach((e) {
        cat.add(e['category']);
      });

      push(categoryList);
    } catch (e) {}
  }

  Future<List<Map<String, dynamic>>> getBudgetForCategoriesList(
      double amount, RxList expenseCategories) async {
    Set<String> activeMainCategories = {};
    Map<String, List<String>> categoriesMap = {};

    for (String subCategory in expenseCategories) {
      for (var entry in categoryWeights.entries) {
        String mainCategory = entry.key;
        var data = entry.value as Map<String, dynamic>;

        if ((data["subcategories"] as Map<String, dynamic>)
            .containsKey(subCategory)) {
          activeMainCategories.add(mainCategory);
          categoriesMap.putIfAbsent(mainCategory, () => []).add(subCategory);
        }
      }
    }

    double totalOriginalPercentage = activeMainCategories.fold(
        0, (sum, category) => sum + categoryWeights[category]?["percentage"]);

    double percentageMultiplier = 100 / totalOriginalPercentage;
    List<Map<String, dynamic>> result = [];

    for (String mainCategory in activeMainCategories) {
      var mainCategoryData =
          categoryWeights[mainCategory] as Map<String, dynamic>;
      List<String> subcategories = categoriesMap[mainCategory] ?? [];

      double adjustedMainPercentage =
          (mainCategoryData["percentage"]) * percentageMultiplier;
      double mainCategoryBudget = (amount * adjustedMainPercentage) / 100;
      double totalSubWeight = subcategories.fold(
          0,
          (sum, sub) =>
              sum +
              (mainCategoryData["subcategories"] as Map<String, dynamic>)[sub]);

      for (String sub in subcategories) {
        double originalWeight = double.parse(
            (mainCategoryData["subcategories"] as Map<String, dynamic>)[sub]
                .toString());
        double adjustedWeight = (originalWeight / totalSubWeight) * 100.0;
        double subBudget = (mainCategoryBudget * adjustedWeight) / 100.0;

        result.add({
          "category": sub,
          "amount": (subBudget * 100).round() / 100.0,
          "percentage": (adjustedWeight * 100).round() / 100.0
        });
      }
    }

    return result;
  }

  Future<Map<String, Map<String, dynamic>>> getBudgetForCategories(
      double amount, RxList expenseCategories) async {
    // Identify active main categories and map them to subcategories
    Set<String> activeMainCategories = {};
    Map<String, List<String>> categoriesMap = {};

    for (String subCategory in expenseCategories) {
      for (var entry in categoryWeights.entries) {
        String mainCategory = entry.key;
        var data = entry.value as Map<String, dynamic>;

        if ((data["subcategories"] as Map<String, dynamic>)
            .containsKey(subCategory)) {
          activeMainCategories.add(mainCategory);
          categoriesMap.putIfAbsent(mainCategory, () => []).add(subCategory);
        }
      }
    }

    // Calculate total percentage of active main categories
    double totalOriginalPercentage = activeMainCategories.fold(
        0,
        (sum, category) =>
            sum + (categoryWeights[category]?["percentage"] as double));

    double percentageMultiplier = 100 / totalOriginalPercentage;
    Map<String, Map<String, dynamic>> result = {};

    // Process each active main category
    for (String mainCategory in activeMainCategories) {
      var mainCategoryData =
          categoryWeights[mainCategory] as Map<String, dynamic>;
      List<String> subcategories = categoriesMap[mainCategory] ?? [];

      // Adjust main category percentage
      double adjustedMainPercentage =
          (mainCategoryData["percentage"] as double) * percentageMultiplier;
      double mainCategoryBudget = (amount * adjustedMainPercentage) / 100;

      // Calculate total weight of active subcategories
      double totalSubWeight = subcategories.fold(
          0,
          (sum, sub) =>
              sum +
              (mainCategoryData["subcategories"] as Map<String, dynamic>)[sub]);

      // Allocate budget for subcategories
      result[mainCategory] = {};
      for (String sub in subcategories) {
        double originalWeight =
            (mainCategoryData["subcategories"] as Map<String, dynamic>)[sub];
        double adjustedWeight = (originalWeight / totalSubWeight) * 100;
        double subBudget = (mainCategoryBudget * adjustedWeight) / 100;

        result[mainCategory]![sub] = {
          "amount":
              (subBudget * 100).round() / 100, // Rounds to 2 decimal places
          "percentage": (adjustedWeight * 100).round() / 100
        };
      }
    }

    return result;
  }

  void push(data) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BudgetOverView(
          amount: widget.amount,
          name: widget.name,
          period: widget.period,
          categoryList: data,
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
                      .backgroundColor, // Match BudgetSearch screen's background
                  child: BudgetSearch(
                    amount: widget.amount,
                    name: widget.name,
                    period: widget.period,
                  ), // Current screen sliding out
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
  // void push(data) {

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BudgetOverView(
  //         amount: widget.amount,
  //         name: widget.name,
  //         period: widget.period,
  //         categoryList: data,
  //       ),
  //     ),
  //   );
  // }
}
