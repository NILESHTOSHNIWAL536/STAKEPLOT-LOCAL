import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/coupons/infoScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/coupons/coupon_card.dart';
import 'package:flutter_application_code_stakeplot/coupons/envelope_grid.dart';
import 'package:get/get.dart';
import '../backed_connections/apiConnect/reward.dart';

late BuildContext dialofBoxContext;
final RxBool showBrands = false.obs;

class CouponPopupUtils {
  static void showCouponPopup(
      BuildContext context, Function(String) onCategorySelected) {
        if (MediaQuery.maybeOf(context) == null) {
     
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        return Container(
          width: MediaQuery.of(sheetContext).size.width,
          height: MediaQuery.of(sheetContext).size.height / 2,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getHeader(sheetContext),
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
              couponAvalible.value
                  ? gridList(sheetContext, onCategorySelected)
                  : Container(
                      height: MediaQuery.of(sheetContext).size.height / 3,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: textStyleImage(
                            context: sheetContext,
                            text: RewardScreenStrings().outOfReaward,
                            fontsize: 17,
                            fontWeight: FontWeight.w500,
                            iswrap: true),
                      ),
                    ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static Widget gridList(context, onCategorySelected) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height / 2.8,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 2 columns
            crossAxisSpacing: 0, // horizontal space
            mainAxisSpacing: 3, // vertical space
            childAspectRatio: 1.1, // width / height ratio
          ),
          scrollDirection: Axis.vertical,
          itemCount: categoriesOfReward.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final category = categoriesOfReward[index];
            return Container(
              margin: EdgeInsets.only(right: 12),
              child: _buildCategoryCard(
                category['title'],
                category['emoji'],
                category['color'],
                onCategorySelected,
                context,
                couponRequestMap[category['title']]?.isNotEmpty ?? false,
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget getHeader(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
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
                'Claim your reward',
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

  static Widget getHeaderForCoupons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Select Your Coupon Reward',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 12,
                  lWeight: FontWeight.w600,
                  color: AppColors.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildCategoryCard(
      String title,
      String emoji,
      Color backgroundColor,
      Function(String) onCategorySelected,
      BuildContext context,
      bool hasRequestedCoupons) {
    return GestureDetector(
      onTap: () async {
        await fetchCategoryCoupons(title);
        if (categoryCoupons.isNotEmpty) {
          // If coupons are available, show the coupon selection popup
          CouponPopupUtils.showCouponSelectionPopup(context, title);
        } else {
        
          // If no coupons, show the status in the card (handled in UI below)
          onCategorySelected(title);
          await getCouponRequestCheck(title.trim());
        }
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

  static void showCouponSelectionPopup(
      BuildContext context, String categoryTitle) async {
    await getCouponRequestCheck(categoryTitle);
if (MediaQuery.maybeOf(context) == null) {
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext sheetContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8, // Subtle shadow for depth
          backgroundColor: Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height / 2.2, // Compact height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                couponRequestMap[categoryTitle]?.isNotEmpty ?? false
                    ? SizedBox.shrink()
                    : getHeaderForCoupons(sheetContext),
                Expanded(
                  child: Obx(() => loadReaward.value
                      ? Center(child: Spinner())
                      : categoryCoupons.isEmpty
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: couponRequestMap[categoryTitle]
                                          ?.isNotEmpty ??
                                      false
                                  ? Column(
                                      children: [
                                        chatAvatartImage(
                                          url: ProfileIcons.noCoupons,
                                          height: 7,
                                          width: 3,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'No Rewards Yet!',
                                          style: FontManager().getTextStyle(
                                            context,
                                            fontSize: 16,
                                            lWeight: FontWeight.w600,
                                            color: AppColors.debitColor,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "Looks like you don't have any coupons right now.",
                                          style: FontManager().getTextStyle(
                                            context,
                                            fontSize: 14,
                                            lWeight: FontWeight.w400,
                                            color: AppColors.accentColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () {
                                            _showBrandSelectionDialog(
                                                context, categoryTitle);
                                          },
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width /
                                                2,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: AppColors.primaryColor,
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Request a Coupon',
                                                style:
                                                    FontManager().getTextStyle(
                                                  context,
                                                  fontSize: 16,
                                                  lWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(sheetContext);
                                          },
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width /
                                                2,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color:
                                                      AppColors.primaryColor),
                                              color: AppColors.backgroundColor,
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Cancel',
                                                style:
                                                    FontManager().getTextStyle(
                                                  context,
                                                  fontSize: 16,
                                                  lWeight: FontWeight.w600,
                                                  color: AppColors.accentColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          chatAvatartImage(
                                            url: ProfileIcons.noCoupons,
                                            height: 10,
                                            width: 3,
                                          ),
                                          Text(
                                            'No coupons available / Coupon request has already been initiated',
                                            style: FontManager().getTextStyle(
                                              context,
                                              fontSize: 12,
                                              lWeight: FontWeight.w500,
                                              color: AppColors.accentColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                            )
                          : EnvelopeGrid(categoryCoupons: categoryCoupons)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// New method to show the brand selection dialog
  static void _showBrandSelectionDialog(
      BuildContext context, String categoryTitle) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedBrand; // Track the selected brand

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height / 2.2,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Available coupon(s)',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 16,
                        lWeight: FontWeight.w600,
                        color: AppColors.bg1,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Maximum 3 items per row
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8, // Adjust for image and text
                        ),
                        itemCount:
                            (couponRequestMap[categoryTitle]?.length ?? 0) +
                                1, // +1 for "Other"
                        itemBuilder: (context, index) {
                          // Handle "Other" option
                          if (index ==
                              (couponRequestMap[categoryTitle]?.length ?? 0)) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedBrand = 'Other';
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: AppColors.backgroundColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Color.fromRGBO(146, 146, 146, 0.25),
                                      blurRadius: 4,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                  border: selectedBrand == 'Other'
                                      ? Border.all(
                                          color: AppColors.primaryColor,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 40,
                                      color: selectedBrand == 'Other'
                                          ? AppColors.primaryColor
                                          : AppColors.accentColor,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Other',
                                      style: FontManager().getTextStyle(
                                        context,
                                        fontSize: 14,
                                        lWeight: FontWeight.w600,
                                        color: selectedBrand == 'Other'
                                            ? AppColors.primaryColor
                                            : AppColors.bg1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          // Brand items
                          final brandData = couponRequestMap[categoryTitle]
                                  ?[index] ??
                              {"brand": "default_brand", "image": ""};
                          final brand = brandData["brand"] ?? "default_brand";
                          final imageUrl = brandData["image"] ?? "";
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedBrand = brand;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.backgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(146, 146, 146, 0.25),
                                    blurRadius: 4,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                                border: selectedBrand == brand
                                    ? Border.all(
                                        color: AppColors.primaryColor,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                              Icons.error,
                                              size: 60,
                                              color: selectedBrand == brand
                                                  ? AppColors.primaryColor
                                                  : AppColors.accentColor,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.image_not_supported,
                                          size: 60,
                                          color: selectedBrand == brand
                                              ? AppColors.primaryColor
                                              : AppColors.accentColor,
                                        ),
                                  SizedBox(height: 4),
                                  Text(
                                    brand,
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14,
                                      lWeight: FontWeight.w500,
                                      color: selectedBrand == brand
                                          ? AppColors.primaryColor
                                          : AppColors.bg1,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'Cancel',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 14,
                              lWeight: FontWeight.w600,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: selectedBrand != null
                              ? () async {
                                  await requestCoupon(
                                      context, categoryTitle, selectedBrand!);
                                  Navigator.of(dialogContext)
                                      .pop(); // Close brand selection dialog
                                  Navigator.of(context)
                                      .pop(); // Close parent dialog
                                }
                              : null, // Disable button if no brand is selected
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Done',
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 14,
                              lWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
    fetchClaimedCoupons();
    fetchCouponsCounts();
    getUserActity();
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
            icon: Icon(Icons.info, color: AppColors.primaryColor),
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
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 0.4,
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
                Obx(() => loadReaward.value
                    ? Center(child: Spinner())
                    : refreshCupon.value
                        ? _buildClaimedTab()
                        : _buildClaimedTab()),
                Obx(() => refreshCupon.value
                    ? _buildUnclaimedTab()
                    : _buildUnclaimedTab()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimedTab() {
    return loadReaward.value
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
              );
  }

  Widget _buildUnclaimedTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: userController.coupons.value <= 0
            ? 0
            : userController.coupons.value,
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
        updateClickOrViewCount(type: "viewCount", id: coupon.id);
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
                      errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(Icons.error)),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      onTap: () {
        if (userActivity != null &&
            userActivity!.todaysClaimCount!.count >=
                RewardScreenStrings().limitCount.value) {
          snackBarCalledfail(context, RewardScreenStrings().claimedAll.value);
        } else {
          callRewardApis(context);
        }
      },
      // onTap: () => CouponPopupUtils.showCouponPopup(context, (category) {
      //    fetchCategoryCoupons(category);
      //   CouponPopupUtils.showCouponSelectionPopup(context, category);
      // }),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.backgroundColor),
          child: ClipOval(
            child: Image.asset(
              'assets/icons/profileScreen/unc2.png', // your PNG path
              height: MediaQuery.sizeOf(context).height / 16,
              width: MediaQuery.sizeOf(context).width / 12,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
