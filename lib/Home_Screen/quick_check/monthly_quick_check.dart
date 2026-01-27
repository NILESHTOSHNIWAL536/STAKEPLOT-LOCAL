import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';


/// -----------------------------------------------------------
///  CONTROLLER
/// -----------------------------------------------------------
// class BalanceController extends GetxController {
//   var selectedBank = 'All'.obs;
//   var selectedInsightTab = 'Credited'.obs;
// }
class BalanceController extends GetxController {
  // already existing
  var selectedBank = 'All'.obs;
  var selectedInsightTab = 'Credited'.obs;
  var hasSelectedInsight = false.obs;    // 'Credited' | 'Debited' | 'Outstanding'
  var selectedPeriod = 'Monthly'.obs;        // 'Monthly' | 'Annually'



  // 🔹 NEW: month selection for the dropdown
  var selectedMonth = 'October'.obs;         // default month
  final List<String> months = const [
    'January', 
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // loading state for graph data
  
  var isInsightsLoading = true.obs;
  Future<void> loadInsightsForMonth(String month) async {
  selectedMonth.value = month;
  isInsightsLoading.value = true;

  try {
    // TODO: replace with real backend API call
    await Future.delayed(const Duration(milliseconds: 500));

    // example response (replace with backend percentages)
    double creditedPct;
    double debitedPct;
    double outstandingPct;

    switch (month) {
      case 'September':
        creditedPct = 50;
        debitedPct = 30;
        outstandingPct = 20;
        break;

      case 'October':
        creditedPct = 62;
        debitedPct = 25;
        outstandingPct = 13;
        break;

      default:
        creditedPct = 40;
        debitedPct = 35;
        outstandingPct = 25;
    }

    updateMonthlyPercentages(
      credited: creditedPct,
      debited: debitedPct,
      outstanding: outstandingPct,
    );
  } finally {
    isInsightsLoading.value = false;
  }
}








  /// Percentages for MONTHLY view – will be filled from backend
  /// keys: 'Credited', 'Debited', 'Outstanding'
  final RxMap<String, double> monthlyPercentages = <String, double>{
    'Credited': 0,
    'Debited': 0,
    'Outstanding': 0,
  }.obs;

  /// Percentages for ANNUAL view – will be filled from backend
  final RxMap<String, double> annualPercentages = <String, double>{
    'Credited': 0,
    'Debited': 0,
    'Outstanding': 0,
  }.obs;


    // total balance used to estimate amounts from percentage (replace with backend value if you have)
  var totalBalance = 63250.0.obs;

  // Title like: "Credited", "Debited", "Outstanding"
  String get currentSelectedTypeLabel => selectedInsightTab.value;

  // Amount based on percentage * total balance
  String get currentSelectedAmountString {
    final pct = currentSelectedPercentage; // 0–100
    final amount = (totalBalance.value * pct) / 100.0;
    return '₹${amount.toStringAsFixed(2)}';
  }


  /// 👉 percentage for currently selected period + tab
  double get currentSelectedPercentage {
    return percentageFor(selectedInsightTab.value);
  }

  /// 👉 helper used by bottom tabs ("(62%)") and dot grid
  double percentageFor(String type) {
    final map = selectedPeriod.value == 'Monthly'
        ? monthlyPercentages
        : annualPercentages;

    return map[type] ?? 0.0;
  }

  // -----------------------------------------------------------------
  // 💾 1) Call this when backend sends PERCENTAGES directly
  // -----------------------------------------------------------------
  void updateMonthlyPercentages({
    required double credited,
    required double debited,
    required double outstanding,
  }) {
    monthlyPercentages['Credited'] = credited;
    monthlyPercentages['Debited'] = debited;
    monthlyPercentages['Outstanding'] = outstanding;
  }

  void updateAnnualPercentages({
    required double credited,
    required double debited,
    required double outstanding,
  }) {
    annualPercentages['Credited'] = credited;
    annualPercentages['Debited'] = debited;
    annualPercentages['Outstanding'] = outstanding;
  }

  // -----------------------------------------------------------------
  // 💾 2) OR: call this when backend sends AMOUNTS (not percentages)
  // -----------------------------------------------------------------
  // void updateMonthlyFromAmounts({
  //   required double creditedAmount,
  //   required double debitedAmount,
  //   required double outstandingAmount,
  // }) {
  //   final total = creditedAmount + debitedAmount + outstandingAmount;

  //   if (total <= 0) {
  //     monthlyPercentages['Credited'] = 0;
  //     monthlyPercentages['Debited'] = 0;
  //     monthlyPercentages['Outstanding'] = 0;
  //     return;
  //   }

  //   monthlyPercentages['Credited'] =
  //       (creditedAmount / total) * 100.0;
  //   monthlyPercentages['Debited'] =
  //       (debitedAmount / total) * 100.0;
  //   monthlyPercentages['Outstanding'] =
  //       (outstandingAmount / total) * 100.0;
  // }

  // void updateAnnualFromAmounts({
  //   required double creditedAmount,
  //   required double debitedAmount,
  //   required double outstandingAmount,
  // }) {
  //   final total = creditedAmount + debitedAmount + outstandingAmount;

  //   if (total <= 0) {
  //     annualPercentages['Credited'] = 0;
  //     annualPercentages['Debited'] = 0;
  //     annualPercentages['Outstanding'] = 0;
  //     return;
  //   }

  //   annualPercentages['Credited'] =
  //       (creditedAmount / total) * 100.0;
  //   annualPercentages['Debited'] =
  //       (debitedAmount / total) * 100.0;
  //   annualPercentages['Outstanding'] =
  //       (outstandingAmount / total) * 100.0;
  // }
}





/// -----------------------------------------------------------
///  MAIN APP
/// -----------------------------------------------------------



/// -----------------------------------------------------------
///  BALANCE SCREEN
/// -----------------------------------------------------------
 class BalanceScreen extends StatelessWidget {
  BalanceScreen({super.key});

