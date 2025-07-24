// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
// import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'coupon_card.dart'; // Import CouponCardWidget
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

// class EnvelopeGrid extends StatefulWidget {
//   final RxList<CouponModel> categoryCoupons;

//   const EnvelopeGrid({Key? key, required this.categoryCoupons}) : super(key: key);

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
//     Future.delayed(Duration(milliseconds: 50), () {
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
//         final randomIndex = availableIndices[_random.nextInt(availableIndices.length)];
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
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 1.0,
//       ),
//       itemCount: widget.categoryCoupons.length,
//       itemBuilder: (context, index) {
//         return AnimatedCouponEnvelope(
//           key: _envelopeKeys[index],
//           coupon: widget.categoryCoupons[index],
//           onClaim: () {
//             setState(() {
//               widget.categoryCoupons.removeAt(index);
//             });
//           },
//         );
//       },
//     );
//   }
// }

// class AnimatedCouponEnvelope extends StatefulWidget {
//   final CouponModel coupon;
//   final VoidCallback onClaim;

//   const AnimatedCouponEnvelope({Key? key, required this.coupon, required this.onClaim})
//       : super(key: key);

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
//     await Future.delayed(Duration(milliseconds: 100));
//     await _controller.reverse();
//     setState(() {
//       isAnimating = false;
//     });
//   }

//   Future<void> _claimCoupon(BuildContext context) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("accessToken");
//       if (token == null) return;

//       // Changed to PATCH call
//       final response = await http.patch(
//         Uri.parse('$url/reward/claim/${widget.coupon.id}'),
//         headers: {
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Authorization': token,
//         },
//       );

//       if (response.statusCode == 200) {
//         userController.coupons.value--;
//         widget.onClaim();
//         Navigator.of(context).pop();
//       }
//     } catch (e) {
//       // Handle error silently as per your code
//     }
//   }

//   void _showCouponCard(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: CouponCardWidget(
//             coupon: widget.coupon,
//             onClaim: () => _claimCoupon(context),
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
//     return GestureDetector(
//       onTap: () => _showCouponCard(context),
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return SizedBox(
//             width: 80,
//             height: 80,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Transform.translate(
//                   offset: Offset(0, -23),
//                   child: Positioned.fill(
//                     child: chatAvatartImage(
//                       url: 'assets/icons/profileScreen/envelopeBack.svg',
//                       height: 17,
//                       width: 17,
//                     ),
//                   ),
//                 ),
//                 Transform.translate(
//                   offset: Offset(1, cardSlideAnimation.value),
//                   child: Container(
//                     width: 60,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 2,
//                           offset: Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     '₹${widget.coupon.actualPricing}',
//                                     style: FontManager().getTextStyle(
//                                       context,
//                                       fontSize: 16,
//                                       lWeight: FontWeight.w500,
//                                       color: Color(0xFFEF4444),
//                                     ),
//                                   ),
//                                   Text(
//                                     'OFF',
//                                     style: TextStyle(
//                                       fontSize: 8,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.grey.shade600,
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
//                 Positioned.fill(
//                   child: Container(
//                     child: chatAvatartImage(
//                       url: 'assets/icons/profileScreen/envelopeFront.svg',
//                       height: 10,
//                       width: 3,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'coupon_card.dart'; // Import CouponCardWidget
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class EnvelopeGrid extends StatefulWidget {
  final RxList<CouponModel> categoryCoupons;

  const EnvelopeGrid({Key? key, required this.categoryCoupons}) : super(key: key);

  @override
  _EnvelopeGridState createState() => _EnvelopeGridState();
}

class _EnvelopeGridState extends State<EnvelopeGrid> {
  Timer? _animationTimer;
  final Random _random = Random();
  final List<GlobalKey<_AnimatedCouponEnvelopeState>> _envelopeKeys = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.categoryCoupons.length; i++) {
      _envelopeKeys.add(GlobalKey<_AnimatedCouponEnvelopeState>());
    }
    // Animation delay set to 0ms as per your code
    Future.delayed(Duration(milliseconds: 0), () {
      _startSequentialAnimation();
    });
  }

  void _startSequentialAnimation() {
    _animationTimer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
      final availableIndices = <int>[];
      for (int i = 0; i < _envelopeKeys.length; i++) {
        final state = _envelopeKeys[i].currentState;
        if (state != null && !state.isAnimating) {
          availableIndices.add(i);
        }
      }
      if (availableIndices.isNotEmpty) {
        final randomIndex = availableIndices[_random.nextInt(availableIndices.length)];
        _envelopeKeys[randomIndex].currentState?.startAnimation();
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Regenerate keys dynamically
    if (_envelopeKeys.length != widget.categoryCoupons.length) {
      _envelopeKeys.clear();
      for (int i = 0; i < widget.categoryCoupons.length; i++) {
        _envelopeKeys.add(GlobalKey<_AnimatedCouponEnvelopeState>());
      }
    }

    if (widget.categoryCoupons.isEmpty) {
      return Center(child: Text("No coupons available"));
    }

    final isSingleCoupon = widget.categoryCoupons.length == 1;

    if (isSingleCoupon) {
      return Center(
        child: AnimatedCouponEnvelope(
          key: _envelopeKeys[0],
          coupon: widget.categoryCoupons[0],
          onClaim: () {
            if (widget.categoryCoupons.isNotEmpty) {
              widget.categoryCoupons.removeAt(0);
            }
          },
        ),
      );
    } else {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: widget.categoryCoupons.length,
        itemBuilder: (context, index) {
          return AnimatedCouponEnvelope(
            key: _envelopeKeys[index],
            coupon: widget.categoryCoupons[index],
            onClaim: () {
              if (index < widget.categoryCoupons.length) {
                widget.categoryCoupons.removeAt(index);
              }
            },
          );
        },
      );
    }
  }
}

