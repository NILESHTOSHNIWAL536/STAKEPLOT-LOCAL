
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'dart:math' as math;
import 'dart:async';

class RewardsOverview extends StatefulWidget {
  @override
  _RewardsOverviewState createState() => _RewardsOverviewState();
}

class _RewardsOverviewState extends State<RewardsOverview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // List of categories for horizontal scroll
  final List<Map<String, dynamic>> categories = [
    {'title': 'Food &\nBeverages', 'emoji': '🍕', 'color': Colors.orange.shade100},
    {'title': 'Shopping', 'emoji': '🛍️', 'color': Colors.purple.shade100},
    {'title': 'Delivery', 'emoji': '🚚', 'color': Colors.blue.shade100},
    {'title': 'Travel', 'emoji': '✈️', 'color': Colors.green.shade100},
    {'title': 'Entertainment', 'emoji': '🎬', 'color': Colors.red.shade100},
    {'title': 'Health', 'emoji': '🏥', 'color': Colors.teal.shade100},
    {'title': 'Beauty', 'emoji': '💄', 'color': Colors.pink.shade100},
    {'title': 'Electronics', 'emoji': '📱', 'color': Colors.indigo.shade100},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'Rewards',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
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
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              tabs: [
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
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _buildRewardCard();
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
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildEnvelopeCard();
        },
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8D5FF),
                    Color(0xFFD4B5FF),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 8,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'derma',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProductIcon(Colors.purple),
                        _buildProductIcon(Colors.green),
                        _buildProductIcon(Colors.purple),
                        _buildProductIcon(Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flat ₹199 off',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'on order of ₹499 & above from derma co at play',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
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
    );
  }

  Widget _buildProductIcon(Color color) {
    return Container(
      width: 20,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
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
                // Close button
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
                
                // Gift icon and title
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Subtitle
                Text(
                  'You selected 2 transactions.\nAs a reward',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24),
                
                // Select category title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select the category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                
                // Horizontal scrollable category cards
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
        Navigator.of(context).pop(); // Close first popup
        _showCouponSelectionPopup(context, title); // Show second popup
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
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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
                // Close button
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
                
                // Gift icon and title
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Subtitle
                Text(
                  'pick one coupon below',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 24),
                
                // Grid of coupon envelopes with animation controller
                Expanded(
                  child: EnvelopeGrid(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Simplified approach - Grid with built-in animation management
class EnvelopeGrid extends StatefulWidget {
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
    // Initialize keys for 9 envelopes
    for (int i = 0; i < 9; i++) {
      _envelopeKeys.add(GlobalKey<_AnimatedCouponEnvelopeState>());
    }
    
    // Start sequential animation after a short delay
    Future.delayed(Duration(milliseconds: 1000), () {
      _startSequentialAnimation();
    });
  }

  void _startSequentialAnimation() {
    _animationTimer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
      // Get available envelopes (not currently animating)
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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return AnimatedCouponEnvelope(
          key: _envelopeKeys[index],
          index: index,
        );
      },
    );
  }
}

class AnimatedCouponEnvelope extends StatefulWidget {
  final int index;

  const AnimatedCouponEnvelope({Key? key, required this.index}) : super(key: key);

  @override
  _AnimatedCouponEnvelopeState createState() => _AnimatedCouponEnvelopeState();
}

class _AnimatedCouponEnvelopeState extends State<AnimatedCouponEnvelope>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> cardSlideAnimation;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    // Card sliding up and down animation
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
          backgroundColor: Colors.transparent,
          child: CouponCardWidget(
            brandName: _getBrandName(widget.index),
            discount: (widget.index + 1) * 5,
            couponCode: _generateCouponCode(),
            index: widget.index,
          ),
        );
      },
    );
  }

  String _getBrandName(int index) {
    final brands = ['KFC', 'McDonald\'s', 'Pizza Hut', 'Domino\'s', 'Subway', 'Starbucks', 'Burger King', 'Taco Bell', 'Dunkin\''];
    return brands[index % brands.length];
  }

  String _generateCouponCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      20, (_) => chars.codeUnitAt(random.nextInt(chars.length))
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCouponCard(context),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. BACK PART - Behind everything
                Transform.translate(
                  offset: Offset(0, -23),
                  child: Positioned.fill(
                    child: chatAvatartImage(
                      url: 'assets/icons/profileScreen/envelopeBack.svg',
                      height: 17,
                      width: 17,
                    ),
                  ),
                ),

                // 2. MIDDLE PART - Animated coupon card (smooth up/down movement)
                Transform.translate(
                  offset: Offset(1, cardSlideAnimation.value),
                  child: Container(
                    width: 60,
                    height: 50,
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
                        // Dynamic coupon content
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
                                    '₹${(widget.index + 1) * 50}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                  Text(
                                    'OFF',
                                    style: TextStyle(
                                      fontSize: 8,
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

                // 3. FRONT PART - Envelope front on top
                Positioned.fill(
                  child: Container(
                    child: chatAvatartImage(
                      url: 'assets/icons/profileScreen/envelopeFront.svg',
                      height: 10,
                      width: 3,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CouponCardWidget extends StatelessWidget {
  final String brandName;
  final int discount;
  final String couponCode;
  final int index;

  const CouponCardWidget({
    Key? key,
    required this.brandName,
    required this.discount,
    required this.couponCode,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: CouponCard(
        height: 600,
        backgroundColor: Colors.white,
        curveAxis: Axis.horizontal,
        curvePosition: 250, // Center position for curves
        curveRadius: 20,
        borderRadius: 16,
        // border: Border.all(color: Colors.grey.shade200, width: 1),
        firstChild: Container(
          height: 250, // Equal height for first section
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand and discount row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand logo/name
                  Text(
                    brandName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53E3E), // KFC red color
                    ),
                  ),
                  // Discount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$discount% OFF',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        brandName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Main offer text
              Text(
                'Get $discount% off at your next $brandName buy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              // Terms and conditions
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('Redeemable at all $brandName restaurants in INDIA.'),
                  SizedBox(height: 6),
                  _buildBulletPoint('Not valid with any other discounts and promotions.'),
                  SizedBox(height: 6),
                  _buildBulletPoint('No cash value.'),
                ],
              ),
            ],
          ),
        ),
        secondChild: Container(
          height: 250, // Equal height for second section
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Copy code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Code container
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            couponCode,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: couponCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Coupon code copied!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Partnership text
                  Text(
                    'In partnership with fishmydeal - exclusively on Stakeplot',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Coupon saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4C51BF), // Purple color
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 6, right: 8),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}