  final BalanceController controller = Get.put(BalanceController());

  final Color backgroundColor = const Color(0xFFFFF9F0); // light cream
  final Color cardColor = const Color(0xFF4B4D73);       // dark purple
  final Color primaryText = Colors.white;

  final Color creditedBaseColor    = const Color(0xFF4B4D73);
  final Color debitedBaseColor     = const Color(0xFF9394B8);
  final Color outstandingBaseColor = const Color(0xFF80B7C7);


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
     
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF4B4D73),
        statusBarIconBrightness: Brightness.light, // white battery/time icons
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
  
        
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopCard(context),
              const SizedBox(height: 22),
               _buildInsightsSection(),
            
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------------------------------------------------
  ///  TOP PURPLE CARD (continuous with status bar)
  /// ---------------------------------------------------------
  Widget _buildTopCard(BuildContext context) {
    return Container(
      width: double.infinity,
      // optional fixed height if you want it
      height: 337,
      decoration: BoxDecoration(
        color: cardColor, // 👈 same as statusBarColor
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),

      // 👇 This makes the Column start *below* the status bar,
      // but the purple background still goes behind it.
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- first row: back, title, download ----------
              Padding(
                padding: const EdgeInsets.only(top:12.0),
                child: Row(
                  
                
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _roundIconButton(Icons.arrow_back),
                    Text(
                      'Balance',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                     _roundIconButton(Icons.download),
                
                    
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // add more widgets here inside the top card


SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            
               child:Row(
                children: [
                  _bankChip('All', Icons.account_balance),
                  const SizedBox(width: 4,height:3),
                  _bankChip('Axis Bank', Icons.account_balance_wallet),
                  const SizedBox(width: 4,height:3),
                  _bankChip('Hdfc Bank', Icons.account_balance),
                  const SizedBox(width: 4,height:3),
                  _bankChip('ICIC Bank', Icons.account_balance),
                ],
                             ),
            ),
          

          const SizedBox(height:28),

          // ---------- Combined balance text ----------
          Text(
            'Combined Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹63,250.00',
            style: TextStyle(
              color: primaryText,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),


        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: [
                _smallAccountChip('Axis','₹50250.00'),
                const SizedBox(width: 1),
                _verticalDivider(),
                _smallAccountChip('Hdfc', '₹6250.00'),
                const SizedBox(width: 1),
                _verticalDivider(),
                _smallAccountChip('ICIC', '₹63250.00'),
                const SizedBox(width: 6),
                _addAccountButton(),
                
            
            ],
            ),
        ),
          ],
    ),),),);

          
     
  }
