import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart'; // For haptic feedback

// Reactive variables
RxMap<String, String> redioButton = <String, String>{}.obs;
RxMap<String, int> redioButtonIndex = <String, int>{}.obs;
RxBool showCheckBox =
    false.obs; // Initialize as false to avoid showing checkboxes by default

Widget historyTransactions(Map<String, dynamic> transaction, String? date,
    int index, BuildContext context,
    [bool hideReview = false]) {
  String logo = transaction['bankLogo']?.toString() ?? "";

  final category = transaction['category']?.toString() ?? 'Uncategorized';
  final subcategory = transaction['subcategory']?.toString() ?? 'General';
  final double amount =
      double.parse(doubleToFixed((transaction['amount'] ?? 0.0).toString()));
  final isManual = transaction['manualTransaction'] ?? false;
  final isSplit = transaction['isSplit'] ?? false;

  final formattedDate = date != null
      ? formatWhatsAppDate3(convertStringToDateTime(date))
      : 'Date';
  final formattedDateManual =
      date != null ? formatWhatsAppDate(convertStringToDateTime(date)) : 'Date';
  final type = transaction['type']?.toString() ?? '0';
  final narration = transaction['narration'] ?? 'Unnamed Group';
  final id = transaction['_id'] ?? 'Unnamed Group';
  bool isReview = transaction['needsReview'] ?? true;

  if (hideReview && isReview) return SizedBox.shrink();

  List<String> parts = narration.split('/');
  if (parts.isEmpty || parts.length == 1) parts = narration.split('-');
  if (parts.isEmpty || parts.length == 1) parts = narration.split('&');
  if (parts.isEmpty || parts.length == 1) parts = narration.split(' ');

  String nameOfUser = parts.length >= 4
      ? parts[3]
      : parts.length >= 3
          ? parts[2]
          : parts.length >= 2
              ? parts[1]
              : parts[0];

  final amtColor = type == 'CREDIT'
      ? Colors.green.shade700
      : const Color.fromARGB(255, 207, 118, 113);
  final formatAmount = type == 'CREDIT'
      ? "+₹${formatMoneyIndian(amount.toString())}"
      : "-₹${formatMoneyIndian(amount.toString())}";

  // Responsive scaling with MediaQuery
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 360; // Base width: 360px
  final padding = 14.0 * scaleFactor;
  final margin = 10.0 * scaleFactor;
  final iconSize = 14.0 * scaleFactor;
  final avatarSize = 40.0 * scaleFactor;
  final fontSizeLarge = 16.0 * scaleFactor;
  final fontSizeMedium = 12.0 * scaleFactor;
  final fontSizeSmall = 10.0 * scaleFactor;
  final badgeSize = 20.0 * scaleFactor;

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
      onTap: () {
        if (!isManual && !showCheckBox.value) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return TransactionDetailsPage(transaction: transaction);
            },
          );
        }
      },
      onLongPress: () {
        showCheckBox.value = true;
        HapticFeedback.mediumImpact(); // Haptic feedback on long press
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: margin / 2, horizontal: margin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scaleFactor),
          border: !isReview
              ? null
              : Border.all(
                  color: Colorcodes.red,
                  width: 0.5,
                ),
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundColor.withOpacity(0.03),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8 * scaleFactor,
              offset: Offset(0, 3 * scaleFactor),
            ),
          ],
        ),
        child: Obx(() => AnimatedContainer(
              duration:
                  Duration(milliseconds: 300), // Smooth animation for checkbox
              curve: Curves.easeInOut,
              child: Row(
                children: [
                  // Animated Checkbox
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: showCheckBox.value
                        ? Container(
                            key: ValueKey('checkbox'),
                            height: 30,
                            width: 30,
                            child: Checkbox(
                              value: redioButton
                                  .containsKey('${transaction['_id']}'),
                              onChanged: (bool? isChecked) {
                                String id = '${transaction['_id']}';
                                if (isChecked == true) {
                                  redioButton[id] = id;
                                  redioButtonIndex[id] = index;
                                  HapticFeedback
                                      .selectionClick(); // Feedback on check
                                } else {
                                  redioButton.remove(id);
                                  redioButtonIndex.remove(id);
                                  HapticFeedback.selectionClick();
                                }
                              },
                              shape: const CircleBorder(),
                              side: BorderSide(color: AppColors.primaryColor),
                              checkColor: Colors.white,
                              activeColor: AppColors.primaryColor,
                              semanticLabel:
                                  'Select transaction ${transaction['_id']}',
                            ),
                          )
                        : SizedBox.shrink(key: ValueKey('no-checkbox')),
                  ),
                  // Main Transaction Content
                  GestureDetector(
                        onTap: (){
                          if(!showCheckBox.value)return;
                            String id = '${transaction['_id']}';
                            bool isChecked =redioButton.containsKey(id);
                            if (!isChecked){
                              redioButton[id] = id;
                              redioButtonIndex[id] = index;
                              HapticFeedback.selectionClick(); // Feedback on check
                            } else
                            {
                              redioButton.remove(id);
                              redioButtonIndex.remove(id);
                              HapticFeedback.selectionClick();
                            }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width /
                          (showCheckBox.value ? 1.2 : 1.1),
                      padding:
                          EdgeInsets.only(top: padding / 6, bottom: padding / 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (isManual || isReview)
                              ? reviewTagTransactions(
                                  isReview,
                                  scaleFactor,
                                  isSplit,
                                  margin,
                                  badgeSize,
                                  fontSizeSmall,
                                  context,
                                  index,
                                  id)
                              : SizedBox(height: padding),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            child: Row(
                              children: [
                                getIconAvtar(avatarSize, category, scaleFactor),
                                SizedBox(width: padding),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Tooltip(
                                            message: narration,
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width /
                                                  3,
                                              child: textStyle(
                                                context: context,
                                                text: !isManual
                                                    ? nameOfUser
                                                    : narration,
                                                c: AppColors.accentColor,
                                                fontsize: fontSizeMedium,
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                              ),
                                            ),
                                          ),
                                          textStyle(
                                            context: context,
                                            text: formatAmount,
                                            c: amtColor,
                                            fontsize: fontSizeLarge,
                                            fontWeight: FontWeight.bold,
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
                                        fontsize: fontSizeSmall,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: getIconsForHideUpdateSplit(
                                iconSize,
                                padding,
                                category,
                                amount,
                                logo,
                                context,
                                index,
                                subcategory,
                                transaction,
                                isReview,
                                id,
                                isManual),
                          ),
                          (isManual || isReview)
                              ? SizedBox(height: 0)
                              : SizedBox(height: padding / 2),
                        ],
                      ),
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
  return Row(
    mainAxisAlignment:
        isSplit ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
    children: [
      if (isSplit)
        Container(
            // width: badgeSize,
            // height: badgeSize,
            decoration: BoxDecoration(
             // color: AppColors.bg5,
              shape: BoxShape.circle,
             
            ),
            child: AvatarProfileImage(
                url: HomePageIcons.isSplit, width: 50, height:50)),
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
                width: 8 * scaleFactor), // Space between review badge and logo
          ],
        ),
    ],
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
    Map<String, dynamic> transaction,
    bool isReview,
    String id,
    bool isManual) {
  // Responsive scaling with MediaQuery
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 360; // Base width: 360px
  final fontSizeMedium = 12.0 * scaleFactor;
  final fontSizeSmall = 10.0 * scaleFactor;
  final badgeSize = 20.0 * scaleFactor;
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
        // Category
        Container(
          width: MediaQuery.sizeOf(context).width / 3,
          child: textStyle(
            context: context,
            text: category,
            c: AppColors.accentColor,
            fontsize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Action Icons
        isReview
            ? getTagButton(transaction, index, category, context, id)
            : Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hide Transaction
                    SizedBox(width: 8 * scaleFactor),
                    (() {
                      return SizedBox.shrink();
                    })(),
                    isManual
                                               ?
                                                  Container(
                            height: 30,
                            width: 30,
                            child: Lottie.asset(
                              'assets/splashScreen/manualTransactionIcon.json',
                              errorBuilder: (context, error, stackTrace) {
                                print('Lottie error: $error');
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
                              print('Error loading logo for URL $logo: $error');
                              return Icon(Icons.error,
                                  size: 22); // Fallback for failed image load
                            },
                          ),
                    SizedBox(width: 8 * scaleFactor),
                    Tooltip(
                      message: 'Hide',
                      child: GestureDetector(
                        onTap: () {
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
                                backgroundColor:
                                    Colors.transparent, // For custom container
                                child: Container(
                                  width:
                                      screenWidth * 0.85, // 85% of screen width
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
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
                                        color: Colors.black.withOpacity(0.1),
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
                                          text:
                                              "Do you want to hide this transaction?",
                                          fontsize: screenWidth < 400 ? 14 : 16,
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
                                              padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.06,
                                                vertical: screenWidth * 0.03,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: textStyleOnly2(
                                              context: context,
                                              text: "No",
                                              fontsize:
                                                  screenWidth < 400 ? 14 : 16,
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
                                            onPressed: () {
                                              hideTransaction(index, true,
                                                  context, transaction['_id']);
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.06,
                                                vertical: screenWidth * 0.03,
                                              ),
                                              backgroundColor: AppColors
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: textStyleOnly2(
                                              context: context,
                                              text: "Yes",
                                              fontsize:
                                                  screenWidth < 400 ? 14 : 16,
                                              color: AppColors.primaryColor,
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
                        child: Container(
                          padding: EdgeInsets.all(6 * scaleFactor),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                          ),
                          child: Icon(
                            Icons.visibility_off_rounded,
                            color: AppColors.primaryColor,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scaleFactor),
                    // Friends Modal
                    Tooltip(
                      message: 'Split with Friends',
                      child: GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          transactionsId.value = transaction['_id'];
                          await showCustomFriendsModalTransactionHistory(
                              context,
                              amount,
                              false,
                              category,
                              subcategory,
                              false);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6 * scaleFactor),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                          ),
                          child: Icon(
                            Icons.group_add_rounded,
                            color: AppColors.primaryColor,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scaleFactor),
                    // Tag Action
                    Tooltip(
                      message: 'Tag',
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
                        child: Container(
                          padding: EdgeInsets.all(6 * scaleFactor),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                          ),
                          child: Icon(
                            Icons.tag_rounded,
                            color: AppColors.primaryColor,
                            size: iconSize,
                          ),
                        ),
                      ),
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
        userId: currentId.value,
        userName: userName.value,
        userAvatar: avatar.value,
        isLendMode: isLendMode,
        category: category,
        subcategory: subcategory,
        flag: true,
        ismanual: false,
      );
    },
  );
}

Widget getTagButton(Map<String, dynamic> transaction, int index,
    String category, BuildContext context, String narration_id) {
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

void callTagModal(BuildContext context, Map<String, dynamic> transaction,
    int index, String category) {
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
}
