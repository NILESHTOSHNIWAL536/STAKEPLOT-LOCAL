import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_svgs.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/date_range_filter.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week_of_year/week_of_year.dart';
import '../Constants/app_assets.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/core/app_shadows.dart';
import '../Constants/core/container_border.dart';
import '../Home_Screen/ManuallyTransactions/cashTransaction.dart';
import '../backed_connections/bankServices/pdf.dart';
import '../Home_Screen/history/amount_range.dart';
import '../controllers/transactions_controller.dart';
import '../repository/transactions_repository.dart';
import 'shared_utils.dart';

List<PredictionEntry> getUniquePredictedCategories(
    List<PredictionEntry> predictions) {
  final Set<String> seenCategories = {};
  final List<PredictionEntry> uniquePredictions = [];

  for (final keyword in predictions) {
    final category = getCategoryForKeyword(keyword.category);

    if (!seenCategories.contains(category)) {
      seenCategories.add(category);
      uniquePredictions.add(keyword); // or add category if needed
    }
  }

  return uniquePredictions;
}

String getCategoryForKeyword(String keyword) {
  final lowerKeyword = keyword.toLowerCase();

  for (final entry in categories.entries) {
    for (final item in entry.value) {
      if (lowerKeyword.contains(item.toLowerCase())) {
        return entry.key;
      }
    }
  }

  return keyword; // return original if not found
}

String getPreviousDate(int no, String type) {
  DateTime now = DateTime.now();
  DateTime previousDate;

  switch (type) {
    case 'days':
      previousDate = now.subtract(Duration(days: no));
      break;
    case 'months':
      previousDate = DateTime(now.year, now.month - no, now.day);
      break;
    case 'year':
      previousDate = DateTime(now.year - no, now.month, now.day);
      break;
    default:
      throw ArgumentError("Invalid type. Use 'days', 'months', or 'years'.");
  }

  return DateFormat('yyyy-MM-dd').format(previousDate);
}

List getLastTenUsers(List allUsers) {
  // Determine the number of users to take
  int numberOfUsersToTake = allUsers.length < 10 ? allUsers.length : 10;

  // Get the last `numberOfUsersToTake` users
  List lastUsers = allUsers.sublist(allUsers.length - numberOfUsersToTake);

  // Reverse the list
  return lastUsers.reversed.toList();
}

