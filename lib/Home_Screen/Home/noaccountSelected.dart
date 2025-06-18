// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manual_transaction.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manually.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';

// class NoAccountScreen extends StatefulWidget {
//   @override
//   _NoAccountScreenState createState() => _NoAccountScreenState();
// }

// class _NoAccountScreenState extends State<NoAccountScreen> {
//   int _selectedIndex = 1; // Cash Out is selected by default

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return  Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.06,
//                     // vertical: screenHeight * 0.,
//                   ),
//                   child: Column(
//                     children: [

//                       // Decorative background with wallet icon
//                       Container(
//                         width: screenWidth * 0.8,
//                         height: screenWidth * 0.8,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             // Large circle background
//                             Container(
//                               width: screenWidth * 0.75,
//                               height: screenWidth * 0.75,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(0.3),
//                               ),
//                             ),

//                             // Decorative elements
//                             Positioned(
//                               top: screenWidth * 0.1,
//                               left: screenWidth * 0.15,
//                               child: Icon(
//                                 Icons.add,
//                                 color: Colors.grey.withOpacity(0.3),
//                                 size: screenWidth * 0.06,
//                               ),
//                             ),

//                             Positioned(
//                               bottom: screenWidth * 0.15,
//                               left: screenWidth * 0.08,
//                               child: Container(
//                                 width: screenWidth * 0.03,
//                                 height: screenWidth * 0.03,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.withOpacity(0.3),
//                                 ),
//                               ),
//                             ),

//                             Positioned(
//                               top: screenWidth * 0.2,
//                               right: screenWidth * 0.1,
//                               child: Container(
//                                 width: screenWidth * 0.04,
//                                 height: screenWidth * 0.04,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.withOpacity(0.3),
//                                 ),
//                               ),
//                             ),

//                             // Wallet/Card icon
//                             Container(
//                               width: screenWidth * 0.25,
//                               height: screenWidth * 0.2,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     // Color(0xFF8B7ED8),
//                                      Color(0xFF6366F1),
//                                     AppColors.primaryColor,
//                                   ],
//                                 ),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Positioned(
//                                     top: 8,
//                                     left: 8,
//                                     right: 8,
//                                     child: Container(
//                                       height: 3,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white.withOpacity(0.8),
//                                         borderRadius: BorderRadius.circular(2),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: screenHeight * 0.04),

//                       // Title
//                       Text(
//                         'No account Linked',
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.07,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1F2937),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),

//                       SizedBox(height: screenHeight * 0.02),

//                       // Description
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//                         child: Text(
//                           'Your money, your view! Connect your bank to see all your expenses in one place. Super easy',
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.04,
//                             color: Color(0xFF6B7280),
//                             height: 1.5,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),

//                       SizedBox(height: screenHeight * 0.04),

