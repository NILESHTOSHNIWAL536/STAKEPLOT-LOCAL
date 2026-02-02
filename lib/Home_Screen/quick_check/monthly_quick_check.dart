
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';
import '../../Utils/snackBar.dart';
import '../../backed_connections/apis_connect.dart';
import '../../constants/app_styles.dart';
import '../../image_service/avatarProfile.dart';
import '../../repository/bankinfo.dart';
import 'package:intl/intl.dart';


 class BalanceScreen extends StatefulWidget {
  BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {

 
  final Color backgroundColor = const Color(0xFFFFF9F0); 
 // light cream
  final Color cardColor = const Color(0xFF4B4D73);       
       // dark purple
  final Color primaryText = Colors.white;

  final Color creditedBaseColor    = const Color(0xFF4B4D73);

  final Color debitedBaseColor     = const Color(0xFF9394B8);

  final Color outstandingBaseColor = const Color(0xFF80B7C7);
  var selectedBank = 'All'.obs;
 final RxnString selectedInsightTab = RxnString();
 // null initially

  var hasSelectedInsight = false.obs;    // 'Credited' | 'Debited' | 'Outstanding'
  var selectedPeriod = 'Monthly'.obs;        // 'Monthly' | 'Annually'

var selectedBankData = Rxn<Map<String, dynamic>>();
var selectedYear = DateTime.now().year.obs;


  // 🔹 NEW: month selection for the dropdown
  var selectedMonth =
    DateFormat('MMMM').format(DateTime.now()).obs;
        // default month
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
@override
void initState() {
  super.initState();

  // 🔹 initial load (Monthly, current month & year)
  fetchMonthlyInsights(
    year: DateTime.now().year,
    monthName: selectedMonth.value,
  );
//   getQuickCheck(
//   view: 'yearly',
//   year: DateTime.now().year,
// );
}


 int _monthNumberFromName(String name) {
  return months.indexOf(name) + 1;
}
Future<void> fetchMonthlyInsights({
  required int year,
  String? monthName,
}) async {
  isInsightsLoading.value = true;
 final start = DateTime.now();
  try {
    final int month =
        monthName != null ? _monthNumberFromName(monthName) : DateTime.now().month;

    await getQuickCheck( view: 'monthly',
  month: _monthNumberFromName(selectedMonth.value),
  year: DateTime.now().year,);

    print(
      "MONTHLY API TIME: ${DateTime.now().difference(start).inMilliseconds} ms",
    );
    updateMonthlyPercentages(
      credited: quickCheckCreditPercent.value,
      debited: quickCheckDebitPercent.value,
      outstanding: quickCheckOutstandingPercent.value,
    );
    selectedInsightTab.value = null;
hasSelectedInsight.value = false;


    selectedMonth.value =
        monthName ?? months[month - 1];
  } finally {
    isInsightsLoading.value = false;
  }
}

List<String> get availableMonths {
  final now = DateTime.now();

  // If current year → allow only past & current months
  return months.take(now.month).toList();
}
List<int> get availableYears {
  final currentYear = DateTime.now().year;

  // show last 5 years including current
  return List.generate(5, (index) => currentYear - index);
}




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


  // Title like: "Credited", "Debited", "Outstanding"
  String? get currentSelectedTypeLabel => selectedInsightTab.value;

  // Amount based on percentage * total balance
  String get currentSelectedAmountString {
  final bank = selectedBankData.value;

  if (bank == null) {
    switch (selectedInsightTab.value) {
      case 'Credited':
        return '₹${quickCheckCredit.value.toStringAsFixed(2)}';
      case 'Debited':
        return '₹${quickCheckDebit.value.toStringAsFixed(2)}';
      case 'Outstanding':
        return '₹${quickCheckOutstanding.value.toStringAsFixed(2)}';
      default:
        return '₹0.00';
    }
  }

  switch (selectedInsightTab.value) {
    case 'Credited':
      return '₹${(bank['credit'] ?? 0).toStringAsFixed(2)}';
    case 'Debited':
      return '₹${(bank['debit'] ?? 0).toStringAsFixed(2)}';
    case 'Outstanding':
      return '₹${(bank['outstanding'] ?? 0).toStringAsFixed(2)}';
    default:
      return '₹0.00';
  }
}




  /// 👉 percentage for currently selected period + tab
  double get currentSelectedPercentage {
    return percentageFor(selectedInsightTab.value ?? 'Credited');
  }

  /// 👉 helper used by bottom tabs ("(62%)") and dot grid
 double percentageFor(String type) {
  final bank = selectedBankData.value;

  if (bank == null) {
    return {
      'Credited': quickCheckCreditPercent.value,
      'Debited': quickCheckDebitPercent.value,
      'Outstanding': quickCheckOutstandingPercent.value,
    }[type]!;
  }

  return {
    'Credited': bank['percentages']['creditPercent'],
    'Debited': bank['percentages']['debitPercent'],
    'Outstanding': bank['percentages']['outstandingPercent'],
  }[type]!.toDouble();
}




  
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      
                      child: globalbackArrow()),
                    Text(
                      'Balance',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                     _roundIconButton(Icons.download, context),
                
                    
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // add more widgets here inside the top card

SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Obx(() {
    final banks = quickCheckBanks.value;

    if (banks.isEmpty) return const SizedBox();

    return Row(
      children: [
        _bankChip('All', Icons.account_balance),

        ...banks.map((bank) {
          return Padding(
            padding: const EdgeInsets.only(left: 6),
            child: _bankChip(
              bank['bankName'],
              Icons.account_balance,
            ),
          );
        }).toList(),
      ],
    );
  }),
),

          

          const SizedBox(height:28),

          // ---------- Combined balance text ----------
          Obx(() {
  final bank = selectedBankData.value;

  return Text(
    bank == null
        ? 'Combined Balance'
        : '${bank['bankName']} Balance',
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 12,
    ),
  );
}),

          const SizedBox(height: 6),
        Obx(() {
  if (selectedBankData.value == null) {
    return Text(
      '₹${quickCheckCurrentBalance.value.toStringAsFixed(2)}',
      style: TextStyle(
        color: primaryText,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  return Text(
    '₹${(selectedBankData.value!['currentBalance'] ?? 0).toStringAsFixed(2)}',
    style: TextStyle(
      color: primaryText,
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
  );

}),


          const SizedBox(height: 20),


        SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Obx(() {
    final banks = quickCheckBanks;

    if (banks.isEmpty) return const SizedBox();

    return Row(
      children: [
        ...banks.asMap().entries.map((entry) {
          final index = entry.key;
          final bank = entry.value;

          return Row(
            children: [
              _smallAccountChip(
                bank['bankName'],
                '₹${(bank['currentBalance'] ?? 0).toString()}',
              ),

              if (index != banks.length - 1) ...[
                const SizedBox(width: 6),
                _verticalDivider(),
                const SizedBox(width: 6),
              ],
            ],
          );
        }).toList(),

        const SizedBox(width: 8),
        _addAccountButton(),
      ],
    );
  }),
),

          ],
    ),),),);

          
     
  }

