// ─── member_spend_amount.dart ─────────────────────────────────────────────────
// PATH: lib/Home_Screen/history/collections/trip/screens/member_spend_amount.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../backed_connections/apis_connect.dart';
import '../../../../../model/collections_model.dart';
import '../utils/app_theme_collections.dart';

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
          // ── TOTAL AMOUNT ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${totalAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.amountLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColorsForCollection.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Combined Amount',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColorsForCollection.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Members count pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColorsForCollection.primaryDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 14,
                      color: AppColorsForCollection.primaryDark,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${members.length} member${members.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColorsForCollection.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── MEMBERS HORIZONTAL SCROLL
          if (members.isNotEmpty)
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: members.length,
                padding: const EdgeInsets.only(left: 2, right: 2),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
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

  // Avatar gradient colors based on name initial
  List<Color> _getAvatarColors(String name) {
    final colors = [
      [const Color(0xFF2D2B5B), const Color(0xFF4B4D73)],
      [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
      [const Color(0xFF7C3AED), const Color(0xFFA78BFA)],
      [const Color(0xFFB45309), const Color(0xFFF59E0B)],
      [const Color(0xFF0369A1), const Color(0xFF38BDF8)],
      [const Color(0xFF9D174D), const Color(0xFFF472B6)],
    ];
    final idx = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final double spent = double.tryParse(member.amountSpend) ?? 0;
    final double total = double.tryParse(member.setAmount) ?? 0;
    final double progress = total == 0 ? 0 : (spent / total).clamp(0.0, 1.0);
    final bool isOver = spent > total && total > 0;
    final avatarColors = _getAvatarColors(member.name);

    return Container(
      width: 155,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOver ? const Color(0xFFFFDDDD) : Colors.grey.shade200,
          width: isOver ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── USER INFO ROW
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: avatarColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: avatarColors[0].withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  member.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── AMOUNT
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₹${spent.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isOver
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF1A1832),
                    letterSpacing: -0.3,
                  ),
                ),
                if (total > 0)
                  TextSpan(
                    text: '/₹${total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── PROGRESS BAR
          Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOver
                          ? [const Color(0xFFEF4444), const Color(0xFFFCA5A5)]
                          : avatarColors,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          if (isOver)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Over limit!',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