void showModalForPdfDownloadBankUiCheckBox(BuildContext context) {
  getPdgLoader.value = false;
  final double screenWidth = MediaQuery.of(context).size.width;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            width: MediaQuery.of(context).size.width, // Full screen width
            // height:
            //     (MediaQuery.of(context).size.height / 2.5), // Full screen height
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p14, vertical: AppSizes.p10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        textStyle(
                            context: context,
                            text: "Select a Bank Account to Download Statement",
                            fontsize: 14,
                            fontWeight: FontWeight.w500),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.close_outlined,
                            size: 20,
                            color: AppColors.accentColor,
                          ),
                        )
                      ],
                    ),
                  ),
                  getBankAccountList(context),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: InkWell(
                        onTap: () async {
                          showModalForPdfDownload(context);
                        },
                        child: getButton(context, "Continue")),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget getBankAccountList(BuildContext context, [bool fromPdf = true]) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
    child: Column(
      children: bankAccountLinkedList.map((account) {
        return Obx(
          () => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppColors.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(156, 156, 156, 0.25),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(
                vertical: AppSizes.p4, horizontal: 6),
            child: ListTile(
              leading: SizedBox(
                width: 40,
                height: 40,
                child: Image.network(
                  account.bankLogo,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textStyle(
                    context: context,
                    text: account.bankName,
                    fontsize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: AppSizes.h4),
                  textStyle(
                    context: context,
                    text: "Acc No: ${account.maskedAccNumber}",
                    fontsize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              trailing: Theme(
                data: Theme.of(context).copyWith(
                  checkboxTheme: const CheckboxThemeData(
                    shape: CircleBorder(),
                  ),
                ),
                child: Checkbox(
                  value:
                      (fromPdf ? accountIdPdf.value : accountSelected.value) ==
                          account.accountId,
                  onChanged: (isChecked) {
                    if (isChecked == true) {
                      if (fromPdf) {
                        accountIdPdf.value = account.accountId;
                      } else {
                        accountSelected.value = account.accountId;
                      }
                    } else {
                      if (fromPdf) {
                        accountIdPdf.value = "-";
                      } else {
                        accountSelected.value = "-";
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

// Widget getBankAccountList(context, [fromPdf = true]) {
//   return Container(
//     margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
//     // decoration: BoxDecoration(
//     //    borderRadius: BorderRadius.circular(5),
//     // color: AppColors.backgroundColor,
//     // boxShadow: [
//     //   BoxShadow(
//     //     color: Color.fromRGBO(156, 156, 156, 0.25),
//     //     blurRadius: 4,
//     //     spreadRadius: 0,
//     //     offset: Offset(0, 0),
//     //   ),
//     // ],
//     // ),
//     child: Column(
//       children: bankAccountLinkedList.map((account) {
//         return Obx(() => Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 color: AppColors.backgroundColor,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color.fromRGBO(156, 156, 156, 0.25),
//                     blurRadius: 4,
//                     spreadRadius: 0,
//                     offset: Offset(0, 0),
//                   ),
//                 ],
//               ),
//               margin: const EdgeInsets.symmetric(vertical: AppSizes.p4, horizontal: 6),
//               child: ListTile(
//                 leading: SizedBox(
//                   width: 40,
//                   height: 40,
//                   child: Image.network(
//                     account["bankLogo"],
//                     width: 22,
//                     height: 22,
//                   ),
//                 ),
//                 title: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       textStyle(
//                         context: context,
//                         text: account["bankName"],
//                         fontsize: 15,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       const SizedBox(
//                         height: 4,
//                       ),
//                       textStyle(
//                         context: context,
//                         text: "Acc No:" + account["maskedAccNumber"],
//                         fontsize: 11,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ]),
//                 trailing: Theme(
//                   data: Theme.of(context).copyWith(
//                     checkboxTheme: CheckboxThemeData(
//                       shape: const CircleBorder(),
//                     ),
//                   ),
//                   child: Checkbox(
//                     value: (fromPdf
//                             ? accountIdPdf.value
//                             : accountSelected.value) ==
//                         account["accountId"].toString(),
//                     onChanged: (isChecked) {
//                       if (isChecked == true) {
//                         if (fromPdf)
//                           accountIdPdf.value = account["accountId"].toString();
//                         else
//                           accountSelected.value =
//                               account["accountId"].toString();
//                       } else {
//                         if (fromPdf)
//                           accountIdPdf.value = "-";
//                         else
//                           accountSelected.value = "-";
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ));
//       }).toList(),
//     ),
//   );
// }

// Widget getBankAccountListForFilter(context, [fromPdf = true]) {
//   return Row(
//     children: bankAccountLinkedList.map((account) {
//       return Obx(() {
//         bool isSelected =
//             (fromPdf ? accountIdPdf.value : accountSelected.value) ==
//                 account["accountId"].toString();

//         Widget content = Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: AppSizes.p4),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: Image.network(
//                   account["bankLogo"],
//                   width: 22,
//                   height: 22,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Center(
//                 child: textStyleImage(
//                     context: context,
//                     text:
//                         "${account["maskedAccNumber"].toString().substring(account["maskedAccNumber"].toString().length - 6)}",
//                     fontsize: 12,
//                     fontWeight: FontWeight.w600,
//                     c: isSelected ? AppColors.backgroundColor : AppColors.bg1),
//               ),
//             ],
//           ),
//         );

//         return GestureDetector(
//           onTap: () {
//             String accId = account["accountId"].toString();
//             if (isSelected) {
//               if (fromPdf)
//                 accountIdPdf.value = "-";
//               else
//                 accountSelected.value = "-";
//             } else {
//               if (fromPdf)
//                 accountIdPdf.value = accId;
//               else
//                 accountSelected.value = accId;
//             }

//             // Optional: auto filter on tap
//             onChanedAutoTransactionStatus(context);
//           },
//           child: isSelected
//               ? Container(
//                   margin: EdgeInsets.symmetric(horizontal: 4, vertical: AppSizes.p2),
//                   padding: EdgeInsets.symmetric(horizontal: 6, vertical: AppSizes.p2),
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryColor,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: content,
//                 )
//               : Container(
//                   margin: EdgeInsets.symmetric(horizontal: 4, vertical: AppSizes.p2),
//                   padding: EdgeInsets.symmetric(horizontal: 4, vertical: AppSizes.p2),
//                   child: DottedBorderBox(
//                     dashWidth: 4,
//                     space: 5,
//                     dashHeight: 1,
//                     color: AppColors.grey,
//                     padding: EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p2),
//                     child: content,
//                   ),
//                 ),
//         );
//       });
//     }).toList(),
//   );
// }
Widget getBankAccountListForFilter(BuildContext context,
    [bool fromPdf = true]) {
  return Row(
    children: bankAccountLinkedList.map((account) {
      return Obx(() {
        final String currentSelectedId =
            fromPdf ? accountIdPdf.value : accountSelected.value;

        final bool isSelected = currentSelectedId == account.accountId;

        // Safely get last 6 characters of maskedAccNumber
        final String masked = account.maskedAccNumber;
        final String lastSix =
            masked.length > 6 ? masked.substring(masked.length - 6) : masked;

        Widget content = Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: AppSizes.p4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Image.network(
                  account.bankLogo,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: AppSizes.w6),
              Center(
                child: textStyleImage(
                  context: context,
                  text: lastSix,
                  fontsize: 12,
                  fontWeight: FontWeight.w600,
                  c: isSelected ? AppColors.backgroundColor : AppColors.bg1,
                ),
              ),
            ],
          ),
        );

        return GestureDetector(
            onTap: () {
              String accId = account.accountId;
              if (isSelected) {
                if (fromPdf) {
                  accountIdPdf.value = "-";
                } else {
                  accountSelected.value = "-";
                }
              } else {
                if (fromPdf) {
                  accountIdPdf.value = accId;
                } else {
                  accountSelected.value = accId;
                }
              }

              // Optional: auto filter on tap
              onChanedAutoTransactionStatus(context);
            },
            child: isSelected
                ? Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: AppSizes.p2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: AppSizes.p2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: content,
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: AppSizes.p2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: AppSizes.p2),
                    decoration: BoxDecoration(
                      color: AppColors.filterContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: content,
                  ));
      });
    }).toList(),
  );
}

Widget getHeader(context, text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: AppSizes.p12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        textStyle(
            context: context,
            text: text,
            fontsize: 16,
            c: AppColors.accentColor,
            fontWeight: FontWeight.w500),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.close_outlined,
            size: 20,
            color: AppColors.accentColor,
          ),
        )
      ],
    ),
  );
}

void showModalForPdfDownload(BuildContext context) {
  getPdgLoader.value = false;
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
          //height: MediaQuery.of(context).size.height / 2.4,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: AppColors.backgroundColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(child: Container()),
                getHeader(context, "Download Statement"),
                // const SizedBox(height: 20),
                getListItemListTile("30", "days", context),
                getListItemListTile("60", "days", context),
                getListItemListTile("6", "months", context),
                // getListItemListTile("1", "year", context),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                      onTap: () async {
                        getPdgLoader.value = true;
                        getPdf3(context, selectedValue, selectedValueType);
                      },
                      child: Obx(() => getPdgLoader.value
                          ? getspinner(context, "")
                          : getButton(context, "Continue"))),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget getListItemListTile(String no, String MorY, context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primaryColor, width: 0.2),
    ),
    child: Obx(() => ListTile(
          title: textStyle(
              context: context,
              text: no + " ${MorY}",
              fontsize: 15,
              fontWeight: FontWeight.w500),
          trailing: Radio<String>(
            value: no, // Assign a unique value for each radio button
            groupValue: selectedValue.value, // The currently selected value
            onChanged: (value) {
              selectedValue.value = value!;
              selectedValueType.value = MorY;
            },
          ),
        )),
  );
}

