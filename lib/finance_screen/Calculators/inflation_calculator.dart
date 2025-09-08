import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';
import 'package:get/get.dart';

class InflationCalculator extends StatefulWidget {
  InflationCalculator({Key? key}) : super(key: key);

  @override
  State<InflationCalculator> createState() => _InflationCalculatorState();
}

class _InflationCalculatorState extends State<InflationCalculator> {
  final amountController = TextEditingController(text: '');

  final yearsController = TextEditingController(text: '');

  @override
  void initState() {
    amountController.text = "";
    yearsController.text = "";
    showResults = false.obs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.primaryColorHeader,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.backgroundColor,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Container(
                        // color: Colors.amber,
                        width: MediaQuery.sizeOf(context).width / 1.8,
                        child: Center(
                          child: Text(
                            "Inflation Calculator",
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w700,
                              fontSize: 20,
                              color: AppColors.backgroundColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Calculate the impact of inflation on your money",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.backgroundColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Note: This calculation is an estimate and not accurate for all scenarios.",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.backgroundColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Current Amount (₹)',
                      labelStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.backgroundColor.withOpacity(0.7),
                      ),
                      floatingLabelStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.backgroundColor,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.backgroundColor.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.backgroundColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.backgroundColor.withOpacity(0.3),
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor.withOpacity(0.1),
                    ),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.backgroundColor,
                    ),
                    onChanged: (value) {
                      originalAmount.value = double.tryParse(value) ?? 10000.0;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: yearsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Time Period (Years)',
                      labelStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.backgroundColor.withOpacity(0.7),
                      ),
                      floatingLabelStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.backgroundColor,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.backgroundColor.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.backgroundColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.backgroundColor.withOpacity(0.3),
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor.withOpacity(0.1),
                    ),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.backgroundColor,
                    ),
                    onChanged: (value) {
                      inflatedYears.value = double.tryParse(value) ?? 5.0;
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoadingInflation.value
                          ? null
                          : () => calculateInflation(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Calculate',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (!showResults.value) {
                      return SizedBox.shrink(); // empty widget when not showing
                    }
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
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
                          Text(
                            'Calculation Results',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w600,
                              fontSize: 18,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Future Value: ₹${inflatedFutureValue.value.toStringAsFixed(2)}',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Disclaimer: These results are based on an assumed inflation rate and may not reflect actual future values.',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppColors.primaryColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Syncfusion Line Chart for Future Values
                          // if (inflationPredictions.isNotEmpty)
                          //   SizedBox(
                          //     height: 200,
                          //     child: SfCartesianChart(
                          //       primaryXAxis: NumericAxis(
                          //         title: AxisTitle(
                          //           text: 'Year',
                          //           textStyle: FontManager().getTextStyle(
                          //             context,
                          //             fontSize: 12,
                          //             color: AppColors.primaryColor,
                          //           ),
                          //         ),
                          //         majorGridLines: MajorGridLines(width: 0),
                          //         interval: 1,
                          //       ),
                          //       primaryYAxis: NumericAxis(
                          //         title: AxisTitle(
                          //           text: 'Future Value (₹)',
                          //           textStyle: FontManager().getTextStyle(
                          //             context,
                          //             fontSize: 12,
                          //             color: AppColors.primaryColor,
                          //           ),
                          //         ),
                          //         majorGridLines: MajorGridLines(width: 0.5),
                          //       ),
                          //       series: <ChartSeries>[
                          //         LineSeries<Map<String, dynamic>, double>(
                          //           dataSource: inflationPredictions,
                          //           xValueMapper:
                          //               (Map<String, dynamic> prediction,
                          //                       _) =>
                          //                   prediction['year'].toDouble(),
                          //           yValueMapper: (Map<String, dynamic>
                          //                       prediction,
                          //                   _) =>
                          //               prediction['future_value'].toDouble(),
                          //           color: AppColors.primaryColor,
                          //           width: 1,
                          //           markerSettings:
                          //               MarkerSettings(isVisible: true),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // const SizedBox(height: 24),
                          // List of Yearly Predictions
                          if (inflationPredictions.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Yearly Predictions',
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...inflationPredictions
                                    .map((prediction) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Text(
                                            'Year ${prediction['year']}: ₹${prediction['future_value'].toStringAsFixed(2)} (Inflation: ${prediction['predicted_inflation_percent']}%)',
                                            style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        )),
                              ],
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
