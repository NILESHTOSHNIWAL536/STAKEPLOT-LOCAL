import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Constants/core/app_padding_sizes.dart';

class ListItemModel {
  final String title;
  final String description;

  ListItemModel({required this.title, required this.description});
}

class CustomExpansionTile extends StatelessWidget {
  final List<ListItemModel>
      howToUseContent; // Content for "How to use the calculator?"
  final List<ListItemModel> howItWorksContent; // Content for "How it works?"

  const CustomExpansionTile({
    super.key,
    required this.howToUseContent,
    required this.howItWorksContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
     
      margin: EdgeInsets.only(left: 4, right: 4, top: 0, bottom: 15),
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _buildExpansionTile(
            context,
            title: "How to use the calculator?",
     icon: "assets/icons/financeScreen/calculator.svg", 
            
            content: howToUseContent
                .map((item) => _buildStringListItem(context, item))
                .toList(),
          ),
           SizedBox(height: AppSizes.h10),
          _buildExpansionTile(
            context,
            title: "How it works?",
             icon: "assets/icons/financeScreen/calculator.svg", 
            content: howItWorksContent
                .map((item) => _buildListItem(context, item))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Generic ExpansionTile Builder
  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
   required String icon,  // now accepts SVG path

    required List<Widget> content,
  }) {
    return Container(
      // Ensure the container background is set to your theme color
      decoration: BoxDecoration(
          color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(10)
          ,border: Border.all(color: Color(0xFF374151)),),

      child: Theme(
        data: ThemeData(
          // dividerColor:
          //     AppColors.accentColor, // This removes the divider between tiles
          splashColor: AppColors.transparentColor, // This removes the splash effect
          highlightColor:
              AppColors.transparentColor, // This removes the highlight effect
        ),
        child: ExpansionTile(
          iconColor: AppColors.primaryColor, // Color when expanded
          collapsedIconColor: AppColors.primaryColor,
          title: Row(
            children: [
             SvgPicture.asset(
  icon,
  height: 24,
  width: 24,
  colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
),

              const SizedBox(width: 10),
              Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: MediaQuery.sizeOf(context).height / 55,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          childrenPadding:
              EdgeInsets.zero, // Removes the default padding around children
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List Item Builder for ListItemModel
  Widget _buildListItem(BuildContext context, ListItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
      
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.accentColor,
            ),
          ),
          SizedBox(height: AppSizes.h5),
          Text(
            item.description,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.newfontcolor,
            ),
          ),
        ],
      ),
    );
  }

  /// List Item Builder for String-based List
  Widget _buildStringListItem(BuildContext context, ListItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.accentColor,
            ),
          ),
          SizedBox(height: AppSizes.h5),
          Text(
            item.description,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.newfontcolor,
            ),
          ),
        ],
      ),
    );
  }
}
