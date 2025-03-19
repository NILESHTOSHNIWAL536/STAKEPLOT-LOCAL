// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/readmore.dart';
// import 'package:getwidget/components/image/gf_image_overlay.dart';

// class ExploreCard extends StatelessWidget {
//   var extractdata;
//   var dataObj;
//   ExploreCard({Key? key, required this.extractdata, required this.dataObj})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
         
//           extractdata['pictures'] != null
//     ? Container(
//       height: 300,
//       width:500,
//       //color: Colors.blue,
//       child: ListView.builder(
//           shrinkWrap: true, // Prevents unbounded height error
//           physics: const ClampingScrollPhysics(), // Optional: for better scrolling behavior
//           scrollDirection: Axis.horizontal,
//           itemCount: extractdata['pictures'].length,
//           itemBuilder: (context, d) {
//             return Padding(
//               padding: EdgeInsets.only(right: 10), // Space between images
//               child: GFImageOverlay(
//                 width: MediaQuery.of(context).size.width / 1.5, // Adjusted width
//                 height: MediaQuery.of(context).size.height / 3, // Adjusted height
//                // boxFit: BoxFit.cover,
//                 borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
//                 image: NetworkImage(extractdata['pictures'][d]),
//               ),
//             );
//           },
//         ),
//     )
//     : getimage(context, dataObj['image']),
//           Row(
//             children: [
//               Row(
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "Place:",
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: AppColors.bg1),
//                           ),
//                           Text(
//                             "${extractdata['place']['name']}",
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.w400,
//                                 fontSize: 12,
//                                 color: AppColors.bg1),
//                           ),
//                         ],
//                       ),
//                       SizedBox(width: 30,),
//                       Row(
//                         children: [
//                           Text(
//                             "Location:",
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: AppColors.bg1),
//                           ),
//                           Text(
//                             " ${extractdata['place']['location']}",
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.w400,
//                                 fontSize: 12,
//                                 color: AppColors.bg1),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//             ],
//           ),
//           SizedBox(height: 10),
//           // Trip Highlight
//           Text(
//             "Budget",
//             style: FontManager().getTextStyle(context,
//                 lWeight: FontWeight.bold, fontSize: 16, color: AppColors.bg1),
//           ),
//           SizedBox(height: 5),
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: (extractdata['budget'] as List).map((budgetItem) {
//               print(
//                   'uploadData: Budget item - Category: ${budgetItem['category']}, Amount: ${budgetItem['amount']}');
//               return Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppColors.backgroundColor,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColors.button),
//                 ),
//                 child: Text(
//                   "${budgetItem['category']}: ₹${budgetItem['amount']}",
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.normal,
//                       fontSize: 14,
//                       color: AppColors.bg1),
//                 ),
//               );
//             }).toList(),
//           ),
//           Text(
//             "Trip Highlight(s)",
//             style: FontManager().getTextStyle(context,
//                 lWeight: FontWeight.w600, fontSize: 16, color: AppColors.bg1),
//           ),
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.pollSelected.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               "${extractdata['tripHighlight']}",
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.w600, fontSize: 16, color: AppColors.bg1),
//             ),
//           ),

//           SizedBox(height: 10),
//           // Description
//           Text(
//             "Description",
//             style: FontManager().getTextStyle(context,
//                 lWeight: FontWeight.w600, fontSize: 16, color: AppColors.bg1),
//           ),
//           Readmore(str: extractdata['description']),
//         ],
//       ),
//     );
//   }



//   Widget getimage(context,image){
//     return Padding(
//                       padding: EdgeInsets.symmetric(
//                           vertical: Colorcodes.borderRadius),
//                       child: Center(
//                         child: GFImageOverlay(
//                           width: MediaQuery.of(context).size.width / 1.2,
//                           height: MediaQuery.of(context).size.height / 2.7,
//                           boxFit: BoxFit.fill,
//                           borderRadius:
//                               BorderRadius.circular(Colorcodes.borderRadius),
//                           image: NetworkImage(image),
//                         ),
//                       ),
//                     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/readmore.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';

class ExploreCard extends StatelessWidget {
  var extractdata;
  var dataObj;
  ExploreCard({Key? key, required this.extractdata, required this.dataObj})
      : super(key: key);

  // ScrollController to control the ListView scrolling
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          extractdata['pictures'] != null
              ? Container(
                  height: 300,
                  width: 600,
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController, // Attach the ScrollController
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: extractdata['pictures'].length,
                        itemBuilder: (context, d) {
                          return Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: GFImageOverlay(
                              width: MediaQuery.of(context).size.width / 1.3,
                              height: MediaQuery.of(context).size.height / 3,
                              borderRadius:
                                  BorderRadius.circular(Colorcodes.borderRadius),
                              image: NetworkImage(extractdata['pictures'][d]),
                            ),
                          );
                        },
                      ),
                      // Left Arrow
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.arrow_left, size: 40, color: AppColors.bg1),
                            onPressed: () {
                              // _scrollController.animateTo(
                              //   _scrollController.offset , // Scroll left by 200 pixels
                              //   duration: Duration(milliseconds: 300),
                              //   curve: Curves.easeInOut,
                              // );
                            },
                          ),
                        ),
                      ),
                      // Right Arrow
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.arrow_right, size: 40, color: AppColors.bg1),
                            onPressed: () {
                              _scrollController.animateTo(
                                _scrollController.offset + 200, // Scroll right by 200 pixels
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : getimage(context, dataObj['image']),
          Row(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        "Place:",
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.bg1),
                      ),
                      Text(
                        "${extractdata['place']['name']}",
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColors.bg1),
                      ),
                    ],
                  ),
                  SizedBox(width: 30),
                  Row(
                    children: [
                      Text(
                        "Location:",
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.bg1),
                      ),
                      Text(
                        " ${extractdata['place']['location']}",
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColors.bg1),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Budget",
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.bold, fontSize: 16, color: AppColors.bg1),
          ),
          SizedBox(height: 5),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (extractdata['budget'] as List).map((budgetItem) {
              print(
                  'uploadData: Budget item - Category: ${budgetItem['category']}, Amount: ${budgetItem['amount']}');
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
          Text(
            "Trip Highlight(s)",
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w600, fontSize: 16, color: AppColors.bg1),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pollSelected.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${extractdata['tripHighlight']}",
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w600, fontSize: 16, color: AppColors.bg1),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Description",
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w600, fontSize: 16, color: AppColors.bg1),
          ),
          Readmore(str: extractdata['description']),
        ],
      ),
    );
  }

  Widget getimage(context, image) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Colorcodes.borderRadius),
      child: Center(
        child: GFImageOverlay(
          width: MediaQuery.of(context).size.width / 1.2,
          height: MediaQuery.of(context).size.height / 2.7,
          boxFit: BoxFit.fill,
          borderRadius: BorderRadius.circular(Colorcodes.borderRadius),
          image: NetworkImage(image),
        ),
      ),
    );
  }
}