import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';

  double cardBalance=300.0;
  double totalInterestPaid=130.0;

class PieChartGraph extends StatefulWidget {
  List graphData;
  List graphDisc;
  String title;
  PieChartGraph({super.key,required this.graphData,required this.title,required this.graphDisc});

  @override
  State<PieChartGraph> createState() => _PieChartGraphState();
}

class _PieChartGraphState extends State<PieChartGraph> {
 
   List pieChatColor=[AppColors.primaryColor,AppColors.uncoloredPie,AppColors.bg6];

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
            padding: EdgeInsets.all( Colorcodes.paddingSize/2),
            child: textStyle(context: context,fontsize: 20,fontWeight: FontWeight.bold,text: widget.title),
          ),
         
          Padding(
            padding: EdgeInsets.only(top:  Colorcodes.paddingSize/2,left:Colorcodes.paddingSize/2,bottom:Colorcodes.paddingSize/2  ),
            child: Column(
                children: widget.graphDisc.map((e)=>getSubtext(e)).toList(),
            ),
          ),
          SizedBox(height: Colorcodes.paddingSize,),
          getGraph(),
          SizedBox(height: Colorcodes.paddingSize*2,),
          

        ],
      ),
    );
  }


  Widget getSubtext(data)
  {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4),
       child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
           children: [
                 textStyle(c: AppColors.userName,context: context,fontsize: 14,fontWeight: FontWeight.w400,text: data['title']),
                 const SizedBox(width: 10,),
                 textStyle(c: AppColors.userName,context: context,fontsize: 14,fontWeight: FontWeight.bold,text: data['amount'].toString()),
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


PieChartSectionData getPieChartSectionData(data,index)
{
    return  PieChartSectionData(
                    value: data['value'],
                    showTitle: false,
                    badgeWidget:  Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                        color: pieChatColor[index],
                           borderRadius: BorderRadius.circular(4)
                        ),
                        child: textStyleOnly(context: context,text:  data['title'],fontWeight: FontWeight.bold,fontsize: 12,c: index-1==0?pieChatColor[0]:pieChatColor[1]),
                    ),
                    // title: data['title'],
                    color: pieChatColor[index] ?? AppColors.uncoloredPie,
                    radius: 50,
                    badgePositionPercentageOffset: 1.6,

          );
} 

}


// PieChartSectionData(
                  //   value: cardBalance,
                  //   title: 'Principal\n₹${cardBalance.toStringAsFixed(0)}',
                  //   color: AppColors.primaryColor,
                  //   radius: 50,
                  // ),
                  // PieChartSectionData(
                  //   value: totalInterestPaid,
                  //   title: 'Interest\n₹${totalInterestPaid.toStringAsFixed(0)}',
                  //   color: AppColors.uncoloredPie,
                  //   radius: 50,
                  // ),