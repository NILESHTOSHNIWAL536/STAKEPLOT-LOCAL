// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'colors.dart';
// import 'package:home_widget/home_widget.dart';

// RxInt selectedIndex = (-1).obs;
// RxList<ChartData> chartData = <ChartData>[].obs;
// RxDouble totalValue = 0.0.obs;

// class ChartData {
//   final String category;
//   final double value;
//   final Color color;

//   ChartData(this.category, this.value, this.color);
// }

// class DoughnutChartExample extends StatefulWidget {
//   @override
//   State<DoughnutChartExample> createState() => _DoughnutChartExampleState();
// }

// class _DoughnutChartExampleState extends State<DoughnutChartExample> {
//   @override
//   void initState() {
//     super.initState();
//     selectedIndex.value = -1;
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await HomeWidget.setAppGroupId('group.com.stakeplot.adnan.dev');
//       getCategoryData();
//       await _updateWidget();
//     });
//     ever(chartData, (_) => _updateWidget());
//     ever(totalValue, (_) => _updateWidget());
//   }
// //  Future<void> _updateWidget() async {
// //     try {
// //       final total = '₹${totalValue.value.toStringAsFixed(2)}';
// //       final timestamp = getMonthlyRange();
// //       String categories = 'None';
// //       if (chartData.isNotEmpty) {
// //         categories = chartData
// //             .map(
// //                 (data) => '${data.category}: ₹${data.value.toStringAsFixed(2)}')
// //             .join('\n');
// //       }

// //       await HomeWidget.saveWidgetData<String>('total_spending', total);
// //       await HomeWidget.saveWidgetData<String>('categories', categories);
// //       await HomeWidget.saveWidgetData<String>('timestamp', timestamp);

// //       await HomeWidget.saveWidgetData<String>('total_spending', total);
// //       await HomeWidget.saveWidgetData<String>('categories', categories);
// //       await HomeWidget.saveWidgetData<String>('timestamp', timestamp);
// //       await HomeWidget.updateWidget(
// //         name: 'StakeplotWidgetProvider', // Match AppWidgetProvider class name
// //         androidName: 'StakeplotWidgetProvider',
// //         iOSName: 'StakeplotWidget',
// //       );
// //     } catch (e) {
// //       print('Error updating widget: $e');
// //     }
// //   }
//   Future<void> _updateWidget() async {
//     try {
//       final total = '₹${totalValue.value?.toStringAsFixed(2) ?? '0.00'}';
//       final timestamp = getMonthlyRange();
//       String categories = 'None';
//       if (chartData.isNotEmpty) {
//         categories = chartData
//             .map(
//                 (data) => '${data.category}: ₹${data.value.toStringAsFixed(2)}')
//             .join('\n');
//       }

//       // Save data only once
//       await HomeWidget.saveWidgetData<String>('total_spending', total);
//       await HomeWidget.saveWidgetData<String>('categories', categories);
//       await HomeWidget.saveWidgetData<String>('timestamp', timestamp);

