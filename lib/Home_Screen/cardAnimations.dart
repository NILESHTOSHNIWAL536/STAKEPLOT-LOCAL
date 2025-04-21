import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';


class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late SwiperController _swiperController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _currentCardIndex = 0;

  // Sample data for insights cards
  final List<Map<String, dynamic>> _insightsData = [
    {
      'title': 'Heads up..',
      'message': 'Travel expenses dropped by 40% this month-working from home, eh?',
      'color': const Color.fromARGB(255, 36, 55, 57),
    },
    {
      'title': 'Quick tip',
      'message': 'Your grocery spending is 15% higher than last month.',
      'color': const Color.fromARGB(255, 142, 212, 72),
    },
    {
      'title': 'Did you know?',
      'message': 'You\'ve saved \$120 more this month compared to your average.',
      'color': const Color.fromARGB(255, 224, 150, 86),
    },
    {
      'title': 'Reminder',
      'message': 'Your subscription renewal is due in 3 days.',
      'color': const Color.fromARGB(255, 77, 79, 217),
    },
  ];

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'title': 'Head',
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

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
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
        height: MediaQuery.of(context).size.height/2.5,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout
            final bool isWideScreen = constraints.maxWidth > 600;   
            return Column(
              children: [

                // Main content area with animated stacked cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWideScreen ? 500 : 400,
                          maxHeight: 300,
                        ),
                        child: _insightsData.isEmpty
                            ? const Center(child: Text('No insights available'))
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Swiper(
                                      // scrollDirection: Axis.vertical,
                                      itemBuilder: (BuildContext context, int index) {
                                        return AnimatedBuilder(
                                          animation: _animationController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _currentCardIndex == index 
                                                  ? _scaleAnimation.value 
                                                  : 0.9,
                                              child: child,
                                            );
                                          },
                                          child: InsightCard(
                                            title: _insightsData[index]['title'],
                                            message: _insightsData[index]['message'],
                                            color: _insightsData[index]['color'],
                                            width: isWideScreen ? 450 : 350,
                                          ),
                                        );
                                      },
                                      itemCount: _insightsData.length,
                                      controller: _swiperController,
                                      layout: SwiperLayout.TINDER,
                                      itemWidth: isWideScreen ? 450 : 350,
                                      itemHeight: 200,
                                      loop: true,
                                      duration: 300,
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
               
                 getMoneyMap()
              ],
            );
          },
        ),
    );
  }



  Widget getMoneyMap(){
    return   Container(
                  width: MediaQuery.of(context).size.width/1.1,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? backgroundColor : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final double width;

  const InsightCard({
    Key? key,
    required this.title,
    required this.message,
    required this.color,
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
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}