import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:get/get.dart';

class UntaggedTransactionScreen extends StatefulWidget {
  const UntaggedTransactionScreen({
    Key? key,
  }) : super(key: key);

  @override
  _UntaggedTransactionScreenState createState() =>
      _UntaggedTransactionScreenState();
}

class _UntaggedTransactionScreenState extends State<UntaggedTransactionScreen> {
  RxList<Map<String, dynamic>> untaggedTransactions =
      <Map<String, dynamic>>[].obs;
  RxBool showSubcategories = false.obs;
  RxString selectedCategory = "".obs;
  RxList<String> subcategories = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _filterUntaggedTransactionsForCurrentMonth();
  }

  void _filterUntaggedTransactionsForCurrentMonth() {

  try {
    untaggedTransactions.value = transactionsHistory.where((transaction) {
     

      // Only include transactions with category 'Untagged' (case-insensitive)
      final category = transaction.category.toString().toLowerCase().trim();
      final isUntagged = category == 'untagged';
     
      if (!isUntagged) {
        return false;
      }

      // Validate transactionTimestamp (optional, for sorting)
      final transactionDate = DateTime.tryParse(transaction.transactionTimestamp.toString());
      if (transactionDate == null) {
        return false; // Skip transactions with invalid dates
      }
      return true;
    }).toList().cast<Map<String, dynamic>>()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['transactionTimestamp']?.toString() ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['transactionTimestamp']?.toString() ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA); // Sort by date descending
      });

  } catch (e, stackTrace) {
    print('Error filtering transactions: $e');
    print('Stack trace: $stackTrace');
    untaggedTransactions.value = [];
  }
}
  void tagTransaction(int index, String category, String subcategory) {
    print(
        'Tagging transaction at index $index with category: $category, subcategory: $subcategory');
    var transaction = untaggedTransactions[index];
    transaction['category'] = category;
    transaction['subcategory'] = subcategory;
    transaction['needsReview'] = false;

    int globalIndex =
        transactionsHistory.indexWhere((t) => t.id == transaction['_id']);
    if (globalIndex != -1) {
      print('Updating global transaction at index $globalIndex');
      transactionsHistory[globalIndex].category = category;
      transactionsHistory[globalIndex].subcategory = subcategory;
      transactionsHistory[globalIndex].needsReview = false;
      transactionsHistory.refresh();
    }

    untaggedTransactions.removeAt(index);
    print('Transaction tagged and removed from untagged list');
  }

  @override
  Widget build(BuildContext context) {
    print('Building UntaggedTransactionScreen UI');
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.finSpaceColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.backgroundColor),
          onPressed: () {
            print('Back button pressed');
            Navigator.pop(context);
          },
        ),
        title: Text(
          "History",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.backgroundColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height / 2.2,
            color: AppColors.finSpaceColor,
            child: Obx(() {
              print('Building Swiper for untagged transactions');
              if (untaggedTransactions.isEmpty) {
                print('No untagged transactions for this month');
                return Center(
                  child: Text(
                    "No untagged transactions for this month",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.bg3.withOpacity(0.8),
                    ),
                  ),
                );
              }

              return Swiper(
                itemCount: untaggedTransactions.length,
                itemBuilder: (BuildContext context, int index) {
                  print('Building transaction card for index $index');
                  var transaction = untaggedTransactions[index];
                  return _buildTransactionCard(transaction, context);
                },
                loop: false,
                itemHeight: MediaQuery.of(context).size.height * 0.3,
                itemWidth: MediaQuery.of(context).size.width * 0.9,
                layout: SwiperLayout.STACK,
                onIndexChanged: (index) {
                  print('Swiper index changed to $index');
                },
              );
            }),
          ),
          Container(
            color: AppColors.backgroundColor,
            height: MediaQuery.sizeOf(context).height / 2.6,
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              print('Building category/subcategory grid');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSubcategories.value) ...[
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.bg3),
                          onPressed: () {
                            print('Back to categories from subcategories');
                            showSubcategories.value = false;
                            selectedCategory.value = "";
                            subcategories.clear();
                          },
                        ),
                        Text(
                          "Subcategories",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.bg3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSubcategoriesGrid(context),
                  ] else ...[
                    Text(
                      "Tag Now",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.bg3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategoriesGrid(context),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
      Map<String, dynamic> transaction, BuildContext context) {
    print('Building transaction card for transaction: \\${transaction['_id']}');
    final isCredit = transaction['type']?.toString().toUpperCase() == 'CREDIT';
    final amountColor = isCredit ? Colors.green : Colors.red;
    String logo = transaction['bankLogo']?.toString() ?? "";
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Row: Title and Amount

            Container(
              color: AppColors.finSpaceColor,
              height: MediaQuery.sizeOf(context).height / 25,
              width: MediaQuery.sizeOf(context).width / 10,
              child: Icon(
                Icons.arrow_outward,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transaction['title']?.toString() ?? 'Unknown',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.bg3,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: amountColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isCredit ? 'Credited from' : 'Debited to',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.normal,
                    fontSize: 12,
                    color: AppColors.bg3.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 4),
                Image.network(
                  logo,
                  width: 22,
                  height: 22,
                  fit: BoxFit.fitWidth,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CircularProgressIndicator(
                        strokeWidth: 2); // Loading indicator
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error,
                        size: 22); // Fallback for failed image load
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height / 20,
                  width: MediaQuery.sizeOf(context).width / 2.4,
                  color: AppColors.button,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Narration: ',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.normal,
                          fontSize: 14,
                          color: AppColors.bg3.withOpacity(0.7),
                        ),
                      ),
                      Container(
                        child: Text(
                          transaction['narration']?.toString() ?? '',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.normal,
                            fontSize: 14,
                            color: AppColors.bg1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.sizeOf(context).height / 20,
                  width: MediaQuery.sizeOf(context).width / 4,
                  color: AppColors.button,
                  child: Center(
                    child: Text(
                      transaction['category']?.toString() ?? 'Untagged',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 16,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    print('Building categories grid');
    final List<Map<String, String>> categoryList = [
      {"name": "Food", "icon": Categories.food},
      {"name": "Shopping", "icon": Categories.shopping},
      {"name": "Travel", "icon": Categories.travel},
      {"name": "Health", "icon": Categories.health},
      {"name": "Bills", "icon": Categories.bills},
      {"name": "Subscription", "icon": Categories.subscription},
      {"name": "Events", "icon": Categories.events},
      {"name": "Personal Care", "icon": Categories.personalCare},
      {"name": "Services", "icon": Categories.services},
      {"name": "EMI's", "icon": Categories.emi},
      {"name": "Investment", "icon": Categories.income},
      {"name": "Insurance", "icon": Categories.insurance},
      {"name": "Support", "icon": Categories.support},
      {"name": "Current", "icon": Categories.current},
      {"name": "Children", "icon": Categories.children},
      {"name": "Pet Care", "icon": Categories.petCare},
      {"name": "Sports", "icon": Categories.sports},
      {"name": "Alcohol", "icon": Categories.alcohal},
      {"name": "Hobbies", "icon": Categories.hobbies},
      {"name": "Education", "icon": Categories.education},
      {"name": "Commerce", "icon": Categories.commerce},
      {"name": "Snacks", "icon": Categories.snacks},
      {"name": "Entertainment", "icon": Categories.entertainment},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        final category = categoryList[index];
        return GestureDetector(
          onTap: () {
            print('Category tapped: \\${category["name"]}');
            selectedCategory.value = category["name"]!;
            subcategories.value = categories[category["name"]!] ?? ["Other"];
            showSubcategories.value = true;
          },
          child: Column(
            children: [
              AvatarProfileImage(
                url: category["icon"]!,
                height: 40,
                width: 40,
              ),
              const SizedBox(height: 4),
              Text(
                category["name"]!,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.bg3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubcategoriesGrid(BuildContext context) {
    print(
        'Building subcategories grid for category: \\${selectedCategory.value}');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = subcategories[index];
        return GestureDetector(
          onTap: () {
            print('Subcategory tapped: $subcategory');
            if (untaggedTransactions.isNotEmpty) {
              tagTransaction(0, selectedCategory.value, subcategory);
            }
          },
          child: Column(
            children: [
              AvatarProfileImage(
                url: BudgetSubCategories.listofSubCategories[subcategory] ??
                    Categories.link + Categories.groceries,
                height: 40,
                width: 40,
              ),
              const SizedBox(height: 4),
              Text(
                subcategory,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.bg3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
