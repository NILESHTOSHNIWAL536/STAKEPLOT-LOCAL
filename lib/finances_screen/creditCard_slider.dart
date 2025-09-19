import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../controllers/credit_card_controller.dart';
import '../email_sync/credit_card_transactions.dart';
import '../email_sync/custom_steps.dart';

class CardDueCarousel extends StatelessWidget {
  bool flag = true;
  final CardDueController controller = Get.put(CardDueController());
  CardDueCarousel({super.key, this.flag = true});

  @override
  Widget build(BuildContext context) {
    controller.fetchCardData();

    return Obx(() {
      return !flag
          ? getDataListView(context)
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  'Credit Cards',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                ),
                backgroundColor: AppColors.white,
                leading: leadIcon(context),
              ),
              body: getDataListView(context),
            );
    });
  }

  Widget getDataListView(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: controller.cardList.isEmpty
          ? controller.loading.value? Center(child: Spinner()):NoCreditCardUi(context)
          : ListView.builder(
              scrollDirection: Axis.vertical,
              // padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: controller.cardList.length,
              itemBuilder: (context, index) {
                final card = controller.cardList[index];
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CreditCardTransactionCard(
                        txn: CreditCardTransaction(
                          bank: card.bank,
                          date: card.date,
                          transactionId: card.transactionId,
                          amount: card.amount,
                          cardNumber: card.cardNumber,
                          merchant: 'merchant',
                          logo: card.logo,
                          bankName: card.bankName,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
  
Widget NoCreditCardUi(BuildContext context)
{
  return Center(
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon or illustration
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_off_rounded,
                size: 60,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              "No Credit Card Found",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Subtitle
            Text(
              "You don’t have any saved credit cards yet.\nAdd one to get started.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // CTA button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add card screen

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add_card, color: Colors.white),
              label: const Text(
                "Add Credit Card",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}