//       // Update widget
//       await HomeWidget.updateWidget(
//         name: 'StakeplotWidgetProvider',
//         androidName: 'StakeplotWidgetProvider',
//         iOSName: 'StakeplotWidget',
//       );
//     } catch (e) {
//       print('Error updating widget: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final isLargeScreen = constraints.maxWidth > 600;
//           return Padding(
//             padding: const EdgeInsets.all(3.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Categorized Expense Overview',
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.normal,
//                       fontSize: 14,
//                       color: AppColors.bg3),
//                 ),
//                 const SizedBox(height: 4),
//                 topHeader(),
//                 const SizedBox(height: 10),
//                 getGraph(isLargeScreen)
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget getGraph(isLargeScreen) {
//     return Expanded(
//       child: Column(
//         //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 8,
//             child: Container(
//               alignment: Alignment.center,
//               child: Obx(() => chartData.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'No Spendings Available',
//                             style: FontManager().getTextStyle(
//                               context,
//                               lWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: AppColors.bg3.withOpacity(0.8),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                         ],
//                       ),
//                     )
//                   : SfCircularChart(
//                     legend: Legend(
//                       isVisible: true,
//                       position: LegendPosition.bottom,
//                       textStyle: FontManager().getTextStyle(
//                         context,
//                         fontSize: 12,
//                         color: AppColors.bg3,
//                       ),
//                     ),
//                     series: <CircularSeries>[
//                       DoughnutSeries<ChartData, String>(
//                         dataSource: chartData,
//                         xValueMapper: (ChartData data, _) => data.category,
//                         yValueMapper: (ChartData data, _) => data.value,
//                         pointColorMapper: (ChartData data, _) => data.color,
//                        // pointRenderMode: PointRenderMode.gradient,
//                         // Adjusted radius for better proportion
//                         radius: '80%',
//                         innerRadius: '50%',
//                         // Smoother corner style
//                        // cornerStyle: CornerStyle.bothCurve,
//                         // Enhanced explode effect
//                         explode: true,
//                         explodeIndex: selectedIndex.value,
//                         explodeOffset: '10%', // Increased for prominence
//                         // Enable and style data labels

//                         // Add stroke for segment separation
//                         //strokeWidth: 2.0,
//                        // strokeColor: AppColors.bg3.withOpacity(0.2),
//                         // Enhanced tooltip
//                         enableTooltip: true,
//                         // tooltipSettings: TooltipSettings(
//                         //   enable: true,
//                         //   format: '{point.x}: ₹{point.y}',
//                         //   textStyle: FontManager().getTextStyle(
//                         //     context,
//                         //     fontSize: 12,
//                         //     color: AppColors.bg1,
//                         //   ),
//                         //   color: AppColors.accentColor.withOpacity(0.9),
//                         //   borderWidth: 1,
//                         //   borderColor: AppColors.bg3,
//                         // ),
//                         // Highlight selected segment
//                         selectionBehavior: SelectionBehavior(
//                           enable: true,
//                           selectedOpacity: 1.0,
//                           unselectedOpacity: 0.1,

//                         ),
//                         onPointTap: (ChartPointDetails details) {
//                           if (chartData.isNotEmpty &&
//                               details.pointIndex != null &&
//                               details.pointIndex! < chartData.length) {
//                             if (selectedIndex.value == details.pointIndex) {
//                               selectedIndex.value = -1;
//                             } else {
//                               selectedIndex.value = details.pointIndex!;
//                             }
//                           }
//                         },
//                       ),
//                     ],
//                   )),
//           ),
//         ),
//           Container(
//               padding: const EdgeInsets.all(12.0),
//               child: Obx(
//                 () => (selectedIndex != -1 && chartData.isNotEmpty)
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Expenses: ${chartData[selectedIndex.value >= chartData.length ? chartData.length - 1 : selectedIndex.value].category}',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: AppColors.accentColor),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               '${getMonthlyRange()}',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.normal,
//                                   fontSize: 12,
//                                   color: AppColors.bg3),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Amount: \₹${formatMoneyIndian(chartData[selectedIndex.value >= chartData.length ? chartData.length - 1 : selectedIndex.value].value.toStringAsFixed(2))}',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                   color: AppColors.accentColor),
//                             ),
//                           ],
//                         ),
//                       )
//                     : Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text('Total Spending',
//                                 style: FontManager().getTextStyle(context,
//                                     lWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                     color: AppColors.accentColor)),
//                             const SizedBox(height: 8),
//                             Text(
//                               '${getMonthlyRange()}',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.normal,
//                                   fontSize: 12,
//                                   color: AppColors.bg3),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Amount: \₹${formatMoneyIndian(totalValue.toStringAsFixed(2))}',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                   color: AppColors.accentColor),
//                             ),
//                           ],
//                         ),
//                       ),
//               )),
//         ],
//       ),
//     );
//   }

//   Widget topHeader() {
//     return Row(
//       children: [
//         Obx(() => Text(
//               '\₹${formatMoneyIndian(totalValue.toStringAsFixed(2))}',
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: AppColors.accentColor),
//             )),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'colors.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