Widget _roundIconButton(IconData icon, BuildContext context) {
  return GestureDetector(
    
          onTap: () {
            int len = bankAccountLinkedList.length;
            if (len == 0) {
              snackBarCalled(context, SnackbarData().noBankForLinking);
            }
            
          //   else {
          //     accountIdPdf.value = bankAccountLinkedList[0]['accountId'];
          //     showModalForPdfDownloadBankUiCheckBox(context);
          //   }
          // },
          else {
  if (bankAccountLinkedList.isNotEmpty) {
    accountIdPdf.value = bankAccountLinkedList[0].accountId;
    showModalForPdfDownloadBankUiCheckBox(context);
  }
}


         
    },
    child: Container(
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
    ),
  );
}

  /// Bank filter chip (All, Axis Bank, etc.)
  Widget _bankChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
  selectedBank.value = label;

  if (label == 'All') {
    selectedBankData.value = null; // combined mode
  } else {
    final bank = quickCheckBanks.firstWhere(
      (b) => b['bankName'] == label,
      orElse: () => {},
    );

    selectedBankData.value = bank;
  }
},

      child:Obx(
        () {
          final bool isSelected = selectedBank.value == label;
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

Widget _buildInsightsSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
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
        Obx(() {
  if (selectedPeriod.value == 'Annually' || !hasSelectedInsight.value) {
    return const SizedBox();
  }

  return Center(
    child:  Column(
          children: [
            Text(
              currentSelectedTypeLabel?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentSelectedAmountString,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${currentSelectedPercentage.toStringAsFixed(2)}% of total',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ],
        )
     
  );
}),

        // ---------- DOT GRID ----------
        Obx(() {
  if (selectedPeriod.value == 'Monthly') {
    return Center(child: _dotGrid());
  }

  // 👇 Annual view
  return _annualBarGraph();
}),


        const SizedBox(height: 30),

        // ---------- BOTTOM TABS ----------
       Obx(() {
        final bank = selectedBankData.value;

final credited = bank == null
    ? quickCheckCredit.value
    : bank['credit'];

final debited = bank == null
    ? quickCheckDebit.value
    : bank['debit'];

final outstanding = bank == null
    ? quickCheckOutstanding.value
    : bank['outstanding'];

  if (selectedPeriod.value == 'Annually') {
    
       

  return Column(
    children: [
      const SizedBox(height: 32),

      _breakdownTile(
        context: context,
        title: "Credited",
        amount: "₹${credited.toStringAsFixed(1)}",
        color: AppColors.creditColor,
        icon: AvatarProfileImageZero(
          url: Finance.credited,
          width: 10,
          height: 30,
        ),
        textColor: AppColors.backgroundColor,
      ),

      const SizedBox(height: 12),

      _breakdownTile(
        context: context,
        title: "Debited",
        amount: "₹${debited.toStringAsFixed(1)}",
        color: AppColors.debitedAmount,
        icon: AvatarProfileImageZero(
          url: Finance.debited,
          width: 10,
          height: 30,
        ),
        textColor: AppColors.backgroundColor,
      ),

      const SizedBox(height: 12),

      _breakdownTile(
        context: context,
        title: "Outstanding",
        amount: "₹${outstanding.toStringAsFixed(1)}",
        color: AppColors.backgroundColor,
        icon: AvatarProfileImageZero(
          url: Finance.outstanding,
          width: 10,
          height: 30,
        ),
        textColor: AppColors.bg1,
        titleColor: AppColors.bg1,
        border: true,
      ),
    ],
  );

  }

  return Row(
    children: [
      Expanded(
        child: _insightTab(
          label: 'Credited',
          percentage:
              '${percentageFor('Credited').toStringAsFixed(1)}%',
          isSelected:
              selectedInsightTab.value == 'Credited',
          activeColor: creditedBaseColor,
          onTap: () {
            selectedInsightTab.value = 'Credited';
            hasSelectedInsight.value = true;
          },
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _insightTab(
          label: 'Debited',
          percentage:
              '${percentageFor('Debited').toStringAsFixed(1)}%',
          isSelected:
              selectedInsightTab.value == 'Debited',
          activeColor: debitedBaseColor,
          onTap: () {
            selectedInsightTab.value = 'Debited';
            hasSelectedInsight.value = true;
          },
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _insightTab(
          label: 'Outstanding',
          percentage:
              '${percentageFor('Outstanding').toStringAsFixed(1)}%',
          isSelected:
              selectedInsightTab.value == 'Outstanding',
          activeColor: outstandingBaseColor,
          onTap: () {
            selectedInsightTab.value = 'Outstanding';
            hasSelectedInsight.value = true;
          },
        ),
      ),
    ],
  );
}),

        

              
            
      ],
    ),
  );
}
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

Widget _periodButton(String label) {
  final bool isSelected = selectedPeriod.value == label;

  return GestureDetector(
    onTap: isInsightsLoading.value
    ? null
    : () {
        // 🛑 GUARD: same period tapped again
        if (selectedPeriod.value == label) return;

        selectedPeriod.value = label;

        selectedInsightTab.value = null;
        hasSelectedInsight.value = false;

        if (label == 'Monthly') {
          fetchMonthlyInsights(
            year: selectedYear.value,
            monthName: selectedMonth.value,
          );
        } else {
          getQuickCheck(
            view: 'yearly',
            year: selectedYear.value,
          );
        }
      },


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
  return Obx(() {
    final bool isMonthly = selectedPeriod.value == 'Monthly';

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE6E3DD)),
        color: const Color(0xFFFFF9F0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: isMonthly
              ? selectedMonth.value
              : selectedYear.value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          isDense: true,
          padding: EdgeInsets.zero,

          items: isMonthly
              ? availableMonths.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m, style: const TextStyle(fontSize: 12)),
                  );
                }).toList()
              : availableYears.map((y) {
                  return DropdownMenuItem(
                    value: y,
                    child: Text(
                      y.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),

          onChanged: (value) async {
            if (value == null) return;
            final start = DateTime.now();

            if (isMonthly) {
              // selectedMonth.value = value;

             // 1️⃣ Guard same selection
if (value == selectedMonth.value) return;

// 2️⃣ Update UI immediately
selectedMonth.value = value;
selectedInsightTab.value = null;
hasSelectedInsight.value = false;

// 3️⃣ Fire API WITHOUT await
fetchMonthlyInsights(
  year: selectedYear.value,
  monthName: value,
);

            } else {
              if (value == selectedYear.value) return;

// UI first
selectedYear.value = value;
selectedInsightTab.value = null;
hasSelectedInsight.value = false;

// API later (no await)
getQuickCheck(
  view: 'yearly',
  year: value,
);

            }
             
          },
        ),
      ),
    );
  });
}

