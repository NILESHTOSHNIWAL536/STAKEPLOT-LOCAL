import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';

import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:flutter_application_code_stakeplot/repository/autopay_repository.dart';

import 'package:get/get.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/theme_helper.dart';
import '../../components/shared_utils.dart';

// Reusable Card Widget
class CardWidget extends StatelessWidget {
  final CardData card;
  final RxMap<String, bool> toggleStates;
  final Function(String, bool)? onToggleChanged;
  final Function(String)? onSetReminder;
  final BuildContext parentContext;
  final Function() onDataChanged;
  final int index;
  const CardWidget({
    required this.card,
    required this.toggleStates,
    required this.parentContext,
    required this.onDataChanged,
    this.onToggleChanged,
    this.onSetReminder,
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final screenSize = MediaQuery.of(context).size;
    final cardHeight = screenSize.height * 0.22;
    final fontScale = screenSize.width / 375;
    final padding = screenSize.width * 0.03;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.onBackground.withOpacity(0.06),
            blurRadius: 8.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title / Date / Amount row ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 16 * fontScale,
                          color: colors.onBackground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6 * fontScale),
                      Text(
                        card.date,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 12 * fontScale,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  card.amount.toString(),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w700,
                    fontSize: 16 * fontScale,
                    color: colors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10 * fontScale),

            // ── Frequency badge + Switch / Reminder ───────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * fontScale,
                        vertical: AppSizes.p4 * fontScale,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6 * fontScale),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          chatAvatartImage(
                            url: 'assets/icons/Home-page/frequency.svg',
                            height: 50 * fontScale,
                            width: 50 * fontScale,
                          ),
                          SizedBox(width: 4 * fontScale),
                          Text(
                            card.frequency,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 12 * fontScale,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (card.frequency.toLowerCase() == 'daily') ...[
                      SizedBox(width: 8 * fontScale),
                      Obx(() => Switch(
                            value: toggleStates[card.id] ?? card.isActive,
                            onChanged: (value) async {
                              toggleStates[card.id] = value;
                              onToggleChanged?.call(card.id, value);
                              final success =
                                  await addRecurringPayment(card.id, value);
                              if (success) {
                                snackBarCalled(parentContext,
                                    "Autopay status updated successfully");
                              } else {
                                toggleStates[card.id] = !value;
                                onToggleChanged?.call(card.id, !value);
                                snackBarCalled(parentContext,
                                    "Failed to update autopay status");
                              }
                            },
                            activeColor: colors.primary,
                            inactiveThumbColor: colors.secondaryText,
                            inactiveTrackColor: colors.border,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          )),
                    ],
                  ],
                ),
                if (card.frequency.toLowerCase() != 'daily' && card.isActive)
                  GestureDetector(
                    onTap: () => onSetReminder?.call(card.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * fontScale,
                        vertical: AppSizes.p4 * fontScale,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8 * fontScale),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        card.nextReminderAt != null
                            ? "Reminder: ${formatWhatsAppDate(card.nextReminderAt!)}"
                            : "Set Reminder",
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 11 * fontScale,
                          color: colors.secondaryText,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 10 * fontScale),

            // ── Occurrences label ─────────────────────────────────────────
            Text(
              "Occurrences",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 13 * fontScale,
                color: colors.secondaryText,
              ),
            ),
            SizedBox(height: 6 * fontScale),

            // ── Occurrence chips + Action buttons ─────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 4.0 * fontScale,
                    runSpacing: 4.0 * fontScale,
                    children: card.occuranceDate.isEmpty
                        ? [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8 * fontScale,
                                vertical: AppSizes.p4 * fontScale,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceVariant,
                                borderRadius:
                                    BorderRadius.circular(6 * fontScale),
                              ),
                              child: Text(
                                "No occurrences",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 10 * fontScale,
                                  color: colors.hintText,
                                ),
                              ),
                            ),
                          ]
                        : card.occuranceDate
                            .map(
                              (date) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8 * fontScale,
                                  vertical: AppSizes.p4 * fontScale,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  date,
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 10 * fontScale,
                                    color: colors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                SizedBox(width: 8 * fontScale),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (card.isActive || card.isDaily)
                      // ── "Added" chip → tap to remove ──────────────────
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: parentContext,
                            useRootNavigator: false,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: colors.dialogBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                "Remove Payment",
                                style: FontManager().getTextStyle(
                                  ctx,
                                  lWeight: FontWeight.w600,
                                  fontSize: 17 * fontScale,
                                  color: colors.onBackground,
                                ),
                              ),
                              content: Text(
                                "Do you want to remove this recurring payment?",
                                style: FontManager().getTextStyle(
                                  ctx,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14 * fontScale,
                                  color: colors.secondaryText,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    "Cancel",
                                    style: FontManager().getTextStyle(
                                      ctx,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14 * fontScale,
                                      color: colors.secondaryText,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    "Remove",
                                    style: FontManager().getTextStyle(
                                      ctx,
                                      lWeight: FontWeight.w600,
                                      fontSize: 14 * fontScale,
                                      color: colors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final success = card.isDaily
                                ? await addRecurringPaymentForDaily(
                                    card.id, false)
                                : await addRecurringPayment(card.id, false);
                            snackBarCalled(
                              parentContext,
                              success
                                  ? "Removed successfully"
                                  : "Failed to remove",
                            );
                            if (success) onDataChanged();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * fontScale,
                            vertical: AppSizes.p4 * fontScale,
                          ),
                          decoration: BoxDecoration(
                            color: colors.credit.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8 * fontScale),
                          ),
                          child: Text(
                            "Added",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 13 * fontScale,
                              lWeight: FontWeight.w600,
                              color: colors.credit,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      // ── "+ Add" button ─────────────────────────────────
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: parentContext,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: colors.dialogBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                "Add Payment",
                                style: FontManager().getTextStyle(
                                  ctx,
                                  lWeight: FontWeight.w600,
                                  fontSize: 17 * fontScale,
                                  color: colors.onBackground,
                                ),
                              ),
                              content: Text(
                                "Are you sure you want to add this recurring payment?",
                                style: FontManager().getTextStyle(
                                  ctx,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14 * fontScale,
                                  color: colors.secondaryText,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    "Cancel",
                                    style: FontManager().getTextStyle(
                                      ctx,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14 * fontScale,
                                      color: colors.secondaryText,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    "Add",
                                    style: FontManager().getTextStyle(
                                      ctx,
                                      lWeight: FontWeight.w600,
                                      fontSize: 14 * fontScale,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            if (card.frequency.toLowerCase() == 'daily') {
                              final success = await addRecurringPaymentForDaily(
                                  card.id, true);
                              snackBarCalled(
                                parentContext,
                                success
                                    ? "Added successfully"
                                    : "Failed to add",
                              );
                              if (success) onDataChanged();
                            } else {
                              onSetReminder?.call(card.id);
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p4 * fontScale,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "+ Add",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 13 * fontScale,
                              lWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6 * fontScale),
                      // ── "Ignore" button ────────────────────────────────
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: parentContext,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: colors.dialogBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                "Ignore Payment",
                                style: FontManager().getTextStyle(
                                  ctx,
                                  lWeight: FontWeight.w600,
                                  fontSize: 17 * fontScale,
                                  color: colors.onBackground,
                                ),
                              ),
                              content: Text(
                                "Are you sure you want to delete this recurring payment?",
                                style: FontManager().getTextStyle(
                                  ctx,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14 * fontScale,
                                  color: colors.secondaryText,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    "Cancel",
                                    style: FontManager().getTextStyle(
                                      ctx,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14 * fontScale,
                                      color: colors.secondaryText,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    "Delete",
                                    style: FontManager().getTextStyle(
                                      ctx,
                                      lWeight: FontWeight.w600,
                                      fontSize: 14 * fontScale,
                                      color: colors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final success =
                                await ignoreRecurringPayment(card.id);
                            snackBarCalled(
                              parentContext,
                              success
                                  ? "Deleted successfully"
                                  : "Failed to delete autopay",
                            );
                            if (success) onDataChanged();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p4 * fontScale,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Ignore",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 13 * fontScale,
                              lWeight: FontWeight.w500,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
