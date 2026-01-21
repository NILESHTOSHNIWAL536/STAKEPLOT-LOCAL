
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';



// /// -------------------- ANNUAL BALANCE --------------------
// class AnnualBalance extends StatelessWidget {
//   const AnnualBalance({super.key});

//   final List<Map<String, double>> monthlyData = const [
//     {"credited": 60000, "debited": 60000},
//     {"credited": 9000, "debited": 4000},
//     {"credited": 7000, "debited": 2500},
//     {"credited": 8500, "debited": 3500},
//     {"credited": 10000, "debited": 4500},
//     {"credited": 9500, "debited": 5000},
//     {"credited": 8700, "debited": 3200},
//     {"credited": 8200, "debited": 3100},
//     {"credited": 8800, "debited": 3600},
//     {"credited": 9100, "debited": 4200},
//     {"credited": 9300, "debited": 4300},
//     {"credited": 9600, "debited": 4800},
//   ];

//   final List<String> months = const [
//     "Jan","Feb","Mar","Apr","May","Jun",
//     "Jul","Aug","Sep","Oct","Nov","Dec"
//   ];

//   @override
//   Widget build(BuildContext context) {
//     // Calculate totals for breakdown section
//     double totalCredited = 0;
//     double totalDebited = 0;
//     for (var data in monthlyData) {
//       totalCredited += data["credited"]!;
//       totalDebited += data["debited"]!;
//     }
//     double totalOutstanding = totalCredited - totalDebited;

//     return Scaffold(
//       backgroundColor: AppColors.newbg,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Toggle
//               Row(
//                 children: [
//                   _toggle(),
//                 ],
//               ),

//               const SizedBox(height: 30),

//               /// Bar Graph
//               SizedBox(
//                 height: 280,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: List.generate(monthlyData.length, (index) {
//                       final credited = monthlyData[index]["credited"]!;
//                       final debited = monthlyData[index]["debited"]!;

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 6),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             _stackedBar(
//                               credited: credited,
//                               debited: debited,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               months[index],
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               const Text(
//                 "Breakdown",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 15),

//               _breakdownTile(
//                 title: "Credited",
//                 amount: "₹${totalCredited.toInt()}",
//                 color: creditedColor,
//                 icon: Icons.account_balance_wallet,
//                 textColor: Colors.white,
//               ),

//               const SizedBox(height: 10),

//               _breakdownTile(
//                 title: "Debited",
//                 amount: "₹${totalDebited.toInt()}",
//                 color: debitedColor,
//                 icon: Icons.credit_card,
//                 textColor: Colors.white,
//               ),

//               const SizedBox(height: 10),

//               _breakdownTile(
//                 title: "Outstanding",
//                 amount: "₹${totalOutstanding.toInt()}",
//                 color: Colors.white,
//                 icon: Icons.payments,
//                 textColor: Colors.black,
//                 border: true,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// ---------------- STACKED BAR (CORRECT LOGIC) ----------------
//   /// Bar Structure from bottom to top:
//   /// - Bottom: Outstanding (light blue) 
//   /// - Middle: Debited (medium blue)
//   /// - Top: Credited remaining (dark blue)
//   Widget _stackedBar({
//     required double credited,
//     required double debited,
//   }) {
//     const double barHeight = 220;
//     const double barWidth = 40;

//     // Calculate outstanding
//     final double outstanding = credited - debited;

//     // Calculate percentages relative to credited amount
//     final double outstandingPercent = outstanding / credited;
//     final double debitedPercent = debited / credited;

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: SizedBox(
//         height: barHeight,
//         width: barWidth,
//         child: Column(
//           children: [
//             /// Top portion - Credited (dark blue)
//             /// This represents the "credited" portion that's still available
//             if (outstandingPercent > 0)
//               Expanded(
//                 flex: (outstandingPercent * 1000).toInt(),
//                 child: Container(
//                   width: barWidth,
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryColor,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       topRight: Radius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),

//             /// Middle portion - Debited (medium blue)
//             /// This represents the amount that was spent/debited
//             if (debitedPercent > 0)
//               Expanded(
//                 flex: (debitedPercent * 1000).toInt(),
//                 child: Container(
//                   width: barWidth,
//                   color: AppColors.debitedAmount,
//                 ),
//               ),

//             /// Bottom portion - Outstanding (light blue)
//             /// This represents the remaining balance
//             if (outstandingPercent > 0)
//               Expanded(
//                 flex: (outstandingPercent * 1000).toInt(),
//                 child: Container(
//                   width: barWidth,
//                   decoration: BoxDecoration(
//                     color: AppColors.backgroundColor,
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(10),
//                       bottomRight: Radius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ---------------- TOGGLE ----------------
//   Widget _toggle() {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           _toggleItem("Monthly", false),
//           _toggleItem("Annually", true),
//         ],
//       ),
//     );
//   }

//   Widget _toggleItem(String text, bool active) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//       decoration: BoxDecoration(
//         color: active ? creditedColor : Colors.transparent,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: active ? Colors.white : Colors.grey,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   /// ---------------- BREAKDOWN TILE ----------------
//   Widget _breakdownTile({
//     required String title,
//     required String amount,
//     required Color color,
//     required IconData icon,
//     required Color textColor,
//     bool border = false,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(14),
//         border: border ? Border.all(color: Colors.grey.shade300) : null,
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: textColor),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Text(
//             amount,
//             style: TextStyle(
//               color: textColor,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// ---------------- COLORS ----------------
// const Color creditedColor = Color(0xFF4B4D73);
// const Color debitedColor = Color(0xFF9394B8);
// const Color bgColor = Color(0xFFFFF9F0);




import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/constants/app_styles.dart';
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Toggle
              Row(
                children: [
                  _toggle(),
                ],
              ),

              const SizedBox(height: 30),

              /// Bar Graph
              SizedBox(
                height: 280,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(monthlyData.length, (index) {
                      final credited = monthlyData[index]["credited"]!;
                      final debited = monthlyData[index]["debited"]!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _stackedBar(
                              credited: credited,
                              debited: debited,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              months[index],
                               
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 30),

               Text(
                "Breakdown",
               style: FontManager().getTextStyle(context, 
                    fontSize: 16, 
                    color: AppColors.bg1,
                    lWeight: FontWeight.w500,
              ),
               ),
              const SizedBox(height: 15),

              _breakdownTile(
                title: "Credited",
                amount: "₹${totalCredited.toInt()}",
                color: creditedColor,
                
                icon: Icons.account_balance_wallet,
                textColor: AppColors.backgroundColor,
                
              ),

              const SizedBox(height: 10),

              _breakdownTile(
                title: "Debited",
                amount: "₹${totalDebited.toInt()}",
                color: debitedColor,
                icon: Icons.credit_card,
                textColor: AppColors.backgroundColor,
              ),

              const SizedBox(height: 10),

              _breakdownTile(
                title: "Outstanding",
                amount: "₹${totalOutstanding.toInt()}",
                color: AppColors.backgroundColor,
                icon: Icons.payments,
                textColor: AppColors.backgroundColor,
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
    const double barHeight = 220;
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
  Widget _toggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleItem("Monthly", false),
          _toggleItem("Annually", true),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: active ? creditedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ---------------- BREAKDOWN TILE ----------------
  Widget _breakdownTile({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
    required Color textColor,
    bool border = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        // border: border ? Border.all(color: Colors.pink) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
               
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- COLORS ----------------
const Color creditedColor = AppColors.primaryColor;
const Color debitedColor = AppColors.debitedAmount;
const Color bgColor =AppColors.backgroundColor;


