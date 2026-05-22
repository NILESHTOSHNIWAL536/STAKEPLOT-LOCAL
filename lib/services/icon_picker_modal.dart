// lib/widgets/icon_picker_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/model/app_icon_option.dart';
import 'package:flutter_application_code_stakeplot/services/app_icon_changer.dart';

import '../Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class IconPickerModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _IconPickerContent(),
    );
  }
}

class _IconPickerContent extends StatefulWidget {
  @override
  State<_IconPickerContent> createState() => _IconPickerContentState();
}

class _IconPickerContentState extends State<_IconPickerContent> {
  bool isLoading = false;
  String selectedIcon = AppIconOptions.defaultAlias;

  @override
  void initState() {
    super.initState();
    _loadSelectedIcon();
  }

  Future<void> _loadSelectedIcon() async {
    final alias = await AppIconChanger.selectedIconAlias();
    if (!mounted) return;

    setState(() {
      selectedIcon = alias;
    });
  }

  Future<void> _changeIcon(String alias) async {
    setState(() {
      isLoading = true;
      selectedIcon = alias;
    });

    final success = await AppIconChanger.changeIcon(alias);

    setState(() => isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "App icon changed successfully!"
            : "Failed to change app icon."),
        backgroundColor: success ? Colors.green : AppColors.redColor,
        duration: const Duration(seconds: 2),
      ),
    );

    if (success) Navigator.pop(context);
  }

  Widget _iconItem(AppIconOption option) {
    final isSelected = selectedIcon == option.alias;

    return GestureDetector(
      onTap: isLoading ? null : () => _changeIcon(option.alias),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Image.asset(
              option.assetPath,
              height: 70,
              width: 70,
            ),
            const SizedBox(height: AppSizes.h8),
            Text(
              option.label,
              style: FontManager().getTextStyle(context,
                  fontSize: 14, lWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSizes.p10, bottom: 20),
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text("Choose App Icon",
              style: FontManager().getTextStyle(context,
                  fontSize: 18, lWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.h20),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: AppIconOptions.all
                      .map((icon) => _iconItem(icon))
                      .toList(),
                ),
        ],
      ),
    );
  }
}
