// lib/widgets/icon_picker_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/services/app_icon_changer.dart';

import '../Constants/core/app_padding_sizes.dart';


class IconPickerModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
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
  String selectedIcon = "";

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
        content: Text(success ? "App icon changed successfully!" : "Failed to change app icon."),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );

    if (success) Navigator.pop(context);
  }

  Widget _iconItem(String label, String asset, String alias) {
    final isSelected = selectedIcon == alias;

    return GestureDetector(
      onTap: isLoading ? null : () => _changeIcon(alias),
      child: Container(
        padding: EdgeInsets.all(10),
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
              asset,
              height: 70,
              width: 70,
            ),
            SizedBox(height: AppSizes.h8),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            margin: EdgeInsets.only(top: 10, bottom: 20),
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text("Choose App Icon", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: AppSizes.h20),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _iconItem("Default", "assets/app_icons/mainicon.png", "IconDefault"),
                    _iconItem("Icon 1", "assets/app_icons/icon1.png", "Icon1"),
                    _iconItem("Icon 2", "assets/app_icons/icon2.png", "Icon2"),
                    _iconItem("Icon 3", "assets/app_icons/icon3.png", "Icon3"),
                  ],
                ),
        ],
      ),
    );
  }
}