//                       // Add Bank Account Button
//                       Container(
//                         width: double.infinity,
//                         height: screenHeight * 0.065,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // Handle add bank account action
//                               Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ShareAccountLogin(),
//                               ),
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primaryColor,
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text(
//                             'Add Bank Account',
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.045,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Bottom Navigation
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.05,
//                     vertical: screenHeight * 0.015,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildBottomNavItem(
//                         icon: Icons.arrow_downward,
//                         label: 'Cash In',
//                         index: 0,
//                         screenWidth: screenWidth,
//                       ),
//                       _buildBottomNavItem(
//                         icon: Icons.arrow_upward,
//                         label: 'Cash Out',
//                         index: 1,
//                         screenWidth: screenWidth,
//                       ),
//                       _buildBottomNavItem(
//                         icon: Icons.history,
//                         label: 'History',
//                         index: 2,
//                         screenWidth: screenWidth,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//   }

//   Widget _buildBottomNavItem({
//     required IconData icon,
//     required String label,
//     required int index,
//     required double screenWidth,
//   }) {
//     final isSelected = _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//            tapNavigate(index);
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: screenWidth * 0.04,
//           vertical: screenWidth * 0.02,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(screenWidth * 0.02),
//               decoration: BoxDecoration(
//                 color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: isSelected ? AppColors.primaryColor: Color(0xFF9CA3AF),
//                 size: screenWidth * 0.06,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: screenWidth * 0.032,
//                 color: isSelected ? AppColors.primaryColor : Color(0xFF9CA3AF),
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//             if (isSelected)
//               Container(
//                 margin: EdgeInsets.only(top: 4),
//                 width: screenWidth * 0.12,
//                 height: 2,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryColor,
//                   borderRadius: BorderRadius.circular(1),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void tapNavigate(index){
//      if(0==index)
//            {
//              isDebit = false;
//             showCustomModal(context,isDebit);
//           }
//           else if(1==index){
//              isDebit = true;
//             showCustomModal(context,isDebit);
//           }
//          else if(2==index){
//             navToHistory(context);
//           }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manually.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';

class NoAccountScreen extends StatefulWidget {
  @override
  _NoAccountScreenState createState() => _NoAccountScreenState();
}

class _NoAccountScreenState extends State<NoAccountScreen> {
  int _selectedIndex = 1; // Cash Out is selected by default

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: MediaQuery.sizeOf(context).height / 11),
        Column(
          children: [
            // Decorative background with wallet icon
            Container(
              // color: Colors.green,
              child: AvatarProfileImage(
                url: HomePageIcons.noAccLink,
                height: 4,
                width: 3,
              ),
            ),

            SizedBox(width: MediaQuery.sizeOf(context).width / 14),
            // Title
            Container(
              // color: Colors.amber,
              width: MediaQuery.sizeOf(context).width ,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'No account Linked',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.accentColor,
                        maxLines: null,
                        overflow: TextOverflow.visible),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Description
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      'Your money, your view! Connect your bank to see all your expenses in one place. Super easy.',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black54,
                          maxLines: null,
                          overflow: TextOverflow.visible),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Add Bank Account Button
                  Container(
                    width: MediaQuery.sizeOf(context).width / 1.8,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle add bank account action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShareAccountLogin(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.finSpaceColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Add Bank Account',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.backgroundColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Bottom Navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Container(
            width: MediaQuery.sizeOf(context).width ,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  icon: AvatarProfileImage(
                    url: HomePageIcons.cashIn,
                    height: 32,
                    width: 34,
                  ),
                  label: 'Cash In',
                  index: 0,
                  screenWidth: screenWidth,
                ),
                _buildBottomNavItem(
                  icon: AvatarProfileImage(
                    url: HomePageIcons.cashOut,
                    height: 32,
                    width: 34,
                  ),
                  label: 'Cash Out',
                  index: 1,
                  screenWidth: screenWidth,
                ),
                _buildBottomNavItem(
                  icon: AvatarProfileImage(
                    url: HomePageIcons.transactionHistoryIcon,
                    height: 32,
                    width: 34,
                  ),
                  label: 'History',
                  index: 2,
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavItem({
    required Widget icon,
    required String label,
    required int index,
    required double screenWidth,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        tapNavigate(index);
      },
      child: Container(
        // padding: EdgeInsets.symmetric(
        //   horizontal: screenWidth * 0.02,

        // ),
        // color: Colors.green,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                // padding: EdgeInsets.all(screenWidth * 0.01),
                // decoration: BoxDecoration(
                //   color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                //   borderRadius: BorderRadius.circular(8),
                // ),
                child: icon),
            Text(
              label,
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w500, fontSize: 12, color: AppColors.bg1),
            ),
          ],
        ),
      ),
    );
  }

  void tapNavigate(index) {
    if (0 == index) {
      isDebit = false;
      showCustomModal(context, isDebit);
    } else if (1 == index) {
      isDebit = true;
      showCustomModal(context, isDebit);
    } else if (2 == index) {
      navToHistory(context);
    }
  }
}