RxInt selectedIndex = (-1).obs;
RxList<ChartData> chartData = <ChartData>[].obs;
RxDouble totalValue = 0.0.obs;

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

class DoughnutChartExample extends StatefulWidget {
  @override
  State<DoughnutChartExample> createState() => _DoughnutChartExampleState();
}

class _DoughnutChartExampleState extends State<DoughnutChartExample> {
  @override
  void initState() {
    super.initState();
    selectedIndex.value = -1;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await HomeWidget.setAppGroupId('group.com.stakeplot.adnan.dev');
      getCategoryData();
      await _updateWidget();
    });
    ever(chartData, (_) => _updateWidget());
    ever(totalValue, (_) => _updateWidget());
  }

  Future<void> _updateWidget() async {
    try {
      final total = '₹${totalValue.value?.toStringAsFixed(2) ?? '0.00'}';
      final timestamp = getMonthlyRange();
      String categories = 'None';
      if (chartData.isNotEmpty) {
        categories = chartData
            .map(
                (data) => '${data.category}: ₹${data.value.toStringAsFixed(2)}')
            .join('\n');
      }

      await HomeWidget.saveWidgetData<String>('total_spending', total);
      await HomeWidget.saveWidgetData<String>('categories', categories);
      await HomeWidget.saveWidgetData<String>('timestamp', timestamp);

      await HomeWidget.updateWidget(
        name: 'StakeplotWidgetProvider',
        androidName: 'StakeplotWidgetProvider',
        iOSName: 'StakeplotWidget',
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorized Expense Overview',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.normal,
                  fontSize: 14,
                  color: AppColors.bg3,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllCategoriesPage(),
                    ),
                  );
                },
                child: Text(
                  'More',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          topHeader(),
          const SizedBox(height: 8),
          Obx(() => chartData.isEmpty
              ? Center(
                  child: Text(
                    'No Spendings Available',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.bg3.withOpacity(0.8),
                    ),
                  ),
                )
              : buildCategoryCards()),
        ],
      ),
    );
  }

  Widget buildCategoryCards() {
    // Take top 4 categories
    final topCategories = chartData.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFour = topCategories.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: topFour.length,
      itemBuilder: (context, index) {
        final data = topFour[index];
        final percentage =
            totalValue.value > 0 ? (data.value / totalValue.value) * 100 : 0.0;
        return CategoryCard(
          category: data.category,
          amount: data.value,
          percentage: percentage,
          color: data.color,
        );
      },
    );
  }

  Widget topHeader() {
    return Row(
      children: [
        Obx(() => Text(
              '₹${formatMoneyIndian(totalValue.toStringAsFixed(2))}',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.accentColor,
              ),
            )),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  const CategoryCard({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        searchController.text = category.toLowerCase();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionHistoryScreen(),
          ),
        );
      },
      child: Card(
        color: AppColors.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.bg3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${formatMoneyIndian(amount.toStringAsFixed(2))}',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.bg3.withOpacity(0.2),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.normal,
                      fontSize: 12,
                      color: AppColors.bg3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllCategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Categories',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.bg3,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.bg3),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() => chartData.isEmpty
            ? Center(
                child: Text(
                  'No Spendings Available',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.bg3.withOpacity(0.8),
                  ),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: chartData.length,
                itemBuilder: (context, index) {
                  final data = chartData[index];
                  final percentage = totalValue.value > 0
                      ? (data.value / totalValue.value) * 100
                      : 0.0;
                  return CategoryCard(
                    category: data.category,
                    amount: data.value,
                    percentage: percentage,
                    color: data.color,
                  );
                },
              )),
      ),
    );
  }
}
