
// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/reward.dart';
// import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
// import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
// import 'package:get/get.dart';
// import 'coupon_card.dart';

// RxString categorySelected = "".obs;

// class EnvelopeGrid extends StatefulWidget {
//   final RxList<CouponModel> categoryCoupons;

//   const EnvelopeGrid({Key? key, required this.categoryCoupons})
//       : super(key: key);

//   @override
//   _EnvelopeGridState createState() => _EnvelopeGridState();
// }

// class _EnvelopeGridState extends State<EnvelopeGrid> {
//   Timer? _animationTimer;
//   final Random _random = Random();
//   final List<GlobalKey<_AnimatedCouponEnvelopeState>> _envelopeKeys = [];

//   @override
//   void initState() {
//     super.initState();
//     for (int i = 0; i < widget.categoryCoupons.length; i++) {
//       _envelopeKeys.add(GlobalKey<_AnimatedCouponEnvelopeState>());
//     }
//     Future.delayed(Duration(milliseconds: 500), () {
//       _startSequentialAnimation();
//     });
//   }

//   void _startSequentialAnimation() {
//     _animationTimer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
//       final availableIndices = <int>[];
//       for (int i = 0; i < _envelopeKeys.length; i++) {
//         final state = _envelopeKeys[i].currentState;
//         if (state != null && !state.isAnimating) {
//           availableIndices.add(i);
//         }
//       }
//       if (availableIndices.isNotEmpty) {
//         final randomIndex =
//             availableIndices[_random.nextInt(availableIndices.length)];
//         _envelopeKeys[randomIndex].currentState?.startAnimation();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Regenerate keys dynamically
//     if (_envelopeKeys.length != widget.categoryCoupons.length) {
//       _envelopeKeys.clear();
//       for (int i = 0; i < widget.categoryCoupons.length; i++) {
//         _envelopeKeys.add(GlobalKey<_AnimatedCouponEnvelopeState>());
//       }
//     }

//     if (widget.categoryCoupons.isEmpty) {
//       return Center(
//         child: Text(
//           "No coupons available",
//           style: FontManager().getTextStyle(
//             context,
//             fontSize: 16,
//             lWeight: FontWeight.w400,
//           ),
//         ),
//       );
//     }

//     final isSingleCoupon = widget.categoryCoupons.length == 1;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     if (isSingleCoupon) {
//       return Center(
//         child: AnimatedCouponEnvelope(
//           key: _envelopeKeys[0],
//           coupon: widget.categoryCoupons[0],
//           onClaim: () {
//             if (widget.categoryCoupons.isNotEmpty) {
//               widget.categoryCoupons.removeAt(0);
//             }
//           },
//         ),
//       );
//     } else {
//       return GridView.builder(
//         padding: EdgeInsets.symmetric(
//           horizontal: screenWidth * 0.04,
//           vertical: screenHeight * 0.02,
//         ),
//         gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//           maxCrossAxisExtent: screenWidth * 0.3, // Responsive max width
//           mainAxisSpacing: screenWidth * 0.03,
//           crossAxisSpacing: screenWidth * 0.03,
//           childAspectRatio: 1.0,
//         ),
//         itemCount: widget.categoryCoupons.length,
//         itemBuilder: (context, index) {
//           return AnimatedCouponEnvelope(
//             key: _envelopeKeys[index],
//             coupon: widget.categoryCoupons[index],
//             onClaim: () {
//               if (index < widget.categoryCoupons.length) {
//                 widget.categoryCoupons.removeAt(index);
//               }
//             },
//           );
//         },
//       );
//     }
//   }
// }

// class AnimatedCouponEnvelope extends StatefulWidget {
//   final CouponModel coupon;
//   final VoidCallback onClaim;

//   const AnimatedCouponEnvelope({
//     Key? key,
//     required this.coupon,
//     required this.onClaim,
//   }) : super(key: key);

//   @override
//   _AnimatedCouponEnvelopeState createState() => _AnimatedCouponEnvelopeState();
// }

// class _AnimatedCouponEnvelopeState extends State<AnimatedCouponEnvelope>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> cardSlideAnimation;
//   bool isAnimating = false;
//   final UserController userController = Get.find<UserController>();

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 800),
//     );
//     cardSlideAnimation = Tween<double>(begin: 0, end: -30).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
    
