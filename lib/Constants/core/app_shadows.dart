import 'package:flutter/material.dart';
import '../colors.dart';

class AppShadows {
  // Soft shadow (your current one)
  static BoxShadow soft = BoxShadow(
    color: AppColors.accentColor.withOpacity(0.03),
    blurRadius: 6,
    offset: const Offset(0, 2),
  );

  // Medium shadow (for cards)
  static BoxShadow tabs =   BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.10),
        offset: Offset(4, 4),
        blurRadius: 16,
      );

  // Strong shadow (dialogs, bottom sheets)
  static BoxShadow strong = BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
}



class AppBorders {
  // Soft border (your current one)
  static Border soft = Border.all(
    color: AppColors.accentColor.withOpacity(0.06),
    width: 1,
  );

  

  // Medium border (cards focus state)
  static Border medium = Border.all(
    color: AppColors.accentColor.withOpacity(0.12),
    width: 1.2,
  );

  // Strong border (selected / active)
  static Border strong = Border.all(
    color: AppColors.accentColor.withOpacity(0.2),
    width: 1.5,
  );
}




class AppDividers {
  // Soft divider (your current one)
  static Divider soft = Divider(
    height: 1,
    thickness: 1,
    color: AppColors.accentColor.withOpacity(0.15),
  );

  // Light divider (lists, subtle separation)
  static Divider light = Divider(
    height: 1,
    thickness: 0.8,
    color: Colors.black.withOpacity(0.08),
  );

  // Medium divider (sections)
  static Divider medium = Divider(
    height: 1,
    thickness: 1.2,
    color: AppColors.accentColor.withOpacity(0.25),
  );

  // Strong divider (headers / emphasis)
  static Divider strong = Divider(
    height: 1,
    thickness: 1.5,
    color: AppColors.accentColor.withOpacity(0.4),
  );
}
