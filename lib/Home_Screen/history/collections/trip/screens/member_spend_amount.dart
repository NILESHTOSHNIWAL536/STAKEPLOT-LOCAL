import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../backed_connections/apis_connect.dart';
import '../../../../../model/collections_model.dart';
import '../utils/app_theme.dart';

class MembersSpendSection extends StatelessWidget {
  const MembersSpendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = collectionsController.collectionDetails.value;

      if (details == null) return const SizedBox();

      final members = details.members;
      final totalAmount = details.collection.totalAmount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 💰 TOTAL AMOUNT
          Text(
            '₹${totalAmount.toStringAsFixed(0)}',
            style: AppTextStyles.amountLarge.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Combined Amount',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),

          const SizedBox(height: 16),

          /// 👥 MEMBERS SCROLLER
          if (members.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: members.length,
                padding: const EdgeInsets.only(left: 2),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final m = members[i];
                  return MemberSpendCardNew(member: m);
                },
              ),
            ),
        ],
      );
    });
  }
}

class MemberSpendCardNew extends StatelessWidget {
  final MemberModel member;

  const MemberSpendCardNew({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final double spent = double.tryParse(member.amountSpend) ?? 0;
    final double total = double.tryParse(member.setAmount) ?? 0;

    final progress = total == 0 ? 0 : (spent / total).clamp(0.0, 1.0);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 👤 USER INFO
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueGrey,
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : "U",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  member.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 💰 AMOUNT
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: spent.toStringAsFixed(0),
                  style: AppTextStyles.amountMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: "/${total.toStringAsFixed(0)}",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// 📊 PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: spent / total,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                spent > total ? AppColors.errorRed : Colors.indigo.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
