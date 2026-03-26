import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import '../../../Constants/app_styles.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';
import '../transactionHistoryScreen.dart';
import 'trip/screens/trip_dashboard_screen.dart';

class CollectionDetailsPage extends StatelessWidget {
  final String title;
  final bool hasTransactions;
  CollectionDetailsPage(
      {super.key, required this.title, required this.hasTransactions});

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
                  ? TripDashboardScreen()
                  : _emptyTransactionsUI(context),
            ),
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
  Widget _emptyTransactionsUI(BuildContext context) {
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
}

class CollectionSettingsModal extends StatefulWidget {
  const CollectionSettingsModal({super.key});

  @override
  State<CollectionSettingsModal> createState() =>
      _CollectionSettingsModalState();
}

class _CollectionSettingsModalState extends State<CollectionSettingsModal> {
  bool alertEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// DRAG / CLOSE
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  "Collection Settings",
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 16,
                    lWeight: FontWeight.w700,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.w40),
            ],
          ),

          SizedBox(height: AppSizes.h12),

          /// ALERT SECTION
          _alertCard(context),

          SizedBox(height: AppSizes.h12),
          _simpleTile(
            context,
            icon: Icons.file_upload_rounded,
            title: "Export Transactions",
            onTap: () {},
          ),

          _simpleTile(
            context,
            icon: Icons.edit,
            title: "Rename Collection",
            onTap: () {},
          ),

          _simpleTile(
            context,
            icon: Icons.access_time_filled,
            title: "Edit Duration Range",
            onTap: () {},
          ),

          SizedBox(height: AppSizes.h6),

          _dangerTile(
            context,
            icon: Icons.close,
            title: "Close Collection",
            onTap: () {},
          ),

          _dangerTile(
            context,
            icon: Icons.delete_rounded,
            title: "Delete Collection",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// ---------------- ALERT CARD ----------------
  Widget _alertCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Alert for Certain Amount",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 14,
                    lWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: alertEnabled,
                inactiveThumbColor: AppColors.backgroundColor,
                inactiveTrackColor: AppColors.border,
                activeColor: AppColors.primaryColor,
                onChanged: (v) {
                  setState(() => alertEnabled = v);
                },
              ),
            ],
          ),
          SizedBox(height: AppSizes.h6),
          Text(
            "Notify me when any transaction exceeds ₹[amount] in this collection.",
            style: FontManager().getTextStyle(
              context,
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
          if (alertEnabled) ...[
            SizedBox(height: AppSizes.h10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                hintText: "Enter amount threshold",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ---------------- NORMAL TILE ----------------
  Widget _simpleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.p6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.border,
          child: Icon(icon, size: 18, color: AppColors.primaryColor),
        ),
        title: Text(
          title,
          style: FontManager().getTextStyle(
            context,
            fontSize: 14,
            lWeight: FontWeight.w500,
            color: AppColors.accentColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  /// ---------------- DANGER TILE ----------------
  Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.p6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.redColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.redColor.withOpacity(0.1),
          child: Icon(icon, size: 18, color: AppColors.redColor),
        ),
        title: Text(
          title,
          style: FontManager().getTextStyle(
            context,
            fontSize: 14,
            lWeight: FontWeight.w500,
            color: AppColors.redColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
