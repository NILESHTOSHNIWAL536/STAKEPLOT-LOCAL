import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../controllers/controllerManagement.dart';
import '../controllers/theme_controller.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

void showThemeSelectorModal(BuildContext context) {
  final ThemeController controller = ControllerManagement.themeController;

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Obx(() {
        final current = controller.themeMode.value;

        return Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Choose Theme",
                  style: FontManager().getTextStyle(context,
                      fontSize: 18, lWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: AppSizes.h12),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('System Default'),
                trailing: current == ThemeMode.system
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  controller.changeTheme(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light Mode'),
                trailing: current == ThemeMode.light
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  controller.changeTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: current == ThemeMode.dark
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  controller.changeTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: AppSizes.h10),
            ],
          ),
        );
      });
    },
  );
}
