import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'dart:math';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late SwiperController _swiperController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _tiltAnimation;
  int _currentCardIndex = 0;

  // Sample data for insights cards with rupee symbol
  final List<Map<String, dynamic>> _insightsData = [
    {
      'title': 'Heads up',
      'message': 'Travel expenses dropped by 40% this month-working from home, eh?',
    },
    {
      'title': 'Heads up',
      'message': '₹0 spent on Zomato and Swiggy this week – chef test in the house? 👨‍🍳',
    },
    {
      'title': 'Heads up',
      'message': 'You\'ve saved ₹120 more this month compared to your average.',
    },
    {
      'title': 'Heads up',
      'message': 'Your subscription renewal is due in 3 days.',
    },
  ];

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'title': 'Heads up',
      'icon': Icons.send,
      'color': const Color(0xFF00565E),
      'backgroundColor': const Color(0xFF00565E),
    },
    {
      'title': 'Money Map',
      'icon': Icons.attach_money,
      'color': Colors.grey,
      'backgroundColor': Colors.grey[300],
    },
  ];

  // Function to dynamically assign icons based on text content
  IconData getIconForInsight(String title, String message) {
    if (message.contains('Travel') || message.toLowerCase().contains('travel')) {
      return Icons.flight;
    } else if (message.toLowerCase().contains('Zomato')) {
      return Icons.shopping_cart;
    } else if (message.toLowerCase().contains('saved')) {
      return Icons.savings;
    } else if (message.contains('subscription') || message.toLowerCase().contains('subscription')) {
      return Icons.subscriptions;
    }
    return Icons.info; // Fallback icon
  }

  // Function to assign colors based on index or content
  Color getColorForInsight(int index) {
    const colors = [
      Color.fromARGB(255, 36, 55, 57),
      Color.fromARGB(255, 150, 193, 108),
      Color.fromARGB(255, 224, 150, 86),
      Color.fromARGB(255, 77, 79, 217),
    ];
    return colors[index % colors.length];
  }

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Add tilt animation for cards
    _tiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.2,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen = constraints.maxWidth > 600;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your Insights',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              // Main content area with animated stacked cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 500 : 400,
                        maxHeight: 320,
                      ),
                      child: _insightsData.isEmpty
                          ? const Center(child: Text('No insights available'))
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Swiper(
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return Transform(
                                            transform: Matrix4.identity()
                                              ..scale(_scaleAnimation.value)
                                              ..rotateZ(_currentCardIndex == index
                                                  ? _tiltAnimation.value
                                                  : 0),
                                            alignment: Alignment.center,
                                            child: child,
                                          );
                                        },
                                        child: InsightCard(
                                          title: _insightsData[index]['title'],
                                          message: _insightsData[index]['message'],
                                          color: getColorForInsight(index),
                                          icon: getIconForInsight(
                                            _insightsData[index]['title'],
                                            _insightsData[index]['message'],
                                          ),
                                          width: isWideScreen ? 450 : 350,
                                        ),
                                      );
                                    },
                                    itemCount: _insightsData.length,
                                    controller: _swiperController,
                                    layout: SwiperLayout.TINDER,
                                    itemWidth: isWideScreen ? 450 : 350,
                                    itemHeight: 220,
                                    loop: true,
                                    duration: 400,
                                    autoplay: false,
                                    onIndexChanged: (index) {
                                      setState(() {
                                        _currentCardIndex = index;
                                        _animationController.reset();
                                        _animationController.forward();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              getMoneyMap(),
            ],
          );
        },
      ),
    );
  }

  Widget getMoneyMap() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _navigationItems.length,
          (index) => NavItem(
            title: _navigationItems[index]['title'],
            icon: _navigationItems[index]['icon'],
            isSelected: _selectedIndex == index,
            color: _navigationItems[index]['color'],
            backgroundColor: _navigationItems[index]['backgroundColor'],
            onTap: () => _onItemTapped(index),
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const NavItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSelected ? backgroundColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? backgroundColor : Colors.grey[200],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final double width;

  const InsightCard({
    Key? key,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'card-$title',
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon with reduced opacity
            Positioned(
              right: 10,
              bottom: 10,
              child: Opacity(
                opacity: 0.25, // Slightly increased for visibility, adjust as needed
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            // Card content (fully opaque)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}