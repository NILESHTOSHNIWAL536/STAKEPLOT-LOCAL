
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_component_sizes.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/core/app_shadows.dart';

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
    
    // showKeyboard = true;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

 
  Widget _buildCircularBackButton(BuildContext context) {
    return InkWell(
      
      onTap: () => Navigator.of(context).pop(),
      child: globalbackArrow()
     
    );
  }

  @override
  Widget build(BuildContext context) {
   
    const double headerHeight = 160;

    return Scaffold(
      backgroundColor: AppColors.border, 
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
              AppShadows.soft
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // top row: circular back button (left) & centered title
                    Row(
                      children: [
                        _buildCircularBackButton(context),
                        SizedBox(
                          width: MediaQuery.of(context).size.width /1.4,
                          child: Center(
                            child: Text(
                              'Cash Transactions',
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w500,
                                fontSize: 17,
                                color: AppColors.accentColor,
                              ),
                            ),
                          ),
                        ),
                        // placeholder space to keep title centered
                         SizedBox(width: AppSizes.w44),
                      ],
                    ),

                    SizedBox(height: AppSizes.h6),

                    // TabBar styled as segmented control
                    Material(
                      color: AppColors.transparentColor,
                      child: TabBar(
  controller: _tabController,

  indicator: const UnderlineTabIndicator(
    borderSide: BorderSide(
      width: 2,
      color: AppColors.primaryColor,
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
    lineHeight: 2.0
  ),

  unselectedLabelStyle: FontManager().getTextStyle(
    context,
    lWeight: FontWeight.normal,
    fontSize: 14,
    color: AppColors.accentColor,
     lineHeight: 2.0
  ),

  tabs: const [
    Tab(text: 'Cash Out',
    
    
     ),
    Tab(text: 'Cash In'),
  ],
)

                    ),
                  ],
                ),
              ),
            ),
          ),

        
          SizedBox(
           
            height: MediaQuery.sizeOf(context).height/1.23,
            child: TabBarView(
              controller: _tabController,
              children:const  [
                // Page for Cash in (isDebit true)
                 ModalContent(true),

                // Page for Cash out (isDebit false)
                 ModalContent(false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
