import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/insightsController.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Utils/headup_moneymap_constant.dart';
import '../Utils/responsiveUi.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  final _selectedIndex = RxInt(0);
  final _currentCardIndex = RxInt(0);
  final _isLoading = RxBool(true);
  final _errorMessage = RxnString();
  late SwiperController _swiperController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _tiltAnimation;
  final InsightsController _controller = Get.put(InsightsController());

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex.value) {
      return;
    }
    _selectedIndex.value = index;
    _currentCardIndex.value = 0;
    _swiperController.move(0, animation: false);
    _animationController.reset();
    _animationController.forward();
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
                  HomepageStringsDart().yourHighlights,
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
              _buildMoneyMap(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      // Ensure _selectedIndex is observed
      final selectedIndex = _selectedIndex.value;
      final insightsList = selectedIndex == 0
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
            title: navigationItems[selectedIndex]['title'],
            message: message,
            color: getColorForInsight(0),
            icon: getIconForInsight(
                navigationItems[selectedIndex]['title'], message),
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
                return Obx(() {
                  // Ensure _currentCardIndex is observed
                  final currentCardIndex = _currentCardIndex.value;
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..scale(_scaleAnimation.value)
                          ..rotateZ(currentCardIndex == index
                              ? _tiltAnimation.value
                              : 0.0),
                        alignment: Alignment.center,
                        child: Semantics(
                          label:
                              'Insight card ${index + 1} of ${insights.length}: $message',
                          child: child,
                        ),
                      );
                    },
                    child: InsightCard(
                      title: navigationItems[selectedIndex]['title'],
                      message: message,
                      color: getColorForInsight(index),
                      icon: getIconForInsight(
                          navigationItems[selectedIndex]['title'], message),
                      width: ResponsiveUtils.getCardWidth(context),
                    ),
                  );
                });
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
                  _currentCardIndex.value = index;
                  _animationController.reset();
                  _animationController.forward();
                } else {
                  _swiperController.move(0, animation: false);
                }
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCustomLoading() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: ResponsiveUtils.getCardWidth(context),
      height: ResponsiveUtils.getCardHeight(context),
      child: Center(child: Spinner()),
    );
  }

  Widget _buildEmptyState() {
    return Obx(() {
      // Ensure _selectedIndex is observed
      final selectedIndex = _selectedIndex.value;
      return Center(
        child: Text(
          selectedIndex == 0
              ? HomepageStringsDart().noHeadsUpInsights
              : HomepageStringsDart().noMoneyMapInsights,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getFontSize(context, 14),
            color: AppColors.bg3..withOpacity(0.7),
          ),
          semanticsLabel: selectedIndex == 0
              ? HomepageStringsDart().noHeadsUpInsights
              : HomepageStringsDart().noMoneyMapInsights,
        ),
      );
    });
  }

  Widget _buildMoneyMap() {
    return Obx(() {
      // Ensure _selectedIndex is observed
      final selectedIndex = _selectedIndex.value;
      return Container(
        width: double.infinity,
        padding: ResponsiveUtils.getPadding(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            navigationItems.length,
            (index) => Expanded(
              child: NavItem(
                title: navigationItems[index]['title'],
                icon: navigationItems[index]['icon'],
                isSelected: selectedIndex == index,
                color: navigationItems[index]['color'],
                backgroundColor: navigationItems[index]['backgroundColor'],
                onTap: () => _onItemTapped(index),
              ),
            ),
          ),
        ),
      );
    });
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
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.backgroundColor : Colors.grey[600],
                  size: ResponsiveUtils.getFontSize(context, 22),
                ),
              ),
               SizedBox(height: AppSizes.h8),
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
          color: color,
          borderRadius: BorderRadius.circular(24),
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
                  color: AppColors.backgroundColor,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ResponsiveUtils.getCardHeight(context) - 48,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getFontSize(context, 26),
                        color: AppColors.backgroundColor,
                      ),
                    ),
                    SizedBox(height: AppSizes.h12),
                    Text(
                      message,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        lineHeight: 1.2,
                        fontSize: ResponsiveUtils.getFontSize(context, 18),
                        color: AppColors.backgroundColor.withOpacity(0.95),
                      ),
                      maxLines: null,
                      overflow: TextOverflow.visible,
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
}
