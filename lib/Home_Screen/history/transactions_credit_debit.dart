// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

// import '../../components/shared_utils.dart';

// class TransactionCreditDebitScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 7.5,
//       padding: const EdgeInsets.all(5.0),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: [
//           TransactionCard(
//             title: 'This week transaction(s)',
//             credits: lastWeekjson['credit'].toString(),
//             debits: lastWeekjson['debit'].toString(),
//           ),
//           TransactionCard(
//             title: 'This month transaction(s)',
//             credits: lastmonthjson['credit'].toString(),
//             debits: lastmonthjson['debit'].toString(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TransactionCard extends StatelessWidget {
//   final String title;
//   final String credits;
//   final String debits;

//   TransactionCard(
//       {required this.title, required this.credits, required this.debits});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width /
//           (credits.toString().length <= 4
//               ? 2.2
//               : credits.toString().length <= 5
//                   ? 2
//                   : credits.toString().length <= 6
//                       ? 1.8
//                       : 1.6),
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//       margin: EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundColor,
//         borderRadius: BorderRadius.circular(5),
//         boxShadow: [
//           BoxShadow(
//             color: Color.fromRGBO(137, 137, 137,
//                 0.25), // Equivalent to rgba(137, 137, 137, 0.25);
//             blurRadius: 4, // Equivalent to box-shadow: 0 0 4px 0;
//             offset: Offset(0, 0), // Equivalent to box-shadow: 0 0 4px 0;
//           ),
//         ],
//         // border: Border.all(width: .3)
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 10),
//           textStyle(
//               context: context,
//               text: title,
//               fontsize: 14,
//               c: AppColors.grey,
//               fontWeight: FontWeight.w600),
//           SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     credits.toString().length >= 6
//                         ? SizedBox(
//                             width: MediaQuery.of(context).size.width /
//                                 4, // adjust as needed
//                             child: SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: textStyle(
//                                   context: context,
//                                   text: '+ ₹${formatMoneyIndian(credits)}',
//                                   fontsize: 14,
//                                   c: AppColors.primaryColor,
//                                   fontWeight: FontWeight.w700),
//                             ),
//                           )
//                         : textStyle(
//                             context: context,
//                             text: '+ ₹${formatMoneyIndian(credits)}',
//                             fontsize: 14,
//                             c: AppColors.primaryColor,
//                             fontWeight: FontWeight.w700),
//                     const SizedBox(
//                       height: 4,
//                     ),
//                     textStyle(
//                         context: context,
//                         text: 'credits',
//                         fontsize: 14,
//                         c: AppColors.grey,
//                         fontWeight: FontWeight.bold),
//                   ],
//                 ),
//                 Container(
//                   height: 30,
//                   child: VerticalDivider(
//                     thickness: .9,
//                     color: AppColors.greyCard,
//                     width: 1,
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     debits.toString().length >= 6
//                         ? SizedBox(
//                             width: MediaQuery.of(context).size.width /
//                                 5, // adjust as needed
//                             child: SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: textStyle(
//                                   context: context,
//                                   text: '- ₹${formatMoneyIndian(debits)}',
//                                   fontsize: 14,
//                                   c: AppColors.primaryColor,
//                                   fontWeight: FontWeight.w700),
//                             ),
//                           )
//                         : textStyle(
//                             context: context,
//                             text:'- ₹${formatMoneyIndian(debits)}',
//                             fontsize: 14,
//                             c: AppColors.primaryColor,
//                             fontWeight: FontWeight.w700),
//                     const SizedBox(
//                       height: 4,
//                     ),
//                     textStyle(
//                         context: context,
//                         text: 'debits',
//                         fontsize: 14,
//                         c: AppColors.grey,
//                         fontWeight: FontWeight.bold),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_shadows.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/shared_utils.dart';
import '../../finance_screen/Budgets/Budget.dart';

class TransactionCreditDebitCard extends StatefulWidget {
  const TransactionCreditDebitCard({super.key});

  @override
  State<TransactionCreditDebitCard> createState() =>
      _TransactionCreditDebitCardState();
}

class _TransactionCreditDebitCardState
    extends State<TransactionCreditDebitCard> {
  bool isWeekSelected = true;

  String get credits =>
      isWeekSelected
          ? lastWeekjson['credit'].toString()
          : lastmonthjson['credit'].toString();

  String get debits =>
      isWeekSelected
          ? lastWeekjson['debit'].toString()
          : lastmonthjson['debit'].toString();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
         borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(137, 137, 137,
                                  0.25), // Equivalent to rgba(137, 137, 137, 0.25);
                              blurRadius:
                                  4, // Equivalent to box-shadow: 0 0 4px 0;
                              offset: Offset(
                                  0, 0), // Equivalent to box-shadow: 0 0 4px 0;
                            ),
                          ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textStyle(
                context: context,
                text: 'Amount',
                fontsize: 14,
                c: AppColors.accentColor,
                fontWeight: FontWeight.w400,
              ),

              _weekMonthToggle(),
            ],
          ),

           SizedBox(height: AppSizes.h16),

          /// 🔹 CREDIT / DEBIT ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _amountBlock(
                context,
                value: '₹${formatMoneyIndian(credits)}',
                label: 'Credited',
              ),

            

              _amountBlock(
                context,
                value: '₹${formatMoneyIndian(debits)}',
                label: 'Debited',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 TOGGLE BUTTON
  Widget _weekMonthToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        
      ),
      child: Row(
        children: [
          _toggleItem('Week', isWeekSelected, () {
            setState(() => isWeekSelected = true);
          }),
          SizedBox(width: AppSizes.w4),
          _toggleItem('Monthly', !isWeekSelected, () {
            setState(() => isWeekSelected = false);
          }),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(6),
           boxShadow: [
          AppShadows.soft
        ],
        ),
        child: textStyle(
                context: context,
                text: text,
                fontsize: 14,
                c: selected ? AppColors.backgroundColor : AppColors.grey,
                fontWeight: FontWeight.w400,
              ),
       
      ),
    );
  }

  /// 🔹 CREDIT / DEBIT BLOCK
  Widget _amountBlock(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width/2.3,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textStyle(
            context: context,
            text: value,
            fontsize: 14,
            c: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(width: AppSizes.w6),
          textStyle(
            context: context,
            text: label,
            fontsize: 13,
            c: AppColors.grey,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  
}
