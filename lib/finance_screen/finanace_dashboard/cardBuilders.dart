import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';

class CardBuilders {

  static Widget budgetCard(BuildContext context, dynamic data) {
    double budgetAmount =
        double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
    double spentAmount =
        double.tryParse(data['spentAmount']?.toString() ?? '0') ?? 0;

    // Clamp values
    if (spentAmount < 0) spentAmount = 0;
    if (budgetAmount < 0) budgetAmount = 0;

    double remaining = budgetAmount - spentAmount;
    if (remaining < 0) remaining = 0;

    double progress =
        budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () {

      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.p8),
        constraints: BoxConstraints(
          minHeight: 80,
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF3F4F6),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {

            },
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top title: "Your Budget"
                  globalText(
                    context: context,
                    text: 'Your Budget',
                    fontWeight: FontWeight.w600,
                    fontsize: 14,
                    color: AppColors.accentColor,
                  ),
                  SizedBox(height: AppSizes.h10),

                  // Row with Total Spent and Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Total Spent
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          globalText(
                            context: context,
                            text: formatMoneyIndian(
                                spentAmount.toStringAsFixed(0)),
                            fontWeight: FontWeight.w700,
                            fontsize: 24,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(height: AppSizes.h2),
                          globalText(
                            context: context,
                            text: 'Total Spent',
                            fontWeight: FontWeight.w500,
                            fontsize: 12,
                            color: Colors.grey[600]!,
                          ),
                        ],
                      ),

                      // Remaining
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          globalText(
                            context: context,
                            text:
                                formatMoneyIndian(remaining.toStringAsFixed(0)),
                            fontWeight: FontWeight.w700,
                            fontsize: 24,
                            color: AppColors.accentColor,
                          ),
                          SizedBox(height: AppSizes.h2),
                          globalText(
                            context: context,
                            text: 'Remaining',
                            fontWeight: FontWeight.w500,
                            fontsize: 12,
                            color: Colors.grey[600]!,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.h12),

