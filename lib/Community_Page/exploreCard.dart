
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';

class ExploreCard extends StatelessWidget {
  var extractdata;
 ExploreCard({ Key? key,required this.extractdata }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return  Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Place Section
                                Row(
                                  children: [
                                    Icon(Icons.place, color: AppColors.bg2, size: 20),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        "${extractdata['place']['name']} - ${extractdata['place']['location']}",
                                        style: FontManager().getTextStyle(context,
                                            lWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColors.bg1),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Trip Highlight
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.pollSelected.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Highlight: ${extractdata['tripHighlight']}",
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppColors.bg1),
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Budget Section
                                Text(
                                  "Budget",
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.bg1),
                                ),
                                SizedBox(height: 5),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: (extractdata['budget'] as List).map((budgetItem) {
                                     print('uploadData: Budget item - Category: ${budgetItem['category']}, Amount: ${budgetItem['amount']}');
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.button),
                                      ),
                                      child: Text(
                                        "${budgetItem['category']}: ₹${budgetItem['amount']}",
                                        style: FontManager().getTextStyle(context,
                                            lWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color: AppColors.bg1),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 10),
                                // Description
                                Readmore(str: extractdata['description']),
                              ],
                            ),
             );
  }
}