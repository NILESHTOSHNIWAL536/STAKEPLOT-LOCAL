import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/insightsController.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

// Utility class for responsive sizing
class ResponsiveUtils {
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 500;
    if (width > 600) return 450;
    return width * 0.85;
  }

  static double getCardHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.25;
  }

  static double getFontSize(BuildContext context, double baseSize) {
    final scale = MediaQuery.of(context).textScaler.scale(1.0);
    return baseSize * scale;
  }

  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return EdgeInsets.symmetric(
      horizontal: width > 600 ? 12.0 : 8.0,
      vertical: width > 600 ? 10.0 : 8.0,
    );
  }
}

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
  bool _isLoading = true;
  String? _errorMessage;
  final InsightsController _controller = Get.put(InsightsController());

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'title': 'Heads up',
      'icon': Icons.send,
      'color': const Color(0xFF00565E),
      'backgroundColor': const Color(0xFF00565E),
    },
    {
      'title': 'Money Map',
      'icon': Icons.currency_rupee_rounded,
      'color': const Color(0xFF00565E),
      'backgroundColor': const Color(0xFF00565E),
    },
  ];

  IconData getIconForInsight(String title, String message) {
    final lowerMessage = message.toLowerCase();
    const keywordIconMap = {
      'saved': Icons.savings,
      'save': Icons.savings,
      'savings': Icons.savings,
      'shopping': Icons.shopping_cart,
      'shop': Icons.shopping_cart,
      'purchase': Icons.shopping_cart,
      'purchases': Icons.shopping_cart,
      'zomato': Icons.restaurant,
      'swiggy': Icons.restaurant,
      'dining': Icons.restaurant,
      'food': Icons.restaurant,
      'chef': Icons.restaurant,
      'travel': Icons.flight,
      'trip': Icons.flight,
      'journey': Icons.flight,
      'subscription': Icons.subscriptions,
      'subscribe': Icons.subscriptions,
      'warning': Icons.warning,
      'overboard': Icons.warning,
      'overspend': Icons.warning,
      'expensive': Icons.currency_rupee_rounded,
      'cost': Icons.currency_rupee_rounded,
      'spent': Icons.currency_rupee_rounded,
      'category': Icons.category,
      'budget': Icons.account_balance_wallet,
      'pocket': Icons.account_balance_wallet,
      'money': Icons.account_balance_wallet,
    };

    for (final entry in keywordIconMap.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }
    return Icons.info;
  }

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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _tiltAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchInsights(); // Initial fetch for "Heads up"
    _animationController.forward();
  }

  Future<void> _fetchInsights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentCardIndex = 0;
    });
    try {
      await _controller.getHomePageInsights(context);
      setState(() {
        _isLoading = false;
        _swiperController.move(0, animation: false);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load insights. Please try again.';
      });
    }
  }

  Future<void> _fetchInsightsMoneyMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentCardIndex = 0;
    });
    try {
      await _controller.getHomePageMoneyMapInsights(context);
      setState(() {
        _isLoading = false;
        _swiperController.move(0, animation: false);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load Money Map insights. Please try again.';
      });
    }
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
      _currentCardIndex = 0; // Reset swiper index
      _swiperController.move(0, animation: false); // Reset swiper
      _animationController.reset();
      _animationController.forward();
    });

    // Fetch data based on selected item
    if (index == 0) {
      _fetchInsights(); // "Heads up"
    } else if (index == 1) {
      _fetchInsightsMoneyMap(); // "Money Map"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.55,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: ResponsiveUtils.getPadding(context),
                  child: Text(
                    'Your Insights',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.getFontSize(context, 18),
                      color: AppColors.bg3.withOpacity(0.9),
                    ),
                    semanticsLabel: 'Your Insights',
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveUtils.getCardWidth(context),
                          maxHeight: ResponsiveUtils.getCardHeight(context),
                        ),
                        child: _buildContent(),
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

  Widget _buildContent() {
    if (_isLoading) {
      return _buildCustomLoading();
    }
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    // Select insights based on _selectedIndex
    final insightsList = _selectedIndex == 0
        ? _controller.totalInSights
        : _controller.totalInSightsMoneyMap;

    if (insightsList.isEmpty) {
      return _buildEmptyState();
    }

    final insights = insightsList.isNotEmpty
        ? insightsList[0]['insights'] as List? ?? []
        : [];

    if (insights.isEmpty) {
      return _buildEmptyState();
    }

    if (insights.length == 1) {
      final message = insights[0] as String;
      return Semantics(
        label: 'Insight card: $message',
        child: InsightCard(
          title: _navigationItems[_selectedIndex]['title'],
          message: message,
          color: getColorForInsight(0),
          icon: getIconForInsight(
              _navigationItems[_selectedIndex]['title'], message),
          width: ResponsiveUtils.getCardWidth(context),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              if (index >= insights.length || index < 0) {
                _swiperController.move(0, animation: false);
                return const SizedBox.shrink();
              }
              final message = insights[index] as String;
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
                    child: Semantics(
                      label:
                          'Insight card ${index + 1} of ${insights.length}: $message',
                      child: child,
                    ),
                  );
                },
                child: InsightCard(
                  title: _navigationItems[_selectedIndex]['title'],
                  message: message,
                  color: getColorForInsight(index),
                  icon: getIconForInsight(
                      _navigationItems[_selectedIndex]['title'], message),
                  width: ResponsiveUtils.getCardWidth(context),
                ),
              );
            },
            itemCount: insights.length,
            controller: _swiperController,
            layout: SwiperLayout.TINDER,
            itemWidth: ResponsiveUtils.getCardWidth(context),
            itemHeight: ResponsiveUtils.getCardHeight(context),
            loop: insights.length >= 2,
            duration: 400,
            autoplay: false,
            onIndexChanged: (index) {
              if (index >= 0 && index < insights.length) {
                setState(() {
                  _currentCardIndex = index;
                  _animationController.reset();
                  _animationController.forward();
                });
              } else {
                _swiperController.move(0, animation: false);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomLoading() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: ResponsiveUtils.getCardWidth(context),
      height: ResponsiveUtils.getCardHeight(context),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg3),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: ResponsiveUtils.getFontSize(context, 40),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getFontSize(context, 16),
              color: Colors.red.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                _selectedIndex == 0 ? _fetchInsights : _fetchInsightsMoneyMap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bg3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.getFontSize(context, 14),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No ${_navigationItems[_selectedIndex]['title']} insights available',
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w600,
          fontSize: ResponsiveUtils.getFontSize(context, 16),
          color: AppColors.bg3.withOpacity(0.7),
        ),
        semanticsLabel:
            'No ${_navigationItems[_selectedIndex]['title']} insights available',
      ),
    );
  }

  Widget getMoneyMap() {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getPadding(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _navigationItems.length,
          (index) => Expanded(
            child: NavItem(
              title: _navigationItems[index]['title'],
              icon: _navigationItems[index]['icon'],
              isSelected: _selectedIndex == index,
              color: _navigationItems[index]['color'],
              backgroundColor: _navigationItems[index]['backgroundColor'],
              onTap: () => _onItemTapped(index),
            ),
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
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 10,
                height: MediaQuery.of(context).size.height / 12,
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
                  size: ResponsiveUtils.getFontSize(context, 22),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.getFontSize(context, 13),
                  color: isSelected ? color : Colors.grey,
                ),
                textAlign: TextAlign.center,
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.96),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 16,
              bottom: 16,
              child: Opacity(
                opacity: 0.25,
                child: Icon(
                  icon,
                  size: ResponsiveUtils.getFontSize(context, 80),
                  color: Colors.white,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.getFontSize(context, 26),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    lineHeight: 1.2,
                    
                    fontSize: ResponsiveUtils.getFontSize(context, 18),
                    color: Colors.white.withOpacity(0.95),
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
