import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../controllers/credit_card_controller.dart';
import '../email_sync/credit_card_transactions.dart';
import '../email_sync/custom_steps.dart';

class CardDueCarousel extends StatelessWidget {
  bool flag = true;
  final CardDueController controller = Get.put(CardDueController());
  CardDueCarousel({super.key ,this.flag = true});

  @override
  Widget build(BuildContext context) {
    controller.fetchCardData();

    return Obx(() {
      return !flag? getDataListView(context):Scaffold(
        appBar: AppBar(
          title:  Text('Credit Cards',style: TextStyle(
            color: AppColors.primaryColor,
          ),),
          backgroundColor: AppColors.white,
          leading: leadIcon(context),
        ),
        body: getDataListView(context),
      );
    });
  }

  Widget getDataListView(context){
    return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: controller.cardList.isEmpty?const Center(child: CircularProgressIndicator()):ListView.builder(
            scrollDirection: Axis.vertical,
            // padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: controller.cardList.length,
            itemBuilder: (context, index) {
              final card = controller.cardList[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
                padding: const EdgeInsets.all(16),
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
                      ),
                     ),
                  ],
                ),
              );
            },
          ),
        );
  }
}
