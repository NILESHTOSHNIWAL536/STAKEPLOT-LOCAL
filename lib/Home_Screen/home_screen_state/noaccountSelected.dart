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
import '../../repository/clearstack.dart';
import '../Home/init_Api_Calls.dart';

class NoAccountScreen extends StatefulWidget {
  @override
  _NoAccountScreenState createState() => _NoAccountScreenState();
}

class _NoAccountScreenState extends State<NoAccountScreen> {
  int _selectedIndex = 1; // default cash out

  @override
  void initState() {
    super.initState();
    getAllContstant(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      color: AppColors.primaryColor,
      backgroundColor: AppColors.backgroundColor,
      strokeWidth: 2.5,

      // WORKING REFRESH
      onRefresh: () async {
        await callApi(context);
      },

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            _buildHeader(screenHeight),
            const SizedBox(height: 20),
            _buildBottomNavigation(screenWidth),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // HEADER UI
  // ---------------------------------------------------
  Widget _buildHeader(double screenHeight) {
    return Column(
      children: [
        AvatarProfileImage(
          url: HomePageIcons.noAccLink,
          height: 4,
          width: 3,
        ),

        const SizedBox(height: 12),

        Text(
          'No account Linked',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.accentColor,
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(
            'Your money, your view! Connect your bank to see all your expenses in one place. Super easy.',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: screenHeight * 0.01),

        SizedBox(
          width: MediaQuery.sizeOf(context).width / 1.8,
          height: 30,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ShareAccountLogin()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.finSpaceColor,
              foregroundColor: AppColors.backgroundColor,
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
    );
  }

  // ---------------------------------------------------
  // BOTTOM NAV
  // ---------------------------------------------------
  Widget _buildBottomNavigation(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
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
      onTap: () => tapNavigate(index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            label,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 12,
              color: AppColors.bg1,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // NAVIGATION TAPS
  // ---------------------------------------------------
  void tapNavigate(int index) {
    if (index == 0) {
      isDebit = false;
      showCustomModal(context, isDebit);
    } else if (index == 1) {
      isDebit = true;
      showCustomModal(context, isDebit);
    } else if (index == 2) {
      navToHistory(context);
    }
  }
}
