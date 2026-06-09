import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/credit_card_controller.dart';
import 'package:flutter_application_code_stakeplot/email_sync/credit_card_transactions.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/finanace_dashboard/cardBuilders.dart';
import 'package:get/get.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Utils/credit_card.dart';
import '../../email_sync/add_credit_card_bank.dart';
import 'select_card_options.dart';

class SliderAdddingFinances extends StatelessWidget {
  // final bool hasData;
  // final Function(Debt) onDebtTap;
  const SliderAdddingFinances({
    Key? key,
    // required this.hasData,
    // required this.onDebtTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    double cardHeight = MediaQuery.of(context).size.height / 4.5;

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
        final totalItems = creditCards.length + budgets.length;
        return ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Add Button Card
            InkWell(
              onTap: () {
                pushnameToRoute(context, SelectAnyOptionScreen(), false);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.p12, horizontal: 3),
                child: Container(
                  width: 52,
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
                  child: Center(
                    child: Text(
                      '+',
                      style: FontManager().getTextStyle(context,
                          color: AppColors.primaryColor,
                          fontSize: 32,
                          lWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
            // Display data if it exists, otherwise show placeholder
            if (!getCreditCardBudgetDebts.value || totalItems == 0)
              getPlaceholderCard(
                "Add Budget or Debt to get started.",
                containerWidth,
              )
            else ...[
              // Display Credit Cards
              // ...creditCards.take(CreditCardScreenStrings().showCreditCard.value?2:0).toList().map((card) => Padding(
              //       padding:
              //           const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
              //       child: SizedBox(
              //         width: containerWidth - 95,
              //         child: CreditCardTransactionCard2(
              //           txn: CreditCardTransaction2(
              //             bank: card.bank,
              //             date: card.date,
              //             transactionId: card.transactionId,
              //             amount: card.amount,
              //             cardNumber: card.cardNumber,
              //             merchant: 'merchant',
              //             logo: card.logo,
              //             bankName: card.bankName,
              //           ),
              //         ), // Use custom credit card widget
              //       ),
              //     )),
              // Display Budgets
              ...budgets.take(2).toList().map((budget) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                    child: SizedBox(
                      width: containerWidth - 95,
                      child: CardBuilders.budgetCard(context, budget),
                    ),
                  )),

              // Display Debts
              // ...debts.take(2).toList().map((debt) => Padding(
              //       padding:
              //           const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
              //       child: SizedBox(
              //         width: containerWidth - 95,
              //         child: CardBuilders.debtCard2(context, debt, onDebtTap),
              //       ),
              //     )),
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
          color: AppColors.backgroundColor,
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
            SizedBox(width: AppSizes.w18),
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: AppSizes.p28, horizontal: 0),
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
                        color: AppColors.primaryColor,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.w16),
            Expanded(
              child: Text(
                title,
                style: FontManager().getTextStyle(contextGlobal,
                    color: Color(0xFF807CA3),
                    lWeight: FontWeight.w400,
                    fontSize: 16.2,
                    letterSpacing: 0.1,
                    lineHeight: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
