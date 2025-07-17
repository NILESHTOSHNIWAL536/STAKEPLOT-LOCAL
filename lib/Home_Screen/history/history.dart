import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart'; // For haptic feedback
import 'package:flutter_application_code_stakeplot/Constants/search.dart';

RxMap<String, String> redioButton = <String, String>{}.obs;
RxMap<String, int> redioButtonIndex = <String, int>{}.obs;
RxMap<String, TransactionModel> balanceOutList =
    <String, TransactionModel>{}.obs;
RxMap<String, double> redioButtonAmount = <String, double>{}.obs;
RxList<String> addManually = <String>[].obs;
RxBool showCheckBox = false.obs;

Widget historyTransactions(
    TransactionModel transaction, String? date, int index, BuildContext context,
    [bool hideReview = false, bool isexpanded = false, bool hide = false]) {
  String logo = transaction.bankLogo ?? "";

  final category = transaction.category;
  final subcategory = transaction.subcategory;
  final double amount = double.parse(((transaction.amount).toString()));
  final isManual = transaction.manualTransaction;
  final isSplit = transaction.isSplit;

  final formattedDate = date != null
      ? formatWhatsAppDateWithoutTime(convertStringToDateTime(date))
      : 'Date';
  final formattedDateManual =
      date != null ? formatWhatsAppDate(convertStringToDateTime(date)) : 'Date';
  final type = transaction.type;
  final narration = transaction.narration;
  final id = transaction.id;
  bool isReview = transaction.needsReview ?? false;
  bool isExcluded = transaction.isExcluded ?? false;

  if (hideReview && isReview) return SizedBox.shrink();

  List<String> parts = narration.split('/');
  if (parts.isEmpty || parts.length == 1) parts = narration.split('-');
  if (parts.isEmpty || parts.length == 1) parts = narration.split('&');
  if (parts.isEmpty || parts.length == 1) parts = narration.split(' ');

  String nameOfUser = transaction.title != null
      ? transaction.title
      : parts.length >= 4
          ? parts[3]
          : parts.length >= 3
              ? parts[2]
              : parts.length >= 2
                  ? parts[1]
                  : parts[0];

  final amtColor =
      type == 'CREDIT' ? AppColors.primaryColor : AppColors.primaryColor;
  final formatAmount = type == 'CREDIT'
      ? "+₹${formatMoneyIndian(amount.toString())}"
      : "-₹${formatMoneyIndian(amount.toString())}";

  String formatAmountBalance = type == 'CREDIT'
      ? "₹${formatMoneyIndian(transaction.balanceOut.toString())}"
      : "₹${formatMoneyIndian(transaction.balanceOut.toString())}";

  final fontSizes = FontSizeFactor(context);
  return WillPopScope(
    onWillPop: () async {
      // If checkboxes are visible, clear them and stay on the screen
      if (showCheckBox.value) {
        redioButton.clear();
        redioButtonIndex.clear();
        balanceOutList.clear();
        showCheckBox.value = false;
        return false; // Prevent popping the screen
      }
      // If no checkboxes, allow normal back navigation and clear state
      redioButton.clear();
      balanceOutList.clear();
      redioButtonIndex.clear();
      showCheckBox.value = false;
      return true; // Allow popping the screen
    },
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isExcluded
          ? () async {
              // Show confirmation dialog before excluding
              final shouldExclude = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: AppColors.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 100, // Minimum height
                        maxHeight: 220,
                        // Limit maximum height of dialog box
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            textStyle(
                              context: context,
                              text: "Include transaction?",
                              c: AppColors.bg1,
                              fontsize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 10),
                            textStyle(
                              context: context,
                              text:
                                  "Are you sure you want to add this transaction? It will be included in your category spending and reflected in your insights.",
                              c: AppColors.grey,
                              fontsize: 14,
                              fontWeight: FontWeight.w600,
                              iswrap: true,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.bg1),
                                    ),
                                    child: textStyle(
                                      context: context,
                                      text: "Cancel",
                                      c: AppColors.grey,
                                      fontsize: 14,
                                      fontWeight: FontWeight.w600,
                                      iswrap: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: textStyle(
                                      context: context,
                                      text: "Include",
                                      c: AppColors.backgroundColor,
                                      fontsize: 14,
                                      fontWeight: FontWeight.w600,
                                      iswrap: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
              if (shouldExclude == true) {
                excludeCashFlowTransaction(
                    index, false, context, transaction.id);
              }
            }
          : () {
              // uncomment this
              if (showCheckBox.value) {
                String id = '${transaction.id}';
                bool isChecked = redioButton.containsKey(id);
                if (!isChecked) {
                  redioButton[id] = id;
                  redioButtonIndex[id] = index;
                  balanceOutList[id] = transaction;
                  redioButtonAmount[id] = transaction.type == "DEBIT"
                      ? 0 - transaction.amount
                      : transaction.amount;
                  if (isManual) addManually.add(id);
                  HapticFeedback.selectionClick();
                } else {
                  redioButton.remove(id);
                  redioButtonIndex.remove(id);
                  balanceOutList.remove(id);
                  redioButtonAmount.remove(id);
                  if (isManual) addManually.remove(id);
                  HapticFeedback.selectionClick();
                }
              } else if (!isManual && !hide) {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return TransactionDetailsPage(transaction: transaction);
                  },
                );
              }
            },
      onLongPress: isExcluded
          ? null
          : () {
              if (hide) return;
              if (!isexpanded) showCheckBox.value = true;
              HapticFeedback.mediumImpact(); // Haptic feedback on long press
            },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            vertical: fontSizes.margin / 2, horizontal: fontSizes.margin),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: !isReview
              ? Border.all(
                  color: Colorcodes.greyLight,
                  width: 0.1,
                )
              : Border.all(
                  color: Colorcodes.red,
                  width: 0.5,
                ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(
                  155, 155, 155, 0.25), // rgba(155, 155, 155, 0.25)
              offset: Offset(0, 0), // 0px 0px
              blurRadius: 4, // 4px
              spreadRadius: 0, // 0px
            ),
          ],
        ),
        child: Obx(() => AnimatedContainer(
              duration:
                  Duration(milliseconds: 300), // Smooth animation for checkbox
              curve: Curves.easeInOut,
              child: Stack(
                children: [
                  // Main content

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      isExcluded
                          ? SizedBox(height: 8)
                          : SizedBox(
                              height: 0,
                            ),
                      Container(
                        padding: EdgeInsets.only(
                            top: isExcluded ? 0 : fontSizes.padding / 6),
                        child: Row(
                          children: [
                            // Animated Checkbox
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: (showCheckBox.value &&
                                      !isExcluded &&
                                      !hide)
                                  ? Container(
                                      key: ValueKey('checkbox'),
                                      height: 30,
                                      width: 30,
                                      child: Checkbox(
                                        value: redioButton
                                            .containsKey('${transaction.id}'),
                                        onChanged: (bool? isChecked) {
                                          String id = '${transaction.id}';
                                          bool ismanual =
                                              transaction.manualTransaction;
                                          if (isChecked == true) {
                                            redioButton[id] = id;
                                            balanceOutList[id] = transaction;
                                            redioButtonIndex[id] = index;
                                            redioButtonAmount[id] =
                                                transaction.type == "DEBIT"
                                                    ? 0 - transaction.amount
                                                    : transaction.amount;
                                            if (ismanual) addManually.add(id);
                                            HapticFeedback
                                                .selectionClick(); // Feedback on check
                                          } else {
                                            redioButton.remove(id);
                                            redioButtonIndex.remove(id);
                                            balanceOutList.remove(id);
                                            redioButtonAmount.remove(id);
                                            if (ismanual)
                                              addManually.remove(id);
                                            HapticFeedback.selectionClick();
                                          }
                                        },
                                        shape: const CircleBorder(),
                                        side: BorderSide(
                                            color: AppColors.primaryColor),
                                        checkColor: Colors.white,
                                        activeColor: AppColors.primaryColor,
                                        semanticLabel:
                                            'Select transaction ${transaction.id}',
                                      ),
                                    )
                                  : SizedBox.shrink(
                                      key: ValueKey('no-checkbox')),
                            ),
                            // Main Transaction Content
                            Container(
                              width: MediaQuery.of(context).size.width /
                                  (showCheckBox.value ? 1.2 : 1.1),
                              padding: EdgeInsets.only(
                                  top: isExcluded ? 0 : fontSizes.padding / 6,
                                  bottom:
                                      isExcluded ? 0 : fontSizes.padding / 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (isManual || isReview)
                                      ? reviewTagTransactions(
                                          isReview,
                                          fontSizes.scaleFactor,
                                          isSplit,
                                          fontSizes.margin,
                                          fontSizes.badgeSize,
                                          fontSizes.fontSizeSmall,
                                          context,
                                          index,
                                          id)
                                      : SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: fontSizes.padding),
                                    child: Row(
                                      children: [
                                        isExcluded
                                            ? getIconAvtar(30, category,
                                                fontSizes.scaleFactor / 2)
                                            : getIconAvtar(
                                                fontSizes.avatarSize,
                                                category,
                                                fontSizes.scaleFactor),
                                        SizedBox(width: fontSizes.padding),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width /
                                                        3.3,
                                                    // adjust here narrations
                                                    child: textStyle(
                                                      context: context,
                                                      text: !isManual
                                                          ? nameOfUser
                                                          : subcategory,
                                                      c: AppColors.accentColor,
                                                      fontsize: fontSizes
                                                          .fontSizeMedium,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      lineHeight: 1.5,
                                                    ),
                                                  ),
                                                  Container(
                                                    //  width: MediaQuery.sizeOf(context).width/3.0,
                                                    //  color: Colors.green,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        textStyle(
                                                          context: context,
                                                          text: formatAmount,
                                                          c: amtColor,
                                                          fontsize: fontSizes
                                                              .fontSizeLarge,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              textStyle(
                                                context: context,
                                                text: isManual
                                                    ? formattedDateManual
                                                    : formattedDate,
                                                c: AppColors.primaryColor
                                                    .withOpacity(0.7),
                                                fontsize:
                                                    fontSizes.fontSizeSmall,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  isExcluded
                                      ? SizedBox(height: 10)
                                      : SizedBox.shrink(),
                                  isExcluded
                                      ? SizedBox.shrink()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4),
                                          child: getIconsForHideUpdateSplit(
                                              fontSizes.iconSize,
                                              fontSizes.padding,
                                              category,
                                              amount,
                                              logo,
                                              context,
                                              index,
                                              subcategory,
                                              transaction,
                                              isReview,
                                              id,
                                              isManual,
                                              hide,
                                              isSplit,
                                              isExcluded,
                                              formatAmountBalance),
                                        ),
                                  (isManual || isReview)
                                      ? SizedBox(height: 0)
                                      : isExcluded
                                          ? SizedBox.shrink()
                                          : SizedBox(
                                              height: fontSizes.padding / 2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Excluded badge at top-right
                  if (isExcluded)
                    Positioned(
                      top: 0,
                      right: -2,
                      child: SvgPicture.asset(
                        'assets/icons/Home-page/notMIne.svg',
                        height: 20,
                        width: 60,
                      ),
                    ),
                ],
              ),
            )),
      ),
    ),
  );
}

Widget reviewTagTransactions(
    bool isReview,
    double scaleFactor,
    bool isSplit,
    double margin,
    double badgeSize,
    double fontSizeSmall,
    BuildContext context,
    int index,
    String narration_id) {
  return Column(
    children: [
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isReview)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colorcodes.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16 * scaleFactor),
                    ),
                  ),
                  child: textStyle(
                      text: "Review",
                      context: context,
                      fontsize: 11,
                      fontWeight: FontWeight.bold,
                      c: Colors.white),
                ),
                SizedBox(
                    width:
                        8 * scaleFactor), // Space between review badge and logo
              ],
            ),
        ],
      ),
    ],
  );
}