Widget getCheckBoxwithText(BuildContext context, String text) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: AppSizes.p4, horizontal: 7),
    child: Obx(() {
      bool isSelected = accountIdPdf.value == text;

      Widget content = Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p12, vertical: AppSizes.p4),
        child: textStyleImage(
            context: context,
            text: text,
            fontsize: 15,
            fontWeight: FontWeight.w500,
            c: isSelected ? AppColors.backgroundColor : AppColors.bg1),
      );

      return GestureDetector(
          onTap: () {
            accountIdPdf.value = isSelected ? "-" : text;
          },
          child: isSelected
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: content,
                )
              : Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: AppSizes.p2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: AppSizes.p2),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: content,
                ));
    }),
  );
}

Widget getCheckBoxwithText2(
    BuildContext context, String text, VoidCallback onTap) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: AppSizes.p6, horizontal: 4),
    child: Obx(() {
      bool isSelected = accountIdPdf.value == text;
      Widget content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Center(
          child: textStyleImage(
            context: context,
            text: text,
            fontsize: 14,
            fontWeight: FontWeight.w500,
            c: isSelected ? AppColors.backgroundColor : AppColors.bg1,
          ),
        ),
      );

      return GestureDetector(
        onTap: () {
          //  final tx = Get.find<TransactionController>();
          // Toggle selection
          accountIdPdf.value = isSelected ? "-" : text;

          // Update search text if Credit, Debit, or Cash
          if (accountIdPdf.value.toLowerCase() == "credit" ||
              accountIdPdf.value.toLowerCase() == "debit" ||
              accountIdPdf.value == "Cash") {
            searchTextController.value = accountIdPdf.value.toLowerCase();
            tnxSearchController.text = accountIdPdf.value.toLowerCase();

            // tx.searchController.text=accountIdPdf.value.toLowerCase();
          } else if (accountIdPdf.value == "-") {
            searchTextController.value = "";
            tnxSearchController.text = "";
            //  tx.searchController.text="";
          }

          // Apply filter and close dialog
          onChanedAutoTransactionStatus(context);
        },
        child: isSelected
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p12, vertical: AppSizes.p2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: content,
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p12, vertical: AppSizes.p2),
                decoration: BoxDecoration(
                  color: AppColors.filterContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: content,
              ),
      );
    }),
  );
}

