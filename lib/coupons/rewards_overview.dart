
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/coupons/coupon_card.dart';
import 'package:flutter_application_code_stakeplot/coupons/envelope_grid.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Import CouponCardWidget

class RewardsOverview extends StatefulWidget {
  @override
  _RewardsOverviewState createState() => _RewardsOverviewState();
}

class _RewardsOverviewState extends State<RewardsOverview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserController userController = Get.find<UserController>();
  RxList<CouponModel> claimedCoupons = <CouponModel>[].obs;
  RxList<CouponModel> categoryCoupons = <CouponModel>[].obs;
  RxBool isLoading = false.obs;

  final List<Map<String, dynamic>> categories = [
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchClaimedCoupons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchClaimedCoupons() async {
    try {
      isLoading.value = true;
      

      final response = await getDataApiCall(
       '$url/reward/'
      );

      if (getFlagOfResponse(response)) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        claimedCoupons.assignAll(CouponModel.listFromJson(data));
      }
    } catch (e) {
      // Handle error silently as per your code
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCategoryCoupons(String category) async {
    try {
      isLoading.value = true;
      
      // Trim spaces and replace with no spaces
      final formattedCategory = category.replaceAll(' ', '');
      final response = await getDataApiCall('$url/reward/search/$formattedCategory');

      if (getFlagOfResponse(response)) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        categoryCoupons.assignAll(CouponModel.listFromJson(data));
      }
    } catch (e) {
      // Handle error silently as per your code
    } finally {
      isLoading.value = false;
    }
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
                _buildClaimedTab(),
                _buildUnclaimedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimedTab() {
    return Obx(() => isLoading.value
        ? Center(child: Spinner())
        : claimedCoupons.isEmpty
            ? Center(child: Text('No claimed coupons'))
            : Padding(
                padding: EdgeInsets.all(16),
                child: GridView.builder(
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
              ));
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
        itemCount: userController.coupons.value ,
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
              backgroundColor: Colors.transparent,
              child: CouponCardWidget(
                coupon: coupon,
                onClaim: () {}, // No-op since coupon is already claimed
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
      onTap: () => _showCouponPopup(context),
      child: Container(
        child: chatAvatartImage(
          url: ProfileIcons.unclaimedCoupon,
          height: 10,
          width: 3,
        ),
      ),
    );
  }

  void _showCouponPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                SizedBox(height: 8),
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
                        fontSize: 20,
                        lWeight: FontWeight.w700,
                        color: AppColors.bg1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'You selected 2 transactions.\nAs a reward',
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    lWeight: FontWeight.w500,
                    color: AppColors.now,
                  ),
                ),
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select the category',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 12,
                      lWeight: FontWeight.w600,
                      color: AppColors.bg1,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Container(
                        margin: EdgeInsets.only(right: 12),
                        child: _buildCategoryCard(
                          category['title'],
                          category['emoji'],
                          category['color'],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String title, String emoji, Color backgroundColor) {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).pop();
        _fetchCategoryCoupons(title);
        _showCouponSelectionPopup(context, title);
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

  void _showCouponSelectionPopup(BuildContext context, String categoryTitle) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
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
                
                SizedBox(height: 24),
                Expanded(
                  child: Obx(() => isLoading.value
                      ? Center(child: Spinner())
                      : categoryCoupons.isEmpty
                          ? Center(child: Text('No coupons available'))
                          : EnvelopeGrid(categoryCoupons: categoryCoupons)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}