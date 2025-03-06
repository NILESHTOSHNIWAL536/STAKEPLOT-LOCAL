import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // final RxInt selectedYear = DateTime.now().year.obs;
  // final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString selectedButton = 'Month'.obs;
  final RxList<String> monthLabels = <String>[].obs;
  final Rx<Map<String, List<double>>> currentChartData =
      Rx<Map<String, List<double>>>({});
  final RxList<String> currentDays = <String>[].obs;
  // final RxBool isYearView = false.obs;
  final RxBool isLoading = false.obs;

  // Map for converting month names to indices
  final Map<String, int> monthNameToIndex = {
    'Jan': 0,
    'Feb': 1,
    'Mar': 2,
    'Apr': 3,
    'May': 4,
    'Jun': 5,
    'Jul': 6,
    'Aug': 7,
    'Sep': 8,
    'Oct': 9,
    'Nov': 10,
    'Dec': 11
  };

  @override
  void initState() {
    super.initState();
    isLoadingMore.value=false;
    currentPage=1;
    hasMoreData = true;
    selectedButton.value = widget.selectedButton;
    currentChartData.value = widget.chartData;
    currentDays.value = List.from(widget.days);
    getAllTransactionHistory(context, true, isYearView.value);
    _updateMonthLabels();
    _filterDataForSelectedMonth();
  }

  void _updateMonthLabels() {
    monthLabels.value = List.generate(12, (index) {
      return DateFormat('MMM')
          .format(DateTime(selectedYear.value, index + 1, 1));
    });
  }

  int _getDaysInMonth(int year, int month) {
    month = month.clamp(1, 12);
    return DateTime(year, month + 1, 0).day;
  }

  Future<void> _fetchYearlyData(int year) async {
    try {
      // isLoading.value = true;
      String yearString = year.toString().padLeft(4, '0');
      String endpoint =
          "${url}/transactionauto/getAllCustomTransactions/${accountId.value}/year/$yearString";

   
      var response = await getDataApiCall(endpoint);


    
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          var data = jsonDecode(response.body);

          if (data['success'] == true) {
            Map<String, List<double>> yearlyData = {
              'credited': List.filled(12, 0.0),
              'debited': List.filled(12, 0.0),
            };

            try {
              //   print('Processing yearly data for year: $year');
              if (data['data'] != null &&
                  data['data']['transactions'] != null) {
                data['data']['transactions'].forEach((key, value) {
                  int monthIndex = monthNameToIndex[key] ?? -1;
                
                  if (monthIndex >= 0 && monthIndex < 12) {
                    yearlyData['credited']![monthIndex] =
                        getDouble(value['credit']);
                    yearlyData['debited']![monthIndex] =
                        getDouble(value['debit']);
                  } else {
                  
                  }
                });

                currentChartData.value = yearlyData;
                maxYValue.value = data['data']['maxAmount']?.toDouble() ?? 500.0;totalExpandedValue.value= data['data']['totalCredit']?.toDouble() ?? 500.0;
                if (maxYValue.value == 0) maxYValue.value = 500.0;
                
              } else {
             
                throw Exception('Invalid data structure received from API');
              }
            } catch (e) {
             
              maxYValue.value = 500.0;
              currentChartData.value = {
                'credited': List.filled(12, 0.0),
                'debited': List.filled(12, 0.0),
              };
            }
          } else {
            //  print('API returned success:false with error: ${data['error']}');
            currentChartData.value = {
              'credited': List.filled(12, 0.0),
              'debited': List.filled(12, 0.0),
            };
          }
        } catch (e) {
          
          currentChartData.value = {
            'credited': List.filled(12, 0.0),
            'debited': List.filled(12, 0.0),
          };
        }
      } else {
        
        try {
          var errorData = jsonDecode(response.body);
         
        } catch (e) {
        
        }
        currentChartData.value = {
          'credited': List.filled(12, 0.0),
          'debited': List.filled(12, 0.0),
        };
      }
    } catch (e) {
      
      currentChartData.value = {
        'credited': List.filled(12, 0.0),
        'debited': List.filled(12, 0.0),
      };
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchMonthlyData(int year, int month) async {
    try {
      // isLoading.value = true;
      String formattedDate =
          DateFormat('yyyy-MM').format(DateTime(year, month));
      var response = await getDataApiCall(
          "${url}/transactionauto/getAllCustomTransactions/${accountId.value}/month/$formattedDate");

      if (getFlagOfResponse(response)) {
        var data = jsonDecode(response.body);
        int daysInMonth = _getDaysInMonth(year, month);
        Map<String, List<double>> monthlyData = {
          'credited': List.filled(daysInMonth, 0.0),
          'debited': List.filled(daysInMonth, 0.0),
        };

        try {
        
          data['data']['transactions'].forEach((key, value) {
            try {
              int dayIndex = int.parse(key.split('-')[2]) - 1;
              
              if (dayIndex >= 0 && dayIndex < daysInMonth) {
                monthlyData['credited']![dayIndex] = getDouble(value['credit']);
                monthlyData['debited']![dayIndex] = getDouble(value['debit']);
              } else {
             
              }
            } catch (e) {
             
            }
          });

          currentChartData.value = monthlyData;
          maxYValue.value = data['data']['maxAmount']?.toDouble() ?? 500.0;
          totalExpandedValue.value=data['data']['totalCredit']?.toDouble() ?? 500.0;
          if (maxYValue.value == 0) maxYValue.value = 500.0;
        } catch (e) {
          
          maxYValue.value = 500.0;
          currentChartData.value = {
            'credited': List.filled(daysInMonth, 0.0),
            'debited': List.filled(daysInMonth, 0.0),
          };
        }
      } else {
        int daysInMonth = _getDaysInMonth(year, month);
        currentChartData.value = {
          'credited': List.filled(daysInMonth, 0.0),
          'debited': List.filled(daysInMonth, 0.0),
        };
      }
    } catch (e) {
    
      int daysInMonth = _getDaysInMonth(year, month);
      currentChartData.value = {
        'credited': List.filled(daysInMonth, 0.0),
        'debited': List.filled(daysInMonth, 0.0),
      };
    } finally {
      isLoading.value = false;
    }
  }

  void _filterDataForSelectedMonth() {
    int monthForCalc = selectedMonth.value.clamp(1, 12);
    int daysInMonth = _getDaysInMonth(selectedYear.value, monthForCalc);
    List<String> newDays = List.generate(daysInMonth, (index) {
      return (index + 1).toString();
    });
    currentDays.value = newDays;

    if (isYearView.value) {
      _fetchYearlyData(selectedYear.value);
    } else {
      _fetchMonthlyData(selectedYear.value, monthForCalc);
    }
  }

  void _showYearPicker(
      BuildContext context, double fontSizeFactor, double screenWidth) {
    final currentYear = DateTime.now().year;
    final yearsCount = currentYear - 2020 + 1;

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
              final year = currentYear - index;
              return GestureDetector(
                onTap: () async {
                  selectedYear.value = year;
                  isYearView.value = true;
                  Navigator.pop(context);
                  transactionsHistory.clear();
                    currentPage=1;
                  getAllTransactionHistory(context, true, true);
                  _updateMonthLabels();
                  await _fetchYearlyData(year);
                  // setState(() {});
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
                onTap: () async {
                  selectedMonth.value = month;
                  isYearView.value = false;
                  // loadChatdataOnChnage.value = !loadChatdataOnChnage.value;
                  Navigator.pop(context);
                  transactionsHistory.clear();
                    currentPage=1;
                  getAllTransactionHistory(context, true, false);
                  await _fetchMonthlyData(selectedYear.value, month);
                  // setState(() {});
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
                      DateFormat('MMMM')
                          .format(DateTime(selectedYear.value, month, 1)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly spending and cash flow',
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500,
              fontSize: fontSizeFactor * 4.5,
              color: AppColors.accentColor),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              '₹$totalExpandedValue',
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: fontSizeFactor * 4,
                  color: AppColors.accentColor),
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'This week',
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: fontSizeFactor * 2.5,
                  color: AppColors.accentColor),
            ),
          ],
        ),
        Row(
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeFactor = screenWidth * 0.01;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Detailed Chart View'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Obx(() => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildMonthYearSelector(fontSizeFactor, screenWidth),
                  if (isLoading.value)
                    Center(child: CircularProgressIndicator())
                  else
                   Obx(()=> Container(
                      height: screenHeight / 2.6,
                      child: LineChartWidget(
                        chartData: currentChartData.value,
                        days: isYearView.value ? monthLabels : currentDays,
                        selectedButton: selectedButton,
                        daysInMonth: isYearView.value
                            ? 12
                            : _getDaysInMonth(
                                selectedYear.value, selectedMonth.value),
                        isExpandedView: true,
                      ),
                    )),
                  SizedBox(
                    height: 10,
                  ),
                  Obx(() => loadChatdataOnChnage.value
                      ? TransactionHistory(
                          isYearView: isYearView.value,
                          isflag: true,
                        )
                      : TransactionHistory(
                          isYearView: isYearView.value,
                          isflag: true,
                        ))
                ],
              ),
            ),
          )),
    );
  }
}