class AnimatedCouponEnvelope extends StatefulWidget {
  final CouponModel coupon;
  final VoidCallback onClaim;

  const AnimatedCouponEnvelope({Key? key, required this.coupon, required this.onClaim})
      : super(key: key);

  @override
  _AnimatedCouponEnvelopeState createState() => _AnimatedCouponEnvelopeState();
}

class _AnimatedCouponEnvelopeState extends State<AnimatedCouponEnvelope>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> cardSlideAnimation;
  bool isAnimating = false;
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    // Restored animation range to prevent card from going too far down
    cardSlideAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> startAnimation() async {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
    });
    await _controller.forward();
    await Future.delayed(Duration(milliseconds: 300));
    await _controller.reverse();
    setState(() {
      isAnimating = false;
    });
  }

  Future<bool> _claimCoupon(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) return false;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: Spinner());
        },
      );

      // PATCH call for claiming coupon
      final response = await http.patch(
        Uri.parse('$url/reward/claim/${widget.coupon.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      // Close loading indicator
      Navigator.of(context).pop();

      if (getFlagOfResponse(response)) {
        userController.coupons.value--;
        widget.onClaim();
        return true;
      }
      return false;
    } catch (e) {
      // Close loading indicator on error
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      // Handle error silently as per your code
      return false;
    }
  }

  void _showCouponCard(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: CouponCardWidget(
            coupon: widget.coupon,
            onClaim: () {}, // No-op since claim is handled on tap
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSingleCoupon = context.findAncestorWidgetOfExactType<EnvelopeGrid>()?.categoryCoupons.length == 1;

    // Responsive sizes based on screen width
    final cardSize = isSingleCoupon ? screenWidth * 0.4 : screenWidth * 0.2; // 40% for single, 20% for grid
    final envelopeBackSize = cardSize * 0.2125; // Scaled from 17/80
    final envelopeFrontHeight = cardSize * 0.125; // Scaled from 10/80
    final envelopeFrontWidth = cardSize * 0.0375; // Scaled from 3/80
    final innerCardWidth = cardSize * 0.75; // Scaled from 60/80
    final innerCardHeight = cardSize * 0.625; // Scaled from 50/80
    final priceFontSize = cardSize * 0.2; // Scaled from 16/80
    final offFontSize = cardSize * 0.1; // Scaled from 8/80
    final envelopeBackOffset = cardSize * -0.2875; // Scaled from -23/80

    return GestureDetector(
      onTap: () async {
        // Trigger claim API call on envelope tap
        final bool success = await _claimCoupon(context);
        if (success) {
          // Show coupon details only if claim is successful
          _showCouponCard(context);
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: cardSize,
            height: cardSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Envelope back
                Transform.translate(
                  offset: Offset(0, envelopeBackOffset),
                  child: chatAvatartImage(
                    url: 'assets/icons/profileScreen/envelopeBack.svg',
                    height: envelopeBackSize,
                    width: envelopeBackSize,
                  ),
                ),
                // Animated card
                Transform.translate(
                  offset: Offset(1, cardSlideAnimation.value),
                  child: Container(
                    width: innerCardWidth,
                    height: innerCardHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '₹${widget.coupon.actualPricing}',
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: priceFontSize,
                                      lWeight: FontWeight.w500,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                  Text(
                                    'OFF',
                                    style: TextStyle(
                                      fontSize: offFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Envelope front
                chatAvatartImage(
                  url: 'assets/icons/profileScreen/envelopeFront.svg',
                  height: envelopeFrontHeight,
                  width: envelopeFrontWidth,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}