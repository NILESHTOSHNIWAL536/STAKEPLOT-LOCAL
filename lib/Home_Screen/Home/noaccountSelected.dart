import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manually.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';

import '../../backed_connections/apiAutomations/bankinfo.dart';
import '../../backed_connections/apiConnect/clearstack.dart';

class NoAccountScreen extends StatefulWidget {
  @override
  _NoAccountScreenState createState() => _NoAccountScreenState();
}

class _NoAccountScreenState extends State<NoAccountScreen> {
  int _selectedIndex = 1; // Cash Out is selected by default

  @override
  void initState() {
    super.initState();
     getAllContstant(context);
  }

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
