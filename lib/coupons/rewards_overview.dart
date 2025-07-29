import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/coupons/infoScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/coupons/coupon_card.dart';
import 'package:flutter_application_code_stakeplot/coupons/envelope_grid.dart';
import 'package:get/get.dart';
import '../backed_connections/apiConnect/reward.dart';

class CouponPopupUtils {
  static final List<Map<String, dynamic>> categories = [
    {'title': 'Fashion', 'emoji': '👗', 'color': Colors.purple.shade100},
    {'title': 'Accessories', 'emoji': '👜', 'color': Colors.pink.shade100},
    {'title': 'Beauty & Personal Care', 'emoji': '💄', 'color': Colors.red.shade100},
    {'title': 'Electronics', 'emoji': '📱', 'color': Colors.blue.shade100},
    {'title': 'Software & Security', 'emoji': '🖥️', 'color': Colors.indigo.shade100},
    {'title': 'Web Services', 'emoji': '🌐', 'color': Colors.teal.shade100},
    {'title': 'Travel & Tourism', 'emoji': '🏖️', 'color': Colors.orange.shade100},
    {'title': 'Flights', 'emoji': '✈️', 'color': Colors.lightBlue.shade100},
    {'title': 'Rentals', 'emoji': '🚗', 'color': Colors.green.shade100},
    {'title': 'Food & Beverage', 'emoji': '🍔', 'color': Colors.amber.shade100},
    {'title': 'Health & Wellness', 'emoji': '🏥', 'color': Colors.cyan.shade100},
    {'title': 'Entertainment', 'emoji': '🎬', 'color': Colors.deepPurple.shade100},
  ];

  static void showCouponPopup(BuildContext context, Function(String) onCategorySelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width ,
          height: MediaQuery.of(context).size.height/2,
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             
               getHeader(context),
              SizedBox(height: 16),
              
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Select the category',
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 14,
                    lWeight: FontWeight.w600,
                    color: AppColors.bg1,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height/2.8,
                  child: GridView.builder(
                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,          // 2 columns
                      crossAxisSpacing: 0,       // horizontal space
                      mainAxisSpacing: 3,        // vertical space
                      childAspectRatio: 1.1,    // width / height ratio
                    ),
                    scrollDirection: Axis.vertical,
                    itemCount: categories.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Container(
                        margin: EdgeInsets.only(right: 12),
                        child: _buildCategoryCard(
                          category['title'],
                          category['emoji'],
                          category['color'],
                          onCategorySelected,
                          context,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }


static  Widget getHeader(context){
    return  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🎁',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'You Won a Coupon!',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 18,
                        lWeight: FontWeight.w700,
                        color: AppColors.bg1,
                      ),
                    ),
                  ],
                ),
                
                 Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                             ],
                          ),
              );
  }

  static Widget _buildCategoryCard(
      String title, String emoji, Color backgroundColor, Function(String) onCategorySelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        onCategorySelected(title);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                lWeight: FontWeight.w600,
                color: AppColors.bg1,
              ),
            ),
          ],
        ),
      ),
    );
  }



static void showCouponSelectionPopup(BuildContext context, String categoryTitle) {
     showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width ,
          height: MediaQuery.of(context).size.height/2,
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              getHeader(context),
              SizedBox(height: 24),
              Expanded(
                child: Obx(() => loadReaward.value
                    ? Center(child: Spinner())
                    : categoryCoupons.isEmpty
                        ? Center(child: textStyle(text:'No coupons available',context: context,fontWeight: FontWeight.bold,fontsize: 12))
                        : EnvelopeGrid(categoryCoupons: categoryCoupons)),
              ),
            ],
          ),
        );
      },
    );
  }

   

}

class RewardsOverview extends StatefulWidget {
  @override
  _RewardsOverviewState createState() => _RewardsOverviewState();
}

class _RewardsOverviewState extends State<RewardsOverview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserController userController = Get.find<UserController>();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userController.fetchUserInfo();
    fetchClaimedCoupons();
    fetchCouponsCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

 

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
              'Rewards ',
              style: FontManager().getTextStyle(
                context,
                fontSize: 16,
                lWeight: FontWeight.w500,
                color: AppColors.bg1,
              ),
            ),
        centerTitle: true,
        actions: [
          IconButton(
          icon: Icon(Icons.info, color: Colors.black),
          onPressed: () => showEarningScoreDialog(context),
        ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 2,
              labelStyle: FontManager().getTextStyle(
                context,
                fontSize: 16,
                lWeight: FontWeight.w400,
                color: AppColors.primaryColor,
              ),
              unselectedLabelStyle: FontManager().getTextStyle(
                context,
                fontSize: 16,
                lWeight: FontWeight.w400,
                color: AppColors.now,
              ),
              tabs: const [
                Tab(text: 'Claimed'),
                Tab(text: 'Unclaimed'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
               Obx(()=> loadReaward.value ? Center(child: Spinner()):  refreshCupon.value ?   _buildClaimedTab() : _buildClaimedTab()) ,
               Obx(()=>  refreshCupon.value ? _buildUnclaimedTab(): _buildUnclaimedTab()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimedTab() {
    return   loadReaward.value
        ? Center(child: Spinner())
        : claimedCoupons.isEmpty
            ? Center(child: Text('No claimed coupons'))
            : Padding(
                padding: EdgeInsets.all(16),
                child:  GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: claimedCoupons.length,
                  itemBuilder: (context, index) {
                    return _buildRewardCard(claimedCoupons[index]);
                  },
                ),
              );
  }

  Widget _buildUnclaimedTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: userController.coupons.value <=0?0:userController.coupons.value,
        itemBuilder: (context, index) {
          return _buildEnvelopeCard();
        },
      ),
    );
  }

 Widget _buildRewardCard(CouponModel coupon) {
  return GestureDetector(
     onTap: () {
        // Show coupon details in a dialog
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Dialog(
               insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: CouponCardWidget(
                coupon: coupon,
                onClaim: () {},
                parentContext: context, // No-op since coupon is already claimed
              ),
            );
          },
        );
      },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ Image as full background
                  Image.network(
                    coupon.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey.shade200, child: Icon(Icons.error)),
                  ),
    
                  // ✅ Optional gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
    
                  // ✅ Brand name at top-left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        coupon.brand,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
     SizedBox(height: 4),
          // ✅ Lower part: Category + Description
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toUpperCase(coupon.category),
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 14,
                      lWeight: FontWeight.w600,
                      color: AppColors.bg1,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    coupon.description,
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 12,
                      lWeight: FontWeight.w400,
                      color: AppColors.bg1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildEnvelopeCard() {
    return GestureDetector(
      onTap: () => CouponPopupUtils.showCouponPopup(context, (category) {
         fetchCategoryCoupons(category);
        CouponPopupUtils.showCouponSelectionPopup(context, category);
      }),
      child: Container(
        child: chatAvatartImage(
          url: ProfileIcons.unclaimedCoupon,
          height: 10,
          width: 3,
        ),
      ),
    );
  }

}