
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

import '../../image_service/avatarProfile.dart';
import '../../repository/transactions_repository.dart';






class ManualTransactionPage extends StatefulWidget {
  const ManualTransactionPage({Key? key}) : super(key: key);

  @override
  _ManualTransactionPageState createState() => _ManualTransactionPageState();
}

class _ManualTransactionPageState extends State<ManualTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // two tabs: index 0 = Cash in (debit true), index 1 = Cash out (debit false)
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Small reusable back button in the circular style from your screenshot
  Widget _buildCircularBackButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentColor.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Icon(Icons.arrow_back, size: 20, color: AppColors.accentColor,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Header height so contents below match your design
    const double headerHeight = 160;

    return Scaffold(
      backgroundColor: AppColors.border, // page background to match modal look
      body: Column(
        children: [
          // Top rounded header area (similar to screenshot)
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              color: AppColors.newbg,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // top row: circular back button (left) & centered title
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          _buildCircularBackButton(context),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Cash Transactions',
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                          ),
                          // placeholder space to keep title centered
                          SizedBox(width: 44),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // TabBar styled as segmented control
                    Material(
                      color: Colors.transparent,
                      child: TabBar(
  controller: _tabController,

  indicator: const UnderlineTabIndicator(
    borderSide: BorderSide(
      width: 2,
      color: AppColors.primaryColor, // change to AppColors.primaryColor
    ),
    insets: EdgeInsets.symmetric(horizontal: 90), 
  ),

  labelColor: AppColors.primaryColor,
  unselectedLabelColor: AppColors.accentColor,

  labelStyle: FontManager().getTextStyle(
    context,
    lWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.primaryColor,
  ),

  unselectedLabelStyle: FontManager().getTextStyle(
    context,
    lWeight: FontWeight.normal,
    fontSize: 14,
    color: AppColors.accentColor,
  ),

  tabs: const [
    Tab(text: 'Cash Out', ),
    Tab(text: 'Cash In'),
  ],
)

                    ),
                  ],
                ),
              ),
            ),
          ),

          // The content area — TabBarView will show your ModalContent pages
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Page for Cash in (isDebit true)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ModalContent(true),
                ),

                // Page for Cash out (isDebit false)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ModalContent(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
