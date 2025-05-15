
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart'; // Assuming AppColors is here
import 'package:flutter_application_code_stakeplot/colorcodes.dart'; // Additional color definitions

final RxString selectedPeriod = 'Month'.obs;

class SwipeableCardsScreen extends StatefulWidget {
  @override
  _SwipeableCardsScreenState createState() => _SwipeableCardsScreenState();
}

class _SwipeableCardsScreenState extends State<SwipeableCardsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final RxInt _currentIndex = 0.obs;
  final int _totalCards = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _currentIndex.value = index ;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;

    return  Container(
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.circular(padding),
        ),
        padding: EdgeInsets.symmetric(horizontal: padding/2, vertical: padding * 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: padding/2,right: padding,left: padding,),
              child: Text(
                'Finora',
                style:FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600,
                  fontSize: screenSize.width * 0.05,
                  color: AppColors.accentColor,
                ),
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.16,
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                onPageChanged: _onPageChanged,
                clipBehavior: Clip.hardEdge,
                 itemCount: _totalCards,
                itemBuilder: (context, index) {
                  final cardIndex = index % _totalCards;
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = (index.toDouble() - (_pageController.page ?? 0.0)).clamp(-1.0, 1.0);
                        value = (1.0 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                      }
                      return Center(
                        child: Transform.scale(
                          scale: value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: padding * 0.3,
                              vertical: padding * 0.2,
                            ),
                            child: _buildCard(cardIndex, context, screenSize),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Uncomment and use if needed
            /*
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalCards, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: padding * 0.3),
                    width: _currentIndex.value == index ? padding : padding * 0.6,
                    height: padding * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex.value == index
                          ? AppColors.accentColor
                          : AppColors.primaryColor.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
            */
          ],
        ),
      
    );
  }

  Widget _buildCard(int cardIndex, BuildContext context, Size screenSize) {
    Widget card;
    switch (cardIndex) {
      case 0:
        card = TotalSpendingCard();
        break;
      case 1:
        card = OverspentCategoriesCard();
        break;
      case 2:
        card = FrequentTransactionCard();
        break;
      default:
        return SizedBox.shrink();
    }

    return Container(
      width: screenSize.width * 0.85,
      height: screenSize.height * 0.14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
        child: card,
      ),
    );
  }
}

class TotalSpendingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.03;

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        padding: EdgeInsets.symmetric(horizontal: padding,vertical: padding*2),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                        'Monthly',
                        style: FontManager().getTextStyle(context,
                                          lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.02,
                          color: AppColors.bg3,
                        ),
                      ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
                          Text(
                            'Total Spending',
                            style:FontManager().getTextStyle(context,
                                          lWeight: FontWeight.w500,
                              fontSize: screenSize.width * 0.04,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Text(
                        '₹${formatMoneyIndian(totalDebitThisMonth.value.toStringAsFixed(2))}',
                        style:FontManager().getTextStyle(context,
                                          lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.06,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                  
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average/Day',
                        style:FontManager().getTextStyle(context,
                                          lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.04,
                          color: AppColors.primaryColor,
                        ),
                      ),
                       SizedBox(height: 10,),
                       Text(
                        '₹${formatMoneyIndian(((totalDebitThisMonth.value / (DateTime.now().day == 0 ? 1 : DateTime.now().day)).toStringAsFixed(2)))}',
                        style:FontManager().getTextStyle(context,
                                          lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.06,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverspentCategoriesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.03;

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overspent Categories',
                  style:FontManager().getTextStyle(context,
                                        lWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.04,
                    color: AppColors.primaryColor,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    selectedPeriod.value = selectedPeriod.value == 'Week' ? 'Month' : 'Week';
                  },
                  child: Icon(
                    Icons.swap_horiz,
                    color: AppColors.primaryColor,
                    size: screenSize.width * 0.06,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: screenSize.height * 0.06,
              child: moreDrasticChange.isEmpty
                  ? Center(
                      child: Text(
                        'No Data',
                        style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.035,
                          color: AppColors.primaryColor.withOpacity(0.8),
                        ),
                      ),
                    )
                  : Column(
                      children: (selectedPeriod.value == 'Week' ? moreDrasticChangeWeek : moreDrasticChange)
                          .take(2)
                          .map((category) => Padding(
                                padding: EdgeInsets.only(bottom: padding * 0.4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category['category'].toString().capitalize!,
                                      style:  FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600,

                                        fontSize: screenSize.width * 0.035,
                                        color: AppColors.accentColor,
                                      ),
                                    ),
                                    Text(
                                      '+₹${formatMoneyIndian(category['debit_diff'].toStringAsFixed(2))}',
                                      style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w500,
                                        fontSize: screenSize.width * 0.033,
                                        color: AppColors.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FrequentTransactionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.03;

    return Obx(() {
    
      return Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Most Frequent Payment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenSize.width * 0.04,
                color: AppColors.primaryColor,
              ),
            ),
            frequentPayments.isEmpty
                ? Text(
                    'No Data',
                    style:FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600,
                      fontSize: screenSize.width * 0.045,
                      color: AppColors.accentColor,
                    ),
                  )
                : Text(
                    frequentPayments[0]['name'].toString(),
                    style:FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600,
                      fontSize: screenSize.width * 0.04,
                      color: AppColors.accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
            frequentPayments.isEmpty
                ? SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${frequentPayments[0]['count']} Transactions',
                        style:FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.035,
                          color: AppColors.accentColor,
                        ),
                      ),
                      Text(
                        '₹${formatMoneyIndian(frequentPayments[0]['totalAmount'].toStringAsFixed(2))}',
                        style:FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.035,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      );
    });
  }
}

