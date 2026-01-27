import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_padding_sizes.dart';

import 'font_manager.dart';

/// -------------------- ANNUAL BALANCE --------------------
class AnnualBalance extends StatelessWidget {
  const AnnualBalance({super.key});

  final List<Map<String, double>> monthlyData = const [
    {"credited": 60000, "debited": 60000},
    {"credited": 6000, "debited": 6000},
    {"credited": 7500, "debited": 7100},
    {"credited": 8500, "debited": 3500},
    {"credited": 10000, "debited": 4500},
    {"credited": 9500, "debited": 5000},
    {"credited": 8700, "debited": 3200},
    {"credited": 8200, "debited": 3100},
    {"credited": 100000, "debited": 3600},
    {"credited": 9100, "debited": 4200},
    {"credited": 9300, "debited": 4300},
    {"credited": 9600, "debited": 4800},
  ];

  final List<String> months = const [
    "Jan","Feb","Mar","Apr","May","Jun",
    "Jul","Aug","Sep","Oct","Nov","Dec"
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate totals for breakdown section
    double totalCredited = 0;
    double totalDebited = 0;
    for (var data in monthlyData) {
      totalCredited += data["credited"]!;
      totalDebited += data["debited"]!;
    }
    double totalOutstanding = totalCredited - totalDebited;

    return Scaffold(
      backgroundColor: AppColors.newbg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Toggle
              Row(
                children: [
                  _toggle(context),
                ],
              ),

           const  SizedBox(height:AppSizes.h30),

              /// Bar Graph
              Padding(
                padding: const EdgeInsets.only(top:AppSizes.p20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25, // 25% of screen height
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(monthlyData.length, (index) {
                        final credited = monthlyData[index]["credited"]!;
                        final debited = monthlyData[index]["debited"]!;
                
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal:AppSizes.p6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _stackedBar(
                                credited: credited,
                                debited: debited,
                              ),
                              const SizedBox(height: AppSizes.h8),
                              Text(
                                months[index],
                                style: FontManager().getTextStyle(context, 
                                fontSize: 12, 
                                color: AppColors.grey,
                                lWeight: FontWeight.w500,
                                 ),
                                 
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.h20),

               Padding(
                 padding: const EdgeInsets.only(left:AppSizes.p4,top:AppSizes.p10),
                 child: Text(
                  "Breakdown",
                 style: FontManager().getTextStyle(context, 
                      fontSize: 16, 
                      color: AppColors.bg1,
                      lWeight: FontWeight.w500,
                               ),
                 ),
               ),
              const SizedBox(height: AppSizes.h15),

              _breakdownTile(
                  context: context,
                title: "Credited",
                amount: "₹${totalCredited.toInt()}",
                color: creditedColor,
                icon: AvatarProfileImageZero(url: Finance.credited,width:10,height:30),
                textColor: AppColors.backgroundColor,
                
              ),

              const SizedBox(height: AppSizes.h12),

              _breakdownTile(
              context: context,
                title: "Debited",
                amount: "₹${totalDebited.toInt()}",
                color: debitedColor,
              icon: AvatarProfileImageZero(url: Finance.debited,width:10,height:30),
                textColor: AppColors.backgroundColor,
              ),

              const SizedBox(height: AppSizes.h12),

              _breakdownTile(
                context: context,
                title: "Outstanding",
                amount: "₹${totalOutstanding.toInt()}",
                color: AppColors.backgroundColor,
                icon: AvatarProfileImageZero(url: Finance.outstanding,width:10,height:30),
                textColor: AppColors.bg1,
                titleColor: AppColors.bg1,
                border: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- STACKED BAR ----------------
  /// All bars same height (220px), divided into 3 portions based on percentages:
  /// - Top: Credited (dark blue - 0xFF4B4D73) - percentage of credited
  /// - Middle: Debited (medium blue - 0xFF9394B8) - percentage of debited
  /// - Bottom: Outstanding (white - 0xFFFFFFFF) - percentage of outstanding
  Widget _stackedBar({
    required double credited,
    required double debited,
  }) {
    const double barHeight =160;
    const double barWidth = 40;
    
    // Calculate outstanding
    // final double outstanding = credited - debited;
    final double outstanding = (credited - debited).clamp(0, double.infinity);

    // Calculate total of all three values
    final double total = credited + debited + outstanding;

    // Calculate percentages
    final double creditedPercentage = credited / total;
    final double debitedPercentage = debited / total;
    final double outstandingPercentage = outstanding / total;

    // Calculate heights based on percentages
    final double creditedHeight = barHeight * creditedPercentage;
    final double debitedHeight = barHeight * debitedPercentage;
    final double outstandingHeight = barHeight * outstandingPercentage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: barHeight,
        width: barWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            /// Top portion - Credited (dark blue - 0xFF4B4D73)
            if (credited > 0)
              Container(
                height: creditedHeight,
                width: barWidth,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor, // Dark blue for credited
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),

            /// Middle portion - Debited (medium blue - 0xFF9394B8)
            if (debited > 0)
              Container(
                height: debitedHeight,
                width: barWidth,
                color: AppColors.debitedAmount, // Medium blue for debited
              ),

            /// Bottom portion - Outstanding (white - 0xFFFFFFFF)
            if (outstanding > 0)
              Container(
                height: outstandingHeight,
                width: barWidth,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor, // White for outstanding
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ---------------- TOGGLE ----------------
  Widget _toggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p4),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleItem(context,"Monthly", false),
          _toggleItem(context,"Annually", true),
        ],
      ),
    );
  }

  Widget _toggleItem(BuildContext context,String text, bool active) {
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p18, vertical: AppSizes.p8),
      decoration: BoxDecoration(
        color: active ? creditedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: FontManager().getTextStyle(context, 
          color: active ? Colors.white : Colors.grey,
            lWeight: FontWeight.w600,
        ),
       

      ),
    );
  }

  /// ---------------- BREAKDOWN TILE ----------------
  Widget _breakdownTile({
   required BuildContext context, 
    required String title,
    required String amount,
    required Color color,
    required Widget icon,
    required Color textColor,
    Color? titleColor,
    bool border = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical:AppSizes.p10),
     
      decoration: BoxDecoration(
      color: color,
        borderRadius: BorderRadius.circular(8),
        // border: border ? Border.all(color: Colors.pink) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left:AppSizes.p10),
        child: Row(
          
          children: [
             icon,
            const SizedBox(width: AppSizes.w20),
            Text(
              title,
              style: FontManager().getTextStyle(
                context, 
                fontSize: 16, 
                 color: titleColor ?? AppColors.backgroundColor, // ← Use your AppColors white
                lWeight: FontWeight.w500,
              ),
            ),
          
           const Spacer(),
            Text(
              amount,
              style: FontManager().getTextStyle(
            context, 
            fontSize: 18, 
        color: titleColor ?? AppColors.backgroundColor,  // ← Use your AppColors white
            lWeight: FontWeight.w600,
          ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- COLORS ----------------
const Color creditedColor = AppColors.primaryColor;
const Color debitedColor = AppColors.debitedAmount;
const Color bgColor =AppColors.backgroundColor;