//   }

//   Future<void> startAnimation() async {
//     if (isAnimating) return;
//     setState(() {
//       isAnimating = true;
//     });
//     await _controller.forward();
//     await Future.delayed(Duration(milliseconds: 300));
//     await _controller.reverse();
//     setState(() {
//       isAnimating = false;
//     });
//   }

//   void _showCouponCard(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           insetPadding: EdgeInsets.symmetric(
//             horizontal: MediaQuery.of(context).size.width * 0.05,
//             vertical: MediaQuery.of(context).size.height * 0.1,
//           ),
//           backgroundColor: Colors.transparent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: CouponCardWidget(
//             coupon: widget.coupon,
//             onClaim: () {},
//             parentContext: context,
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isSingleCoupon =
//         context.findAncestorWidgetOfExactType<EnvelopeGrid>()?.categoryCoupons.length == 1;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final envelopeSize = isSingleCoupon ? screenWidth * 0.55 : screenWidth * 0.25;
//     final fontSize = isSingleCoupon ? screenWidth * 0.04 : screenWidth * 0.03;

//     return GestureDetector(
//       onTap: () async {
//         Navigator.of(context).popUntil((route) => route.isFirst);
//         _showCouponCard(context);
//         await claimCoupon(context, widget.coupon.id, widget, widget.coupon);
//       },
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return SizedBox(
//             width: envelopeSize,
//             height: envelopeSize,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Envelope back
//                 Transform.translate(
//                   offset: Offset(0, isSingleCoupon ? -envelopeSize * 0.32 : -envelopeSize * 0.34),
//                   child: chatAvatartImage(
//                     url: 'assets/icons/profileScreen/envelopeBack.svg',
//                     height: isSingleCoupon ? envelopeSize * 0.025 : envelopeSize * 0.06,
//                     width: isSingleCoupon ? envelopeSize * 0.093 : envelopeSize * 0.2,
//                   ),
//                 ),
//                 // Animated card
//                 Transform.translate(
//                   offset: Offset(0, cardSlideAnimation.value * (isSingleCoupon ? 1.5 : 1.0)),
//                   child: Container(
//                     width: isSingleCoupon ? envelopeSize * 0.92 : envelopeSize * 0.9,
//                     height: isSingleCoupon ? envelopeSize * 0.5 : envelopeSize * 0.5,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(envelopeSize * 0.05),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: envelopeSize * 0.025,
//                           offset: Offset(0, envelopeSize * 0.0125),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
                      
//                       children: [
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(envelopeSize * 0.05),
//                             ),
//                             child: Center(
//                               child: Column(
//                                 // mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Row(
//                                    mainAxisAlignment: MainAxisAlignment.start, 
//                                     children:[
//                                         SizedBox(width: envelopeSize * 0.04),
//                                        widget.coupon.image.isNotEmpty
//                                         ? Image.network(
//                                             widget.coupon.image,
//                                             width: isSingleCoupon?fontSize * 3:fontSize * 1.5, // Adjust size as needed
//                                             height: isSingleCoupon?fontSize * 3:fontSize * 1.5,

                                            
//                                             errorBuilder: (context, error, stackTrace) => Icon(
//                                               Icons.broken_image,
//                                               size: fontSize * 1.5,
//                                               color: Colors.grey,
//                                             ),
//                                           )
//                                         : Icon(
//                                             Icons.image,
//                                             size: fontSize * 1.5,
//                                             color: Colors.grey,
//                                           ),
//                                             SizedBox(width: envelopeSize * 0.02),
//                                             Container(
//                                                width: isSingleCoupon?MediaQuery.sizeOf(context).width/3:MediaQuery.sizeOf(context).width/7,
//                                               child: Text(
//                                                                                    widget.coupon.brand,
//                                                                                   style: FontManager().getTextStyle(
//                                                                                     context,
//                                                                                     fontSize: fontSize,
//                                                                                     lWeight: FontWeight.w500,
//                                                                                     color: Color(0xFFEF4444),
//                                                                                   ),
//                                                                                   overflow: TextOverflow.ellipsis,
//                                                                                 ),
//                                             ),
//                                     ]
//                                   ),
                                 
                                
//                                   SizedBox(height: envelopeSize * 0.02),
//                                   Text(
//                                     '₹${widget.coupon.actualPricing}',
//                                     style: FontManager().getTextStyle(
//                                       context,
//                                       fontSize: fontSize,
//                                       lWeight: FontWeight.w500,
//                                       color: Color(0xFFEF4444),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                
//                 ),
//                 // Envelope front
//                 chatAvatartImage(
//                   url: 'assets/icons/profileScreen/envelopeFront.svg',
//                   height: isSingleCoupon ? envelopeSize * 0.027 : envelopeSize * 0.14,
//                   width: isSingleCoupon ? envelopeSize * 0.093 : envelopeSize * 0.2,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/reward.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:get/get.dart';
import 'coupon_card.dart';

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
            color: Colors.grey,
          ),
        ),
      );
    }

    // Duplicate the single coupon to simulate multiple coupons
    final coupon = widget.categoryCoupons[0];
    final duplicatedCoupons = List.filled(5, coupon); // Create 5 duplicates

    return Container(
      child: CarouselSlider.builder(
        itemCount: duplicatedCoupons.length,
        itemBuilder: (context, index, realIndex) {
          return CouponCarouselCard(
            coupon: duplicatedCoupons[index],
            onClaim: () {
              if (widget.categoryCoupons.isNotEmpty) {
                widget.categoryCoupons.removeAt(0);
                setState(() {}); // Refresh UI after removal
              }
            },
            isCentered: index == (duplicatedCoupons.length ~/ 2), // Highlight middle card
            screenWidth: screenWidth,
          );
        },
        options: CarouselOptions(
          height: screenHeight * 0.4,
          initialPage: duplicatedCoupons.length ~/ 2, // Start at middle card
          viewportFraction: 0.76, // Show partial cards on sides
          enlargeCenterPage: true, // Scale up center card
          enableInfiniteScroll: true, // Loop the carousel
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

  const CouponCarouselCard({
    Key? key,
    required this.coupon,
    required this.onClaim,
    required this.isCentered,
    required this.screenWidth,
  }) : super(key: key);

  void _showCouponCard(BuildContext context) {
    final confettiController = ConfettiController(
      duration: const Duration(milliseconds: 500),
    );

    // Show dialog and trigger confetti
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // Start confetti animation after dialog is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          confettiController.play();
        });

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.1,
          ),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CouponCardWidget(
                coupon: coupon,
                onClaim: () {},
                parentContext: context,
              ),
              ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                maxBlastForce: 20,
                minBlastForce: 5,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.2,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.yellow,
                  Colors.green,
                  Colors.purple,
                ],
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Dispose confetti controller when dialog is closed
      confettiController.dispose();
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
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenWidth * 0.04),
      child: Stack(
        clipBehavior: Clip.none, // Allow badge to overflow outside the card
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white, // Plain white background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCentered ? Colors.grey[300]! : Colors.grey[200]!,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isCentered ? 0.12 : 0.06),
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
                        fontSize: fontSize * 0.95, // Slightly smaller for hierarchy
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
                    onPressed: () async {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      _showCouponCard(context);
                      // await claimCoupon(context, coupon.id, this, coupon);
                      onClaim(); // Trigger removal and UI refresh
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor, // App theme color
                      foregroundColor: const Color(0xFF374151), // Dark grey text
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
          // Shiny Ribbon Badge
          Positioned(
            top: -screenWidth * 0.003, // Moved further up to be above the card
            left: -screenWidth * 0.04, // Adjusted to align with top-left corner
            child: Transform.rotate(
              angle: -0.785, // 45-degree rotation for ribbon effect
              child: Stack(
                children: [
                  // Main ribbon body
                  Container(
                    width: screenWidth * 0.13,
                    height: screenWidth * 0.05,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                  // Folded ribbon effect (triangle overlay)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Transform.rotate(
                      angle: 0.785, // Counter-rotate for fold
                      child: ClipPath(
                        clipper: TriangleClipper(),
                        child: Container(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ),
                  // Glossy shine overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 0.3, 0.6],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Ribbon text
                ],
              ),
            ),
          ),
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