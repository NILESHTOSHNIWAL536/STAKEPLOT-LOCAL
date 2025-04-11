// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

// class PlotFinance extends StatefulWidget {
//   const PlotFinance({super.key});

//   @override
//   State<PlotFinance> createState() => _PlotFinanceState();
// }

// class _PlotFinanceState extends State<PlotFinance> {
//   @override
//   void initState() {
//     super.initState();
//     getBudget();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       bottomNavigationBar: BottomNavigations(data: 1),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header Banner
//                 AvatarProfileImage(
//                   url: Finance.plot,
//                   height: 6,
//                   width: 1,
//                 ),

//                 budgetAndDebtCalulator(),
//                 textStyle(
//                     context: context,
//                     text: "Calculators",
//                     fontsize: 18,
//                     fontWeight: FontWeight.w800),
//                 calculatorList(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget budgetAndDebtCalulator() {
//     return // Budget and Debt Buttons
//         Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 5,
//       // color: Colorcodes.appBarColor,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.only(right: 50),
//         children: [
//           _buildCard(
//             icon: AvatarProfileImage(
//               url: Finance.budget,
//               height: 7,
//               width: 7,
//             ),
//             path: budgetList.isEmpty ? "/Budget" : "/BudgetDisplay",
//           ),
//           _buildCard(
//             icon: AvatarProfileImage(
//               url: Finance.debt,
//               height: 7,
//               width: 7,
//             ),
//             path: "/Debt",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget calculatorList() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
//       width: MediaQuery.of(context).size.width,
//       child: Wrap(
//         spacing: 8,
//         runSpacing: 8,
//         children: [
//            _buildCalculatorTile(
//             'Veg and non veg',
//             'Calculator',
//             url: Finance.vegNonveg,
//             path: "/VegNonveg",
//           ),
//           _buildCalculatorTile(
//             'Credit Card Payoff',
//             'Calculator',
//             url: Finance.credit,
//             path: "/CreditCard",
//           ),
//           _buildCalculatorTile(
//             'EMI',
//             'Calculator',
//             url: Finance.emi,
//             path: "/emi",
//           ),
//           _buildCalculatorTile(
//             'Rent vs Buy',
//             'Calculator',
//             url: Finance.key,
//             path: "/rent_buy",
//           ),
//           _buildCalculatorTile(
//             'Savings goal',
//             'Calculator',
//             url: Finance.savings,
//             path: "/Savings",
//           ),
//           _buildCalculatorTile(
//             'Auto loan',
//             'Calculator',
//             url: Finance.auto,
//             path: "/autoLoan",
//           ),
//           _buildCalculatorTile(
//             'Trip cost',
//             'Calculator',
//             url: Finance.location,
//             path: "/TripCost",
//           ),

//         ],
//       ),
//     );
//   }

//   Widget _buildCard({icon, required String path}) {
//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(context, path);
//       },
//       child: icon,
//     );
//   }

