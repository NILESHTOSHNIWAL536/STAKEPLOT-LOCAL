import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

class ListItemModel {
  final String title;
  final String description;

  ListItemModel({required this.title, required this.description});
}

class CustomExpansionTile extends StatelessWidget {
  final List<ListItemModel> howToUseContent; // Content for "How to use the calculator?"
  final List<ListItemModel> howItWorksContent; // Content for "How it works?"

  const CustomExpansionTile({
    super.key,
    required this.howToUseContent,
    required this.howItWorksContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildExpansionTile(
          context,
          title: "How to use the calculator?",
          icon: Icons.timer_outlined,
          content: howToUseContent.map((item) => _buildStringListItem(context, item)).toList(),
        ),
        const SizedBox(height: 10),
        _buildExpansionTile(
          context,
          title: "How it works?",
          icon: Icons.settings,
          content: howItWorksContent.map((item) => _buildListItem(context, item)).toList(),
        ),
      ],
    );
  }

  /// Generic ExpansionTile Builder
  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    return Container(
      color: AppColors.mt, // Ensure the container background is set to your theme color
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent, // This removes the divider between tiles
          splashColor: Colors.transparent, // This removes the splash effect
          highlightColor: Colors.transparent, // This removes the highlight effect
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(icon, color: AppColors.primaryColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w300,
                  fontSize: 14,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          childrenPadding: EdgeInsets.zero, // Removes the default padding around children
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.description,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w300,
              fontSize: 14,
              color: Colors.black54,
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.description,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w300,
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
