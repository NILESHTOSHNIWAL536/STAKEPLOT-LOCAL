import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constants/app_theme_colors.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/font_manager.dart';
import '../Constants/theme_helper.dart';
import '../controllers/controllerManagement.dart';
import '../controllers/theme_controller.dart';

void showThemeSelectorModal(BuildContext context) {
  final ThemeController controller = ControllerManagement.themeController;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _ThemeSelectorSheet(controller: controller);
    },
  );
}

class _ThemeSelectorSheet extends StatelessWidget {
  final ThemeController controller;
  const _ThemeSelectorSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Appearance',
            style: FontManager().getTextStyle(
              context,
              fontSize: 18,
              lWeight: FontWeight.w700,
              color: colors.onBackground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose how Stakeplot looks to you',
            style: FontManager().getTextStyle(
              context,
              fontSize: 13,
              lWeight: FontWeight.w400,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          // Theme options
          Obx(() {
            final current = controller.themeMode.value;
            return Column(
              children: [
                _ThemeOptionTile(
                  icon: Icons.brightness_auto_rounded,
                  label: 'System Default',
                  description: 'Follows your device setting',
                  isSelected: current == ThemeMode.system,
                  colors: colors,
                  onTap: () {
                    controller.changeTheme(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _ThemeOptionTile(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Light',
                  description: 'Clean, bright interface',
                  isSelected: current == ThemeMode.light,
                  colors: colors,
                  onTap: () {
                    controller.changeTheme(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _ThemeOptionTile(
                  icon: Icons.nightlight_round,
                  label: 'Dark',
                  description: 'Easier on the eyes at night',
                  isSelected: current == ThemeMode.dark,
                  colors: colors,
                  onTap: () {
                    controller.changeTheme(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final AppThemeColors colors;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? colors.primary : colors.border;
    final bgColor = isSelected
        ? colors.primary.withOpacity(0.08)
        : colors.surfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withOpacity(0.15)
                    : colors.iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.secondaryText,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 15,
                      lWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? colors.primary : colors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 12,
                      lWeight: FontWeight.w400,
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Check indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Container(
                      key: const ValueKey('check'),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    )
                  : Container(
                      key: const ValueKey('empty'),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border, width: 1.5),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
