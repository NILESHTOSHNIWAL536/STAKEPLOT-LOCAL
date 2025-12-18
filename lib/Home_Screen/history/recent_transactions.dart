import 'package:flutter/material.dart';
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
      decoration: BoxDecoration(
        color: AppColors.newbg,
        borderRadius: const BorderRadius.vertical(
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
                  child: Icon(Icons.arrow_back_ios,
                      size: 18, color: AppColors.accentColor),
                ),
                const SizedBox(width: 50),
                Text(
                  "Recent Transactions",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 18,
                    lWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 20),
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
          const SizedBox(height: 6),
          Text(
            "₹63,250.00",
            style: FontManager().getTextStyle(
              context,
              fontSize: 28,
              lWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward,
                    size: 14, color: Colors.green),
                const SizedBox(width: 6),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
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

  // ---------------- PLACEHOLDER LIST ----------------
  Widget _yourTransactionsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.accentColor.withOpacity(0.3)),
                ),
                child: Icon(Icons.north_east,
                    color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Meena",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 14,
                        lWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "25 Oct • Food",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 12,
                        lWeight: FontWeight.w400,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "- ₹15.00",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        );
      },
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
        const SizedBox(height: 6),
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