Widget animatedIconTransition(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      late final AnimationController controller = AnimationController(
        vsync: Scaffold.of(context),
        duration: Duration(seconds: 2),
      );

      late final Animation<Offset> offset = Tween<Offset>(
        begin: Offset(0, 0),
        end: Offset(2, 0), // Move right; change this for other direction
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      bool showMt1 = true;

      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            showMt1 = false;
          });
        }
      });

      controller.forward();

      return SlideTransition(
        position: offset,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: Container(
            key: ValueKey(showMt1),
            width: 50,
            height: 50,
            child: AvatarProfileImage(
              url: showMt1 ? HomePageIcons.mt1 : HomePageIcons.mt2,
              width: 50,
              height: 50,
            ),
          ),
        ),
      );
    },
  );
}

Widget getIconsForHideUpdateSplit(
    double iconSize,
    double padding,
    String category,
    double amount,
    String logo,
    BuildContext context,
    int index,
    String subcategory,
    TransactionModel transaction,
    bool isReview,
    String id,
    bool isManual,
    bool hide,
    bool isSplit,
    bool isExcluded,
    String formatAmountBalance) {
  // Responsive scaling with MediaQuery
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 360; // Base width: 360px
  final fontSizeMedium = 12.0 * scaleFactor;
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Container(
      width: (transaction.predictions != null &&
              transaction.predictions!.entries.length > 4 &&
              (transaction.isBalanceOut ?? false) &&
              formatAmountBalance != "₹-1")
          ? null
          : MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 20,
      //  color:Colors.red,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  category == 'Untagged'
                      ? getPredictedCategoryIcons(transaction, context, index)
                      : GestureDetector(
                          onTap: category == 'Untagged'
                              ? null
                              : () {
                                  tagName.value = category;
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    builder: (context) {
                                      return TagShowmodal(
                                        data: transaction,
                                        index: index,
                                      );
                                    },
                                  );
                                },
                          child: textStyleImage(
                            context: context,
                            text: toUpperCase(category),
                            c: AppColors.primaryColor,
                            fontsize: fontSizeMedium,
                            fontWeight: FontWeight.w600,
                          )),
                  ((transaction.isBalanceOut ?? false) &&
                          formatAmountBalance != "₹-1")
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            textStyle(
                                context: context,
                                text: " ( " +
                                    (formatAmountBalance.toString()) +
                                    " )",
                                fontsize: 13,
                                fontWeight: FontWeight.w500)
                          ],
                        )
                      : SizedBox.shrink()
                ],
              ),
              if (isSplit)
                Container(
                    width: MediaQuery.sizeOf(context).width / 11,
                    child: AvatarProfileImage(
                        url: HomePageIcons.isSplit, width: 50, height: 50)),
            ],
          ),

          isReview
              ? getTagButton(transaction, index, category, context, id)
              : Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hide Transaction
                      Tooltip(
                        message: HomepageStringsDart().hideTooltip,
                        child: GestureDetector(
                          onTap: hide
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      double screenWidth =
                                          MediaQuery.sizeOf(context).width;
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          width: screenWidth * 0.95,
                                          padding: EdgeInsets.all(
                                              screenWidth * 0.05),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white,
                                                Colors.grey[50]!,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Title / Prompt Text
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: screenWidth * 0.02,
                                                ),
                                                child: textStyleOnly2(
                                                  context: context,
                                                  text: HomepageStringsDart()
                                                      .hideTransactionPrompt,
                                                  fontsize: screenWidth < 400
                                                      ? 14
                                                      : 16,
                                                  color: AppColors.bg1,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              // Divider
                                              Divider(
                                                color: Colors.grey[200],
                                                thickness: 1,
                                                height: screenWidth * 0.06,
                                              ),

                                              // Buttons Row
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  // No Button
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            screenWidth * 0.06,
                                                        vertical:
                                                            screenWidth * 0.03,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    child: textStyleOnly2(
                                                      context: context,
                                                      text:
                                                          HomepageStringsDart()
                                                              .noButton,
                                                      fontsize:
                                                          screenWidth < 400
                                                              ? 14
                                                              : 16,
                                                      color: AppColors.bg1
                                                          .withOpacity(0.7),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),

                                                  // Vertical Divider
                                                  Container(
                                                    width: 1,
                                                    height: screenWidth * 0.06,
                                                    color: Colors.grey[200],
                                                  ),

                                                  // Yes Button
                                                  TextButton(
                                                    onPressed: () async {
                                                      await hideTransaction(
                                                        index,
                                                        !hide,
                                                        context,
                                                        transaction.id,
                                                      );

                                                      if (context.mounted) {
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            screenWidth * 0.06,
                                                        vertical:
                                                            screenWidth * 0.03,
                                                      ),
                                                      backgroundColor: AppColors
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    child: textStyleOnly2(
                                                      context: context,
                                                      text:
                                                          HomepageStringsDart()
                                                              .yesButton,
                                                      fontsize:
                                                          screenWidth < 400
                                                              ? 14
                                                              : 16,
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              : null, // null if `hide` is false
                          child: hide
                              ? Icon(
                                  Icons.visibility_outlined,
                                  color: AppColors.primaryColor,
                                  size: 18,
                                )
                              : const SizedBox
                                  .shrink(), // empty widget if hide is false
                        ),
                      ),
                      SizedBox(width: 8 * scaleFactor),

                      // Friends Modal
                      Tooltip(
                        message: HomepageStringsDart().splitWithFriendsTooltip,
                        child: GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            transactionsId.value = transaction.id;
                            await showCustomFriendsModalTransactionHistory(
                                context,
                                amount,
                                false,
                                category,
                                subcategory,
                                false);
                          },
                          child: AvatarProfileImage(
                              url: HomePageIcons.splitIcon,
                              width: 120,
                              height: 46),
                        ),
                      ),

                      // Tag Action
                      getRightSidePart(category, context, isManual, logo,
                          scaleFactor, transaction, index),
                    ],
                  ),
                ),
        ],
      ),
    ),
  );
}

