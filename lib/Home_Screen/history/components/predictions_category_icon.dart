
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:lottie/lottie.dart'; // For haptic feedback



Widget getRightSidePart(String category, BuildContext context, bool isManual,
    String logo, double scaleFactor, TransactionModel transaction, int index) {
  return Row(
    children: [
      if (category == 'Untagged')
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
              url: HomePageIcons.tagIcon,
              width: 1200,
              height: 46,
            ),
          ),
        ),
      SizedBox(width: 8 * scaleFactor),
      isManual
          ? Container(
              child: Lottie.asset(
                'assets/splashScreen/manualTransactionIcon.json',
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            )
          : Image.network(
              logo,
              width: 22,
              height: 22,
              fit: BoxFit.fitWidth,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator(strokeWidth: 2);
              },
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 22),
            ),
   
    ],
  );
}

bool isValidUrl(String? url) {
  return url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
}

Widget getPredictedCategoryIcons(
    TransactionModel transaction, BuildContext context, int index) {
  final predictions = transaction.predictions;
  if (predictions == null || predictions.entries.isEmpty) {
    return const SizedBox.shrink();
  }

  Timer? _debounce;

  return Row(
    children: predictions.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () async {
            if (_debounce?.isActive ?? false) return;
            _debounce = Timer(const Duration(milliseconds: 500), () {});

            tagBool.value = true;
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
                transactionsHistory[index],
              );
            } catch (e) {
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