Widget _roundIconButton(IconData icon) {
  return Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: Icon(
      icon,
      color: Color(0xFF3F3D7D),
    ),
  );
}


  /// Bank filter chip (All, Axis Bank, etc.)
  Widget _bankChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () => controller.selectedBank.value = label,
      child:Obx(
        () {
          final bool isSelected = controller.selectedBank.value == label;
          return Container(
            padding: const EdgeInsets.symmetric( horizontal:8,vertical: 6),
            
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Color(0xFF4B4D73),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10, width: 2),
              
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? cardColor : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? cardColor : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),);
  }

  /// Small chip under balance, showing per account amount
  Widget _smallAccountChip(String bankShortName, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
       
        
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
         
          // const SizedBox(width: 4),
          Text(
            amount,
            style: const TextStyle(color: Colors.white, fontSize:14),
            
          ),
          const SizedBox(width: 2),
          
          
          
        ],
      ),);
  }
Widget _verticalDivider() {
  return Container(
    width: 1.5,
    height: 18,
    color: Colors.white,
    margin: const EdgeInsets.symmetric(horizontal: 1),
  );
}


 
    
  
  
  /// "+" button at the end of the small chips row
  Widget _addAccountButton() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Color(0xFF4B4D73),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white)
    ),
      child: const Icon(Icons.add,size: 16, color: Colors.white),
    );

    
  }

 ///  BOTTOM AREA: "My Insights", grid + bottom tabs
  /// ---------------------------------------------------------
