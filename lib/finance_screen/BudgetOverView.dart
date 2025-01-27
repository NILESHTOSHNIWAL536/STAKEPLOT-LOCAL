import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

class BudgetOverView extends StatefulWidget {
  final String amount;
  final String name;
  final String period;

  BudgetOverView({
    Key? key,
    required this.amount,
    required this.name,
    required this.period,
  }) : super(key: key);

  @override
  _BudgetOverViewState createState() => _BudgetOverViewState();
}

class _BudgetOverViewState extends State<BudgetOverView> {
  // Dummy data for categories and amounts
  final List<Map<String, dynamic>> categories = [
    {"category": "Food", "amount": "5000", "icon": Icons.face},
    {"category": "Transport", "amount": "3000", "icon": Icons.savings},
    {"category": "Entertainment", "amount": "2000", "icon": Icons.savings},
    {"category": "Utilities", "amount": "4000", "icon": Icons.savings},
    {"category": "Savings", "amount": "5000", "icon": Icons.savings},
  ];

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
          Text(
            "Budget Calculations",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Colorcodes.paddingSize / 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Budget amount", style: TextStyle(fontSize: 1)),
              Text(
                "\$${widget.amount}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text("Budget ${widget.period}", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
            ],
          ),
          SizedBox(height: 10),
          categoryList(),
        ],
      ),
    );
  }

  categoryList() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(categories.length, (index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(categories[index]['icon']),
                Text(
                  categories[index]['category']!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  "\$${categories[index]['amount']!}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
