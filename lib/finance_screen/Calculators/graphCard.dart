
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

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
    AppColors.uncoloredPie,
    AppColors.bg6,
    AppColors.message,
    AppColors.border,
     AppColors.bg6,
    AppColors.message,
    AppColors.border,
  ];

  @override
  Widget build(BuildContext context) {
    return buildPieChart();
  }

  Widget buildPieChart() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(Colorcodes.paddingSize / 2),
            child: textStyle(
                context: context,
                fontsize: 20,
                fontWeight: FontWeight.bold,
                text: widget.title),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: Colorcodes.paddingSize / 2,
                left: Colorcodes.paddingSize / 2,
                bottom: Colorcodes.paddingSize / 2),
            // child: Column(
            //   children: widget.graphDisc.map((e) => getSubtext(e)).toList(),
            // ),
            child: Column(
              children: [
                 Column(
                  children: List.generate(
                    widget.graphDisc.length,
                    (index) => getSubtext(widget.graphDisc[index]),
                  ),
                          ),
                Column(
                  
                  children: List.generate(
                    widget.graphData.length,
                    (index) => getSubtext2( widget.graphData[index]),
                  ),
                          ),
                          
              ],
            ),),
          SizedBox(
            height: Colorcodes.paddingSize,
          ),
          getGraph(),
          SizedBox(height: Colorcodes.paddingSize*2,),

        ],
      ),
    );
  }
 Widget getSubtext2( dynamic graphData) {
    int index = widget.graphData.indexOf(graphData); 
    // Get index for color
    

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: pieChatColor[index], // Match pie chart color
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    textStyle(
                      c: AppColors.userName,
                      context: context,
                      fontsize: 14,
                      fontWeight: FontWeight.w400,
                      text: graphData['title'], // Title from graphData (PieChartSectionData)
                    ),
                    const SizedBox(width: 5),
                    
                  ],
                ),
                
                
              ],
            ),
          ),
        ],
      ),
    );
 }
  Widget getSubtext(data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          textStyle(
              c: AppColors.userName,
              context: context,
              fontsize: 14,
              fontWeight: FontWeight.w400,
              text: data['title']),
          const SizedBox(
            width: 10,
          ),
          textStyle(
              c: AppColors.userName,
              context: context,
              fontsize: 14,
              fontWeight: FontWeight.bold,
              text: data['amount'].toString()),
        ],
      ),
    );
  }


Widget getGraph(){
   return Container(
         
           margin: EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width/1.1,
                height:  MediaQuery.of(context).size.height/4,
            child: PieChart(
              
                  PieChartData(
                      borderData: FlBorderData(
                                show: false,
                         ),
                 sections: widget.graphData
                  .asMap()
                  .entries
                  .map((entry) => getPieChartSectionData(entry.value, entry.key))
                  .toList()
                  ),
            
      ),
    );
  }

  PieChartSectionData getPieChartSectionData(data, index) {
    return PieChartSectionData(
      value: data['value'],
      showTitle: false,
      // badgeWidget: Container(
      //   padding: EdgeInsets.all(10),
      //   decoration: BoxDecoration(
      //       color: pieChatColor[index], borderRadius: BorderRadius.circular(4)),
      //   child: textStyleOnly(
      //       context: context,
      //      text: data['title'],
      //       fontWeight: FontWeight.bold,
      //       fontsize: 12,
      //       c: index - 1 == 0 ? pieChatColor[0] : pieChatColor[1]),
      // ),
      
      // title: data['title'],
      color: pieChatColor[index] ?? AppColors.uncoloredPie,
      radius: 50,
      // titlePositionPercentageOffset: 1.8,
      badgePositionPercentageOffset: 1.7,
    );
  }



}

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
//         //SizedBox(height: Colorcodes.paddingSize),
//         getGraph(),
//          Padding(
//           padding: EdgeInsets.symmetric(vertical: 8),
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
//       padding: const EdgeInsets.symmetric(vertical: 4),
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
//       margin: EdgeInsets.only(top: 10),
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
