import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';

Widget showModel(BuildContext context, String id, [bool flag = false, int indexElement = -1,isTribeOne=false]) {
  String? selectedOption; // To track the selected report option

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    height: MediaQuery.of(context).size.height * 0.55,
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: AppColors.accentColor.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
    child: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Report",
                    style: FontManager().getTextStyle(
                                context,
                                lWeight:  FontWeight.w500,
                                fontSize: 18,
                                color: AppColors.bg1,
                              ),
                  ),
                ],
              ),
            ),
            // Report Options
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                itemCount: reportOptions.length,
                itemBuilder: (context2, index) {
                  final option = reportOptions[index];
                  return InkWell(
                    onTap: () {
                      if (option['isDescription'] == true) {
                        return;
                      }
                      setState(() {
                        selectedOption = option['title']; // Update selected option
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          option['isDescription'] == true
                              ? const SizedBox(width: 0) // Placeholder for alignment
                              :  Checkbox(
                                    value: selectedOption == option['title'],
                                    onChanged: (bool? value) {
                                      if (value == true) {
                                        setState(() {
                                          selectedOption = option['title']; // Update selected option
                                        });
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4), 
                                      // Square shape
                                    ),
                                    activeColor: AppColors.finSpaceColor,
                                    checkColor: AppColors.backgroundColor,
                                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    
                                  ),
                              
                           Container(
                             width: option['isDescription'] == true?MediaQuery.sizeOf(context).width/1.1:MediaQuery.sizeOf(context).width/1.4,
                             child: Text(
                                option['title']!,
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: option['isDescription'] == true
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: option['isDescription'] == true ? 16 : 14,
                                  color: AppColors.bg1,
                                  overflow: TextOverflow.visible,
                                  maxLines: 4
                                ),
                              ),
                           ),
                          
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Report and Cancel Buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: selectedOption == null
                          ? null
                          : () {
                              Navigator.pop(context);
                               if(isTribeOne)
                                {
                                    Navigator.pop(context);
                                }
                             reportPost(context, id, selectedOption!, "report", indexElement);
                            },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor:  AppColors.finSpaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Report',
                       style: FontManager().getTextStyle(
                                context,
                                lWeight:  FontWeight.w500,
                                fontSize: 16,
                                color: AppColors.backgroundColor,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}