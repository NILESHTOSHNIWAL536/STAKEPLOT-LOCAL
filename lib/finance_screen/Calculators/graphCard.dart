import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

import '../../Constants/core/app_padding_sizes.dart';

double cardBalance = 300.0;
double totalInterestPaid = 130.0;

class PieChartGraph extends StatefulWidget {
  List graphData;
  List graphDisc;
  String title;
  PieChartGraph(
      {super.key,
      required this.graphData,
      required this.title,
      required this.graphDisc});

  @override
  State<PieChartGraph> createState() => _PieChartGraphState();
}

class _PieChartGraphState extends State<PieChartGraph> {
  List pieChatColor = [
    AppColors.primaryColor,
    AppColors.newuncoloredpie,
    //  AppColors.bg6,
    // AppColors.message,
    // AppColors.border,
    // AppColors.bg6,
    // AppColors.message,
    AppColors.border,
  ];

  @override
  Widget build(BuildContext context) {
    return buildPieChart();
  }

  Widget buildPieChart() {
    return Container(
      
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)
      ),
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Padding(
            padding: EdgeInsets.only(
                 top: Colorcodes.paddingSize / 2,
                left: Colorcodes.paddingSize / 2,
                // bottom: Colorcodes.paddingSize / 2
                ),
            // child: Column(
            //   children: widget.graphDisc.map((e) => getSubtext(e)).toList(),
            // ),
            child: Column(
              children: [
                // Column(
                //   children: List.generate(
                //     widget.graphDisc.length,
                //     (index) => getSubtext(widget.graphDisc[index]),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(right:AppSizes.p14 ),
                  child: Row(
                    children: List.generate(
                      widget.graphDisc.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index == widget.graphDisc.length - 1 ? 0 : 12, // ✅ spacing
                          ),
                          child: getSubtext(widget.graphDisc[index]),
                        ),
                      ),
                    ),
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(right:15),
                //   child: Row(
                //     children: List.generate(
                //       widget.graphData.length,
                //       (index) => Expanded(
                //         child: Padding(
                //           padding: EdgeInsets.only(
                //             right: index == widget.graphData.length - 1 ? 0 : 12, // ✅ spacing
                //           ),
                //            child: getSubtext2(widget.graphData[index]),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),


      ],
            ),
          ),
          SizedBox(
            height: Colorcodes.paddingSize,
          ),
          getGraph(),
          
        ],
      ),
    );
  }

  Widget getSubtext2(dynamic graphData) {
    int index = widget.graphData.indexOf(graphData);
    // Get index for color

    return Padding(
      padding: const EdgeInsets.only(top:20),
      child: Container(
        width: MediaQuery.of(context).size.shortestSide * 0.15,
        height: MediaQuery.of(context).size.shortestSide * 0.20,
         padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
        //  color:Colors.pink,
         decoration: BoxDecoration(
        color: Colors.white, // ✅ white card
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      
     
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                
                
                
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor, // Match pie chart color
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width:20),
            // Expanded(
            //   child: Container(
           
                
            //     decoration: BoxDecoration(
            //        color: AppColors.backgroundColor,// Match pie chart color
            //       borderRadius: BorderRadius.circular(2),
            //     ),
            //   ),
            // ),
           
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    textStyle(
                      context: context,
                      fontWeight: FontWeight.w300,
                      fontsize: 70,
                      c: AppColors.newfontcolor,
                      text: graphData[
                          'title'], // Title from graphData (PieChartSectionData)
                    ),
                    // const SizedBox(width: 5),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



 Widget getSubtext(Map<String, dynamic> data) {
  return Container(
    height: 80,
    width: 150,
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12,vertical:AppSizes. p8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.withOpacity(0.15),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE
        textStyle(
          context: context,
          fontWeight: FontWeight.w700,
          fontsize: 12,
          c: AppColors.newfontcolor,
          text: data['title'], // ✅ from graphDisc
        ),

         const SizedBox(height: AppSizes. h15), // ✅ vertical gap works in Column

        // AMOUNT
        textStyle(
          context: context,
          fontWeight: FontWeight.bold,
          fontsize: 14,
          c: AppColors.accentColor,
          text: data['amount'], // ✅ already formatted string
        ),
      ],
    ),
  );
}


Widget getGraph() {
  final double total = widget.graphData.fold(
  0.0,
  (sum, item) => sum + (item['value'] as double),
);

  return Container(
    margin: EdgeInsets.only(top: AppSizes. m8,left:AppSizes. m4),
    padding: const EdgeInsets.only(left:AppSizes. p10,top:AppSizes. p20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    width: MediaQuery.of(context).size.width / 1.1,
    child: Column(
      
      children: [
        // Title at the top
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Principal vs Interest',
              style: TextStyle(
                
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height:AppSizes. h20),
        // Pie Chart
        SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: PieChart(
            PieChartData(
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              sections: widget.graphData
    .asMap()
    .entries
    .map(
      (entry) => getPieChartSectionData(
        entry.value,
        entry.key,
        total, // ✅ THIS is the key
      ),
    )
    .toList(),

            ),
          ),
        ),
        SizedBox(height: AppSizes. h20),
        // Legend at the bottom
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Color(0xFF9ECAD7), 'Principal'),
            SizedBox(width: AppSizes. w20),
              _buildLegendItem(Color(0xFF4B4D73), 'Interest'),
          ],
        ),
         SizedBox(height: AppSizes. h20),
      ],
    ),
  );
  
}

