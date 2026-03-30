import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import '../../../Constants/app_styles.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';
import '../transactionHistoryScreen.dart';
import 'collection_setting.dart';
import 'group_collections_page.dart';
import 'trip/screens/select_transactions_sheet.dart';
import 'trip/screens/trip_dashboard_screen.dart';

void _openSelectTransactions(context, type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SelectTransactionsSheet(splitType: type),
  );
}

class CollectionDetailsPage extends StatelessWidget {
  final String title;
  final bool hasTransactions;
  final String type;
  CollectionDetailsPage(
      {super.key,
      required this.title,
      required this.hasTransactions,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.border,
      body: SafeArea(
        child: Column(
          children: [
            // _appBar(context),
            Expanded(
              child: hasTransactions
                  ? (type == "SHARED"
                      ? TripDashboardScreen()
                      : _transactionsUI(context))
                  : emptyTransactionsUI(context, type),
            )
          ],
        ),
      ),
    );
  }

  /// ---------------- APP BAR ----------------
  Widget _appBar(BuildContext context) {
    return Container(
      color: AppColors.newbg,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p12),
        child: Row(
          children: [
            /// BACK
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: AppColors.backgroundColor,
                child: Icon(Icons.arrow_back,
                    size: 18, color: AppColors.accentColor),
              ),
            ),

            const Spacer(),

            /// TITLE
            Text(
              title,
              style: FontManager().getTextStyle(
                context,
                fontSize: 18,
                lWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            /// FILTER
            Container(
              padding: const EdgeInsets.all(AppSizes.p8),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _iconButton(HomePageIcons.filterOn),

                  VerticalDashDivider(
                    height: 30,
                    color: AppColors.border,
                    dashGap: 0,
                  ),

                  /// SETTINGS
                  GestureDetector(
                      onTap: () {
                        // Open settings page
                        showCollectionSettingsModal(context);
                      },
                      child: _iconButton(HomePageIcons.settings)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCollectionSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => const CollectionSettingsModal(),
    );
  }

  Widget _summarySection(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p12),
      child: Row(
        children: [
          _summaryCard(
            context,
            title: "Total Spent",
            amount: "₹12,450",
            bgColor: AppColors.bg5,
            isSpent: true,
          ),
          SizedBox(width: AppSizes.w12),
          _summaryCard(
            context,
            title: "Remaining",
            amount: "₹5,550",
            bgColor: AppColors.backgroundColor,
            isSpent: false,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required bool isSpent,
    required String title,
    required String amount,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p14),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryColor,
              radius: 14,
              child: Icon(
                isSpent ? Icons.arrow_downward : Icons.arrow_upward,
                size: 18,
                color: AppColors.backgroundColor,
              ),
            ),
            SizedBox(height: AppSizes.h6),
            Text(
              amount,
              style: FontManager().getTextStyle(
                context,
                fontSize: 24,
                lWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSizes.h6),
            Text(
              title,
              style: FontManager().getTextStyle(
                context,
                fontSize: 13,
                color: isSpent ? AppColors.creditColor : AppColors.debitColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionsUI(BuildContext context) {
    return Container(
      color: AppColors.border,
      child: Column(
        children: [
          _appBar(context),
          _summarySection(context),
          Container(
            height: MediaQuery.sizeOf(context).height / 1.43,
            color: AppColors.border,
            child: TransactionHistoryScreen(
              isFromCollection: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _iconButton(String asset) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p8),
      child: Center(
        child: AvatarProfileImageZero(
          url: asset,
          width: 50,
          height: 50,
        ),
      ),
    );
  }

  /// ---------------- EMPTY STATE ----------------
}

Widget emptyTransactionsUI(
  BuildContext context,
  String splitType,
) {
  return Container(
    color: AppColors.border,
    child: Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /// SVG ILLUSTRATION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AvatarProfileImage(
                  url: HomePageIcons.noTransactionsInCollection,
                  width: 3,
                  height: 6.5),
              AvatarProfileImage(
                  url: HomePageIcons.noTransactionsInCollection,
                  width: 3,
                  height: 6.5)
            ],
          ),

          SizedBox(height: AppSizes.h30),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: AppSizes.p30),
            child: Column(
              children: [
                AvatarProfileImage(
                    url: HomePageIcons.noTransactionsInCollection2,
                    width: 2,
                    height: 6),

                Text(
                  "No transactions yet!",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 20,
                    lWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: AppSizes.h8),

                Text(
                  "Start tracking your spending today and take control of your finances ✨",
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),

                SizedBox(height: AppSizes.h30),

                /// ADD TRANSACTION BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // open add transaction flow
                      _openSelectTransactions(context, splitType);
                    },
                    child: Text(
                      "+ Add Transactions",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 16,
                        lWeight: FontWeight.w500,
                        color: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
