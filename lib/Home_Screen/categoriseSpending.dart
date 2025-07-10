import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/untaggedcards.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'colors.dart';
import 'package:get/get.dart';

RxInt selectedIndex = (-1).obs;
RxList<ChartData> chartData = <ChartData>[].obs;
RxDouble totalValue = 0.0.obs;

class ChartData {
  final String category;
  String persentage = "";
  final double value;
  final Color color;
  ChartData(this.category, this.value, this.color, this.persentage);
}

class DoughnutChartExample extends StatefulWidget {
  @override
  State<DoughnutChartExample> createState() => _DoughnutChartExampleState();
}

class _DoughnutChartExampleState extends State<DoughnutChartExample> {
  @override
  void initState() {
    super.initState();
    selectedIndex.value = -1;
    catWidgetBindUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                HomepageStringsDart().spendingsOnCategories,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.bg3,
                ),
              ),
              Obx(() => chartData.length >= 7
                  ? TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllCategoriesPage(),
                          ),
                        );
                      },
                      child: Text(
                        HomepageStringsDart().moreButton,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.bg3,
                        ),
                      ))
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          textStyleImage(
              context: context,
              text: getDaysLeftInMonth(),
              fontsize: 14,
              fontWeight: FontWeight.w400),
          const SizedBox(
            height: 5,
          ),
          Obx(() => chartData.isEmpty
              ? Center(
                  child: Text(
                    HomepageStringsDart().noSpendingsAvailable,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.bg3.withOpacity(0.8),
                    ),
                  ),
                )
              : buildCategoryCards()),
        ],
      ),
    );
  }

  Widget buildCategoryCards() {
    // Take top 4 categories
    final topCategories = chartData.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFour = topCategories.take(6).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: topFour.length,
      itemBuilder: (context, index) {
        final data = topFour[index];
        String percentage = data
            .persentage; // totalValue.value > 0 ? (data.value / totalValue.value) * 100 : 0.0;
        return CategoryCard(
          category: data.category,
          amount: data.value,
          percentage: percentage,
          color: AppColors.backgroundColor,
          // color: UniversalColors.categoryColors[index % UniversalColors.categoryColors.length],
        );
      },
    );
  }

  Widget topHeader() {
    return Row(
      children: [
        Obx(() => Text(
              '₹${formatMoneyIndian(totalValue.toStringAsFixed(2))}',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.accentColor,
              ),
            )),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String category;
  final double amount;
  final String percentage;
  final Color color;

  const CategoryCard({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  String getCategoryIconPath(String category) {
    final iconFileName =
        BudgetCategories.listofCategories[toUpperCase(category)];
    if (iconFileName != null) {
      return '${Categories.link}$iconFileName';
    }
    return HomePageIcons.none; // Fallback icon
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      //  if (category.toLowerCase() == 'untagged' ||
      //       category.toLowerCase() == 'uncategorized') {
      //      Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => FutureBuilder(
      //                   future: getAllTransactionHistory(context, false, false, isRefreshing: true),
      //                   builder: (context, AsyncSnapshot snapshot) {
      //                     if (snapshot.connectionState == ConnectionState.waiting) {
      //                       print('FutureBuilder: Waiting for transaction history');
      //                       return const Scaffold(
      //                         body: Center(child: CircularProgressIndicator()),
      //                       );
      //                     }
      //                     if (snapshot.hasError) {
      //                       print('FutureBuilder: Error - ${snapshot.error}');
      //                       return Scaffold(
      //                         body: Center(child: Text("Error: ${snapshot.error}")),
      //                       );
      //                     }
      //                     print('FutureBuilder: Navigating to UntaggedTransactionScreen');
      //                     return const UntaggedTransactionScreen();
      //                   },
      //                 ),
      //               ),
      //             );
      //   } else {
          searchController.text = category.toLowerCase();
          onChanedAutoTransactionStatus(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionHistoryScreen(),
            ),
          );
        // }
      },
      child: Container(
        height: MediaQuery.sizeOf(context).height / 5,
        decoration: BoxDecoration(
          color: color, // Use the assigned color with opacity for background
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset: Offset(0, 5), // Changes the position of the shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: AvatarProfileImage(
                          url: getCategoryIconPath(category),
                          width: 50,
                          height: 50)),
                  Container(
                    width: MediaQuery.sizeOf(context).width / 4.2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        toUpperCase(category),
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.bg3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width / 2,
                      child: Text(
                        '₹${formatMoneyIndian(amount.toStringAsFixed(2))}',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width / 1.1,
                          height: 5,
                          child: LinearProgressIndicator(
                            // value: getProgressValue(percentage) / 100,
                            value: totalValue.value > 0
                                ? amount / totalValue.value
                                : 0.0,
                            backgroundColor: AppColors.bg3.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors
                                    .primaryColor), // Use the assigned color
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.sizeOf(context).width / 2.4,
                          child: Text(
                            '${percentage}',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.normal,
                              fontSize: 10,
                              color: percentage.startsWith("-")
                                  ? Colorcodes.redDeleteIcon
                                  : percentage.startsWith("+")
                                      ? Colorcodes.green
                                      : AppColors.bg3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllCategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          HomepageStringsDart().allCategories,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.bg3,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.bg3),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          // Sort chartData by value in descending order
          final sortedData = chartData.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return sortedData.isEmpty
              ? Center(
                  child: Text(
                    HomepageStringsDart().noSpendingsAvailable,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.bg3.withOpacity(0.8),
                    ),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: sortedData.length,
                  itemBuilder: (context, index) {
                    final data = sortedData[index];
                    String percentage = data.persentage;
                    //  totalValue.value > 0
                    //     ? (data.value / totalValue.value) * 100
                    //     : 0.0;
                    // Assign a unique color from UniversalColors
                    final color = AppColors.backgroundColor;
                    // final color = UniversalColors
                    //     .categoryColors[index % UniversalColors.categoryColors.length];
                    return CategoryCard(
                      category: data.category,
                      amount: data.value,
                      percentage: percentage,
                      color: color,
                    );
                  },
                );
        }),
      ),
    );
  }
}
