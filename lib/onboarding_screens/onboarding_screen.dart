import 'package:flutter/material.dart';


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_progressController);
    _animationController.forward();
    _updateProgress();
  }

  void _updateProgress() {
    _progressController.value = _currentPage / 2; // Adjust based on total pages (e.g., 2 steps)
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _animationController.reset();
    _animationController.forward();
    _updateProgress();
    if (index < 2) {
      _progressController.forward(from: _currentPage / 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          OnboardingPage(
            title: 'A powerful tool for expense tracking.',
            subtitle: 'Your go-to tool for hassle-free expense management.',
            image: 'assets/screen1.png', // Replace with your image path
            isLastPage: false,
          ),
          OnboardingPage(
            title: 'Connect with the unique community.',
            subtitle: 'Connect and engage with a community like no other.',
            image: 'assets/screen3.png', // Replace with your image path
            isLastPage: false,
          ),
          OnboardingPage(
            title: 'We look after your budgets and debts.',
            subtitle: 'We manage your budgets and debts with care.',
            image: 'assets/screen2.png', // Replace with your image path
            isLastPage: true,
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool isLastPage;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    final _onboardingScreenState = context.findAncestorStateOfType<_OnboardingScreenState>()!;
    return Column(
      children: [
        // First Container: Dots and Animation/Image
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                // Dots (Page Indicator) above animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => _onboardingScreenState.buildDot(index)),
                ),
                const SizedBox(height: 20),
                // Animation/Image
                Expanded(
                  child: Center(
                    child: Image.asset(
                      image,
                      height: 250, // Adjust based on your design
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Second Container: Text and Button
        Expanded(
          flex: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10), // Space for layout
                // Title
                FadeTransition(
                  opacity: _onboardingScreenState._fadeAnimation,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Subtitle
                FadeTransition(
                  opacity: _onboardingScreenState._fadeAnimation,
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Circular Progress Button with "Next" or "Let's Go"
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _onboardingScreenState._currentPage < 2
                            ? _onboardingScreenState._progressAnimation.value
                            : 1.0,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_onboardingScreenState._currentPage == 2) {
                          // Navigate to home screen or login
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          _onboardingScreenState._pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            _onboardingScreenState._currentPage == 2 ? 'Let\'s Go' : 'Next',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Terms and Privacy Policy Text
                const Text(
                  'By moving forward, you consent to our TERMS OF SERVICE & PRIVACY POLICY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}