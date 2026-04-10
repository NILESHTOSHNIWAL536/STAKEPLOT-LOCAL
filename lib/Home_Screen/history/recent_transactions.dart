import 'package:flutter/material.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';
import '../../Constants/colors.dart';
import 'transaction_history.dart';

class RecentTransactionsScreen extends StatelessWidget {
  const RecentTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          _header(context),
          _spendingSection(context),
          _statsRow(context),
          _transactionsTitle(context),
          Expanded(
            child: TransactionHistory(
              isYearView: false,
              isflag: true,
              showIcon: false,
              expandedPage: false,
              fromAutoPay: false,
            ), // <-- replace later
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.newbg,
        borderRadius:  BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios,
                      size: 18, color: AppColors.accentColor),
                ),
                
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.77,
                  
                  child: Center(
                    child: Text(
                      "Recent Transactions",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 18,
                        lWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.h8),
            Center(
              child: Text(
                "Fetched on 24-12-2024, 8:00 PM",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 12,
                  lWeight: FontWeight.w400,
                  color: AppColors.accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SPENDING SECTION ----------------
  Widget _spendingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p20),
      child: Column(
        children: [
          Text(
            "Spent",
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              lWeight: FontWeight.w400,
              color: AppColors.accentColor,
            ),
          ),
          SizedBox(height: AppSizes.h6),
          Text(
            "₹63,250.00",
            style: FontManager().getTextStyle(
              context,
              fontSize: 28,
              lWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward,
                    size: 14, color: Colors.green),
                SizedBox(width: AppSizes.w6),
                Text(
                  "8.2% below your usual spend",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    lWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- STATS ROW ----------------
  Widget _statsRow(BuildContext context) {
    return const Padding(
      padding:  EdgeInsets.symmetric(horizontal: AppSizes.p20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:  [
          _StatItem(title: "Transactions", value: "10"),
          _StatItem(title: "Debit", value: "₹1500"),
          _StatItem(title: "Credit", value: "₹1500"),
        ],
      ),
    );
  }

  // ---------------- TRANSACTIONS TITLE ----------------
  Widget _transactionsTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Transactions",
          style: FontManager().getTextStyle(
            context,
            fontSize: 16,
            lWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }


  
}
// ---------------- STAT ITEM ----------------
class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: FontManager().getTextStyle(
            context,
            fontSize: 12,
            lWeight: FontWeight.w400,
            color: AppColors.accentColor,
          ),
        ),
        SizedBox(height: AppSizes.h6),
        Text(
          value,
          style: FontManager().getTextStyle(
            context,
            fontSize: 14,
            lWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