//   Widget _buildCalculatorTile(String title, String subtitle,
//       {required String url, required String path}) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, path);
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width / 2.4,
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: AppColors.mt,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: AvatarProfileImage(
//                   url: url,
//                   height: 25,
//                   width: 20,
//                 ),
//               ),
//               SizedBox(height: 14),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       width: MediaQuery.sizeOf(context).width / 4,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(title,
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w700,
//                                   fontSize:
//                                       MediaQuery.sizeOf(context).height / 56,
//                                   overflow: TextOverflow.ellipsis,
//                                   color: AppColors.bg1)),
//                           Text(subtitle,
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w500,
//                                   fontSize:
//                                       MediaQuery.sizeOf(context).height / 56,
//                                   color: AppColors.bg1)),
//                         ],
//                       ),
//                     ),
//                     Container(
//                         height: MediaQuery.of(context).size.height * 0.04,
//                         width: MediaQuery.of(context).size.width * 0.08,
//                         decoration: BoxDecoration(
//                             color: AppColors.primaryColor,
//                             borderRadius: BorderRadius.circular(36)),
//                         child:
//                             Icon(Icons.arrow_forward_ios, color: Colors.white)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget gridViewList() {
//     return ListView(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: [
//         _buildCalculatorTile(
//           'Credit Card Payoff',
//           'Calculator',
//           url: Finance.credit,
//           path: "/CreditCard",
//         ),
//         _buildCalculatorTile(
//           'EMI',
//           'Calculator',
//           url: Finance.emi,
//           path: "/EMI",
//         ),
//         _buildCalculatorTile(
//           'Rent vs Buy',
//           'Calculator',
//           url: Finance.key,
//           path: "/Rent",
//         ),
//         _buildCalculatorTile(
//           'Savings goal',
//           'Calculator',
//           url: Finance.savings,
//           path: "/Savings",
//         ),
//         _buildCalculatorTile(
//           'Auto loan',
//           'Calculator',
//           url: Finance.auto,
//           path: "/Auto",
//         ),
//         _buildCalculatorTile(
//           'Trip cost',
//           'Calculator',
//           url: Finance.location,
//           path: "/TripCost",
//         ),
//       ],
//     );
//   }
// }

// Map<String, dynamic> getJsonBodyObj(String name, double value, double min,
//     double max, Function(double) onChanged, TextEditingController controller,
//     [bool flag = true, String symbol = "₹"]) {
//   return {
//     'name': name,
//     'value': value,
//     'min': min,
//     'max': max,
//     'onChanged': onChanged,
//     'controller': controller,
//     'symbol': symbol,
//     'flag': flag,
//   };
// }

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/BudgetDisplay.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/MyBudget.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PlotFinance extends StatefulWidget {
  const PlotFinance({super.key});

  @override
  State<PlotFinance> createState() => _PlotFinanceState();
}

class _PlotFinanceState extends State<PlotFinance> {
  @override
  void initState() {
    super.initState();
    getBudget();
    getRemainders(context); // Fetch payables and oweds
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: BottomNavigations(data: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                AvatarProfileImage(
                  url: Finance.plot,
                  height: 6,
                  width: 1,
                ),
                // Budget List
                budgetHorizontalList(),
                const SizedBox(height: 24),
                // Budget and Other Buttons
                budgetAndDebtCalulator(),
                const SizedBox(height: 24),
                // Calculators Header
                globalText(
                  context: context,
                  text: "Calculators",
                  fontsize: 20,
                  fontWeight: FontWeight.w800,
                ),
                const SizedBox(height: 16),
                calculatorList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget budgetAndDebtCalulator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Add Budget
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/Budget");
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.button,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 12,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      globalText(
                        context: context,
                        text: "Add Budget",
                        fontsize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Add Debt
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/AddDebt"); // Placeholder route
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.button,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 12,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      globalText(
                        context: context,
                        text: "Add Debt",
                        fontsize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Veg Non-Veg Calculator
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/VegNonveg");
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.button,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 12,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      globalText(
                        context: context,
                        text: "Veg Non-Veg",
                        fontsize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListScreen(isPayable: false),
                    ),
                  ); // Oweds
                },
                child: Obx(() => _buildSummaryCard(
                      "To Receive",
                      lendAmountRemainders,
                      Colors.green,
                    )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListScreen(isPayable: true),
                    ),
                  ); // Payables
                },
                child: Obx(() => _buildSummaryCard(
                      "To Pay",
                      dueAmountRemainders,
                      Colors.red,
                    )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget budgetHorizontalList() {
    return Obx(() {
      // Sort budgets by creation date (latest first)
      
      final sortedBudgets = budgetList.toList()
        ..sort(
            (a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));

      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        child: sortedBudgets.isEmpty
            ? Center(
                child: globalText(
                  context: context,
                  text: "No budgets available",
                  fontsize: 16,
                  color: Colors.grey[600],
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sortedBudgets.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: budgetCard(context,sortedBudgets[index]),
                    ),
                  );
                },
              ),
      );
    });
  }