Widget filterTransaction(context) {
  return Column(
    children: [
      Container(
        color: AppColors.newbg,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height /
            (bankAccountLinkedList.length <= 1 ? 18 : 20),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(width: AppSizes.w12),
            getCheckBoxwithText2(context, "Credit", () {
              onChanedAutoTransactionStatus(context);
              // Navigator.pop(context);
            }),
            getCheckBoxwithText2(context, "Debit", () {
              onChanedAutoTransactionStatus(context);
              // Navigator.pop(context);
            }),
            getCheckBoxwithText2(context, "Cash", () {
              onChanedAutoTransactionStatus(context);
              // Navigator.pop(context);
            }),
            bankAccountLinkedList.length >= 2
                ? Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: AppSizes.p4, horizontal: 2),
                    child: getBankAccountListForFilter(context, false))
                : const SizedBox.shrink(),

            Obx(
              () => GestureDetector(
                onTap: toggleAmountFilter,
                child: Container(
                  child: showAmountFilter.value
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: AppSizes.p6, horizontal: 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.p12, vertical: AppSizes.p4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Filter by Amount",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: showAmountFilter.value
                                      ? AppColors.backgroundColor
                                      : AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: AppSizes.p6, horizontal: 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: AppSizes.p2),
                          decoration: BoxDecoration(
                            color: AppColors.filterContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showAmountFilter.value)
                                const Icon(Icons.check,
                                    size: 18, color: Colors.green),
                              SizedBox(width: AppSizes.w4),
                              Text(
                                "Filter by Amount",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.w10),
            // --------- Date Button ---------
            Obx(
              () => GestureDetector(
                onTap: toggleDateFilter, // ✅ Whole container is tappable
                child: Container(
                  child: showDateFilter.value
                      ? Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: AppSizes.p6, horizontal: 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: AppSizes.p2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Filter by Date",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: showDateFilter.value
                                        ? AppColors.backgroundColor
                                        : AppColors.accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: AppSizes.p6, horizontal: 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: AppSizes.p2),
                          decoration: BoxDecoration(
                            color: AppColors.filterContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Filter by Date",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      Obx(() => showAmountFilter.value
          ? const AmountRangeField()
          : const SizedBox.shrink()),
      Obx(() => showDateFilter.value
          ? const DateRangeField()
          : const SizedBox.shrink()),
      // AmountRangeField(),
      // DateRangeField()
    ],
  );
}

// String getBankLogo() {
//   for (var bankAccount in bankAccountLinkedList) {
//     if (bankAccount['accountId'] == accountIdPdf.value) {
//       return bankAccount['bankLogo'];
//     }
//   }

//   return bankImage; // return null if no match found
// }

String getBankLogo() {
  for (var bankAccount in bankAccountLinkedList) {
    // bankAccount is BankAccountModel now
    if (bankAccount.accountId == accountIdPdf.value) {
      return bankAccount.bankLogo;
    }
  }

  return bankImage; // default if no match
}

String getDaysLeftInMonth() {
  final now = DateTime.now();
  final nextMonth = (now.month < 12)
      ? DateTime(now.year, now.month + 1, 1)
      : DateTime(now.year + 1, 1, 1);
  final lastDayOfMonth = nextMonth.subtract(const Duration(days: 1));
  final daysLeft = lastDayOfMonth.day - now.day;
  return '$daysLeft days left';
}

List<Map<String, dynamic>> getthelist() {
  final lowerSearch = searchTextController.value.toLowerCase();
  // final lowerSearch = searchController.text.toLowerCase();

  final filtered = customCategoryList.where((e) {
    final name = e['name']?.toString().toLowerCase() ?? '';
    return name.contains(lowerSearch);
  }).toList();

  return filtered.reversed.toList().cast<Map<String, dynamic>>();
}



const List<Map<String, dynamic>> reportOptions = [
  {
    'title': 'Helps us to understand the issue and look into it',
    'subtitle': 'Provide details about the problem',
    'isDescription': true
  },
  {'title': 'Not interested', 'subtitle': ''},
  {'title': 'Harassment or hateful speech', 'subtitle': ''},
  {'title': 'Self-harm or suicide', 'subtitle': ''},
  {'title': 'Adult content', 'subtitle': ''},
  {'title': 'False information or misleading', 'subtitle': ''},
  {'title': 'Spam', 'subtitle': ''},
];

getErrorBankLogo() => (context, error, stackTrace) => const Icon(
      Icons.account_balance,
      size: 30,
      color: AppColors.primaryColor,
    );

bool checkRangeofAmount(context, [bool f = true]) {
  double f1 =
      double.parse(minController.text.isNotEmpty ? minController.text : "0");
  double f2 =
      double.parse(maxController.text.isNotEmpty ? maxController.text : "0");
  if (f1 >= f2 && maxController.text.isNotEmpty) {
    if (f) snackBarCalledfail(context, SnackbarData().maxMinAmount);
    minController.text = "";
    maxController.text = "";
  }
  return f1 < f2;
}

bool getListIsValid(String s) {
  List sdc = ["credit", "debit", "cash"];
  return sdc.contains(s);
}

bool checkRangeofDate(BuildContext context, [bool f = true]) {
  String startDateText =
      startDateController.text.isNotEmpty ? startDateController.text : '';
  String endDateText =
      endDateController.text.isNotEmpty ? endDateController.text : '';
  if (startDateText.isEmpty || endDateText.isEmpty) {
    return true;
  }
  try {
    final DateFormat formatter = DateFormat('yyyy/MM/dd');
    final DateTime startDate = formatter.parse(startDateText);
    final DateTime endDate = formatter.parse(endDateText);

    if (endDate.isBefore(startDate) && endDateText.isNotEmpty) {
      if (f) {
        snackBarCalledfail(context, 'End date must be after start date');
      }
      startDateController.text = '';
      endDateController.text = '';
      return false;
    }
    return true;
  } catch (e) {
    if (f) {
      snackBarCalledfail(context, 'Invalid date format');
    }
    startDateController.text = '';
    endDateController.text = '';
    return false;
  }
}



String getCurrentWeek() {
  final now = DateTime.now().subtract(Duration(days: 7));
  final year = now.year;
  String s = '$year-W${now.weekOfYear.toString().padLeft(2, '0')}';
  return s;
}




final Map<String, int> monthNameToIndex = {
  'Jan': 0,
  'Feb': 1,
  'Mar': 2,
  'Apr': 3,
  'May': 4,
  'Jun': 5,
  'Jul': 6,
  'Aug': 7,
  'Sep': 8,
  'Oct': 9,
  'Nov': 10,
  'Dec': 11
};

void updateMonthLabels() {
  monthLabels.value = List.generate(12, (index) {
    return DateFormat('MMM').format(DateTime(selectedYear.value, index + 1, 1));
  });
}

int getDaysInMonthExpanded(int year, int month) {
  month = month.clamp(1, 12);
  return DateTime(year, month + 1, 0).day;
}

double getDouble(data) {
  return double.parse(data.toString());
}


String getNextDay(String endDate) {
  // Parse the input date string
  DateTime date = DateTime.parse(endDate);
  // Add one day
  DateTime nextDay = date.add(Duration(days: 1));
  // Return formatted as YYYY-MM-DD
  return nextDay.toIso8601String().split('T')[0];
}

List<String> getWeekDays() {
  return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}

List<String> getDaysInMonth(String yearMonth) {
  List<String> days = [];
  List<String> parts = yearMonth.split('-');
  if (parts.length != 2) return days;

  int year = int.tryParse(parts[0]) ?? 0;
  int month = int.tryParse(parts[1]) ?? 0;
  if (year == 0 || month == 0) return days;

  int daysInMonth = DateTime(year, month + 1, 0).day;

  for (int i = 1; i <= daysInMonth; i++) {
    days.add('${i.toString().padLeft(2, '0')}');
  }

  return days;
}



Widget manualTransactionButton(BuildContext context) {
  final colors = context.appPalette;
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ManualTransactionPage()),
      );
    },
    borderRadius: BorderRadius.circular(10),
    child: Container(
      // width: MediaQuery.sizeOf(context).width / 2.4,
      // height: MediaQuery.sizeOf(context).height / 21,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.blackColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.blackColor, width: 1),
        boxShadow: [AppShadows.soft],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
           const ResponsiveSvg(
              asset:HomeSvgs.cashTnxs,
              widthFactor: 16,
            ),
            const SizedBox(width: AppSizes.w8),
            Text(
              'Cash transactions',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 13,
                lineHeight: 1.0,
                color: colors.whiteColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget actionButtonForCashAndHistory({
  required BuildContext context,
  required String text,
  required String icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: MediaQuery.sizeOf(context).width / 2.4,
      height: MediaQuery.sizeOf(context).height / 21,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryColor,
          width: 1,
        ),
        boxShadow: [AppShadows.soft],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarProfileImageZero(
            url: icon,
            width: 5,
            height: 32,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 13,
              color: AppColors.accentColor,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget globalbackArrow() {
  return CustomStyledContainer(
    radius: 20,
    child: Builder(
      builder: (context) {
        final colors = context.appColors;
        return Padding(
          padding: EdgeInsets.all(AppSizes.p8),
          child: Icon(
            Icons.arrow_back,
            color: colors.onBackground,
            size: 24,
          ),
        );
      },
    ),
  );
}

class RotatingStopwatchIcon extends StatefulWidget {
  final double size;
  final Color color;

  const RotatingStopwatchIcon({
    Key? key,
    this.size = 26,
    this.color = AppColors.backgroundColor,
  }) : super(key: key);

  @override
  State<RotatingStopwatchIcon> createState() => _RotatingStopwatchIconState();
}

class _RotatingStopwatchIconState extends State<RotatingStopwatchIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // speed of rotation
    )..repeat(); // continuous rotation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// Stopwatch outline
          Icon(
            Icons.timer_outlined,
            size: widget.size,
            color: widget.color,
          ),

          /// Rotating hand
          AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: child,
              );
            },
            child: Container(
              width: 2,
              height: widget.size * 0.32,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
