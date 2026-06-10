import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora_dashboard.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/skipFInvuProcess.dart';

import '../Constants/app_palette.dart';
import '../Constants/app_svgs.dart';
import '../Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/font_manager.dart';

AppBar getAppBar(context) {
  return AppBar(
    backgroundColor: AppColors.newbg,
    toolbarHeight: 40,
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        child: GestureDetector(
          onTap: () {
            showSkipModal2(context);
          },
          child: Icon(
            Icons.login,
            color: AppColors.bg1,
            size: 30,
          ),
        ),
      ),
    ],
    leading: IconButton(
      icon: Icon(Icons.arrow_back_sharp),
      color: AppColors.bg1,
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showHomeButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.backgroundColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      toolbarHeight: 80,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(
            Icons.arrow_back,
            color: colors.bottomText,
            size: 25,
          ),
        ),
      ),
      title: Text(
        title,
        style: FontManager().getTextStyle(
          context,
          fontSize: 15,
          lWeight: FontWeight.w600,
          color: colors.blackColor,
        ),
      ),
      actions: showHomeButton
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      // Navigator.pushNamedAndRemoveUntil(
                      //   context,
                      //   '/home',
                      //   (route) => false,
                      // );
                      showSkipModal2(context);
                    },
                    child: Container(
                        height: 40,
                        child: iconBox(colors, HomeSvgs.autopaysIcon,
                            height: 40, width: 40, widthFactor: 12))),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
