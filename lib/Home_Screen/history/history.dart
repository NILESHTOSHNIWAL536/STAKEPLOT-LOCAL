import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/iconSwitch.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart'; // For haptic feedback
import 'package:flutter_application_code_stakeplot/Constants/search.dart';

// Reactive variables

RxMap<String, String> redioButton = <String, String>{}.obs;
RxMap<String, int> redioButtonIndex = <String, int>{}.obs;
RxList<String> addManually = <String>[].obs;
RxBool showCheckBox =
    false.obs; // Initialize as false to avoid showing checkboxes by default

Widget historyTransactions(
    TransactionModel transaction, String? date, int index, BuildContext context,
    [bool hideReview = false, bool isexpanded = false, bool hide = false]) {
  String logo = transaction.bankLogo ?? "";

  final category = transaction.category;
  final subcategory = transaction.subcategory;
  final double amount =
      double.parse(doubleToFixed((transaction.amount).toString()));
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

  final fontSizes = FontSizeFactor(context);

  return WillPopScope(
    onWillPop: () async {
      // If checkboxes are visible, clear them and stay on the screen
      if (showCheckBox.value) {
        redioButton.clear();
        redioButtonIndex.clear();
        showCheckBox.value = false;
        return false; // Prevent popping the screen
      }
      // If no checkboxes, allow normal back navigation and clear state
      redioButton.clear();
      redioButtonIndex.clear();
      showCheckBox.value = false;
      return true; // Allow popping the screen
    },
    
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      
      onTap: isExcluded?  () async {
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
      minHeight: 100,  // Minimum height
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            :() {
        // uncomment this
        if (showCheckBox.value) {
          String id = '${transaction.id}';
          bool isChecked = redioButton.containsKey(id);
          if (!isChecked) {
            redioButton[id] = id;
            redioButtonIndex[id] = index;
            if (isManual) addManually.add(id);
            HapticFeedback.selectionClick();
          } else {
            redioButton.remove(id);
            redioButtonIndex.remove(id);
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
        // if (!isManual && !showCheckBox.value) {
        //   showModalBottomSheet(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return TransactionDetailsPage(transaction: transaction);
        //     },
        //   );
        // }
      },
      onLongPress: isExcluded?null:() {
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
          borderRadius: BorderRadius.circular(16 * fontSizes.scaleFactor),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
               
                children: [
                   if (isExcluded)
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 4 * fontSizes.scaleFactor,
                          horizontal: 10 * fontSizes.scaleFactor),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
    colors: [
      AppColors.finSpaceColor,           // Start color
      AppColors.finSpaceColorGradient, // End color (you can change this)
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16 * fontSizes.scaleFactor),
                        ),
                      ),
                      child: textStyle(
                        context: context,
                        text: "Not Mine",
                        c: AppColors.backgroundColor,
                        fontsize: fontSizes.fontSizeSmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Container(
                    // color: Colors.green,
                    padding: EdgeInsets.only(top: 0),
                    child: Row(
                      children: [
                        // Animated Checkbox
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: (showCheckBox.value && !hide)
                              ? Container(
                                  key: ValueKey('checkbox'),
                                  height: 30,
                                  width: 30,
                                  child: Checkbox(
                                    value:
                                        redioButton.containsKey('${transaction.id}'),
                                    onChanged: (bool? isChecked) {
                                      String id = '${transaction.id}';
                                      bool ismanual = transaction.manualTransaction;
                                      if (isChecked == true) {
                                        redioButton[id] = id;
                                        redioButtonIndex[id] = index;
                                        if (ismanual) addManually.add(id);
                                        HapticFeedback
                                            .selectionClick(); // Feedback on check
                                      } else {
                                        redioButton.remove(id);
                                        redioButtonIndex.remove(id);
                                        if (ismanual) addManually.remove(id);
                                        HapticFeedback.selectionClick();
                                      }
                                    },
                                    shape: const CircleBorder(),
                                    side: BorderSide(color: AppColors.primaryColor),
                                    checkColor: Colors.white,
                                    activeColor: AppColors.primaryColor,
                                    semanticLabel:
                                        'Select transaction ${transaction.id}',
                                  ),
                                )
                              : SizedBox.shrink(key: ValueKey('no-checkbox')),
                        ),
                        // Main Transaction Content
                    
                        // remove gesture detector here
                        Container(
                          width: MediaQuery.of(context).size.width /
                              (showCheckBox.value ? 1.2 : 1.1),
                          padding: EdgeInsets.only(
                              top: isExcluded?0:fontSizes.padding / 6,
                              bottom: isExcluded?6:fontSizes.padding / 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (isManual || isReview )
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
                                  :SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: fontSizes.padding),
                                child: Row(
                                  children: [
                                     isExcluded?getIconAvtar(30, category,
                                        fontSizes.scaleFactor/2):getIconAvtar(fontSizes.avatarSize, category,
                                        fontSizes.scaleFactor),
                                    SizedBox(width: fontSizes.padding),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                // color: Colorcodes.red,
                                                width:
                                                    MediaQuery.sizeOf(context).width /
                                                        2.4,
                                                child: textStyle(
                                                  context: context,
                                                  text: !isManual
                                                      ? nameOfUser
                                                      : subcategory,
                                                  c: AppColors.accentColor,
                                                  fontsize: fontSizes.fontSizeMedium,
                                                  fontWeight: FontWeight.w600,
                                                  lineHeight: 1.5,
                                                ),
                                              ),
                                              Container(
                                                // color: Colorcodes.red,
                                                child: textStyle(
                                                  context: context,
                                                  text: formatAmount,
                                                  c: amtColor,
                                                  fontsize: fontSizes.fontSizeLarge,
                                                  fontWeight: FontWeight.w500,
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
                                            fontsize: fontSizes.fontSizeSmall,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                             isExcluded? SizedBox(height: 10):SizedBox(height: 0),
                              isExcluded?SizedBox.shrink():Padding(
                                padding: const EdgeInsets.only(left: 10),
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
                                    isExcluded),
                              ),
                              (isManual || isReview)
                                  ? SizedBox(height: 0)
                                  : SizedBox(height: fontSizes.padding / 2),
                            ],
                          ),
                        ),
                      ],
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
) {
  // Responsive scaling with MediaQuery
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 360; // Base width: 360px
  final fontSizeMedium = 12.0 * scaleFactor;

  bool isValidUrl(String? url) {
    return url != null &&
        url.isNotEmpty &&
        Uri.tryParse(url)?.hasAbsolutePath == true;
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Category icon
        Row(
          children: [
            Container(
              // width: MediaQuery.sizeOf(context).width / 6,
              child: GestureDetector(
                onTap: category == 'Untagged'
                    ? null
                    : () {
                        tagName.value = category;
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return TagShowmodal(
                              data: transaction,
                              index: index,
                            );
                          },
                        );
                      },
                child: textStyle(
                  context: context,
                  text: toUpperCase(category),
                  c: AppColors.primaryColor,
                  fontsize: fontSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSplit)
              Container(
                  width: MediaQuery.sizeOf(context).width / 11,
                  // width: badgeSize,
                  // height: badgeSize,

                  child: AvatarProfileImage(
                      url: HomePageIcons.isSplit, width: 50, height: 50)),
          ],
        ),
        // Action Icons
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
                        onTap: () {
                          !hide
                              ? null
                              :
                              // Show confirmation dialog
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    double screenWidth =
                                        MediaQuery.sizeOf(context).width;
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 4,
                                      backgroundColor: Colors
                                          .transparent, // For custom container
                                      child: Container(
                                        width: screenWidth *
                                            0.95, // 85% of screen width
                                        padding:
                                            EdgeInsets.all(screenWidth * 0.05),
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
                                              color:
                                                  Colors.black.withOpacity(0.1),
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
                                            // Content
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: screenWidth * 0.02),
                                              child: textStyleOnly2(
                                                context: context,
                                                text: hide
                                                    ? HomepageStringsDart()
                                                        .unhideTransactionPrompt
                                                    : HomepageStringsDart()
                                                        .hideTransactionPrompt,
                                                fontsize:
                                                    screenWidth < 400 ? 14 : 16,
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
                                            // Actions
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
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
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: textStyleOnly2(
                                                    context: context,
                                                    text: HomepageStringsDart()
                                                        .noButton,
                                                    fontsize: screenWidth < 400
                                                        ? 14
                                                        : 16,
                                                    color: AppColors.bg1
                                                        .withOpacity(0.7),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: screenWidth * 0.06,
                                                  color: Colors.grey[200],
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await hideTransaction(
                                                        index,
                                                        !hide,
                                                        context,
                                                        transaction.id);

                                                    if (context.mounted) {
                                                      Navigator.of(context)
                                                          .pop(); // Pop the dialog after hiding
                                                    }
                                                    //                                           //Navigator.of(context).pop();
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
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: textStyleOnly2(
                                                    context: context,
                                                    text: HomepageStringsDart()
                                                        .yesButton,
                                                    fontsize: screenWidth < 400
                                                        ? 14
                                                        : 16,
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontWeight: FontWeight.w600,
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
                        },
                        child: !hide
                            ? Text('')
                            : Icon(
                                hide
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_rounded,
                                color: AppColors.primaryColor,
                                size: 18,
                              ),
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
                          child: AvatarProfileImage(
                              url: HomePageIcons.tagIcon,
                              width: 1200,
                              height: 46),
                        ),
                      ),
                    ],
                    isExcluded
                        ? GestureDetector(
                            onTap: () async {
                              // Show confirmation dialog before excluding
                              final shouldExclude = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Exclusion'),
                                    content: Text(
                                        'Are you sure you want to exclude this transaction?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (shouldExclude == true) {
                                excludeCashFlowTransaction(
                                    index, false, context, transaction.id);
                                    
                                
                              }
                            },
                            child: Tooltip(
                              message: "Exclude",
                              child: AvatarProfileImage(
                                  url: HomePageIcons.cashIn,
                                  width: 1200,
                                  height: 46),
                            ),
                          )
                        : const SizedBox.shrink(),
                    SizedBox(width: 8 * scaleFactor),
                   
                    isManual
                        ? Container(
                            height: 30,
                            width: 30,
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
                ),
              ),
      ],
    ),
  );
}

// Reusable showCustomFriendsModal function
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
