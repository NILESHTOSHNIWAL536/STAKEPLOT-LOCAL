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
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'coupon_card.dart'; // Import CouponCardWidget
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class EnvelopeGrid extends StatefulWidget {
  final RxList<CouponModel> categoryCoupons;

  const EnvelopeGrid({Key? key, required this.categoryCoupons})
      : super(key: key);

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
    // Reduced delay from 1000ms to 500ms for faster animation start
    Future.delayed(Duration(milliseconds: 500), () {
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
        final randomIndex =
            availableIndices[_random.nextInt(availableIndices.length)];
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

  const AnimatedCouponEnvelope(
      {Key? key, required this.coupon, required this.onClaim})
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
    cardSlideAnimation = Tween<double>(begin: 0, end: -30).animate(
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

  Future<void> _claimCoupon(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) return;

      // PATCH call for claiming coupon
      final response = await http.patch(
        Uri.parse('$url/reward/claim/${widget.coupon.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      if (getFlagOfResponse(response)) {
        userController.coupons.value--;
        widget.onClaim();
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle error silently as per your code
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
            onClaim: () {},
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
        final isSingleCoupon = context.findAncestorWidgetOfExactType<EnvelopeGrid>()?.categoryCoupons.length == 1;

   return GestureDetector(
      onTap: () async{
      await _claimCoupon(context); // Explicitly assign to bool
       
          _showCouponCard(context);
        

      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            // Increase size for single coupon
            width: isSingleCoupon ? 220 : 80,
            height: isSingleCoupon ? 220 : 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Envelope back
                Transform.translate(
                  offset: Offset(0, isSingleCoupon ? -34.5 : -23), // Scaled offset for larger size
                  child: chatAvatartImage(
                    url: 'assets/icons/profileScreen/envelopeBack.svg',
                    height: isSingleCoupon ? 25.5 : 17, // Scaled size
                    width: isSingleCoupon ? 25.5 : 17,
                  ),
                ),
                // Animated card
                Transform.translate(
                  offset: Offset(1, cardSlideAnimation.value),
                  child: Container(
                    width: isSingleCoupon ? 90 : 60, // Scaled size
                    height: isSingleCoupon ? 75 : 50,
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
                                    '${widget.coupon.brand}',
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: isSingleCoupon ? 24 : 12, // Larger font for single coupon
                                      lWeight: FontWeight.w500,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.coupon.actualPricing}',
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: isSingleCoupon ? 24 : 12, // Larger font for single coupon
                                      lWeight: FontWeight.w500,
                                      color: Color(0xFFEF4444),
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
                  height: isSingleCoupon ? 15 : 10, // Scaled size
                  width: isSingleCoupon ? 4.5 : 3,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
