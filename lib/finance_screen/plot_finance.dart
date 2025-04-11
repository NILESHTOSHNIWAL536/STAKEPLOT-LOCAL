// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

// class PlotFinance extends StatefulWidget {
//   const PlotFinance({super.key});

//   @override
//   State<PlotFinance> createState() => _PlotFinanceState();
// }

// class _PlotFinanceState extends State<PlotFinance> {
//   @override
//   void initState() {
//     super.initState();
//     getBudget();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       bottomNavigationBar: BottomNavigations(data: 1),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header Banner
//                 AvatarProfileImage(
//                   url: Finance.plot,
//                   height: 6,
//                   width: 1,
//                 ),

//                 budgetAndDebtCalulator(),
//                 textStyle(
//                     context: context,
//                     text: "Calculators",
//                     fontsize: 18,
//                     fontWeight: FontWeight.w800),
//                 calculatorList(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget budgetAndDebtCalulator() {
//     return // Budget and Debt Buttons
//         Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 5,
//       // color: Colorcodes.appBarColor,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.only(right: 50),
//         children: [
//           _buildCard(
//             icon: AvatarProfileImage(
//               url: Finance.budget,
//               height: 7,
//               width: 7,
//             ),
//             path: budgetList.isEmpty ? "/Budget" : "/BudgetDisplay",
//           ),
//           _buildCard(
//             icon: AvatarProfileImage(
//               url: Finance.debt,
//               height: 7,
//               width: 7,
//             ),
//             path: "/Debt",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget calculatorList() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
//       width: MediaQuery.of(context).size.width,
//       child: Wrap(
//         spacing: 8,
//         runSpacing: 8,
//         children: [
//            _buildCalculatorTile(
//             'Veg and non veg',
//             'Calculator',
//             url: Finance.vegNonveg,
//             path: "/VegNonveg",
//           ),
//           _buildCalculatorTile(
//             'Credit Card Payoff',
//             'Calculator',
//             url: Finance.credit,
//             path: "/CreditCard",
//           ),
//           _buildCalculatorTile(
//             'EMI',
//             'Calculator',
//             url: Finance.emi,
//             path: "/emi",
//           ),
//           _buildCalculatorTile(
//             'Rent vs Buy',
//             'Calculator',
//             url: Finance.key,
//             path: "/rent_buy",
//           ),
//           _buildCalculatorTile(
//             'Savings goal',
//             'Calculator',
//             url: Finance.savings,
//             path: "/Savings",
//           ),
//           _buildCalculatorTile(
//             'Auto loan',
//             'Calculator',
//             url: Finance.auto,
//             path: "/autoLoan",
//           ),
//           _buildCalculatorTile(
//             'Trip cost',
//             'Calculator',
//             url: Finance.location,
//             path: "/TripCost",
//           ),
         
//         ],
//       ),
//     );
//   }

//   Widget _buildCard({icon, required String path}) {
//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(context, path);
//       },
//       child: icon,
//     );
//   }

