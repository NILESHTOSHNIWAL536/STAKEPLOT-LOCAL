import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/skipFInvuProcess.dart';

import '../Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';

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
