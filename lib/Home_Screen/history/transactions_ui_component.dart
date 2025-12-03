import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_components/transactions_container.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';


RxMap<String, String> redioButton = <String, String>{}.obs;
RxMap<String, int> redioButtonIndex = <String, int>{}.obs;
RxMap<String, TransactionModel> balanceOutList = <String, TransactionModel>{}.obs;
RxMap<String, double> redioButtonAmount = <String, double>{}.obs;
RxList<String> addManually = <String>[].obs;
RxBool showCheckBox = false.obs;

class HistoryTransactions extends StatelessWidget {
  final TransactionModel transaction;
  final String? date;
  final int index;
  final bool hideReview;
  final bool isExpanded;
  final bool hide;
  final BuildContext context;

  const HistoryTransactions({
    Key? key,
    required this.transaction,
    required this.date,
    required this.index,
    required this.context,
    this.hideReview = false,
    this.isExpanded = false,
    this.hide = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String logo = transaction.bankLogo ?? "";
    final category = transaction.category;
    final double amount = double.parse(transaction.amount.toString());
    final isManual = transaction.manualTransaction;
    final isSplit = transaction.isSplit;
    final formattedDate = date != null
        ? formatWhatsAppDateWithoutTime(convertStringToDateTime(date!))
        : 'Date';
    final formattedDateManual =
        date != null ? formatWhatsAppDate(convertStringToDateTime(date!)) : 'Date';
    final type = transaction.type;
    final narration = transaction.narration;
    final id = transaction.id;
    final bool isReview = transaction.needsReview ?? false;
    final bool isExcluded = transaction.isExcluded ?? false;

    // if (hideReview && isReview) return const SizedBox.shrink();

    final List<String> parts = _parseNarration(narration);
    final String nameOfUser = transaction.title ?? _getNameOfUser(parts);
    final Color amtColor =type == 'CREDIT' ? AppColors.primaryColor : AppColors.primaryColor;
    final String formatAmount = type == 'CREDIT'
        ? "+₹${formatMoneyIndian(amount.toString())}"
        : "-₹${formatMoneyIndian(amount.toString())}";
    final String formatAmountBalance = "₹${formatMoneyIndian(transaction.balanceOut.toString())}";
    final fontSizes = FontSizeFactor(context);

    return WillPopScope(
      onWillPop: () async {
        if (showCheckBox.value) {
          redioButton.clear();
          redioButtonIndex.clear();
          balanceOutList.clear();
          showCheckBox.value = false;
          return false;
        }
        redioButton.clear();
        balanceOutList.clear();
        redioButtonIndex.clear();
        showCheckBox.value = false;
        return true;
      },
      child: TransactionContainer(
        transaction: transaction,
        id: id,
        index: index,
        isExcluded: isExcluded,
        isReview: isReview,
        isManual: isManual,
        isSplit: isSplit,
        hide: hide,
        category: category,
        logo: logo,
        amount: amount,
        formatAmount: formatAmount,
        formatAmountBalance: formatAmountBalance,
        nameOfUser: nameOfUser,
        formattedDate: formattedDate,
        formattedDateManual: formattedDateManual,
        type: type,
        fontSizes: fontSizes,
        amtColor: amtColor,
        isExpanded: isExpanded,
        context: context,
      ),
    );
  }

  List<String> _parseNarration(String narration) {
    List<String> parts = narration.split('/');
    if (parts.length <= 1) parts = narration.split('-');
    if (parts.length <= 1) parts = narration.split('&');
    if (parts.length <= 1) parts = narration.split(' ');
    return parts;
  }

  String _getNameOfUser(List<String> parts) {
    return parts.length >= 4
        ? parts[3]
        : parts.length >= 3
            ? parts[2]
            : parts.length >= 2
                ? parts[1]
                : parts[0];
  }
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
      
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isReview)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colorcodes.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16 * scaleFactor),
                ),
              ),
              child: textStyle(
                text: "Review",
                context: context,
                fontsize: 9,
                fontWeight: FontWeight.bold,
                c: AppColors.backgroundColor,
              ),
            ),
        ],
      ),
      SizedBox(height: 4,)
    ],
  );
}

Widget animatedIconTransition(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      final AnimationController controller = AnimationController(
        vsync: Scaffold.of(context),
        duration: const Duration(seconds: 2),
      );

      final Animation<Offset> offset = Tween<Offset>(
        begin: const Offset(0, 0),
        end: const Offset(2, 0),
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
          duration: const Duration(milliseconds: 500),
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

Future<dynamic> showCustomFriendsModalTransactionHistory(
    BuildContext context,
    double amount,
    bool isLendMode,
    String category,
    String subcategory,
    [bool isManualTransaction = false]) async {
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