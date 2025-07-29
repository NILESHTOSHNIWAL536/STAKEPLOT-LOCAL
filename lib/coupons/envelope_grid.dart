
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/reward.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
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
  Timer? _animationTimer;
  final Random _random = Random();
  final List<GlobalKey<_AnimatedCouponEnvelopeState>> _envelopeKeys = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.categoryCoupons.length; i++) {
      _envelopeKeys.add(GlobalKey<_AnimatedCouponEnvelopeState>());
    }
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
  Widget build(BuildContext context) {
    // Regenerate keys dynamically
    if (_envelopeKeys.length != widget.categoryCoupons.length) {
      _envelopeKeys.clear();
      for (int i = 0; i < widget.categoryCoupons.length; i++) {
        _envelopeKeys.add(GlobalKey<_AnimatedCouponEnvelopeState>());
      }
    }

    if (widget.categoryCoupons.isEmpty) {
      return Center(
        child: Text(
          "No coupons available",
          style: FontManager().getTextStyle(
            context,
            fontSize: 16,
            lWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final isSingleCoupon = widget.categoryCoupons.length == 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: screenWidth * 0.3, // Responsive max width
          mainAxisSpacing: screenWidth * 0.03,
          crossAxisSpacing: screenWidth * 0.03,
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

  const AnimatedCouponEnvelope({
    Key? key,
    required this.coupon,
    required this.onClaim,
  }) : super(key: key);

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

  void _showCouponCard(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.1,
          ),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: CouponCardWidget(
            coupon: widget.coupon,
            onClaim: () {},
            parentContext: context,
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
    final isSingleCoupon =
        context.findAncestorWidgetOfExactType<EnvelopeGrid>()?.categoryCoupons.length == 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final envelopeSize = isSingleCoupon ? screenWidth * 0.55 : screenWidth * 0.25;
    final fontSize = isSingleCoupon ? screenWidth * 0.04 : screenWidth * 0.03;

    return GestureDetector(
      onTap: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        _showCouponCard(context);
        await claimCoupon(context, widget.coupon.id, widget, widget.coupon);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: envelopeSize,
            height: envelopeSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Envelope back
                Transform.translate(
                  offset: Offset(0, isSingleCoupon ? -envelopeSize * 0.32 : -envelopeSize * 0.34),
                  child: chatAvatartImage(
                    url: 'assets/icons/profileScreen/envelopeBack.svg',
                    height: isSingleCoupon ? envelopeSize * 0.025 : envelopeSize * 0.06,
                    width: isSingleCoupon ? envelopeSize * 0.093 : envelopeSize * 0.2,
                  ),
                ),
                // Animated card
                Transform.translate(
                  offset: Offset(0, cardSlideAnimation.value * (isSingleCoupon ? 1.5 : 1.0)),
                  child: Container(
                    width: isSingleCoupon ? envelopeSize * 0.92 : envelopeSize * 0.9,
                    height: isSingleCoupon ? envelopeSize * 0.5 : envelopeSize * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(envelopeSize * 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: envelopeSize * 0.025,
                          offset: Offset(0, envelopeSize * 0.0125),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(envelopeSize * 0.05),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                   mainAxisAlignment: MainAxisAlignment.center, 
                                    children:[
                                       widget.coupon.image.isNotEmpty
                                        ? Image.network(
                                            widget.coupon.image,
                                            width: isSingleCoupon?fontSize * 2.5:fontSize * 1.5, // Adjust size as needed
                                            height: isSingleCoupon?fontSize * 2.5:fontSize * 1.5,

                                            
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              Icons.broken_image,
                                              size: fontSize * 1.5,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Icon(
                                            Icons.image,
                                            size: fontSize * 1.5,
                                            color: Colors.grey,
                                          ),
                                            SizedBox(width: envelopeSize * 0.02),
                                            Text(
                                    widget.coupon.brand.length > 9
                                        ? '${widget.coupon.brand.substring(0, 9)}...'
                                        : widget.coupon.brand,
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: fontSize,
                                      lWeight: FontWeight.w500,
                                      color: Color(0xFFEF4444),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                    ]
                                  ),
                                 
                                
                                  SizedBox(height: envelopeSize * 0.02),
                                  Text(
                                    '₹${widget.coupon.actualPricing}',
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: fontSize,
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
                  height: isSingleCoupon ? envelopeSize * 0.027 : envelopeSize * 0.14,
                  width: isSingleCoupon ? envelopeSize * 0.093 : envelopeSize * 0.2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}