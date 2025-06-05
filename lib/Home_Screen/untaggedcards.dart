import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';

class UntaggedTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedTransaction;

  const UntaggedTransactionScreen({Key? key, this.selectedTransaction})
      : super(key: key);

  @override
  State<UntaggedTransactionScreen> createState() =>
      _UntaggedTransactionScreenState();
}

class _UntaggedTransactionScreenState extends State<UntaggedTransactionScreen>
    with SingleTickerProviderStateMixin {
  RxList<Map<String, dynamic>> untaggedTransactions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> skippedTransactions = <Map<String, dynamic>>[].obs;
  int currentIndex = 0;
  AnimationController? _swipeController;
  Animation<double>? _swipeAnimation;
  double _dragPosition = 0.0;
  bool _isSwipingRight = false;
  RxString selectedCategory = ''.obs;
  RxBool showSubcategories = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchUntaggedTransactions();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeController!.addListener(() {
      setState(() {
        _dragPosition = _swipeAnimation!.value;
      });
    });
  }

  void _fetchUntaggedTransactions() {
    untaggedTransactions.value = transactionsHistory
        .where((transaction) =>
            (transaction['needsReview'] == true) ||
            (transaction['category']?.toString().toLowerCase() == 'untagged') ||
            (transaction['category']?.toString().toLowerCase() == 'uncategorized'))
        .toList()
        .cast<Map<String, dynamic>>()
      ..sort((a, b) => DateTime.parse(b['transactionTimestamp'])
          .compareTo(DateTime.parse(a['transactionTimestamp']))); // Sort by most recent
  }

  void _onDragStart(DragStartDetails details) {
    _swipeController!.reset();
    _dragPosition = 0.0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dx;
      _isSwipingRight = _dragPosition > 0;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragPosition.abs() > MediaQuery.of(context).size.width * 0.3) {
      // Swipe threshold reached
      _swipeAnimation = Tween<double>(
        begin: _dragPosition,
        end: _isSwipingRight
            ? MediaQuery.of(context).size.width
            : -MediaQuery.of(context).size.width,
      ).animate(CurvedAnimation(
        parent: _swipeController!,
        curve: Curves.easeOut,
      ));
      _swipeController!.forward().then((_) {
        if (_isSwipingRight) {
          // Swipe right: Remove transaction
          if (currentIndex < untaggedTransactions.length) {
            untaggedTransactions.removeAt(currentIndex);
            if (untaggedTransactions.isEmpty && skippedTransactions.isNotEmpty) {
              untaggedTransactions.addAll(skippedTransactions);
              skippedTransactions.clear();
              currentIndex = 0;
            }
          }
        } else {
          // Swipe left: Skip transaction
          if (currentIndex < untaggedTransactions.length) {
            final skipped = untaggedTransactions[currentIndex];
            untaggedTransactions.removeAt(currentIndex);
            skippedTransactions.add(skipped);
            if (untaggedTransactions.isEmpty && skippedTransactions.isNotEmpty) {
              untaggedTransactions.addAll(skippedTransactions);
              skippedTransactions.clear();
              currentIndex = 0;
            } else {
              currentIndex = currentIndex >= untaggedTransactions.length ? 0 : currentIndex;
            }
          }
        }
        setState(() {
          _dragPosition = 0.0;
        });
      });
    } else {
      // Return to original position
      _swipeAnimation = Tween<double>(
        begin: _dragPosition,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _swipeController!,
        curve: Curves.easeOut,
      ));
      _swipeController!.forward();
    }
  }

  @override
  void dispose() {
    _swipeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "",
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
      body: Obx(() => untaggedTransactions.isEmpty
          ? Center(
              child: Text(
                "HomepageStringsDart().noUntaggedTransactions",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.bg3.withOpacity(0.8),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background cards for stacked effect
                      for (int i = currentIndex + 2; i >= currentIndex; i--)
                        if (i < untaggedTransactions.length && i >= 0)
                          Positioned(
                            top: 20.0 + (i - currentIndex) * 10.0,
                            left: 16.0 - (i - currentIndex) * 5.0,
                            right: 16.0 - (i - currentIndex) * 5.0,
                            child: Opacity(
                              opacity: i == currentIndex ? 0.0 : 0.5,
                              child: _buildTransactionCard(
                                context,
                                untaggedTransactions[i],
                                i,
                                isBackground: true,
                              ),
                            ),
                          ),
                      // Foreground card (swipeable)
                      if (currentIndex < untaggedTransactions.length)
                        Transform.translate(
                          offset: Offset(_dragPosition, 0),
                          child: Transform.rotate(
                            angle: _dragPosition / MediaQuery.of(context).size.width * 0.5,
                            child: GestureDetector(
                              onHorizontalDragStart: _onDragStart,
                              onHorizontalDragUpdate: _onDragUpdate,
                              onHorizontalDragEnd: _onDragEnd,
                              child: _buildTransactionCard(
                                context,
                                untaggedTransactions[currentIndex],
                                currentIndex,
                                isBackground: false,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildTagOptions(context, untaggedTransactions[currentIndex], currentIndex),
                const SizedBox(height: 20),
              ],
            )),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Map<String, dynamic> transaction, int index,
      {required bool isBackground}) {
    final narration = transaction['narration'] ?? 'Unnamed Transaction';
    final amount = double.parse(doubleToFixed((transaction['amount'] ?? 0.0).toString()));
    final type = transaction['type']?.toString() ?? 'DEBIT';
    final formattedAmount = '₹${formatMoneyIndian(amount.toString())}';
    final isCredit = type == 'CREDIT';

    // Extract name from narration similar to the screenshot
    List<String> parts = narration.split('/');
    if (parts.isEmpty || parts.length == 1) parts = narration.split('-');
    if (parts.isEmpty || parts.length == 1) parts = narration.split('&');
    if (parts.isEmpty || parts.length == 1) parts = narration.split(' ');
    String nameOfUser = transaction['title'] != null
        ? transaction['title']
        : parts.length >= 4
            ? parts[3]
            : parts.length >= 3
                ? parts[2]
                : parts.length >= 2
                    ? parts[1]
                    : parts[0];

    return Container(
      height: MediaQuery.of(context).size.height * 0.25, // Adjusted height
      width: MediaQuery.of(context).size.width * 0.95, // Adjusted width
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nameOfUser,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.bg3,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      formattedAmount,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        fontSize: 18,
                        color: isCredit ? Colorcodes.green : AppColors.accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isCredit)
                      Icon(
                        Icons.arrow_upward,
                        size: 18,
                        color: Colorcodes.green,
                      ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  isCredit ? 'credited from' : 'debited to',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.bg3.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.account_balance_wallet,
                  size: 14,
                  color: AppColors.bg3.withOpacity(0.7),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  narration,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.bg3.withOpacity(0.7),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colorcodes.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Untagged',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colorcodes.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagOptions(BuildContext context, Map<String, dynamic> transaction, int index) {
    final List<Map<String, dynamic>> categories = BudgetCategories.listofCategories.entries
        .map((entry) => {
              'name': entry.key,
              'icon': '${Categories.link}${entry.value}',
            })
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.bg3,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, catIndex) {
                final category = categories[catIndex];
                return GestureDetector(
                  onTap: () {
                    selectedCategory.value = category['name'];
                    showSubcategories.value = true;
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          category['icon'],
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 24),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['name'],
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
            ),
          ),
          Obx(() => showSubcategories.value && selectedCategory.value.isNotEmpty
              ? _buildSubcategories(context, transaction, index)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSubcategories(BuildContext context, Map<String, dynamic> transaction, int index) {
    final subcategories = BudgetCategories.listofCategories[selectedCategory.value] != null
        ? categories[selectedCategory.value] ?? ['Other']
        : ['Other'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subcategories.length,
        itemBuilder: (context, subIndex) {
          final subcategory = subcategories[subIndex];
          return GestureDetector(
            onTap: () {
              // Tag the transaction and remove it from the stack
              updateTheTagOfTarnsactions(
                selectedCategory.value,
                subcategory,
                transaction['_id'],
                context,
                index,
              );
              transactionsHistory[index]['category'] = selectedCategory.value;
              transactionsHistory[index]['subcategory'] = subcategory;
              transactionsHistory[index]['needsReview'] = false;
              transactionsHistory.refresh();

              untaggedTransactions.removeAt(currentIndex);
              if (untaggedTransactions.isEmpty && skippedTransactions.isNotEmpty) {
                untaggedTransactions.addAll(skippedTransactions);
                skippedTransactions.clear();
                currentIndex = 0;
              } else {
                currentIndex = currentIndex >= untaggedTransactions.length ? 0 : currentIndex;
              }
              showSubcategories.value = false;
              selectedCategory.value = '';
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subcategory,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.bg3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}