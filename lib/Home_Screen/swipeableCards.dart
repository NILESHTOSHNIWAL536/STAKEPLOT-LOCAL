
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
final RxString selectedPeriod = 'Month'.obs; // <-- Moved here

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
    _currentIndex.value = index % _totalCards;
  }

  @override
 @override
Widget build(BuildContext context) {
 // Add this line

  return Scaffold(
   
    body: SafeArea(
      child: Container(
        decoration: BoxDecoration(
         color: AppColors.mt,
         borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Finora',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.accentColor,
                    ),
                  ),
                 
                ],
              ),
            ),
            Container(
              height: MediaQuery.sizeOf(context).height/5,
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                onPageChanged: _onPageChanged,
                clipBehavior: Clip.hardEdge,
                itemBuilder: (context, index) {
                  final cardIndex = index % _totalCards;
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = index - (_pageController.page ?? 0);
                        value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                      }
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.0, // ⬅ Reduced vertical spacing
                          ),
                          child: _buildCard(cardIndex, context),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Obx(
            //   () => Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: List.generate(_totalCards, (index) {
            //       return AnimatedContainer(
            //         duration: Duration(milliseconds: 300),
            //         margin: EdgeInsets.symmetric(horizontal: 3.0),
            //         width: _currentIndex.value == index ? 10.0 : 6.0,
            //         height: 8.0,
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           color: _currentIndex.value == index
            //               ? Colors.blue
            //               : Colors.grey.withOpacity(0.5),
            //         ),
            //       );
            //     }),
            //   ),
            // ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCard(int cardIndex, BuildContext context) {
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
      width: MediaQuery.sizeOf(context).width * 0.85,
      height: 120, // Slightly increased height for better content fit
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: card,
      ),
    );
  }
}

class TotalSpendingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
         color:AppColors.backgroundColor,
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Spending',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryColor,
              ),
            ),
           
             Text(
              '₹${formatMoneyIndian(totalDebitThisMonth.value.toStringAsFixed(2))}',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.accentColor,
              ),
            ),
           
            Text(
              'Avg/Day: ₹${formatMoneyIndian(((totalDebitThisMonth.value / (DateTime.now().day == 0 ? 1 : DateTime.now().day)).toStringAsFixed(2)))}',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 12,
                color: AppColors.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverspentCategoriesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
         color: AppColors.backgroundColor
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overspent Categories',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    selectedPeriod.value = selectedPeriod.value == 'Week' ? 'Month' : 'Week';
                  },
                  child: Icon(
                    Icons.swap_horiz,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
            Expanded(
              
              child: moreDrasticChange.isEmpty
                  ? Center(
                      child: Text(
                        'No Data',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    )
                  : Column(
  children: (selectedPeriod.value == 'Week' ? moreDrasticChangeWeek : moreDrasticChange)
      .take(2)
      .map((category) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category['category'].toString().capitalize!,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '+₹${formatMoneyIndian(category['debit_diff'].toStringAsFixed(2))}',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ))
      .toList(),
)

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
    return Obx(() {
      final selectedList =
          selectedPeriod.value == 'Week' ? frequentPaymentsWeek : frequentPayments;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frequent Transaction',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryColor,
              ),
            ),
            selectedList.isEmpty
                ? Text(
                    'No Data',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.accentColor,
                    ),
                  )
                : Text(
                    selectedList[0]['name'].toString(),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
            selectedList.isEmpty
                ? SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedList[0]['count']} Txns',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.accentColor,
                        ),
                      ),
                      Text(
                        '₹${formatMoneyIndian(selectedList[0]['totalAmount'].toStringAsFixed(2))}',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.bold,
                          fontSize: 14,
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

String formatMoneyIndian(String value) {
  return value.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}