//   Widget _buildCalculatorTile(String title, String subtitle,
//       {required String url, required String path}) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, path);
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width / 2.4,
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: AppColors.mt,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: AvatarProfileImage(
//                   url: url,
//                   height: 25,
//                   width: 20,
//                 ),
//               ),
//               SizedBox(height: 14),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       width: MediaQuery.sizeOf(context).width / 4,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(title,
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w700,
//                                   fontSize:
//                                       MediaQuery.sizeOf(context).height / 56,
//                                   overflow: TextOverflow.ellipsis,
//                                   color: AppColors.bg1)),
//                           Text(subtitle,
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w500,
//                                   fontSize:
//                                       MediaQuery.sizeOf(context).height / 56,
//                                   color: AppColors.bg1)),
//                         ],
//                       ),
//                     ),
//                     Container(
//                         height: MediaQuery.of(context).size.height * 0.04,
//                         width: MediaQuery.of(context).size.width * 0.08,
//                         decoration: BoxDecoration(
//                             color: AppColors.primaryColor,
//                             borderRadius: BorderRadius.circular(36)),
//                         child:
//                             Icon(Icons.arrow_forward_ios, color: Colors.white)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget gridViewList() {
//     return ListView(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: [
//         _buildCalculatorTile(
//           'Credit Card Payoff',
//           'Calculator',
//           url: Finance.credit,
//           path: "/CreditCard",
//         ),
//         _buildCalculatorTile(
//           'EMI',
//           'Calculator',
//           url: Finance.emi,
//           path: "/EMI",
//         ),
//         _buildCalculatorTile(
//           'Rent vs Buy',
//           'Calculator',
//           url: Finance.key,
//           path: "/Rent",
//         ),
//         _buildCalculatorTile(
//           'Savings goal',
//           'Calculator',
//           url: Finance.savings,
//           path: "/Savings",
//         ),
//         _buildCalculatorTile(
//           'Auto loan',
//           'Calculator',
//           url: Finance.auto,
//           path: "/Auto",
//         ),
//         _buildCalculatorTile(
//           'Trip cost',
//           'Calculator',
//           url: Finance.location,
//           path: "/TripCost",
//         ),
//       ],
//     );
//   }
// }

// Map<String, dynamic> getJsonBodyObj(String name, double value, double min,
//     double max, Function(double) onChanged, TextEditingController controller,
//     [bool flag = true, String symbol = "₹"]) {
//   return {
//     'name': name,
//     'value': value,
//     'min': min,
//     'max': max,
//     'onChanged': onChanged,
//     'controller': controller,
//     'symbol': symbol,
//     'flag': flag,
//   };
// }




import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/BudgetDisplay.dart';

class PlotFinance extends StatefulWidget {
  const PlotFinance({super.key});

  @override
  State<PlotFinance> createState() => _PlotFinanceState();
}

class _PlotFinanceState extends State<PlotFinance> {
  @override
  void initState() {
    super.initState();
    getBudget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: BottomNavigations(data: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                AvatarProfileImage(
                  url: Finance.plot,
                  height: 6,
                  width: 1,
                ),

                budgetAndDebtCalulator(),
                textStyle(
                    context: context,
                    text: "Calculators",
                    fontsize: 18,
                    fontWeight: FontWeight.w800),
                calculatorList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget budgetAndDebtCalulator() {
    return // Budget and Debt Buttons
        Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 5,
      // color: Colorcodes.appBarColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 50),
        children: [
          // _buildCard(
          //   icon: AvatarProfileImage(
          //     url: Finance.budget,
          //     height: 7,
          //     width: 7,
          //   ),
          //   path: budgetList.isEmpty ? "/Budget" : "/BudgetDisplay",
          // ),
          BudgetDisplay(),
          // _buildCard(
          //   icon: AvatarProfileImage(
          //     url: Finance.debt,
          //     height: 7,
          //     width: 7,
          //   ),
          //   path: "/Debt",
          // ),
        ],
      ),
    );
  }

  Widget calculatorList() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
           _buildCalculatorTile(
            'Veg and non veg',
            'Calculator',
            url: Finance.vegNonveg,
            path: "/VegNonveg",
          ),
          _buildCalculatorTile(
            'Credit Card Payoff',
            'Calculator',
            url: Finance.credit,
            path: "/CreditCard",
          ),
          _buildCalculatorTile(
            'EMI',
            'Calculator',
            url: Finance.emi,
            path: "/emi",
          ),
          _buildCalculatorTile(
            'Rent vs Buy',
            'Calculator',
            url: Finance.key,
            path: "/rent_buy",
          ),
          _buildCalculatorTile(
            'Savings goal',
            'Calculator',
            url: Finance.savings,
            path: "/Savings",
          ),
          _buildCalculatorTile(
            'Auto loan',
            'Calculator',
            url: Finance.auto,
            path: "/autoLoan",
          ),
          _buildCalculatorTile(
            'Trip cost',
            'Calculator',
            url: Finance.location,
            path: "/TripCost",
          ),
         
        ],
      ),
    );
  }

  Widget _buildCard({icon, required String path}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, path);
      },
      child: icon,
    );
  }

  Widget _buildCalculatorTile(String title, String subtitle,
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w700,
                                  fontSize:
                                      MediaQuery.sizeOf(context).height / 56,
                                  overflow: TextOverflow.ellipsis,
                                  color: AppColors.bg1)),
                          Text(subtitle,
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w500,
                                  fontSize:
                                      MediaQuery.sizeOf(context).height / 56,
                                  color: AppColors.bg1)),
                        ],
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.08,
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(36)),
                        child:
                            Icon(Icons.arrow_forward_ios, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget gridViewList() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildCalculatorTile(
          'Credit Card Payoff',
          'Calculator',
          url: Finance.credit,
          path: "/CreditCard",
        ),
        _buildCalculatorTile(
          'EMI',
          'Calculator',
          url: Finance.emi,
          path: "/EMI",
        ),
        _buildCalculatorTile(
          'Rent vs Buy',
          'Calculator',
          url: Finance.key,
          path: "/Rent",
        ),
        _buildCalculatorTile(
          'Savings goal',
          'Calculator',
          url: Finance.savings,
          path: "/Savings",
        ),
        _buildCalculatorTile(
          'Auto loan',
          'Calculator',
          url: Finance.auto,
          path: "/Auto",
        ),
        _buildCalculatorTile(
          'Trip cost',
          'Calculator',
          url: Finance.location,
          path: "/TripCost",
        ),
      ],
    );
  }
}

Map<String, dynamic> getJsonBodyObj(String name, double value, double min,
    double max, Function(double) onChanged, TextEditingController controller,
    [bool flag = true, String symbol = "₹"]) {
  return {
    'name': name,
    'value': value,
    'min': min,
    'max': max,
    'onChanged': onChanged,
    'controller': controller,
    'symbol': symbol,
    'flag': flag,
  };
}
