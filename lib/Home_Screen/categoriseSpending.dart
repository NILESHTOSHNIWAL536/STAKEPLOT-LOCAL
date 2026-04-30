// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/search.dart';

// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
// import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';

// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/repository/finora_repository.dart';
// import 'package:get/get.dart';


// import '../Constants/core/app_padding_sizes.dart';
// import '../components/shared_utils.dart';
// import '../controllers/transactions_controller.dart';
// import '../repository/transactions_repository.dart';

// RxInt selectedIndex = (-1).obs;
// RxList<ChartData> spendingsOnCategories = <ChartData>[].obs;
// RxDouble totalValue = 0.0.obs;
// RxBool spendingsOnCategoriesBool = false.obs;

// class ChartData {
//   final String category;
//   String persentage = "";
//   final double value;
//   final Color color;
//   ChartData(this.category, this.value, this.color, this.persentage);
// }

// class DoughnutChartExample extends StatefulWidget {
//   @override
//   State<DoughnutChartExample> createState() => _DoughnutChartExampleState();
// }

// class _DoughnutChartExampleState extends State<DoughnutChartExample> {
  
//   @override
//   void initState() {
//     super.initState();
//     selectedIndex.value = -1;
//     catWidgetBindUpdate(context);
//     if(spendingsOnCategories.isEmpty)getCategoryData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(AppSizes.p8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 HomepageStringsDart().spendingsOnCategories,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: AppColors.bg3,
//                 ),
//               ),
//               Obx(() => spendingsOnCategoriesBool.value
//                   ? checkFlagCount()
//                   : checkFlagCount())
//             ],
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           textStyleImage(
//               context: context,
//               text: getDaysLeftInMonth(),
//               fontsize: 14,
//               fontWeight: FontWeight.w400),
//           const SizedBox(
//             height: 10,
//           ),
//           Obx(() =>
//               spendingsOnCategoriesBool.value ? checkFlag() : checkFlag()),
//         ],
//       ),
//     );
//   }

//   Widget checkFlagCount() {
//     return spendingsOnCategories.length >= 7
//         ? TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AllCategoriesPage(),
//                 ),
//               );
//             },
//             child: Text(
//               HomepageStringsDart().moreButton,
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.w500,
//                 fontSize: 14,
//                 color: AppColors.bg3,
//               ),
//             ))
//         : const SizedBox.shrink();
//   }

//   Widget checkFlag() {
//     return spendingsOnCategories.isEmpty
//         ? Center(
//             child: Text(
//               HomepageStringsDart().noSpendingsAvailable,
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: AppColors.bg3.withOpacity(0.8),
//               ),
//             ),
//           )
//         : buildCategoryCards();
//   }

//   Widget buildCategoryCards() {
//     // Take top 4 categories
//     final topCategories = spendingsOnCategories.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//     final topFour = topCategories.take(6).toList();
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//         childAspectRatio: 1.5,
//       ),
//       itemCount: topFour.length,
//       itemBuilder: (context, index) {
//         final data = topFour[index];
//         String percentage = data
//             .persentage; // totalValue.value > 0 ? (data.value / totalValue.value) * 100 : 0.0;
//         return CategoryCard(
//           category: data.category,
//           amount: data.value,
//           percentage: percentage,
//           color: AppColors.backgroundColor,
//           // color: UniversalColors.categoryColors[index % UniversalColors.categoryColors.length],
//         );
//       },
//     );
//   }

//   Widget topHeader() {
//     return Row(
//       children: [
//         Obx(() => Text(
//               '₹${formatMoneyIndian(totalValue.toStringAsFixed(2))}',
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: AppColors.accentColor,
//               ),
//             )),
//       ],
//     );
//   }
// }

// class CategoryCard extends StatelessWidget {
//   final String category;
//   final double amount;
//   final String percentage;
//   final Color color;

//   const CategoryCard({
//     required this.category,
//     required this.amount,
//     required this.percentage,
//     required this.color,
//   });

//   String getCategoryIconPath(String category) {
//     final iconFileName =
//         BudgetCategories.listofCategories[toTitleCase(category)];
//     if (iconFileName != null) {
//       return '${Categories.link}$iconFileName';
//     }
//     return "assets/icons/subCategoryIcons2/others.svg"; // Fallback icon
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//           // final tx = Get.find<TransactionController>();
//         tnxSearchController.text = category.toLowerCase();
//           // tx.searchController.text = category.toLowerCase();
//         onChanedAutoTransactionStatus(context);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const TransactionHistoryScreen(),
//           ),
//         );
//         // }
//       },
//       child: Container(
//         height: MediaQuery.sizeOf(context).height / 5,
//         decoration: BoxDecoration(
//           color: color, // Use the assigned color with opacity for background
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.accentColor.withAlpha(26), // Shadow color
//               spreadRadius: 2, // Spread radius
//               blurRadius: 5, // Blur radius
//               offset: Offset(0, 5), // Changes the position of the shadow
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(AppSizes.p10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                       child: AvatarProfileImage(
//                           url: getCategoryIconPath(category),
//                           width: 50,
//                           height: 50)),
//                   Container(
//                     width: MediaQuery.sizeOf(context).width / 4.2,
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         toTitleCase(category),
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w500,
//                           fontSize: 14,
//                           color: AppColors.bg3,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//                SizedBox(height: AppSizes.h2),
//               Padding(
//                 padding: const EdgeInsets.only(left:AppSizes.p6),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: MediaQuery.sizeOf(context).width / 2,
//                       child: Text(
//                         '₹${formatMoneyIndian(amount.toStringAsFixed(2))}',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w500,
//                           fontSize: 16,
//                           color: AppColors.accentColor,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: AppSizes.h8),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: MediaQuery.sizeOf(context).width / 1.1,
//                           height: 5,
//                           child: LinearProgressIndicator(
//                             // value: getProgressValue(percentage) / 100,
//                             value: totalValue.value > 0
//                                 ? amount / totalValue.value
//                                 : 0.0,
//                             backgroundColor:
//                                 AppColors.bg3.withOpacity(0.2),
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                                 AppColors
//                                     .primaryColor), // Use the assigned color
//                             minHeight: 6,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Container(
//                           width: MediaQuery.sizeOf(context).width / 2.4,
//                           child: Text(
//                             '${percentage}',
//                             style: FontManager().getTextStyle(
//                               context,
//                               lWeight: FontWeight.normal,
//                               fontSize: 10,
//                               color: percentage.startsWith("-")
//                                   ? AppColors.redColor
//                                   : percentage.startsWith("+")
//                                       ? AppColors.green
//                                       : AppColors.bg3,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AllCategoriesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         title: Text(
//           HomepageStringsDart().allCategories,
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.bold,
//             fontSize: 18,
//             color: AppColors.bg3,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.bg3),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(AppSizes.p8),
//         child: Obx(() {
//           // Sort chartData by value in descending order
//           final sortedData = spendingsOnCategories.toList()
//             ..sort((a, b) => b.value.compareTo(a.value));
//           return sortedData.isEmpty
//               ? Center(
//                   child: Text(
//                     HomepageStringsDart().noSpendingsAvailable,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: AppColors.bg3.withOpacity(0.8),
//                     ),
//                   ),
//                 )
//               : GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 14,
//                     mainAxisSpacing: 14,
//                     childAspectRatio: 1.4,
//                   ),
//                   itemCount: sortedData.length,
//                   itemBuilder: (context, index) {
//                     final data = sortedData[index];
//                     String percentage = data.persentage;
//                     //  totalValue.value > 0
//                     //     ? (data.value / totalValue.value) * 100
//                     //     : 0.0;
//                     // Assign a unique color from UniversalColors
//                     final color = AppColors.backgroundColor;
//                     // final color = UniversalColors
//                     //     .categoryColors[index % UniversalColors.categoryColors.length];
//                     return CategoryCard(
//                       category: data.category,
//                       amount: data.value,
//                       percentage: percentage,
//                       color: color,
//                     );
//                   },
//                 );
//         }),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';

import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';

import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/repository/finora_repository.dart';
import 'package:get/get.dart';


import '../Constants/core/app_padding_sizes.dart';
import '../components/shared_utils.dart';
import '../controllers/finora_controller.dart';
import '../controllers/transactions_controller.dart';
import '../repository/transactions_repository.dart';
import '../Constants/theme_helper.dart';

// RxInt selectedIndex = (-1).obs;
// RxList<ChartData> spendingsOnCategories = <ChartData>[].obs;
// RxDouble totalValue = 0.0.obs;
// RxBool spendingsOnCategoriesBool = false.obs;

class ChartData {
  final String category;
  String persentage = "";
  final double value;
  final Color color;
  ChartData(this.category, this.value, this.color, this.persentage);
}

class SpendingCategoryChart extends StatefulWidget {
  @override
  State<SpendingCategoryChart> createState() => _SpendingCategoryChartState();
}

class _SpendingCategoryChartState extends State<SpendingCategoryChart> {
   final controller = Get.find<FinoraController>();
  
  @override
  void initState() {
    super.initState();
    controller.selectedIndex.value = -1;
    catWidgetBindUpdate(context);
    if(controller.spendingsOnCategories.isEmpty)getCategoryData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.p8),
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
                  color: colors.onBackground,
                ),
              ),
              Obx(() => controller.spendingsOnCategoriesBool.value
                  ? checkFlagCount()
                  : checkFlagCount())
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          textStyleImage(
              context: context,
              text: getDaysLeftInMonth(),
              fontsize: 14,
              fontWeight: FontWeight.w400),
          const SizedBox(
            height: 10,
          ),
          Obx(() =>
              controller.spendingsOnCategoriesBool.value ? checkFlag() : checkFlag()),
        ],
      ),
    );
  }

  Widget checkFlagCount() {
    final colors = context.appColors;
    return controller.spendingsOnCategories.length >= 7
        ? TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllCategoriesPage(controller: controller,),
                ),
              );
            },
            child: Text(
              HomepageStringsDart().moreButton,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 14,
                color: colors.primary,
              ),
            ))
        : const SizedBox.shrink();
  }

  Widget checkFlag() {
    final colors = context.appColors;
    return controller.spendingsOnCategories.isEmpty
        ? Center(
            child: Text(
              HomepageStringsDart().noSpendingsAvailable,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 16,
                color: colors.secondaryText,
              ),
            ),
          )
        : buildCategoryCards();
  }

  Widget buildCategoryCards() {
    // Take top 4 categories
    final topCategories = controller.spendingsOnCategories.toList()
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
          controller: controller,
          category: data.category,
          amount: data.value,
          percentage: percentage,
          color: context.appColors.surface,
          // color: UniversalColors.categoryColors[index % UniversalColors.categoryColors.length],
        );
      },
    );
  }

  Widget topHeader() {
    return Row(
      children: [
        Obx(() => Text(
              '₹${formatMoneyIndian(controller.totalValue.toStringAsFixed(2))}',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 18,
                color: context.appColors.onBackground,
              ),
            )),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final FinoraController controller;
  final String category;
  final double amount;
  final String percentage;
  final Color color;

   CategoryCard({
    required this.controller,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  String getCategoryIconPath(String category) {
    final iconFileName =
        BudgetCategories.listofCategories[toTitleCase(category)];
    if (iconFileName != null) {
      return '${Categories.link}$iconFileName';
    }
    return "assets/icons/subCategoryIcons2/others.svg"; // Fallback icon
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          // final tx = Get.find<TransactionController>();
        tnxSearchController.text = category.toLowerCase();
          // tx.searchController.text = category.toLowerCase();
        onChanedAutoTransactionStatus(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TransactionHistoryScreen(),
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
              color: context.appColors.onBackground.withAlpha(26),
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset: Offset(0, 5), // Changes the position of the shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p10),
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
                        toTitleCase(category),
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 14,
                          color: context.appColors.secondaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
               SizedBox(height: AppSizes.h2),
              Padding(
                padding: const EdgeInsets.only(left:AppSizes.p6),
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
                          color: context.appColors.onBackground,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.h8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width / 1.1,
                          height: 5,
                          child: LinearProgressIndicator(
                            // value: getProgressValue(percentage) / 100,
                            value: controller.totalValue.value > 0
                                ? amount / controller.totalValue.value
                                : 0.0,
                            backgroundColor:
                                context.appColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                context.appColors.primary),
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
                                  ? AppColors.redColor
                                  : percentage.startsWith("+")
                                      ? AppColors.green
                                      : context.appColors.secondaryText,
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
   final FinoraController controller;
   AllCategoriesPage({required this.controller});
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          HomepageStringsDart().allCategories,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18,
            color: colors.onBackground,
          ),
        ),
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p8),
        child: Obx(() {
          // Sort chartData by value in descending order
          final sortedData = controller.spendingsOnCategories.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return sortedData.isEmpty
              ? Center(
                  child: Text(
                    HomepageStringsDart().noSpendingsAvailable,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colors.secondaryText,
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
                    final color = colors.surface;
                    return CategoryCard(
                      controller: controller,
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
