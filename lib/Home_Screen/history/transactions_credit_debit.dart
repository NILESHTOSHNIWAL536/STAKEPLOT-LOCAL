import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_shadows.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/shared_utils.dart';
import '../../finance_screen/Budgets/Budget.dart';

class TransactionCreditDebitCard extends StatefulWidget {
  const TransactionCreditDebitCard({super.key});

  @override
  State<TransactionCreditDebitCard> createState() =>
      _TransactionCreditDebitCardState();
}

class _TransactionCreditDebitCardState
    extends State<TransactionCreditDebitCard> {
  bool isWeekSelected = true;

  String get credits => isWeekSelected
      ? lastWeekjson['credit'].toString()
      : lastmonthjson['credit'].toString();

  String get debits => isWeekSelected
      ? lastWeekjson['debit'].toString()
      : lastmonthjson['debit'].toString();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p12, vertical: AppSizes.p12),
      margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.p12, vertical: AppSizes.p12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.onBackground.withOpacity(0.08),
            blurRadius: 4, // Equivalent to box-shadow: 0 0 4px 0;
            offset: Offset(0, 0), // Equivalent to box-shadow: 0 0 4px 0;
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textStyle(
                context: context,
                text: 'Amount',
                fontsize: 14,
                c: colors.onSurface,
                fontWeight: FontWeight.w400,
              ),
              _weekMonthToggle(),
            ],
          ),

          SizedBox(height: AppSizes.h16),

          /// 🔹 CREDIT / DEBIT ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _amountBlock(
                context,
                value: '₹${formatMoneyIndian(credits)}',
                label: 'Credited',
              ),
              _amountBlock(
                context,
                value: '₹${formatMoneyIndian(debits)}',
                label: 'Debited',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 TOGGLE BUTTON
  Widget _weekMonthToggle() {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          _toggleItem('Week', isWeekSelected, () {
            setState(() => isWeekSelected = true);
          }),
          SizedBox(width: AppSizes.w4),
          _toggleItem('Monthly', !isWeekSelected, () {
            setState(() => isWeekSelected = false);
          }),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, bool selected, VoidCallback onTap) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p14, vertical: AppSizes.p6),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [if (selected) AppShadows.soft],
        ),
        child: textStyle(
          context: context,
          text: text,
          fontsize: 14,
          c: selected ? Colors.white : colors.secondaryText,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// 🔹 CREDIT / DEBIT BLOCK
  Widget _amountBlock(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    final colors = context.appColors;
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 2.3,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textStyle(
            context: context,
            text: value,
            fontsize: 14,
            c: colors.primary,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(width: AppSizes.w6),
          textStyle(
            context: context,
            text: label,
            fontsize: 13,
            c: colors.secondaryText,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
