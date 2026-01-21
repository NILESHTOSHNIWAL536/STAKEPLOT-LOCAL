import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/cashTransaction.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../repository/bankinfo.dart';
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
             SizedBox(height: AppSizes.h14),
            _buildHeader(screenHeight),
             SizedBox(height: AppSizes.h20),
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

        SizedBox(height: AppSizes.h12),

        Text(
          'No account Linked',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.accentColor,
          ),
        ),

        SizedBox(height: AppSizes.h8),

        Padding(
          padding: const EdgeInsets.all(AppSizes.p14),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p20),
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
            manualTransactionButton(context),
           
           historyButton(context),
           
          ],
        ),
      ),
    );
  }

 
  
}