Widget getRightSidePart(String category, BuildContext context, bool isManual,
    String logo, double scaleFactor, TransactionModel transaction, int index) {
  return Row(
    children: [
      if (category == 'Untagged') ...[
        Tooltip(
          message: HomepageStringsDart().tagTooltip,
          child: GestureDetector(
            onTap: () {
              tagName.value = category;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return TagShowmodal(
                    data: transaction,
                    index: index,
                  );
                },
              );
            },
            child: AvatarProfileImage(
                url: HomePageIcons.tagIcon, width: 1200, height: 46),
          ),
        ),
      ],
      SizedBox(width: 8 * scaleFactor),
      isManual
          ? Container(
              // height: 50,
              // width: 10,
              child: Lottie.asset(
                'assets/splashScreen/manualTransactionIcon.json',
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error); // fallback UI
                },
              ),
            )
          // Fallback icon
          : Image.network(
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
  );
}

bool isValidUrl(String? url) {
  return url != null &&
      url.isNotEmpty &&
      Uri.tryParse(url)?.hasAbsolutePath == true;
}

Widget getPredictedCategoryIcons(
    TransactionModel transaction, BuildContext context, int index) {
  final predictions = transaction.predictions;
  if (predictions == null || predictions.entries.isEmpty) {
    return const SizedBox.shrink();
  }

  // Timer for debouncing taps
  Timer? _debounce;

  return Row(
    children: predictions.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () async {
            // Debounce to prevent multiple taps
            if (_debounce?.isActive ?? false) return;
            _debounce = Timer(const Duration(milliseconds: 500), () {});

            // Show loader and provide immediate feedback
            tagBool.value = true;

            // Optimistic UI update
            final originalTransaction = transactionsHistory[index];
            transactionsHistory[index] = transaction.copyWith(
              category: entry.category,
              subcategory: "Other",
              needsReview: false,
            );
            transactionsHistory.refresh();

            try {
              await updateTheTagOfTarnsactions(
                entry.category,
                "Other",
                transaction.id,
                context,
                index,
                transactionsHistory[index], // Pass updated transaction
              );
            } catch (e) {
              // Revert UI on failure
              transactionsHistory[index] = originalTransaction;
              transactionsHistory.refresh();
              snackBarCalledfail(context, "Failed to tag transaction", Colorcodes.red);
            } finally {
              tagBool.value = false;
              _debounce?.cancel();
            }
          },
          child: Tooltip(
            message: 'Tag as ${entry.category}',
            child: getPredictedCategorySvgUrl(25, entry.category, 10, true),
          ),
        ),
      );
    }).toList(),
  );
}
Future<dynamic> showCustomFriendsModalTransactionHistory(BuildContext context,
    double amount, bool isLendMode, String category, String subcategory,
    [bool ismanulTransaction = false]) async {
  return await showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (BuildContext context) {
      return NewFriendsUi(
        totalAmount: amount.toDouble(),
        userId: userController.userId.value,
        userName: userController.userName.value,
        userAvatar: userController.avatar.value,
        isLendMode: isLendMode,
        category: category,
        subcategory: subcategory,
        flag: true,
        ismanual: false,
      );
    },
  );
}

Widget getTagButton(TransactionModel transaction, int index, String category,
    BuildContext context, String narration_id) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      InkWell(
        onTap: () async {
          await addTagToTransactions(context, narration_id, false, index);
        },
        child: Icon(
          Icons.close_rounded,
          color: Colorcodes.red,
          size: 30,
        ),
      ),
      const SizedBox(width: 10),
      InkWell(
        onTap: () {
          addTagToTransactions(context, narration_id, true, index);
        },
        child: Icon(
          Icons.check,
          color: Colorcodes.green,
          size: 30,
        ),
      ),
    ],
  );
}
