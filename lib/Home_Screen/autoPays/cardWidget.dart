import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:flutter_application_code_stakeplot/repository/autopay_repository.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final cardHeight = screenSize.height * 0.2; // Responsive card height
    final fontScale = screenSize.width / 375; // Base font scaling
    final padding = screenSize.width * 0.03; // Responsive padding
    const List<Color> _autoPayColors = [
      AppColors.autoPay1,
      AppColors.autoPay2,
      AppColors.autoPay3,
      AppColors.autoPay4,
      AppColors.autoPay5,
    ];
    Color _getColorForIndex() {
      return _autoPayColors[index % _autoPayColors.length];
    }

    
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: _getColorForIndex(),
        borderRadius: BorderRadius.circular(16 * fontScale),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          fontSize: 14 * fontScale,
                          color: AppColors.accentColor,
                        ),
                      ),
                      SizedBox(height: 4 * fontScale),
                      Text(
                        card.date,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 10 * fontScale,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  card.amount.toString(),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 16 * fontScale,
                    color: AppColors.accentColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4 * fontScale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8 * fontScale, vertical: 4 * fontScale),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2 * fontScale),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          chatAvatartImage(
                            url: 'assets/icons/Home-page/frequency.svg',
                            height: 50 * fontScale,
                            width: 50 * fontScale,
                          ),
                          SizedBox(width: 2 * fontScale),
                          Text(
                            card.frequency,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 12 * fontScale,
                              color: AppColors.primaryColor,
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
                            activeColor: AppColors.primaryColor,
                            inactiveThumbColor: Colors.white70,
                            inactiveTrackColor: AppColors.backgroundColor.withOpacity(0.3),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          )),
                    ],
                  ],
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  if (card.isActive || card.isDaily)
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: parentContext,
                          useRootNavigator: false,
                          builder: (context) => AlertDialog(
                            title: Text(
                              "Remove Payment",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 18 * fontScale,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            content: Text(
                              "Do you want to remove this recurring payment?",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w500,
                                fontSize: 16 * fontScale,
                                color: AppColors.accentColor,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 14 * fontScale,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  "Remove",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 14 * fontScale,
                                    color: AppColors.primaryColor,
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
                            horizontal: 8 * fontScale, vertical: 4 * fontScale),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10 * fontScale),
                        ),
                        child: Text(
                          "Added",
                          style: TextStyle(
                              fontSize: 14 * fontScale, color: AppColors.backgroundColor),
                        ),
                      ),
                    )
                  else ...[
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: parentContext,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.backgroundColor,
                            title: Text(
                              "Add Payment",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 18 * fontScale,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to add this recurring payment?",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w500,
                                fontSize: 16 * fontScale,
                                color: AppColors.accentColor,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 14 * fontScale,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  "Add",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w600,
                                    fontSize: 14 * fontScale,
                                    color: AppColors.primaryColor,
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
                              success ? "Added successfully" : "Failed to add ",
                            );
                            if (success) onDataChanged();
                          } else {
                            onSetReminder?.call(card.id);
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12 * fontScale,
                            vertical: 4 * fontScale),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20 * fontScale),
                            topRight: Radius.circular(20 * fontScale),
                          ),
                        ),
                        child: Text(
                          "+",
                          style: TextStyle(
                              fontSize: 18 * fontScale, color: AppColors.backgroundColor),
                        ),
                      ),
                    ),
                    SizedBox(height: 2 * fontScale),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: parentContext,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.backgroundColor,
                            title: Text(
                              "Ignore Payment",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 18 * fontScale,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to delete this recurring payment?",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w500,
                                fontSize: 16 * fontScale,
                                color: AppColors.accentColor,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 14 * fontScale,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  "delete",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w600,
                                    fontSize: 14 * fontScale,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final success = await ignoreRecurringPayment(card.id);
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
                            horizontal: 12.5 * fontScale,
                            vertical: 4 * fontScale),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20 * fontScale),
                            bottomRight: Radius.circular(20 * fontScale),
                          ),
                        ),
                        child: Text(
                          "x",
                          style: TextStyle(
                              fontSize: 18 * fontScale, color: AppColors.backgroundColor),
                        ),
                      ),
                    ),
                  ],
                ])
              ],
            ),
            SizedBox(height: 4 * fontScale),
            Text(
              "Occurrences",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 14 * fontScale,
                color: AppColors.bg1,
              ),
            ),
            SizedBox(height: 4 * fontScale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  vertical: 4 * fontScale),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(4 * fontScale),
                              ),
                              child: Text(
                                "No occurrences",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 10 * fontScale,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ]
                        : card.occuranceDate
                            .map((date) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8 * fontScale,
                                      vertical: 4 * fontScale),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundColor.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(8 * fontScale),
                                  ),
                                  child: Text(
                                    date,
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w400,
                                      fontSize: 10 * fontScale,
                                      color: AppColors.backgroundColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                  ),
                ),
                card.frequency.toLowerCase() == 'daily'
                    ? SizedBox.shrink()
                    : !card.isActive
                        ? SizedBox.shrink()
                        : GestureDetector(
                            onTap: () => onSetReminder?.call(card.id),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8 * fontScale,
                                  vertical: 6 * fontScale),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(10 * fontScale),
                              ),
                              child: Text(
                                card.nextReminderAt != null
                                    ? "Upcoming reminder: ${formatWhatsAppDateWithoutTime(card.nextReminderAt!)}"
                                    : "Set Reminder",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 12 * fontScale,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
