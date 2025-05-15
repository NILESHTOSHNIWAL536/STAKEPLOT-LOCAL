import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';


class SwipeableCardsScreen extends StatefulWidget {
  @override
  _SwipeableCardsScreenState createState() => _SwipeableCardsScreenState();
}

class _SwipeableCardsScreenState extends State<SwipeableCardsScreen> {
  final PageController _pageController = PageController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Replace with AppColors.bg
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final cardIndex = index % _totalCards;
                  return Center(
                    // Center the card horizontally
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Reduced vertical padding
                      child: _buildCard(cardIndex, context),
                    ),
                  );
                },
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalCards, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 3.0),
                    width: _currentIndex.value == index ? 8.0 : 4.0, // Smaller dots
                    height: 4.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex.value == index
                          ? Colors.blue // Replace with AppColors.primaryColor
                          : Colors.grey.withOpacity(0.4),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 12), // Reduced bottom spacing
          ],
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

    // Wrap each card in a Container with fixed size
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.8,
      height: 100, // Set height to 100 as requested
      child: card,
    );
  }
}

// Card 1: Total Spending and Average Spending Per Day
class TotalSpendingCard extends StatelessWidget {
  final double totalSpending = 25000.0;
  final double averageSpendingPerDay = 833.33;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8), // Reduced border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6, // Reduced blur
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(12), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Spending',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14, // Smaller font
              color: Colors.white,
            ),
          ),
          Text(
            '₹${formatMoneyIndian(totalSpending.toStringAsFixed(2))}',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 18, // Smaller font
              color: Colors.white,
            ),
          ),
          Text(
            'Avg/Day: ₹${formatMoneyIndian(averageSpendingPerDay.toStringAsFixed(2))}',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 10, // Smaller font
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// Card 2: Top 2 Overspent Categories Compared to Last Month
class OverspentCategoriesCard extends StatelessWidget {
  final List<Map<String, dynamic>> overspentCategories = [
    {'category': 'Dining', 'amount': 8000.0, 'lastMonth': 5000.0},
    {'category': 'Shopping', 'amount': 12000.0, 'lastMonth': 9000.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade300, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8), // Reduced border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6, // Reduced blur
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(12), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Overspent Categories',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14, // Smaller font
              color: Colors.white,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: overspentCategories.asMap().entries.map((entry) {
                final category = entry.value;
                final overspent = category['amount'] - category['lastMonth'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0), // Tight spacing
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category['category'],
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 12, // Smaller font
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '+₹${formatMoneyIndian(overspent.toStringAsFixed(2))}',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.bold,
                          fontSize: 12, // Smaller font
                          color: Colorcodes.redDeleteIcon,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Card 3: Most Frequent Transaction
class FrequentTransactionCard extends StatelessWidget {
  final String mostFrequentCategory = 'Coffee Shops';
  final int transactionCount = 15;
  final double totalAmount = 4500.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade300, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8), // Reduced border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6, // Reduced blur
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(12), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Frequent Transaction',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14, // Smaller font
              color: Colors.white,
            ),
          ),
          Text(
            mostFrequentCategory,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 16, // Smaller font
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$transactionCount Txns',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                 
                  fontSize: 12, // Smaller font
                  color: Colors.white,
                ),
              ),
              Text(
                '₹${formatMoneyIndian(totalAmount.toStringAsFixed(2))}',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 12, // Smaller font
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Placeholder for formatMoneyIndian
String formatMoneyIndian(String value) {
  return value.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}