Widget budgetCard(BuildContext context, dynamic data) {
  // Parse amounts safely
  double budgetAmount = double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
  double spentAmount = 800;
  // Calculate percentage spent
  double percentageSpent = budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;
  if (percentageSpent > 100) percentageSpent = 100; // Cap at 100%

  // Data for Syncfusion chart
  List<ChartData> chartData = [
    ChartData(
      'Spent',
      spentAmount > budgetAmount ? spentAmount : spentAmount,
      AppColors.primaryColor.withOpacity(0.9),
    ),
    ChartData(
      'Remaining',
      spentAmount > budgetAmount ? 0 : budgetAmount - spentAmount,
      Colors.grey[300]!.withOpacity(0.7),
    ),
  ];

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyBudgetScreen(data: data)),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      constraints: BoxConstraints(
        minHeight: 140,
        maxWidth: MediaQuery.of(context).size.width * 0.85,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mt.withOpacity(0.95),
            AppColors.mt.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyBudgetScreen(data: data)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Budget Details
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      globalText(
                        context: context,
                        text: data['name']?.toString() ?? 'Unnamed Budget',
                        fontWeight: FontWeight.w700,
                        fontsize: 18,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        color: AppColors.accentColor,
                      ),
                      const SizedBox(height: 6),
                      globalText(
                        context: context,
                        text: data['budgetPeriod']?.toString() ?? 'Unknown Period',
                        fontWeight: FontWeight.w500,
                        fontsize: 13,
                        color: Colors.grey[600]!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          globalText(
                            context: context,
                            text: 'Budget: ',
                            fontWeight: FontWeight.w600,
                            fontsize: 14,
                            color: AppColors.accentColor.withOpacity(0.9),
                          ),
                          Flexible(
                            child: globalText(
                              context: context,
                              text: '₹${budgetAmount.toStringAsFixed(2)}',
                              fontWeight: FontWeight.w600,
                              fontsize: 14,
                              color: AppColors.primaryColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          globalText(
                            context: context,
                            text: 'Spent: ',
                            fontWeight: FontWeight.w500,
                            fontsize: 13,
                            color: AppColors.accentColor.withOpacity(0.9),
                          ),
                          Flexible(
                            child: globalText(
                              context: context,
                              text: '₹${spentAmount.toStringAsFixed(2)}',
                              fontWeight: FontWeight.w500,
                              fontsize: 13,
                              color: Colors.redAccent,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      globalText(
                        context: context,
                        text: '${percentageSpent.toStringAsFixed(1)}% Spent',
                        fontWeight: FontWeight.w500,
                        fontsize: 12,
                        color: percentageSpent > 80
                            ? Colors.redAccent
                            : AppColors.primaryColor,
                      ),
                      const SizedBox(height: 4),
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(10),
                      //   child: LinearProgressIndicator(
                      //     value: percentageSpent / 100,
                      //     backgroundColor: Colors.grey[200],
                      //     valueColor: AlwaysStoppedAnimation<Color>(
                      //       percentageSpent > 80
                      //           ? Colors.redAccent
                      //           : AppColors.primaryColor,
                      //     ),
                      //     minHeight: 5,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Syncfusion Doughnut Chart
                Flexible(
                  flex: 2,
                  child: Container(
                    height: 110,
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: SfCircularChart(
                      series: <CircularSeries>[
                        DoughnutSeries<ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.category,
                          yValueMapper: (ChartData data, _) => data.value,
                          pointColorMapper: (ChartData data, _) => data.color,
                          innerRadius: '60%', // Doughnut hole size
                          radius: '100%', // Outer radius
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          dataLabelMapper: (ChartData data, _) =>
                              '${(data.value / budgetAmount * 100).toStringAsFixed(0)}%',
                          animationDuration: 800,
                          enableTooltip: true,
                        ),
                      ],
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        format: 'point.x: ₹point.y',
                      ),
                      annotations: <CircularChartAnnotation>[
                        CircularChartAnnotation(
                          widget: Container(
                            child: globalText(
                              context: context,
                              text: '${percentageSpent.toStringAsFixed(0)}%',
                              fontWeight: FontWeight.bold,
                              fontsize: 14,
                              color: percentageSpent > 80
                                  ? Colors.redAccent
                                  : AppColors.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


// Data class for Syncfusion chart


  Widget calculatorList(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        
        _buildCalculatorTile(
          context: context,
          title: 'Credit Card Payoff',
          subtitle: 'Calculator',
          url: Finance.credit,
          path: '/CreditCard',
        ),
        _buildCalculatorTile(
          context: context,
          title: 'EMI',
          subtitle: 'Calculator',
          url: Finance.emi,
          path: '/emi',
        ),
        _buildCalculatorTile(
          context: context,
          title: 'Rent vs Buy',
          subtitle: 'Calculator',
          url: Finance.key,
          path: '/rent_buy',
        ),
        _buildCalculatorTile(
          context: context,
          title: 'Savings Goal',
          subtitle: 'Calculator',
          url: Finance.savings,
          path: '/Savings',
        ),
        _buildCalculatorTile(
          context: context,
          title: 'Auto Loan',
          subtitle: 'Calculator',
          url: Finance.auto,
          path: '/autoLoan',
        ),
        _buildCalculatorTile(
          context: context,
          title: 'Trip Cost',
          subtitle: 'Calculator',
          url: Finance.location,
          path: '/TripCost',
        ),
      ],
    );
  }

  Widget _buildCalculatorTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String url,
    required String path,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, path);
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarProfileImage(
              url: url,
              height: 40,
              width: 40,
            ),
            const SizedBox(height: 12),
            globalText(
              context: context,
              text: title,
              fontsize: 16,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            globalText(
              context: context,
              text: subtitle,
              fontsize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, RxList list, Color color) {
    // Filter pending items (not paid)
   final pendingItems = list
    .where((item) => !(item is Map<String, dynamic> && (item['isPaid'] ?? false)))
    .map((item) => item as Map<String, dynamic>)
    .toList();

final totalAmount = pendingItems.fold<double>(
  0.0,
  (sum, item) => sum + (double.tryParse(item['amount']?.toString() ?? '0') ?? 0),
);


    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          globalText(
            context: context,
            text: title,
            fontsize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          const SizedBox(height: 8),
          globalText(
            context: context,
            text: '₹${totalAmount.toStringAsFixed(2)}',
            fontsize: 18,
            fontWeight: FontWeight.bold,
          ),
          globalText(
            context: context,
            text: '${pendingItems.length} pending',
            fontsize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget globalText({
    required BuildContext context,
    required String text,
    double fontsize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    TextOverflow? overflow,
    int? maxLines,
    TextDecoration? decoration,
    String? fontFamily,
  }) {
    return Text(
      text,
      style: textStyle4(
        context: context,
        text: text,
        fontsize: fontsize,
        fontWeight: fontWeight,
        color: color,
        overflow: overflow,
        decoration: decoration,
        fontFamily: fontFamily,
      ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  TextStyle textStyle4({
    required BuildContext context,
    required String text,
    double fontsize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    TextOverflow? overflow,
    TextDecoration? decoration,
    String? fontFamily,
  }) {
    return FontManager()
        .getTextStyle(
          context,
          lWeight: fontWeight,
          fontSize: fontsize,
          color: color ?? Colors.black,
        )
        .copyWith(
          overflow: overflow ?? TextOverflow.clip,
          decoration: decoration,
          fontFamily: fontFamily,
        );
  }
}

Map<String, dynamic> getJsonBodyObj(String name, double value, double min,
    double max, Function(double) onChanged, TextEditingController controller,
    [bool flag = true, String symbol = "₹"]) {
  return {
    'name': name,
    'value': value,
    'min': min,
    'max': max,
    'onChanged': onChanged,
    'controller': controller,
    'symbol': symbol,
    'flag': flag,
  };
}

class ChartData {
  ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}