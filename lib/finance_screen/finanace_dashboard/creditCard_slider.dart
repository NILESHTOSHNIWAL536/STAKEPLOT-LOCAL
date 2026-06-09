import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../backed_connections/apis_connect.dart';
import '../../controllers/credit_card_controller.dart';
import '../../email_sync/credit_card_transactions.dart';
import '../../email_sync/custom_steps.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class CardDueCarousel extends StatefulWidget {
  bool flag = true;
  CardDueCarousel({super.key, this.flag = true});

  @override
  State<CardDueCarousel> createState() => _CardDueCarouselState();
}

class _CardDueCarouselState extends State<CardDueCarousel> {
  @override
  void initState() {
    super.initState();
    cardController.fetchCardData();
    cardController.getBanksListCrediCard();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return !widget.flag
          ? getDataListView(context)
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  'Credit Cards',
                  style: FontManager()
                      .getTextStyle(context, color: AppColors.primaryColor),
                ),
                backgroundColor: AppColors.backgroundColor,
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
      child: cardController.cardList.isEmpty
          ? cardController.loading.value
              ? Center(child: Spinner())
              : NoCreditCardUi(context)
          : ListView.builder(
              scrollDirection: Axis.vertical,
              // padding: const EdgeInsets.symmetric(vertical: AppSizes.p8, horizontal: AppSizes.p12),
              itemCount: cardController.cardList.length,
              itemBuilder: (context, index) {
                final card = cardController.cardList[index];
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(
                      vertical: AppSizes.p10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
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

  Widget NoCreditCardUi(BuildContext context) {
    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin:
            const EdgeInsets.symmetric(horizontal: 24, vertical: AppSizes.p16),
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
              SizedBox(height: AppSizes.h20),

              // Title
              Text(
                "No Credit Card Found",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSizes.h10),

              // Subtitle
              Text(
                "You don’t have any saved credit cards yet.\nAdd one to get started.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSizes.h20),
            ],
          ),
        ),
      ),
    );
  }
}