//   Widget _buildInsightsSection() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 22),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ---------- TOP ROW: Monthly / Annually + dropdown ----------
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Obx(
//               () => Row(
//                 children: [
//                   _periodButton('Monthly'),
//                   const SizedBox(width: 2),
//                   _periodButton('Anually'),
//                 ],
//               ),
            
//             ),
//             const SizedBox(width: 50),
//             _simpleDropdown(),
//           ],
//         ),

//         const SizedBox(height: 24),

//         // ---------- "Most Used Account" ----------
// // ---------- DYNAMIC "MOST USED ACCOUNT / INSIGHT" AREA ----------
// Center(
//   child: Obx(
//     () {
//       // 👉 BEFORE any button click: show original static content
//       if (!controller.hasSelectedInsight.value) {
//         return Column(
//           children: const [
//             Text(
//               'Most Used Account',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.black54,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Axis Bank',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               '48 transactions in October',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.black45,
//               ),
//             ),
//           ],
//         );
//       }

//       // 👉 AFTER user taps Credited / Debited / Outstanding:
//       return Column(
//         children: [
//           Text(
//             controller.currentSelectedTypeLabel,  // "Credited" / "Debited" / "Outstanding"
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             controller.currentSelectedAmountString, // ₹XX,XXX.XX (from percentage * totalBalance)
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${controller.currentSelectedPercentage.toStringAsFixed(0)}% of total',
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.black45,
//             ),
//           ),
//         ],
//       );
//     },
//   ),
// ),


//         // ---------- BOTTOM TABS ----------
//         Obx(
//   () => Row(
//     children: [
//       Expanded(
//         child: _insightTab(
//           label: 'Credited',
//           percentage:
//               '${controller.percentageFor('Credited').toStringAsFixed(0)}%',
//           isSelected: controller.selectedInsightTab.value == 'Credited',
//           activeColor: creditedBaseColor,
//           onTap: () => controller.selectedInsightTab.value = 'Credited',
//         ),
//       ),
//       const SizedBox(width: 8),
//       Expanded(
//         child: _insightTab(
//           label: 'Debited',
//           percentage:
//               '${controller.percentageFor('Debited').toStringAsFixed(0)}%',
//           isSelected: controller.selectedInsightTab.value == 'Debited',
//           activeColor: debitedBaseColor,
//           onTap: () => controller.selectedInsightTab.value = 'Debited',
//         ),
//       ),
//       const SizedBox(width: 8),
//       Expanded(
//         child: _insightTab(
//           label: 'Outstanding',
//           percentage:
//               '${controller.percentageFor('Outstanding').toStringAsFixed(0)}%',
//           isSelected: controller.selectedInsightTab.value == 'Outstanding',
//           activeColor: outstandingBaseColor,
//           onTap: () => controller.selectedInsightTab.value = 'Outstanding',
//         ),
//       ),
//     ],
//   ),
// ),


//         const SizedBox(height: 32),
//       ],
//     ),
//   );
// }





Widget _buildInsightsSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- TOP ROW: Monthly / Annually + dropdown ----------
        Padding(
          padding: const EdgeInsets.only(left: 25,right:15),
           child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Row(
                  
                  children: [
                    _periodButton('Monthly'),
                    const SizedBox(width: 4),
                    _periodButton('Annually'), // small typo fix
                  ],
                ),
              ),
              _simpleDropdown(),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ---------- DYNAMIC "MOST USED ACCOUNT / INSIGHT" AREA ----------
        Center(
          child: Obx(
            () {
              // BEFORE any button click: show original static content
              if (!controller.hasSelectedInsight.value) {
                return Column(
                  children: const [
                    Text(
                      'Most Used Account',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Axis Bank',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '48 transactions in October',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                );
              }

              // AFTER user taps Credited / Debited / Outstanding:
              return Column(
                children: [
                  Text(
                    controller.currentSelectedTypeLabel, // "Credited" etc.
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.currentSelectedAmountString, // ₹XX,XXX.XX
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.currentSelectedPercentage.toStringAsFixed(0)}% of total',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // ---------- DOT GRID ----------
        Center(
          child: _dotGrid(), // 10x10 grid, color based on selected tab
        ),

        const SizedBox(height: 30),

        // ---------- BOTTOM TABS ----------
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _insightTab(
                  label: 'Credited',
                  percentage:
                    '${controller.percentageFor('Credited').toStringAsFixed(0)}%',
                  isSelected:
                      controller.selectedInsightTab.value == 'Credited',
                  activeColor: creditedBaseColor,
                  onTap: () {
                    controller.selectedInsightTab.value = 'Credited';
                    controller.hasSelectedInsight.value = true;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _insightTab(
                  label: 'Debited',
                  percentage:
                      '${controller.percentageFor('Debited').toStringAsFixed(0)}%',
                  isSelected:
                      controller.selectedInsightTab.value == 'Debited',
                  activeColor: debitedBaseColor,
                  onTap: () {
                    controller.selectedInsightTab.value = 'Debited';
                    controller.hasSelectedInsight.value = true;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _insightTab(
                  label: 'Outstanding',
                  percentage:
                      '${controller.percentageFor('Outstanding')
                          .toStringAsFixed(0)}%',
                  isSelected:
                      controller.selectedInsightTab.value == 'Outstanding',
                  activeColor: outstandingBaseColor,
                  onTap: () {
                    controller.selectedInsightTab.value = 'Outstanding';
                    controller.hasSelectedInsight.value = true;
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    ),
  );
}

Widget _periodButton(String label) {
  final bool isSelected = controller.selectedPeriod.value == label;

  return GestureDetector(
    onTap: () => controller.selectedPeriod.value = label,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? cardColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                   spreadRadius: 4,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
        border: Border.all(
          color: isSelected ? cardColor : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : cardColor,
        ),
      ),
    ),
  );
}

Widget _simpleDropdown() {
  return Container(
    height: 32,  // 👈 makes the dropdown compact
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),   // small rounded rectangle
      border: Border.all(color: Color(0xFFE6E3DD)),
      color: Color(0xFFFFF9F0),
    ),

    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: null, // always show "Select"
        hint: const Text(
          'Select',
          style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),
        ),

        // 👇 very small arrow, tight spacing
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),

        isDense: true,   // removes extra internal padding
        // menuMaxHeight: 300,
        padding: EdgeInsets.zero,  // removes unwanted spacing

        items: controller.months.map((m) {
          return DropdownMenuItem<String>(
            value: m,
            child: Text(
              m,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),

        onChanged: (value) {
          if (value != null) {
            controller.loadInsightsForMonth(value);
          }
        },
      ),
    ),
  );
}


Widget _dotGrid() {
  return Obx(() {
    const int gridSize = 10;                    // 10 x 10 grid
    const int totalDots = gridSize * gridSize;  // 100 dots
    const double dotSize = 14;      
    const double spacing = 10;

    const double gridWidth =
        (dotSize * gridSize) + (spacing * (gridSize - 1));

    // ------------------ LOADING STATE ------------------
    if (controller.isInsightsLoading.value) {
      return SizedBox(
        width: gridWidth,
        height: gridWidth,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }

    // ------------------ GET PERCENTAGES ------------------
    final double creditedPct     = controller.percentageFor('Credited');
    final double debitedPct      = controller.percentageFor('Debited');
    final double outstandingPct  = controller.percentageFor('Outstanding');

    // ------------------ CONVERT TO DOT COUNTS ------------------
    int creditedDots =
        (totalDots * creditedPct / 100).round().clamp(0, totalDots);

    int debitedDots =
        (totalDots * debitedPct / 100).round().clamp(0, totalDots);

    int outstandingDots =
        (totalDots * outstandingPct / 100).round().clamp(0, totalDots);

    // always clamp so total = 100
    int totalAssignedDots =
        creditedDots + debitedDots + outstandingDots;

    if (totalAssignedDots > totalDots) {
      final overflow = totalAssignedDots - totalDots;
      outstandingDots = (outstandingDots - overflow).clamp(0, totalDots);
    }

    // ------------------ WHICH SEGMENT IS SELECTED ------------------
    final String selectedLabel = controller.selectedInsightTab.value;

    return SizedBox(
      width: gridWidth,
      height: gridWidth,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
        ),
        itemCount: totalDots,
        itemBuilder: (context, index) {
          // ------------------ DETERMINE SEGMENT OF EACH DOT ------------------
          late String segmentLabel;

          if (index < creditedDots) {
            segmentLabel = 'Credited';
          } else if (index < creditedDots + debitedDots) {
            segmentLabel = 'Debited';
          } else {
            segmentLabel = 'Outstanding';
          }

          // ------------------ SEGMENT COLORS ------------------
          Color baseColor;

          switch (segmentLabel) {
            case 'Credited':
              baseColor = creditedBaseColor;
              break;
            case 'Debited':
              baseColor = debitedBaseColor;
              break;
            case 'Outstanding':
              baseColor = outstandingBaseColor;
              break;
            default:
              baseColor = Colors.grey;
          }

          // ------------------ SELECTED SEGMENT FULL OPACITY ------------------
          final bool isActiveSegment = (segmentLabel == selectedLabel);
          
          final Color dotColor = 
              isActiveSegment ? baseColor : baseColor.withOpacity(0.18);

          return Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          );
        },
      ),
    );
  });
}





// Widget _dotGrid() {
//   return Obx(() {
//     const int gridSize = 10;            // 10 rows x 10 columns
//     // const int totalDots = 100;  
//     const int totalDots = gridSize * gridSize; // 100 dots        // total fixed dots
//     const double dotSize = 14;          // size of dot
//     const double spacing = 10;           // even spacing
    
//     // Fixed square container size
//     const double gridWidth =
//         (dotSize * gridSize) + (spacing * (gridSize - 1));

//     // ---- loading spinner ----
//     if (controller.isInsightsLoading.value) {
//       return SizedBox(
//         width: gridWidth,
//         height: gridWidth,
//         child: const Center(
//           child: CircularProgressIndicator(strokeWidth: 2.0),
//         ),
//       );
//     }

//     // ---- percentage of selected type ----
//     final double pct = controller.currentSelectedPercentage;
//     final int activeDots =
//         ((pct / 100) * totalDots).round().clamp(0, totalDots);

//     // ---- color based on selected type ----
//     Color baseColor;
//     switch (controller.selectedInsightTab.value) {
//       case 'Debited':
//         baseColor = debitedBaseColor;      // e.g. 0xFF9394B8
//         break;
//       case 'Outstanding':
//         baseColor = outstandingBaseColor;  // e.g. 0xFF80B7C7
//         break;
//       case 'Credited':
//       default:
//         baseColor = creditedBaseColor;     // e.g. 0xFF4B4D73
//         break;
//     }

//     // ---- active = 100% opacity | inactive = faded ----
//     final Color activeColor = baseColor;                 // ← FULL OPACITY
//     final Color inactiveColor = baseColor.withOpacity(0.18);

//     // ---- build square 10×10 grid ----
//     return SizedBox(
//       width: gridWidth,
//       height: gridWidth,
//       child: GridView.builder(
//         padding: EdgeInsets.zero,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: gridSize,        // 10 dots per row
//           mainAxisSpacing: spacing,
//           crossAxisSpacing: spacing,
//         ),
//         itemCount: totalDots,
//         itemBuilder: (context, index) {
//           final bool isActive = index < activeDots;
//           return Container(
//             width: dotSize,
//             height: dotSize,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isActive ? activeColor : inactiveColor,
//             ),
            
//           );
//         },
//       ),
//     );
//   });
// }


// Widget _dotGrid() {
//   return Obx(() {
//     const int gridSize = 10;          // 10 rows, 10 columns
//     const int totalDots = gridSize * gridSize; // 100 dots
//     const double dotSize = 10;
//     const double spacing = 6;
//     const double gridWidth =
//         (dotSize * gridSize) + (spacing * (gridSize - 1));

//     if (controller.isInsightsLoading.value) {
//       // 🔹 While loading, show a fixed-size loader so layout doesn't jump
//       return SizedBox(
//         width: gridWidth,
//         height: gridWidth,
//         child: const Center(
//           child: CircularProgressIndicator(strokeWidth: 2),
//         ),
//       );
//     }

//     // 🔹 percentage for the currently selected tab & period
//     final double percentage = controller.currentSelectedPercentage;
//     final int activeDots =
//         ((percentage / 100.0) * totalDots).round().clamp(0, totalDots);

//     // 🔹 choose base color based on selected insight tab
//     Color baseColor;
//     switch (controller.selectedInsightTab.value) {
//       case 'Debited':
//         baseColor = debitedBaseColor;      // 0xFF9394B8
//         break;
//       case 'Outstanding':
//         baseColor = outstandingBaseColor;  // 0xFF80B7C7
//         break;
//       case 'Credited':
//       default:
//         baseColor = creditedBaseColor;     // 0xFF4B4D73
//         break;
//     }

//     // 🔹 full opacity for active dots, lighter for inactive
//     final Color activeColor = baseColor;                        // 100% opacity
//     final Color inactiveColor = baseColor.withOpacity(0.18);    // faint

//     return SizedBox(
//       width: gridWidth,
//       height: gridWidth,
//       child: GridView.builder(
//         padding: EdgeInsets.zero,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: gridSize,   // 10 columns
//           mainAxisSpacing: spacing,   // equal vertical spacing
//           crossAxisSpacing: spacing,  // equal horizontal spacing
//         ),
//         itemCount: totalDots,
//         itemBuilder: (context, index) {
//           final bool isActive = index < activeDots;

//           return Container(
//             width: dotSize,
//             height: dotSize,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isActive ? activeColor : inactiveColor,
//             ),
//           );
//         },
//       ),
//     );
//   });
// }











Widget _insightTab({
  required String label,
  required String percentage,
  required bool isSelected,
  required Color activeColor,
  required VoidCallback onTap,   // 🔹 new
}) {
  return GestureDetector(
    onTap: onTap,                // 🔹 use callback from outside
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      
        border: Border.all(
          color: isSelected ? activeColor : Colors.black26,
                width: isSelected ? 2 : 1,    
        ),
      ),
      child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // mainAxisAlignment: MainAxisAlignment.center,
         mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isSelected ? activeColor : Colors.black54,
            ),
          ),
          const SizedBox(width:8,height:2),
          Text(
            '($percentage)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isSelected ? activeColor : Colors.black45,
            ),
          ),
        ],
      ),
    ),
  );
}
 }

