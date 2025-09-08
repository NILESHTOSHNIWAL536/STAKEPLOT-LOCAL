// import 'package:flutter/material.dart';

// import '../email_sync/add_credit_card_bank.dart';
// import 'dilogbox.dart';
// import 'select_card_options.dart';

// class SliderAdddingFinances extends StatelessWidget {

//   const SliderAdddingFinances({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double containerWidth = MediaQuery.of(context).size.width ;
//     double cardHeight = MediaQuery.of(context).size.height / 4.8;

//     return Container(
//       width: containerWidth,
//       height: cardHeight , // extra space for indicator dots
//       child: Column(
//         children: [
//           SizedBox(
//             height: cardHeight,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 // Add Button Card
//                 InkWell(
//                   onTap: (){
//                     // showBudgetDebtCreditCard(context);
//                      pushnameToRoute(context, SelectAnyOptionScreen(),false);
//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(builder: (context) => AddCreditCardBankScreen()),
//                     // );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
//                     child: Container(
//                       width: 52,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(18),
//                         border: Border.all(
//                           color: Color(0xFFE4E2F0), // subtle border shade
//                           width: 1.2,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '+',
//                           style: TextStyle(
//                             color: Color(0xFF635D8F),
//                             fontSize: 32,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Main Finance Card
//                 getcard("Add a Credit Card, Budget, or Debt to get started.",containerWidth),

//               ],
//             ),
//           ),
//           // Dot Indicators

//         ],
//       ),
//     );
//   }

//   Widget getcard(String title,double containerWidth){
//     return  Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
//                   child: Container(
//                     width: containerWidth - 95, // width minus add card and margin
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color(0x142D284D), // subtle purple/grey shadow
//                           blurRadius: 10,
//                           offset: Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         SizedBox(width: 18),
//                         // Replace below with your own image/icon widget
//                         Container(
//                           padding: EdgeInsets.symmetric(vertical: 28, horizontal: 0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 width: 64,
//                                 height: 64,
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFF6F6FA),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Center(
//                                   child: Icon(
//                                     Icons.receipt_long, // temp placeholder icon
//                                     color: Color(0xFF635D8F),
//                                     size: 36,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         // Placeholder text
//                         Expanded(
//                           child: Text(
//                            title,
//                             style: TextStyle(
//                               color: Color(0xFF807CA3),
//                               fontWeight: FontWeight.w400,
//                               fontSize: 16.2,
//                               letterSpacing: 0.1,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// // import 'package:flutter_application_code_stakeplot/email_sync/add_credit_card_bank.dart';
// // import 'package:flutter_application_code_stakeplot/finances_screen/select_card_options.dart';

// // class SliderAdddingFinances extends StatelessWidget {
// //   const SliderAdddingFinances({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final double containerWidth = MediaQuery.of(context).size.width / 1.1;
// //     final double cardHeight = MediaQuery.of(context).size.height / 5;

// //     return GestureDetector(
// //       onTap: () {
// //         // Navigate to the selection screen for adding credit card, budget, or debt
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //               builder: (context) => const SelectAnyOptionScreen()),
// //         );
// //       },
// //       child: Container(
// //         width: containerWidth,
// //         height: cardHeight,
// //         decoration: BoxDecoration(
// //           color: AppColors.backgroundColor,
// //           borderRadius: BorderRadius.circular(8),
// //           border: Border.all(
// //             color: Color(0xFFF3F4F6),
// //             width: 1,
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Color.fromRGBO(0, 0, 0, 0.05),
// //               offset: Offset(0, 1),
// //               blurRadius: 2,
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           children: [
// //             // Left side: Icon and Text
// //             Expanded(
// //               child: Padding(
// //                 padding: const EdgeInsets.symmetric(
// //                     horizontal: 16.0, vertical: 12.0),
// //                 child: Row(
// //                   children: [
// //                        Container(
// //               margin: const EdgeInsets.only(right: 16.0),
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: AppColors.primaryColor,
// //               ),
// //               child: const Icon(
// //                 Icons.add,
// //                 color: Colors.white,
// //                 size: 24,
// //               ),
// //             ),
// //                     // Icon

// //                     // Text
// //                     Expanded(
// //                       child: Text(
// //                         'Add a Credit Card, Budget, or Debt to get started.',
// //                         style: FontManager().getTextStyle(
// //                           context,
// //                           lWeight: FontWeight.w500,
// //                           fontSize: 14,
// //                           color: AppColors.accentColor,
// //                         ),
// //                         maxLines: 2,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             // Right side: Plus Button

// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/credit_card_controller.dart';
import 'package:flutter_application_code_stakeplot/email_sync/credit_card_transactions.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/cardBuilders.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/financeWidgets.dart';
import 'package:flutter_application_code_stakeplot/finances_screen/creditCard_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../colorcodes.dart';
import '../email_sync/add_credit_card_bank.dart';
import 'select_card_options.dart';

class SliderAdddingFinances extends StatelessWidget {
  final bool hasData;
  final Function(Debt) onDebtTap;
  const SliderAdddingFinances({
    Key? key,
    required this.hasData,
    required this.onDebtTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    double cardHeight = MediaQuery.of(context).size.height / 4.8;

    // Get data from controllers
    final cardController =
        Get.find<CardDueController>(); // Use Get.find for singleton
    final creditCards = cardController.cardList ?? RxList([]);
    final budgets = budgetList ?? RxList([]);

    // Debugging: Log data

    return Container(
      width: containerWidth,
      height: cardHeight,
      child: Obx(() {
        // Ensure at least one observable is used
        final totalItems = creditCards.length + budgets.length + debts.length;
        return ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Add Button Card
            InkWell(
              onTap: () {
                pushnameToRoute(context, SelectAnyOptionScreen(), false);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
                child: Container(
                  width: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Color(0xFFE4E2F0),
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: Color(0xFF635D8F),
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Display data if it exists, otherwise show placeholder
            if (!hasData || totalItems == 0)
              getPlaceholderCard(
                "Add a Credit Card, Budget, or Debt to get started.",
                containerWidth,
              )
            else ...[
              // Display Credit Cards
              ...creditCards.map((card) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                    child: SizedBox(
                      width: containerWidth - 95,
                      child: CreditCardTransactionCard2(
                        txn: CreditCardTransaction2(
                          bank: card.bank,
                          date: card.date,
                          transactionId: card.transactionId,
                          amount: card.amount,
                          cardNumber: card.cardNumber,
                          merchant: 'merchant',
                          logo: card.logo,
                          bankName: card.bankName,
                        ),
                      ), // Use custom credit card widget
                    ),
                  )),
              // Display Budgets
              ...budgets.map((budget) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                    child: SizedBox(
                      width: containerWidth - 95,
                      child: CardBuilders.budgetCard(context, budget),
                    ),
                  )),
              // Display Debts
              ...debts.map((debt) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                    child: SizedBox(
                      width: containerWidth - 95,
                      child: CardBuilders.debtCard2(context, debt, onDebtTap),
                    ),
                  )),
            ],
          ],
        );
      }),
    );
  }

  Widget getPlaceholderCard(String title, double containerWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      child: Container(
        width: containerWidth - 95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Color(0x142D284D),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 18),
            Container(
              padding: EdgeInsets.symmetric(vertical: 28, horizontal: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6FA),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.receipt_long,
                        color: Color(0xFF635D8F),
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Color(0xFF807CA3),
                  fontWeight: FontWeight.w400,
                  fontSize: 16.2,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
