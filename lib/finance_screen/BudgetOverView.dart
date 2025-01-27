import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
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

    RxList<String> cat=<String>[].obs;

    @override
  void initState() {
    super.initState();
    widget.categoryList.forEach((e){
          cat.add(e['category']);
    });
    
  }

  
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: getBudgetUiScreen(height, width),
        bottomNavigationBar: BottomNavigations(data: 1),
      ),
    );
  }

  Widget getBudgetUiScreen(double height, double width) {
    return Container(
      width: width,
      height: height / 1.1,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: AppColors.backgroundColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Colorcodes.paddingSize),
           textStyle(context: context,text:  "Budget Calculations",fontsize: 16,fontWeight: FontWeight.bold),
          SizedBox(height: Colorcodes.paddingSize / 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             textStyle(context: context,text:  "Budget amount",fontsize: 16,fontWeight: FontWeight.bold),
             Padding(
               padding: EdgeInsets.symmetric(vertical:  Colorcodes.paddingSize),
               child: textStyle(context: context,text:  widget.amount,fontsize: 16,fontWeight: FontWeight.bold),
             ),
             textStyle(context: context,text:  "Budget ${widget.period}",fontsize: 16,fontWeight: FontWeight.bold),

            ],
          ),
      
          categoryList(),

          InkWell(
            onTap: (){
                   addBudget(context, widget.name, widget.amount, widget.categoryList, widget.period);
            },
            child: getButton(context, "Add Budget")
          ),


        ],
      ),
    );
  }

  categoryList() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate( widget.categoryList.length, (index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon( widget.categoryList[index]['icon']),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.cyan,
                      child: AvatarProfileImage(url: Categories.link+widget.categoryList[index]['category']+".svg", width: 20, height: 20)),
                  ),
                   const SizedBox(width: 10,),
               Expanded(
                    flex: 5,
                  child: Text(
                     widget.categoryList[index]['category']!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                 const SizedBox(width: 10,),
              Expanded(
                    flex: 3,
                  child:  TextField(
                          controller: TextEditingController(
                              text: widget.categoryList[index]['amount'].toString()),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter amount",
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (value)async {
                              widget.categoryList[index]['amount'] = double.tryParse(value) ?? 0;
                             var d=await  adjustBudget(double.parse(widget.amount),widget.categoryList[index]['category'],double.parse(value),cat);
                              // {Bills: 1500.67, Insurance: 1791.39, Travel: 2507.94}
                               List categoryList=[];

                                 widget.categoryList.forEach((e){
                                       String name = e['category'];
                                       double amount = d[name]!;
                                       print(name);
                                       print(amount);
                                       categoryList.add({'category':e['category'],'amount':amount.toString()});
                                 });

                                 widget.categoryList.clear();
                                setState(() {
                                  widget.categoryList = List.from(categoryList);
                                });

                          },
                          
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }




  Future<Map<String, double>> adjustBudget(
    double totalAmount, String updatedCategory, double updatedAmount, RxList<String> selectedCategories) async {
  // Flatten the subcategories and calculate total weights
  Map<String, double> subcategoryWeights = {};
  categoryWeights.forEach((mainCategory, data) {
    (data["subcategories"] as Map<String, dynamic>).forEach((subCategory, weight) {
      subcategoryWeights[subCategory] = weight.toDouble();
    });
  });

  // Filter only selected categories and calculate total weight
  Map<String, double> selectedWeights = {
    for (var category in selectedCategories)
      if (subcategoryWeights.containsKey(category)) category: subcategoryWeights[category]!
  };

  double totalSelectedWeight = selectedWeights.values.reduce((a, b) => a + b);

  // Calculate the initial budget for selected subcategories
  Map<String, double> initialBudgets = {};
  selectedWeights.forEach((subCategory, weight) {
    initialBudgets[subCategory] = (totalAmount * weight) / totalSelectedWeight;
  });

  // Adjust the budget for the updated category
  double difference = updatedAmount - (initialBudgets[updatedCategory] ?? 0);
  initialBudgets[updatedCategory] = updatedAmount;

  // Redistribute the difference proportionally among other selected categories
  double remainingWeight = totalSelectedWeight - (selectedWeights[updatedCategory] ?? 0);
  if (remainingWeight > 0) {
    selectedWeights.forEach((subCategory, weight) {
      if (subCategory != updatedCategory) {
        double adjustment = (weight / remainingWeight) * difference;
        initialBudgets[subCategory] =
            ((initialBudgets[subCategory] ?? 0) - adjustment).clamp(0, double.infinity);
      }
    });
  }

  // Round to 2 decimal places for each budget
  initialBudgets.updateAll((key, value) => (value * 100).roundToDouble() / 100);

  return initialBudgets;
}

}
