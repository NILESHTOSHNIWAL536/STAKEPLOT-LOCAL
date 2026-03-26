// ─── widgets/common_widgets.dart ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';

// ── Avatar ────────────────────────────────────────────────────────────────────
class MemberAvatar extends StatelessWidget {
  final TripMember member;
  final double size;
  final bool showBorder;

  const MemberAvatar({
    super.key,
    required this.member,
    this.size = 40,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: member.avatarColor,
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Center(
        child: Text(
          member.avatarInitial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Category Tag ──────────────────────────────────────────────────────────────
class CategoryTag extends StatelessWidget {
  final String label;
  const CategoryTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }
}

// ── Member Tag (dark pill with name) ──────────────────────────────────────────
class MemberPill extends StatelessWidget {
  final String name;
  final Color color;
  const MemberPill({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Transaction Card ──────────────────────────────────────────────────────────
class TransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final bool showCheckbox;

  RxBool flag = false.obs;

  TransactionCard({
    super.key,
    required this.tx,
    this.showCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () {
            if (collectionsController.selectedTransactions.contains(tx.id)) {
              collectionsController.selectedTransactions.remove(tx.id);
              flag.value = false;
            } else {
              collectionsController.selectedTransactions.add(tx.id);
              flag.value = true;
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border:
                  collectionsController.selectedTransactions.contains(tx.id) &&
                          showCheckbox
                      ? Border.all(color: AppColors.primaryBlue, width: 1.5)
                      : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (showCheckbox) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: flag.value
                          ? AppColors.primaryDark
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: flag.value
                            ? AppColors.primaryDark
                            : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: flag.value
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                ],
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.north_east,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.narration, style: AppTextStyles.labelBold),
                      const SizedBox(height: 2),
                      Text(formatWhatsAppDate(tx.transactionTimestamp),
                          style: AppTextStyles.bodySmall),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CategoryTag(label: tx.category),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.group,
                            size: 14,
                            color: AppColors.textLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-₹${tx.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.amountMedium.copyWith(
                        color: AppColors.errorRed,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (showCheckbox)
                      const Icon(
                        Icons.bookmark_border,
                        size: 18,
                        color: AppColors.textLight,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

// ── Fixed Bill Card ───────────────────────────────────────────────────────────
class FixedBillCard extends StatelessWidget {
  final FixedBill bill;
  const FixedBillCard({super.key, required this.bill});

  IconData _iconFor(String key) {
    switch (key) {
      case 'electricity':
        return Icons.lightbulb_outline;
      case 'rent':
        return Icons.home_outlined;
      case 'coffee':
        return Icons.coffee_outlined;
      case 'internet':
        return Icons.wifi_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = bill.status == BillStatus.paid;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tagBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconFor(bill.iconKey),
              size: 20,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.title, style: AppTextStyles.labelBold),
                const SizedBox(height: 2),
                Text(bill.dueDate, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${bill.amount.toStringAsFixed(0)}',
                style: AppTextStyles.amountMedium,
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid ? AppColors.paidBadge : AppColors.pendingBadge,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPaid
                        ? AppColors.successGreen
                        : AppColors.warningOrange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.heading3),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryDark),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                label,
                style: AppTextStyles.labelBold,
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: onPressed != null
                    ? AppColors.primaryDark
                    : AppColors.textLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}
