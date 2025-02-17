import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';

import 'package:intl/intl.dart';
import 'package:get/get.dart';

// Add this after your existing classes
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
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString selectedButton = 'Month'.obs;
  late Map<String, List<double>> currentChartData;
  late List currentDays;

  @override
  void initState() {
    super.initState();
    selectedButton.value = widget.selectedButton;
    currentChartData = widget.chartData;
    currentDays = widget.days;
  }

  void _showYearPicker(
      BuildContext context, double fontSizeFactor, double screenWidth) {
    final currentYear = DateTime.now().year;
    final yearsCount = currentYear - 2000 + 1;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.0,
          padding: EdgeInsets.all(8.0),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 2.5,
            children: List.generate(yearsCount, (index) {
              final year = 2000 + index;
              return GestureDetector(
                onTap: () {
                  selectedYear.value = year;
                  // Add your data fetching logic here if needed
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      year.toString(),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal,
                          fontSize: 14,
                          color: AppColors.accentColor),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  void _showMonthPicker(
      BuildContext context, double fontSizeFactor, double screenWidth) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 220.0,
          padding: EdgeInsets.all(8.0),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 2.0,
            childAspectRatio: 2.5,
            children: List.generate(12, (index) {
              final month = index + 1;
              return GestureDetector(
                onTap: () {
                  selectedMonth.value = month;
                  // Add your data fetching logic here if needed
                  Navigator.pop(context);
                },
                child: Container(
                  height: 20,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('MMMM').format(DateTime(2023, month, 1)),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: AppColors.accentColor),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildMonthYearSelector(double fontSizeFactor, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Spendings',
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: fontSizeFactor * 3.4,
              color: AppColors.bg1),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () =>
                  _showMonthPicker(context, fontSizeFactor, screenWidth),
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
                            color: AppColors.accentColor),
                      )),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            GestureDetector(
              onTap: () =>
                  _showYearPicker(context, fontSizeFactor, screenWidth),
              child: Container(
                height: 35,
                width: screenWidth * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.button,
                ),
                child: Center(
                  child: Obx(() => Text(
                        selectedYear.value.toString(),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.normal,
                            fontSize: fontSizeFactor * 3.4,
                            color: AppColors.accentColor),
                      )),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Detailed Chart View'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Column(
        children: [
          _buildMonthYearSelector(fontSizeFactor, screenWidth),
          Expanded(
            child: LineChartWidget(
              chartData: currentChartData,
              days: currentDays,
              selectedButton: selectedButton,
              
            ),
          ),
        ],
      ),
    );
  }
}
