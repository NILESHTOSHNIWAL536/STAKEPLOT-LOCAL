import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:get/get.dart';
import '../../../Constants/app_styles.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';
import '../../../Constants/theme_helper.dart';
import '../history_button.dart';
import 'collection_setting.dart';
import 'personal-collections.dart';
import 'trip/screens/select_transactions_sheet.dart';
import 'trip/screens/shared_dashboard_screen.dart';

void openSelectTransactions(context, type) {
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
    return Obx(() {
      final hasTransactions = collectionsController
              .collectionDetails.value?.transactions?.isNotEmpty ??
          false;

      if (hasTransactions && type.toUpperCase() == "PERSONAL") {
        return const CollectionSummarySection();
      }

      return WillPopScope(
        onWillPop: () async {
          navToHistoryReplacment(context);
          return true;
        },
        child: Scaffold(
          backgroundColor: context.appColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _appBar(context),
                Expanded(
                  child: collectionsController.splitsList.isNotEmpty
                      ? (type.toUpperCase() == "SHARED"
                          ? SharedCollectionDashboard()
                          : _transactionsUI(context))
                      : emptyTransactionsUI(context, type),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  /// ---------------- APP BAR ----------------
  Widget _appBar(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.appBarBackground,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p2),
        child: Row(
          children: [
            /// BACK
            InkWell(
              onTap: () => {navToHistoryReplacment(context)},
              child: CircleAvatar(
                backgroundColor: colors.surface,
                child: Icon(Icons.arrow_back,
                    size: 18, color: colors.onBackground),
              ),
            ),

            const Spacer(),

            /// TITLE
            Container(
              // color: AppColors.bg1,
              width: MediaQuery.of(context).size.width / 2,
              alignment: Alignment.center,
              child: Obx(() => Text(
                    collectionsController
                            .collectionDetails.value?.collection.name ??
                        "Collection",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 18,
                      lWeight: FontWeight.w600,
                      color: colors.onBackground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
            ),

            const Spacer(),

            /// FILTER
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p8, vertical: AppSizes.p2),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  _iconButton(HomePageIcons.filterOn),

                  VerticalDashDivider(
                    height: 30,
                    color: colors.border,
                    dashGap: 0,
                  ),

                  /// SETTINGS
                  InkWell(
                      onTap: () {
                        // Open settings page
                        // (collectionsController.currentUser?.role == "VIEW")
                        //     ? snackBarCalledfail(
                        //         context, "You have view only access")
                        //     :
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
          ),
          SizedBox(width: AppSizes.w12),
          _summaryCard(
            context,
          ),
        ],
      ),
    );
  }

  Widget _topItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double amount,
    required bool isCredit,
  }) {
    final colors = context.appColors;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ICON + TITLE
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.iconBackground,
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 13,
                    lWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            /// SUBTEXT
            Text(
              subtitle,
              style: FontManager().getTextStyle(
                context,
                fontSize: 11,
                color: colors.secondaryText,
              ),
            ),

            const SizedBox(height: 6),

            /// AMOUNT
            Text(
              "₹${amount.toStringAsFixed(0)}",
              style: FontManager().getTextStyle(
                context,
                fontSize: 20,
                lWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final colors = context.appColors;
    final data = collectionsController.collectionDetails.value;

    final totalCredit = data?.collection.totalCredit ?? 0;

    final totalDebit = data?.collection.totalDebit ?? 0;

    final outstanding = data?.collection.outStandingAmount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            /// 🔥 TOP (RECEIVED + SPENT)
            Row(
              children: [
                _topItem(
                  context,
                  title: "Received",
                  subtitle: "10 credits",
                  amount: totalCredit,
                  isCredit: true,
                ),

                /// Divider
                Container(
                  height: 70,
                  width: 1,
                  color: colors.divider,
                ),

                _topItem(
                  context,
                  title: "Spent",
                  subtitle: "10 debits",
                  amount: totalDebit,
                  isCredit: false,
                ),
              ],
            ),

            /// Bottom divider
            Divider(color: colors.divider, height: 1),

            /// 🔥 OUTSTANDING
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Outstanding Amount",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 13,
                      color: colors.secondaryText,
                    ),
                  ),
                  Text(
                    "₹ ${outstanding.toStringAsFixed(2)}",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 14,
                      lWeight: FontWeight.w600,
                      color: colors.onSurface,
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

  Widget _transactionsUI(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.background,
      child: Column(
        children: [
          _appBar(context),
          CollectionSummarySection(),
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
          width: 40,
          height: 40,
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
  final colors = context.appColors;
  return Container(
    color: colors.background,
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
                    color: colors.onBackground,
                  ),
                ),

                SizedBox(height: AppSizes.h8),

                Text(
                  "Start tracking your spending today and take control of your finances ✨",
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 14,
                    color: colors.secondaryText,
                  ),
                ),

                SizedBox(height: AppSizes.h30),

                /// ADD TRANSACTION BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // open add transaction flow
                      openSelectTransactions(context, splitType);
                    },
                    child: Text(
                      "+ Add Transactions",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 16,
                        lWeight: FontWeight.w500,
                        color: Colors.white,
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
