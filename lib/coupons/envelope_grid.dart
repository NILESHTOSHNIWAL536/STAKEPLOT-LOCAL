import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/reward.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'coupon_card.dart';
import 'rewards_overview.dart';

RxString categorySelected = "".obs;

class EnvelopeGrid extends StatefulWidget {
  final RxList<CouponModel> categoryCoupons;

  const EnvelopeGrid({Key? key, required this.categoryCoupons})
      : super(key: key);

  @override
  _EnvelopeGridState createState() => _EnvelopeGridState();
}

class _EnvelopeGridState extends State<EnvelopeGrid> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.categoryCoupons.isEmpty) {
      return Center(
        child: Text(
          "No coupons available",
          style: FontManager().getTextStyle(
            context,
            fontSize: 18,
            lWeight: FontWeight.w400,
            color: AppColors.greyColor,
          ),
        ),
      );
    }
    
    return Container(
      child: CarouselSlider.builder(
        itemCount: widget.categoryCoupons.length,
        itemBuilder: (context, index, realIndex) {
          return CouponCarouselCard(
            coupon: widget.categoryCoupons[index],
            dialogContext: context,
            onClaim: () {
              if (widget.categoryCoupons.isNotEmpty) {
                widget.categoryCoupons.removeAt(index);
                setState(() {}); // Refresh UI after removal
              }
            },
            isCentered: index ==
                (widget.categoryCoupons.length ~/ 2), // Highlight middle card
            screenWidth: screenWidth,
          );
        },
        options: CarouselOptions(
          height: screenHeight * 0.4,
          initialPage:
              widget.categoryCoupons.length ~/ 2, // Start at middle card
          viewportFraction: 0.76, // Show partial cards on sides
          enlargeCenterPage: true, // Scale up center card
          enableInfiniteScroll:
              widget.categoryCoupons.length > 1, // Loop the carousel
          scrollPhysics: const BouncingScrollPhysics(),
          autoPlay: false, // Disable auto-play for user control
        ),
      ),
    );
  }
}

class CouponCarouselCard extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback onClaim;
  final bool isCentered;
  final double screenWidth;
  BuildContext dialogContext;

  CouponCarouselCard({
    Key? key,
    required this.coupon,
    required this.onClaim,
    required this.isCentered,
    required this.screenWidth,
    required this.dialogContext,
  }) : super(key: key);

  void _showCouponCard(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.1,
          ),
          backgroundColor: AppColors.transparentColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: CouponCardWidget(
            coupon: coupon,
            onClaim: () {},
            parentContext: context,
          ),
        );
      },
    );
  }

  void _showLottieAnimation(BuildContext context) {
     
  // Call the API first
  
  claimCoupon(context, coupon.id, this, coupon).then((success) {
    
    if (success) {
      // Show Lottie animation only on API success
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.accentColor.withOpacity(0.5),
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => false, // Prevent dismissing during animation
            child: Center(
              child: Lottie.asset(
                'assets/splashScreen/coupon.json', // Ensure this path matches your Lottie file
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
                fit: BoxFit.contain,
                repeat: false,
                onLoaded: (composition) {
                  // Automatically close animation dialog and proceed after animation completes
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(dialogContext).pop(); // Close animation dialog
                    Navigator.of(context).popUntil((route) => route.isFirst); // Navigate back to first route
                    _showCouponCard(context); // Show the coupon card
                    // onClaim(); // Trigger removal and UI refresh
                  });
                },
              ),
            ),
          );
        },
      );
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
      // Handle API failure
      snackBarCalledfail(context, "Failed to claim ");
    }
  });
}
  @override
  Widget build(BuildContext context) {
    final cardWidth = screenWidth * 0.76; // Adjusted for golden ratio
    final cardHeight = cardWidth * 0.64; // Approx golden ratio height
    final fontSize = screenWidth * 0.04; // Base font size for scaling

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenWidth * 0.04),
      child: Stack(
        clipBehavior: Clip.none, // Allow badge to overflow outside the card
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor, // Plain white background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCentered ? Colors.grey[300]! : Colors.grey[200]!,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(isCentered ? 0.12 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Coupon Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: coupon.image.isNotEmpty
                        ? Image.network(
                            coupon.image,
                            width: fontSize * 5.5,
                            height: fontSize * 3.5,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: fontSize * 1.8,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(
                            Icons.image,
                            size: fontSize * 1.8,
                            color: Colors.grey[400],
                          ),
                  ),
                  SizedBox(height: screenWidth * 0.015), // Reduced spacing
                  // Brand Name
                  Container(
                    width: cardWidth * 0.9,
                    child: Text(
                      coupon.brand,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: fontSize * 1.2, // Prominent brand
                        lWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.05), // Reduced spacing
                  // Coupon Title
                  Container(
                    width: cardWidth * 1,
                    child: Text(
                      coupon.title,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize:
                            fontSize * 0.95, // Slightly smaller for hierarchy
                        lWeight: FontWeight.w500,
                        color: AppColors.accentColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02), // Reduced spacing
                  // Coupon Description
                  Container(
                    width: cardWidth * 0.9,
                    child: Text(
                      coupon.description,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: fontSize * 0.7, // Smallest for secondary info
                        lWeight: FontWeight.w400,
                        color: AppColors.grey,
                        lineHeight: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 7,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.018), // Reduced spacing
                  // Claim Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialofBoxContext);
                      HapticFeedback.heavyImpact();
                      _showLottieAnimation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryColor, // App theme color
                      foregroundColor:
                          const Color(0xFF374151), // Dark grey text
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenWidth * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Claim',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: fontSize * 0.9,
                        lWeight: FontWeight.w600, // Stronger weight for CTA
                        color: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          Positioned(
              top: screenWidth * 0.002, // Moved further up to be above the card
              right:
                  screenWidth * 0.002, // Adjusted to align with top-left corner
              child: Transform.rotate(
                angle: 0, // 45-degree rotation for ribbon effect
                child: chatAvatartImage(
                  url: ProfileIcons.tag,
                  height: 30,
                  width: 8,
                ),
              )),
        ],
      ),
    );
  }
}

// Custom clipper for folded ribbon effect
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