// Helper method for legend items
Widget _buildLegendItem(Color color, String label) {
  return Row(
    children: [
      Container(
        width: MediaQuery.of(context).size.width * 0.04,
height: MediaQuery.of(context).size.height * 0.017, 
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.zero,
        ),
      ),
      SizedBox(width:AppSizes. w8),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    ],
  );
}


// PieChartSectionData getPieChartSectionData(dynamic data, int index) {
//   Color sectionColor;

//   if (data['title'].toString().toLowerCase().contains('principal')) {
//     sectionColor = const Color(0xFF9ECAD7); // Principal
//   } else if (data['title'].toString().toLowerCase().contains('interest')) {
//     sectionColor = const Color(0xFF4B4D73); // Interest
//   } else {
//     sectionColor = pieChatColor[index] ?? AppColors.uncoloredPie;
//   }

//   return PieChartSectionData(
//     value: data['value'], // used only for slice size
//     showTitle: true,

//     // ✅ ONLY percentage text
//     title: '${data['value'].toStringAsFixed(1)}%',

//     titleStyle: const TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.w600,
//       color: Colors.white,
//     ),

//     color: sectionColor,
//     radius: 110,
//     titlePositionPercentageOffset: 0.55,
//   );
// }
// }

PieChartSectionData getPieChartSectionData(
  dynamic data,
  int index,
  double total,
) {
  Color sectionColor;
  String label;

  if (data['title'].toString().toLowerCase().contains('principal')) {
    sectionColor = const Color(0xFF9ECAD7);
    label = 'Principal';
  } else {
    sectionColor = const Color(0xFF4B4D73);
    label = 'Interest';
  }

  final double value = data['value'];
  final double percent = total == 0 ? 0 : (value / total) * 100;

  return PieChartSectionData(
    value: value, // slice size (amount)
    showTitle: true,
    title: '$label\n${percent.toStringAsFixed(1)}%', // ✅ NAME + %
    titleStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.3, // spacing between lines
    ),
    color: sectionColor,
    radius: 110,
    titlePositionPercentageOffset: 0.55,
  );
}
}
  // Widget getGraph() {
  //   return Container(
  //     margin: EdgeInsets.only(top: 10),
  //     width: MediaQuery.of(context).size.width / 1.1,
  //     height: MediaQuery.of(context).size.height / 4,
  //     child: PieChart(
  //       PieChartData(
  //           borderData: FlBorderData(
  //             show: false,
  //           ),
  //           sections: widget.graphData
  //               .asMap()
  //               .entries
  //               .map((entry) => getPieChartSectionData(entry.value, entry.key))
  //               .toList()),
  //     ),
  //   );
  // }

  // PieChartSectionData getPieChartSectionData(data, index) {
  //   return PieChartSectionData(
  //     value: data['value'],
  //     showTitle: false,
  //     // badgeWidget: Container(
  //     //   padding: EdgeInsets.all(10),
  //     //   decoration: BoxDecoration(
  //     //       color: pieChatColor[index], borderRadius: BorderRadius.circular(4)),
  //     //   child: textStyleOnly(
  //     //       context: context,
  //     //      text: data['title'],
  //     //       fontWeight: FontWeight.bold,
  //     //       fontsize: 12,
  //     //       c: index - 1 == 0 ? pieChatColor[0] : pieChatColor[1]),
  //     // ),

  //     // title: data['title'],
  //     color: pieChatColor[index] ?? AppColors.uncoloredPie,
  //     radius: 50,
  //     // titlePositionPercentageOffset: 1.8,
  //     badgePositionPercentageOffset: 1.7,
  //   );
  // }


// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';

// class PieChartGraph extends StatefulWidget {
//   final List graphData;
//   final List graphDisc;
//   final String title;

//   PieChartGraph({
//     Key? key,
//     required this.graphData,
//     required this.title,
//     required this.graphDisc,
//   }) : super(key: key);

//   @override
//   _PieChartGraphState createState() => _PieChartGraphState();
// }

// class _PieChartGraphState extends State<PieChartGraph> {
//   List pieChatColor = [
//     AppColors.primaryColor,
//     AppColors.uncoloredPie,
//     AppColors.bg6,
//     AppColors.message,
//     AppColors.border,
//     AppColors.bg6,
//     AppColors.message,
//     AppColors.border,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return buildDonutChart();
//   }

//   Widget buildDonutChart() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         textStyle(
//           context: context,
//           fontsize: 20,
//           fontWeight: FontWeight.bold,
//           text: widget.title,
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize / 2),
//           child: Wrap(
//             spacing: 16, // Spacing between items
//             runSpacing: 8, // Spacing between rows
//             children: List.generate(
//               widget.graphDisc.length,
//               (index) => getSubtext(widget.graphDisc[index]),
//             ),
//           ),
//         ),
//         //SizedBox(height: AppSizes.h20),
//         getGraph(),
//          Padding(
//           padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.swipe, size: 18, color: Colors.grey), // Swipe Icon
//               SizedBox(width: 4),
//               textStyle(
//                 context: context,
//                 fontsize: 14,
//                 fontWeight: FontWeight.w400,
//                 c: Colors.grey,
//                 text: "Swipe to see more",
//               ),
//             ],
//           ),),
       
//       ],
//     );
//   }
//    Widget getSubtext(data) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: AppSizes.p4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           textStyle(
//               c: AppColors.userName,
//               context: context,
//               fontsize: 14,
//               fontWeight: FontWeight.w400,
//               text: data['title']),
//           const SizedBox(
//             width: 10,
//           ),
//           textStyle(
//               c: AppColors.userName,
//               context: context,
//               fontsize: 14,
//               fontWeight: FontWeight.bold,
//               text: data['amount'].toString()),
//         ],
//       ),
//     );
//   }
//   /// **Legend Row Item**
//   Widget getLegendItem(dynamic graphData, int index) {
//     return Container(
//       child: Row(
        
//         //mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               color: pieChatColor[index], // Match donut color
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 8),
//           textStyle(
//             c: AppColors.userName,
//             context: context,
//             fontsize: 14,
//             fontWeight: FontWeight.w400,
//             text: "${graphData['title']}",
//           ),
//         ],
//       ),
//     );
//   }

//   /// **Donut Chart**
//   Widget getGraph() {
//     return Container(
//       margin: EdgeInsets.only(top:AppSizes.p10),
//       width: MediaQuery.of(context).size.width / 1.1,
//       height: MediaQuery.of(context).size.height / 2.5,
//       child: SfCircularChart(
//         legend: Legend(
//           isVisible: true,
//           position: LegendPosition.bottom,
//         ),
//         series: <CircularSeries>[
//           DoughnutSeries<dynamic, String>(
//             dataSource: widget.graphData,
//             xValueMapper: (data, _) => data['title'],
//             yValueMapper: (data, _) => data['value'],
//             pointColorMapper: (data, index) =>
//                 pieChatColor[index % pieChatColor.length],
//             dataLabelSettings: DataLabelSettings(isVisible: false),
//             innerRadius: '50%', // Makes it a donut chart
//           ),
//         ],
//       ),
//     );
//   }
// }
