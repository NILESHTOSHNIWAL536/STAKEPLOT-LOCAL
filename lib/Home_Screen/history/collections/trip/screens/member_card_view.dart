import 'package:flutter/material.dart';

import '../../../../../Constants/colors.dart';
import '../../../../../model/collections_model.dart';

class MemberSpendCardNew extends StatelessWidget {
  final MemberModel member;
  final double totalAmount;
  final List<BalanceModel> balances;

  const MemberSpendCardNew({
    required this.member,
    required this.totalAmount,
    required this.balances,
  });

  @override
  Widget build(BuildContext context) {
    final memberBalance = balances
        .where((b) => b.userId == member.userId)
        .fold(0.0, (sum, b) => sum + b.balance);

    final pct =
        totalAmount > 0 ? (memberBalance / totalAmount).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg5, // light card inside
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 👤 Avatar + Name
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryColorOpacity,
                child: Text(
                  member.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fontcolor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 💰 Amount
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${memberBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.fontcolor,
                  ),
                ),
                TextSpan(
                  text: '/${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.newfontcolor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// 📊 Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.newgrey,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
