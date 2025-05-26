import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';


class ExpandedChartView extends StatefulWidget {
  final Map<String, List<double>> chartData;
  final List days;
  final String selectedButton;
  final int selectedYear;
  final int selectedMonth;

  const ExpandedChartView({
    Key? key,
    required this.chartData,
    required this.days,
    required this.selectedButton,
    required this.selectedYear,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  State<ExpandedChartView> createState() => _ExpandedChartViewState();
}

class _ExpandedChartViewState extends State<ExpandedChartView> {

   final ScrollController scrollController = ScrollController();
   
 
  @override
  void initState() {
    super.initState();
     currentPage=1;
     hasMoreData = true;
     currentDays.value = List.from(widget.days);
     getAllTransactionHistory(context, true, isYearView.value,isRefreshing: true);
     updateMonthLabels();
     filterDataForSelectedMonth();
     scrollController.addListener(_onScroll);
  }


  void callBackApi()
  {
      currentPage = 1;
      isLoadingMore.value=false;
      getAllTransactionHistory(context,false,false,isRefreshing: true);
  }
  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeFactor = screenWidth * 0.01;

    return WillPopScope(
           onWillPop: () async {
            callBackApi();
             return true;
       },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: appbarWidget(),
        body:  SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: _buildMonthYearSelector(fontSizeFactor, screenWidth),
                   ),
              
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(()=> isLoading.value ? Center(child: CircularProgressIndicator()) :  getLineGraph(screenHeight,screenWidth)),
                  ),
              
                 const SizedBox(
                    height: 10,
                  ),
                    
                  transactionsHistoryList(),
                       
                ],
              ),
            )),
    );
  }



Widget getLineGraph(screenHeight,screenWidth){
    return  Container(
                        height: screenHeight / 2.6,
                        width: screenWidth /1.1,
                        child: LineChartWidget(
                          chartData: currentChartData.value,
                          days: isYearView.value ? monthLabels : currentDays,
                          selectedButton: selectedButton,
                          daysInMonth: isYearView.value
                              ? 12
                              : getDaysInMonthExpanded(
                                  selectedYear.value, selectedMonth.value),
                          isExpandedView: true,
                        ),
     );
}


  

  Widget _buildMonthYearSelector(double fontSizeFactor, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HomepageStringsDart().spendingAndCashFlow,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500,
              fontSize: fontSizeFactor * 4.5,
              color: AppColors.accentColor),
        ),
        SizedBox(height: 10),
        Row(
          children: [
          Obx(()=> Text(
              '₹${formatMoneyIndian(doubleToFixed(totalExpandedValue.toString()))}'
              ,
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: fontSizeFactor * 4,
                  color: AppColors.accentColor),
            )),
           
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              HomepageStringsDart().bankSpendings,
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: fontSizeFactor * 3.4,
                  color: AppColors.bg1),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      showMonthPicker(context, fontSizeFactor, screenWidth),
                  child: Container(
                    height: 35,
                    width: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.button,
                    ),
                    child: Center(
                      child: Obx(() => Text(
                            DateFormat('MMMM').format(DateTime(
                                selectedYear.value, selectedMonth.value, 1)),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: fontSizeFactor * 3.4,
                                 color: !isYearView.value
                                  ? AppColors.primaryColor // Contrast text color for highlight
                                  : AppColors.accentColor),
                          )),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: () =>
                      showYearPicker(context, fontSizeFactor, screenWidth),
                  child: Container(
                    height: 35,
                    width: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color:  AppColors.button,
                    ),
                    child: Center(
                      child: Obx(() => Text(
                            selectedYear.value.toString(),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: fontSizeFactor * 3.4,
                               color: isYearView.value
                                  ? AppColors.primaryColor // Contrast text color for highlight
                                  : AppColors.accentColor),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
 AppBar appbarWidget() {
    return AppBar(
          leading: InkWell(
            onTap: () {
                Navigator.pop(context);
                 callBackApi();
            },
            child: Icon(
              Icons.arrow_back,
              color: AppColors.accentColor,
            ),
          ),
          title: Text( HomepageStringsDart().detailedChartView),
          backgroundColor: AppColors.backgroundColor,
        );
  }

  void _onScroll() {
    scrollController.addListener(() async{
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50)
          {
               getAllTransactionHistory(context, true, isYearView.value);
          }
    });
}

Widget  transactionsHistoryList() {
    return  Obx(() => loadChatdataOnChnage.value
                        ? TransactionHistory(
                            isYearView: isYearView.value,
                            isflag: true,
                            showIcon: true,
                            expandedPage: true,
                          )
                        : TransactionHistory(
                            isYearView: isYearView.value,
                            isflag: true,
                             showIcon: true,
                              expandedPage: true,
                          ));
  }

}