                  // Horizontal progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor.withOpacity(0.9),
                        ),
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

  // static Widget budgetCard(BuildContext context, dynamic data) {
  //   double budgetAmount =
  //       double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
  //   double spentAmount =
  //       double.tryParse(data['spentAmount']?.toString() ?? '0') ?? 0;

  //   double percentageSpent =
  //       budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;
  //   if (percentageSpent > 100) percentageSpent = 100;

  //   List<ChartData> chartData = [
  //     ChartData(
  //       PlotFinanceStaticData().spent,
  //       spentAmount > budgetAmount ? spentAmount : spentAmount,
  //       AppColors.primaryColor.withOpacity(0.9),
  //     ),
  //     ChartData(
  //       PlotFinanceStaticData().remaining,
  //       spentAmount > budgetAmount ? 0 : budgetAmount - spentAmount,
  //       Colors.grey[300]!.withOpacity(0.7),
  //     ),
  //   ];

  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => MyBudgetScreen(
  //                   data: data,
  //                 )),
  //       );
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: AppSizes.p8),
  //       constraints: BoxConstraints(
  //         minHeight: 140,
  //         maxWidth: MediaQuery.of(context).size.width * 0.85,
  //       ),
  //       decoration: BoxDecoration(
  //         color: AppColors.backgroundColor,
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(
  //           color: Color(0xFFF3F4F6),
  //           width: 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Color.fromRGBO(0, 0, 0, 0.05),
  //             offset: Offset(0, 1),
  //             blurRadius: 2,
  //           ),
  //         ],
  //       ),
  //       child: Material(
  //         color: Colors.transparent,
  //         borderRadius: BorderRadius.circular(20),
  //         child: InkWell(
  //           borderRadius: BorderRadius.circular(20),
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => MyBudgetScreen(data: data)),
  //             );
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.all(AppSizes.p16),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Flexible(
  //                   flex: 3,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       globalText(
  //                         context: context,
  //                         text: data['name']?.toString() ??
  //                             PlotFinanceStaticData().unnamedBudget,
  //                         fontWeight: FontWeight.w700,
  //                         fontsize: 18,
  //                         overflow: TextOverflow.ellipsis,
  //                         maxLines: 1,
  //                         color: AppColors.accentColor,
  //                       ),
  //                       const SizedBox(height: 6),
  //                       globalText(
  //                         context: context,
  //                         text: data['budgetPeriod']?.toString() ??
  //                             PlotFinanceStaticData().unknownPeriod,
  //                         fontWeight: FontWeight.w500,
  //                         fontsize: 13,
  //                         color: Colors.grey[600]!,
  //                         overflow: TextOverflow.ellipsis,
  //                         maxLines: 1,
  //                       ),
  //                       const SizedBox(height: 10),
  //                       Row(
  //                         children: [
  //                           globalText(
  //                             context: context,
  //                             text: PlotFinanceStaticData().budgetPrefix,
  //                             fontWeight: FontWeight.w600,
  //                             fontsize: 14,
  //                             color: AppColors.accentColor.withOpacity(0.9),
  //                           ),
  //                           Flexible(
  //                             child: globalText(
  //                               context: context,
  //                               text:
  //                                   '₹${formatMoneyIndian(budgetAmount.toStringAsFixed(2))}',
  //                               fontWeight: FontWeight.w600,
  //                               fontsize: 14,
  //                               color: AppColors.primaryColor,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Row(
  //                         children: [
  //                           globalText(
  //                             context: context,
  //                             text: PlotFinanceStaticData().spentPrefix,
  //                             fontWeight: FontWeight.w500,
  //                             fontsize: 12,
  //                             color: AppColors.accentColor.withOpacity(0.9),
  //                           ),
  //                           Flexible(
  //                             child: globalText(
  //                               context: context,
  //                               text:
  //                                   '₹${formatMoneyIndian(spentAmount.toStringAsFixed(2))}',
  //                               fontWeight: FontWeight.w500,
  //                               fontsize: 12,
  //                               color: Colors.redAccent,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 8),
  //                       globalText(
  //                         context: context,
  //                         text: PlotFinanceStaticData()
  //                             .percentageSpent
  //                             .replaceFirst(
  //                                 '{percentage}',
  //                                 percentageSpent
  //                                     .toStringAsFixed(1)), // Updated
  //                         fontWeight: FontWeight.w500,
  //                         fontsize: 12,
  //                         color: percentageSpent > 80
  //                             ? Colors.redAccent
  //                             : AppColors.primaryColor,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Flexible(
  //                   flex: 2,
  //                   child: Container(
  //                     height: 110,
  //                     constraints: const BoxConstraints(maxWidth: 110),
  //                     child: SfCircularChart(
  //                       series: <CircularSeries>[
  //                         DoughnutSeries<ChartData, String>(
  //                           dataSource: chartData,
  //                           xValueMapper: (ChartData data, _) => data.category,
  //                           yValueMapper: (ChartData data, _) => data.value,
  //                           pointColorMapper: (ChartData data, _) => data.color,
  //                           innerRadius: '60%',
  //                           radius: '100%',
  //                           dataLabelSettings: DataLabelSettings(
  //                             isVisible: false,
  //                             labelPosition: ChartDataLabelPosition.outside,
  //                             textStyle: TextStyle(
  //                               fontSize: 10,
  //                               fontWeight: FontWeight.bold,
  //                               color: AppColors.backgroundColor,
  //                             ),
  //                           ),
  //                           dataLabelMapper: (ChartData data, _) =>
  //                               '${(data.value / budgetAmount * 100).toStringAsFixed(0)}%',
  //                           animationDuration: 800,
  //                           enableTooltip: true,
  //                         ),
  //                       ],
  //                       tooltipBehavior: TooltipBehavior(
  //                         enable: true,
  //                         format: 'point.x: ₹point.y',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  static Widget budgetCard2(BuildContext context, dynamic data) {
    double budgetAmount =
        double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
    double spentAmount =
        double.tryParse(data['spentAmount']?.toString() ?? '0') ?? 0;

    double percentageSpent =
        budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;
    if (percentageSpent > 100) percentageSpent = 100;

    List<ChartData> chartData = [
      ChartData(
        PlotFinanceStaticData().spent,
        spentAmount > budgetAmount ? spentAmount : spentAmount,
        AppColors.primaryColor.withOpacity(0.9),
      ),
      ChartData(
        PlotFinanceStaticData().remaining,
        spentAmount > budgetAmount ? 0 : budgetAmount - spentAmount,
        Colors.grey[300]!.withOpacity(0.7),
      ),
    ];

    return GestureDetector(
      onTap: () {

      },
      child: Container(
        // margin: const EdgeInsets.symmetric(vertical: AppSizes.p8),
        // constraints: BoxConstraints(
        //   minHeight: 140,
        //   maxWidth: MediaQuery.of(context).size.width * 0.85,
        // ),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFFF3F4F6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: AppColors.transparentColor,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
           
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarProfileImageZero(
                      url: Finance.debtIcon, width: 1, height: 26),
                  SizedBox(height: AppSizes.h10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            globalText(
                              context: context,
                              text: data['name']?.toString() ??
                                  PlotFinanceStaticData().unnamedBudget,
                              fontWeight: FontWeight.w500,
                              fontsize: 16,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              color: AppColors.accentColor,
                            ),
                            SizedBox(height: AppSizes.h10),
                            Row(
                              children: [
                                Flexible(
                                  child: globalText(
                                    context: context,
                                    text:
                                        '₹${formatMoneyIndian(spentAmount.toStringAsFixed(2))}',
                                    fontWeight: FontWeight.w500,
                                    fontsize: 12,
                                    color: Colors.redAccent,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  child: globalText(
                                    context: context,
                                    text:
                                        '/₹${formatMoneyIndian(budgetAmount.toStringAsFixed(2))}',
                                    fontWeight: FontWeight.w600,
                                    fontsize: 14,
                                    color: AppColors.primaryColor,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizes.h4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildSummaryCard(
      BuildContext context, String title, RxList list, Color color) {
    final pendingItems = list
        .where((item) =>
            !(item is Map<String, dynamic> && (item['isPaid'] ?? false)))
        .map((item) => item as Map<String, dynamic>)
        .toList();

    final totalAmount = pendingItems.fold<double>(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item['amount']?.toString() ?? '0') ?? 0),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor, // or AppColors.mt
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.1), // soft shadow
            blurRadius: 8, // how soft the shadow looks
            spreadRadius: 2, // how much it expands
            offset: const Offset(0, 4), // x, y position
          ),
        ],
      ),
      child: Stack(
        children: [
          AvatarProfileImageZero(
              url: svgIconPath.financepayReceive, width: 1, height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: AppSizes.p20),
            decoration: BoxDecoration(
              // color: AppColors.mt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                globalText(
                  context: context,
                  text: title,
                  fontsize: 16,
                  fontWeight: FontWeight.w600,
                  // color: color,
                ),
                SizedBox(height: AppSizes.h10),
                globalText(
                  context: context,
                  text: '₹${formatMoneyIndian(totalAmount.toStringAsFixed(2))}',
                  fontsize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: AppSizes.h6),
                globalText(
                  context: context,
                  text: PlotFinanceStaticData().pendingItems.replaceFirst(
                      '{count}', pendingItems.length.toString()), // Updated
                  fontsize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildCalculatorTile(
      BuildContext context, String title, String subtitle,
      {required String url, required String path}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, path);
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.4,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: AvatarProfileImage(
                  url: url,
                  height: 25,
                  width: 20,
                ),
              ),
              SizedBox(height: AppSizes.h14),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w700,
                              fontSize: MediaQuery.sizeOf(context).height / 56,
                              // overflow: TextOverflow.ellipsis,
                              color: AppColors.bg1,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: MediaQuery.sizeOf(context).height / 56,
                              color: AppColors.bg1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.04,
                      width: MediaQuery.of(context).size.width * 0.08,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Icon(Icons.arrow_forward_ios,
                          color: AppColors.backgroundColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget globalText({
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

  static TextStyle textStyle4({
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
          color: color ?? AppColors.accentColor,
        )
        .copyWith(
          overflow: overflow ?? TextOverflow.clip,
          decoration: decoration,
          fontFamily: fontFamily,
        );
  }
}

class ChartData {
  ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}
