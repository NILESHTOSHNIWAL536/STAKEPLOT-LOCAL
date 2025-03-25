
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'colors.dart';

//   RxInt selectedIndex=(-1).obs;
//   RxList<ChartData> chartData=<ChartData>[].obs;
//   RxDouble totalValue = 0.0.obs;


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
//     getCategoryData();
//   }

 

//   @override
//   Widget build(BuildContext context) {
//     return  Container(
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final isLargeScreen = constraints.maxWidth > 600;

//           return Padding(
//             padding: const EdgeInsets.all(5.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Monthly Expenses',
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.normal,
//                       fontSize: 14,
//                       color: AppColors.bg3),
//                 ),
//                 const SizedBox(height: 4),
//                 topHeader(),
//                 const SizedBox(height: 10),
//                  getGraph(isLargeScreen)
               
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//  String _getMonthlyRange() {
//     final now = DateTime.now();
//     final startOfMonth = DateTime(now.year, now.month, 1);
//     final currentDay = now; // Use current date as the end date

//     return '${_formatDate(startOfMonth)} - ${_formatDate(currentDay)}';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
//   }

  

//   String _getMonthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return months[month - 1];
//   }



//   Widget getGraph(isLargeScreen){
//       return  Expanded(
//                   child: Column(
//                     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                   Expanded(
//                         flex: 8,
//                         child: Container(
//                           alignment: Alignment.center,
//                           child: SfCircularChart(
                            
//                             series: <CircularSeries>[

//                               DoughnutSeries<ChartData, String>(
//                                 dataSource: chartData,
//                                 xValueMapper: (ChartData data, _) =>data.category,
//                                 yValueMapper: (ChartData data, _) => data.value,
//                                 explode: true,
                                 
                        
//                                 explodeIndex: selectedIndex.value,
//                                 dataLabelSettings:
//                                     const DataLabelSettings(isVisible: false),
//                                 enableTooltip: true,
//                                 onPointTap: (ChartPointDetails details) {
//                                   setState(() {
//                                     if (selectedIndex.value == details.pointIndex) {
//                                       selectedIndex.value = -1;
//                                     } else {
//                                       selectedIndex.value = details.pointIndex!;
//                                     }
//                                   });
//                                 },
//                               ),
//                             ],
                            
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(12.0),
//                         child: (selectedIndex != -1 && chartData.isNotEmpty)
//                             ? Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.center,
//                                   children: [
//                                  Text(
//                                       'Expenses: ${chartData[selectedIndex.value].category}',
//                                       style: FontManager().getTextStyle(
//                                           context,
//                                           lWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                           color: AppColors.accentColor),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       '${_getMonthlyRange()}',
//                                       style: FontManager().getTextStyle(
//                                           context,
//                                           lWeight: FontWeight.normal,
//                                           fontSize: 12,
//                                           color: AppColors.bg3),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Amount: \₹${chartData[selectedIndex.value].value.toStringAsFixed(2)}',
//                                       style: FontManager().getTextStyle(
//                                           context,
//                                           lWeight: FontWeight.bold,
//                                           fontSize: 14,
//                                           color: AppColors.accentColor),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text('Total Spending',
//                                         style: FontManager().getTextStyle(
//                                             context,
//                                             lWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                             color: AppColors.accentColor)),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       '${_getMonthlyRange()}',
//                                       style: FontManager().getTextStyle(
//                                           context,
//                                           lWeight: FontWeight.normal,
//                                           fontSize: 12,
//                                           color: AppColors.bg3),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Amount: \₹${totalValue.toStringAsFixed(2)}',
//                                       style: FontManager().getTextStyle(
//                                           context,
//                                           lWeight: FontWeight.bold,
//                                           fontSize: 14,
//                                           color: AppColors.accentColor),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                       ),
//                     ],
//                   ),
//                 );
//   }


//   Widget emptyDataDonectChat(){
//       return Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height/3,
//           color: Colors.cyan,
//         ),
//       );
//   }
  
//  Widget topHeader() {
//      return Row(
//                   children: [
//                    Obx(()=> Text(
//                       '\₹${totalValue.toStringAsFixed(2)}',
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: AppColors.accentColor),
//                     )),
                    
//                   ],
//                 );
//   }
// }



import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'colors.dart';

  RxInt selectedIndex=(-1).obs;
  RxList<ChartData> chartData=<ChartData>[].obs;
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
    getCategoryData();
  }

 

  @override
  Widget build(BuildContext context) {
    return  Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;

          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Expenses',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
                      fontSize: 14,
                      color: AppColors.bg3),
                ),
                const SizedBox(height: 4),
                topHeader(),
                const SizedBox(height: 10),
                 getGraph(isLargeScreen)
               
              ],
            ),
          );
        },
      ),
    );
  }

 String _getMonthlyRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final currentDay = now; // Use current date as the end date

    return '${_formatDate(startOfMonth)} - ${_formatDate(currentDay)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }



  Widget getGraph(isLargeScreen){
      return  Expanded(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Expanded(
                        flex: 8,
                        child: Container(
                          alignment: Alignment.center,
                          child: Obx(() =>
                          chartData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insert_chart_outlined,
                          size: 60,
                          color: AppColors.bg3.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Expense Data Available',
                          style: FontManager().getTextStyle(
                            Get.context!,
                            lWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.bg3.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some transactions to see the chart',
                          style: FontManager().getTextStyle(
                            Get.context!,
                            lWeight: FontWeight.normal,
                            fontSize: 14,
                            color: AppColors.bg3.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                :SfCircularChart(
                            
                            series: <CircularSeries>[

                              DoughnutSeries<ChartData, String>(
                                dataSource: chartData,
                                xValueMapper: (ChartData data, _) =>data.category,
                                yValueMapper: (ChartData data, _) => data.value,
                                explode: true,
                                 
                        
                                explodeIndex: selectedIndex.value,
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: false),
                                enableTooltip: true,
                                // onPointTap: (ChartPointDetails details) {
                                  
                                //     if (selectedIndex.value == details.pointIndex) {
                                //       selectedIndex.value = -1;
                                //     } else {
                                //       selectedIndex.value = details.pointIndex!;
                                //     }
                                 
                                // },
                                onPointTap: (ChartPointDetails details) {
  if (chartData.isNotEmpty && details.pointIndex != null && details.pointIndex! < chartData.length) {
    if (selectedIndex.value == details.pointIndex) {
      selectedIndex.value = -1;
    } else {
      selectedIndex.value = details.pointIndex!;
    }
  }
},

                              ),
                            ],
                            
                          )),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        child:  Obx(() =>(selectedIndex != -1 && chartData.isNotEmpty)
                            ? Center(
                                 child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                 Text(
                                      'Expenses: ${chartData[selectedIndex.value].category}',
                                      style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.accentColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_getMonthlyRange()}',
                                      style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: AppColors.bg3),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Amount: \₹${chartData[selectedIndex.value].value.toStringAsFixed(2)}',
                                      style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.accentColor),
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Total Spending',
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.accentColor)),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_getMonthlyRange()}',
                                      style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: AppColors.bg3),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Amount: \₹${totalValue.toStringAsFixed(2)}',
                                      style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.accentColor),
                                    ),
                                  ],
                                ),
                              ),
                      )),
                    ],
                  ),
                );
  }


  Widget emptyDataDonectChat(){
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/3,
          color: Colors.cyan,
        ),
      );
  }
  
 Widget topHeader() {
     return Row(
                  children: [
                   Obx(()=> Text(
                      '\₹${totalValue.toStringAsFixed(2)}',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.accentColor),
                    )),
                    
                  ],
                );
  }
}
