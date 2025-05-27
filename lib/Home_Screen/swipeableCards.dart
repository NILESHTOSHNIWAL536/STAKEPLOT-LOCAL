
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
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
                HomepageStringsDart().finora,
                style:FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600,
                  fontSize: screenSize.width * 0.05,
                  color: AppColors.accentColor,
                ),
              ),
            ),
            Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // PageView for Cards
              SizedBox(
                height: screenSize.height * 0.14,
                width: screenSize.width /1.2,
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
              // Indicator Dots
              Padding(
                padding: EdgeInsets.only(right: padding * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalCards,
                    (index) => Obx(
                      () => Container(
                        margin: EdgeInsets.symmetric(vertical: padding * 0.3),
                        width: _currentIndex.value == index ? 6.0 : 4.0,
                        height: _currentIndex.value == index ? 6.0 : 4.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex.value == index
                              ? AppColors.primaryColor
                              : AppColors.bg3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  
            // Uncomment and use if needed

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
    // final padding = screenSize.width * 0.03;

    return Obx(
      () => Container(
        height: MediaQuery.of(context).size.height/4,
        
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
        ),
       padding: EdgeInsets.symmetric(horizontal: 10,vertical:4),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                        'Monthly',
                        style: FontManager().getTextStyle(context,
                                          lWeight: FontWeight.w500,
                          fontSize: screenSize.width * 0.02,
                          color: AppColors.bg3,
                        ),
                      ),
               SizedBox(height: 5,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      SizedBox(height: 7,),
                      
                      Container(
                         width: MediaQuery.sizeOf(context).width/2.6,
                        child: Text(
                          '₹${formatMoneyIndian(totalDebitThisMonth.value.toStringAsFixed(0))}',
                          style:FontManager().getTextStyle(context,
                                            lWeight: FontWeight.w500,
                            fontSize: (totalDebitThisMonth.value.toString().length > 8)  ? screenSize.width * 0.05 : screenSize.width * 0.056,
                            color: AppColors.accentColor,
                          ),
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
                       SizedBox(height: 7,),
                       Container(
                         width: MediaQuery.sizeOf(context).width/2.9,
                         child: Text(
                          '₹${formatMoneyIndian(((totalDebitThisMonth.value / (DateTime.now().day == 0 ? 1 : DateTime.now().day)).toStringAsFixed(0)))}',
                          style:FontManager().getTextStyle(context,
                                            lWeight: FontWeight.w500,
                            fontSize: (totalDebitThisMonth.value.toString().length > 8)  ? screenSize.width * 0.05 : screenSize.width * 0.056,
                            color: AppColors.accentColor,
                            overflow: TextOverflow.ellipsis
                          ),
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
       padding: EdgeInsets.symmetric(horizontal: 10,vertical:4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overspent Categories',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: screenSize.width * 0.04,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                     Text(
                      '(${selectedPeriod.value}ly)',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: screenSize.width * 0.02,
                        color: AppColors.bg3,
                      ),
                    ),
                  ],
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
            SizedBox(height: 5),
            _buildCategoryList(screenSize, padding,context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Size screenSize, double padding, BuildContext context) {
    // Check if lists are null or empty
    final isMonthPeriod = selectedPeriod.value == 'Month';
    final categoryList = isMonthPeriod ? moreDrasticChange : moreDrasticChangeWeek;

    if (categoryList == null || categoryList.isEmpty) {
      return Center(
        child: Text(
          'No Data',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: screenSize.width * 0.035,
            color: AppColors.primaryColor.withOpacity(0.8),
          ),
        ),
      );
    }

    return Column(
      children: categoryList
          .take(2)
          .map((category) {
            // Null checks for category map entries
            final categoryName = category != null && category['category'] != null
                ? category['category'].toString().capitalize ?? 'Unknown'
                : 'Unknown';
            final debitDiff = category != null && category['debit_diff'] != null
                ? formatMoneyIndian(category['debit_diff'].toStringAsFixed(2))
                : '0.00';

            return Padding(
              padding: EdgeInsets.only(bottom: padding * 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    categoryName,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: screenSize.width * 0.035,
                      color: AppColors.accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '+₹$debitDiff',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: screenSize.width * 0.033,
                      color: AppColors.accentColor,
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(),
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
                                        lWeight: FontWeight.w500,
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

