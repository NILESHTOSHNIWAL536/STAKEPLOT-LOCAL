import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/BudgetOverView.dart';

import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:get/get.dart';

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
  String selectedValue = categoriesSeleted[0] ?? "";
  RxList<String> filteredCategories = <String>[].obs;
  RxBool isCategoriesUpdated = false.obs;
final FocusNode _searchFocusNode = FocusNode(); // FocusNode for search field
  bool _isSearchFocused = false; 
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: getBudgetUiScreen(height, width),
        // bottomNavigationBar: BottomNavigations(data: 1),
      ),
    );
  }

  Widget getBudgetUiScreen(height, width) {
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
                height: Colorcodes.paddingSize,
              ),
              textStyle(
                  context: context,
                  text: "Budget Categories",
                  fontsize: 20,
                  fontWeight: FontWeight.bold),
              SizedBox(
                height: Colorcodes.paddingSize / 2,
              ),
              searchList(width, height),
              SizedBox(
                height: Colorcodes.paddingSize,
              ),
               Obx(() => getListOfCat()),
              SizedBox(
                height: Colorcodes.paddingSize,
              ),
              InkWell(
                  onTap: () {
                    calculateBudget(widget.amount, widget.name, widget.period);
                  },
                  child: getButton(context, "Continue")),
            ],
          ),
        ),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colorcodes.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          textStyle(
              context: context,
              text: toUpperCase(name.toString()),
              fontsize: 16),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              categoriesSeleted.remove(name);
              getCategories.value = !getCategories.value;
            },
            child: Icon(
              Icons.close,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget searchList(double width, double height) {
    return Container(
      width: width / 1.1,
      child: Column(
        children: [
          TextFeildWidgetCustom(
            textEditingController: nameController,
            heading: "Search",
            keyBoard: TextInputType.emailAddress,
            lableText: "Search for category",
            icon: ProfileIcons.friends,
            flag: false,

            focusNode: _searchFocusNode,
          ),
          AnimatedContainer(
            width: width,
            height: _isSearchFocused ? height / 3 : 0, // Expand or collapse
            duration: Duration(milliseconds: 100), // Animation duration
            curve: Curves.easeInOut, // Animation curve
            decoration: BoxDecoration(
                color: Colorcodes.white,
                borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Obx(() => getSearchBox()),
            ),
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
            child: Text("No categories found", style: TextStyle(color: Colors.grey)),
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
                url: Categories.link + BudgetCategories2.listofCategories[categorie], width: 25, height: 26),
            const SizedBox(
              width: 20,
            ),
            textStyle(context: context, text: categorie,fontsize: 17,fontWeight: FontWeight.w400)
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
      categoriesDividedList.forEach((e){
            cat.add(e['category']);
      });

      push(categoryList);
    } catch (e) {
    
    }
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
      MaterialPageRoute(
        builder: (context) => BudgetOverView(
          amount: widget.amount,
          name: widget.name,
          period: widget.period,
          categoryList: data,
        ),
      ),
    );
  }
}