Widget _dotGrid() {
  return Obx(() {
    const int gridSize = 10;
    const int totalDots = gridSize * gridSize;
    const double dotSize = 14;
    const double spacing = 10;

    final double creditedPct = percentageFor('Credited');
    final double debitedPct = percentageFor('Debited');
    final double outstandingPct = percentageFor('Outstanding');

    int creditedDots =
        (totalDots * creditedPct / 100).round().clamp(0, totalDots);
    int debitedDots =
        (totalDots * debitedPct / 100).round().clamp(0, totalDots);
    int outstandingDots =
        (totalDots * outstandingPct / 100).round().clamp(0, totalDots);

    final String? selectedLabel = selectedInsightTab.value;

    return SizedBox(
      width: (dotSize + spacing) * gridSize,
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: List.generate(totalDots, (index) {
          late String segmentLabel;

          if (index < creditedDots) {
            segmentLabel = 'Credited';
          } else if (index < creditedDots + debitedDots) {
            segmentLabel = 'Debited';
          } else {
            segmentLabel = 'Outstanding';
          }

          Color baseColor;
          switch (segmentLabel) {
            case 'Credited':
              baseColor = creditedBaseColor;
              break;
            case 'Debited':
              baseColor = debitedBaseColor;
              break;
            default:
              baseColor = outstandingBaseColor;
          }

          final bool isActive =
              selectedLabel == null || selectedLabel == segmentLabel;

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (selectedInsightTab.value == segmentLabel) {
                selectedInsightTab.value = null;
                hasSelectedInsight.value = false;
              } else {
                selectedInsightTab.value = segmentLabel;
                hasSelectedInsight.value = true;
              }
            },
            child: SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: AnimatedScale(
                  scale:
                      selectedLabel == segmentLabel ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? baseColor
                          : baseColor.withOpacity(0.18),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  });
}

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
Widget _annualBarGraph() {
  return Obx(() {
    final bank = selectedBankData.value;

    // 1️⃣ Decide data source
    List months = [];

    if (bank == null) {
      // ALL BANKS → merge months by index
      final Map<int, Map<String, double>> merged = {};

      for (final b in quickCheckBanks) {
        for (final m in (b['months'] ?? [])) {
          final int month = m['month'];

          merged.putIfAbsent(month, () => {
                'credit': 0,
                'debit': 0,
                'outstanding': 0,
              });

          merged[month]!['credit'] =
              merged[month]!['credit']! + (m['credit'] ?? 0);
          merged[month]!['debit'] =
              merged[month]!['debit']! + (m['debit'] ?? 0);
          merged[month]!['outstanding'] =
              merged[month]!['outstanding']! + (m['outstanding'] ?? 0);
        }
      }

      months = merged.entries.map((e) {
        return {
          'month': e.key,
          'credit': e.value['credit'],
          'debit': e.value['debit'],
          'outstanding': e.value['outstanding'],
        };
      }).toList()
        ..sort((a, b) => (a['month'] as int).compareTo(b['month'] as int));

    } else {
      months = bank['months'] ?? [];
    }

   

    // 2️⃣ Render graph
    return SizedBox(
      height: 220,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: months.map((m) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _stackedBar(
                    credited: (m['credit'] ?? 0).toDouble(),
                    debited: (m['debit'] ?? 0).toDouble(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat.MMM().format(
                      DateTime(0, m['month']),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  });
}

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

}

