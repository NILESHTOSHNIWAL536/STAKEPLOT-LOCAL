import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Placeholder for OnboardingImages class (replace with your actual implementation)

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late IO.Socket socket;

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
    _progressAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_progressController);
    _animationController.forward();
    _updateProgress();
    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    fetchedTrsacntionList.clear();
    setUpSocketListener();
  }

  setUpSocketListener() {
    socket.onConnect((_) {
      flagToFetchData.value = false;
      socket.emit("registerUser", '${number.value}@finvu');
    });

    socket.on(
        "registerUser",
        (data) => {
              flagToFetchData.value = true,
              fetchedData.value = true,
              fetchedTrsacntionList.clear(),
              fetchedTrsacntionList.addAll(data['data']['data']),
            });

    socket.onConnectError((data) {
      print("error-----------");
      print(data);
    });
  }

  void _updateProgress() {
    _progressController.value = _currentPage / 2;
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
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              OnboardingPage(
                title: 'A powerful tool for expense tracking.',
                subtitle: 'Your go-to tool for hassle-free expense management.',
                baseImage: OnboardingImages.page11,
                baseSize: const Size(15, 15),
                baseOffset: const Offset(40, 60),
                animatedImages: [
                  AnimatedImage(
                    path: OnboardingImages.page12,
                    size: const Size(135, 135),
                    initialOffset: const Offset(0, 1.0),
                    finalOffset: const Offset(30, 150),
                    duration: const Duration(milliseconds: 600), // Faster
                  ),
                  AnimatedImage(
                    path: OnboardingImages.page13,
                    size: const Size(40, 40),
                    initialOffset: const Offset(-1, 0),
                    finalOffset: const Offset(50, 150),
                    duration: const Duration(milliseconds: 1200), // Medium
                  ),
                  AnimatedImage(
                    path: OnboardingImages.page14,
                    size: const Size(40, 40),
                    initialOffset: const Offset(1, 0),
                    finalOffset: const Offset(180, 280),
                    duration: const Duration(milliseconds: 1500), // Slower
                  ),
                ],
                isLastPage: false,
              ),
              OnboardingPage(
                title: 'Plot your finances with our calculators',
                subtitle: 'Use our EMI, Credit and 5+ calculators',
                baseImage: OnboardingImages.page21,
                baseSize: const Size(260, 260),
                baseOffset: const Offset(64, 45),
                animatedImages: [
                  AnimatedImage(
                    path: OnboardingImages.page22,
                    size: const Size(40, 40),
                    initialOffset: const Offset(-1.0, -1.0),
                    finalOffset: const Offset(30, 60),
                    duration: const Duration(milliseconds: 600), // Very fast
                  ),
                  AnimatedImage(
                    path: OnboardingImages.page23,
                    size: const Size(40, 40),
                    initialOffset: const Offset(1.0, -1.0),
                    finalOffset: const Offset(140, 250),
                    duration: const Duration(milliseconds: 1000), // Fast
                  ),
                ],
                isLastPage: false,
              ),
              //third screen
              // Update the third OnboardingPage in the PageView
              OnboardingPage(
                title: 'Connect with the unique community.',
                subtitle: 'Connect and engage with a community like no other.',
                baseImage: OnboardingImages.p1,
                baseSize: const Size(320, 320),
                baseOffset: const Offset(20, 85),
                animatedImages: [
                 
                  AnimatedImage(
                    path: OnboardingImages.p2,
                    size: const Size(60, 60),
                   initialOffset: const Offset(-1.0, 0.0), // Start from top-right
                    finalOffset:
                        const Offset(0.8, 0.3), // Slightly different position
                    duration: const Duration(milliseconds: 500),
                  ),
                  AnimatedImage(
                    path: OnboardingImages.p3,
                    size: const Size(60, 60),
                    initialOffset: const Offset(1.0, 0.0),
                    finalOffset: const Offset(0.1, 0.37), // Unique position
                    duration: const Duration(milliseconds: 700),
                  ),
                  AnimatedImage(
                    path: OnboardingImages.p4,
                    size: const Size(60, 60),
                    initialOffset: const Offset(0.0, 1.0),
                    finalOffset: const Offset(0.1, 0.9), // Unique position
                    duration: const Duration(milliseconds: 900),
                  ),
                  AnimatedImage(
                    path: OnboardingImages.p5,
                    size: const Size(60, 60),
                    initialOffset: const Offset(1.0, -1.0),
                    finalOffset: const Offset(0.8, 0.8), // Unique position
                    duration: const Duration(milliseconds: 1100),
                  ),
                   AnimatedImage(
                    path: OnboardingImages.p6,
                    size: const Size(60, 60),
                    initialOffset: const Offset(0.0, 1.0),
                     finalOffset:
                        const Offset(0.5, 0.7), // Unique position
                    duration: const Duration(milliseconds: 1300),
                  ),
                  
                ],
                isLastPage: false,
              ),
              OnboardingPage(
                title: 'We look after your budgets and debts.',
                subtitle: 'We manage your budgets and debts with care.',
                baseImage: OnboardingImages.page41,
                baseSize: const Size(260, 260),
                baseOffset: const Offset(15, 40),
                animatedImages: [
                  AnimatedImage(
                    path: OnboardingImages.page42,
                    size: const Size(30, 30),
                    initialOffset: const Offset(-1.0, -1.0),
                    finalOffset: const Offset(30, 100),
                    duration: const Duration(milliseconds: 500), // Fast
                  ),
                  AnimatedImage(
                    path: OnboardingImages.page43,
                    size: const Size(30, 30),
                    initialOffset: const Offset(1.0, -1.0),
                    finalOffset: const Offset(30, 150),
                    duration: const Duration(milliseconds: 900), // Medium
                  ),
                  AnimatedImage(
                    path: OnboardingImages.page44,
                    size: const Size(30, 30),
                    initialOffset: const Offset(-1.0, 0.0),
                    finalOffset: const Offset(30, 200),
                    duration: const Duration(milliseconds: 1300), // Medium-slow
                  ),
                  AnimatedImage(
                    path: OnboardingImages.page45,
                    size: const Size(30, 30),
                    initialOffset: const Offset(1.0, 0.0),
                    finalOffset: const Offset(30, 250),
                    duration: const Duration(milliseconds: 1700), // Slow
                  ),
                  AnimatedImage(
                    path: OnboardingImages.page46,
                    size: const Size(120, 160),
                    initialOffset: const Offset(0.0, 1.0),
                    finalOffset: const Offset(217, 130),
                    duration: const Duration(milliseconds: 1200), // Very slow
                  ),
                ],
                isLastPage: true,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            child: Obx(() => !flagToFetchData.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 30,
                          height: 30,
                          child: Spinner(
                            size: 30,
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      Text("Data is Not Yet Fetched"),
                    ],
                  )
                : Container(
                    child: Text("Featched data successfully..."),
                  )),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 12,
      width: _currentPage == index ? 20 : 12,
      decoration: BoxDecoration(
        color:
            _currentPage == index ? AppColors.primaryColor : AppColors.button,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class AnimatedImage {
  final String path;
  final Size size;
  final Offset initialOffset;
  final Offset finalOffset;
  final Duration duration; // Individual animation speed

  AnimatedImage({
    required this.path,
    required this.size,
    required this.initialOffset,
    required this.finalOffset,
    required this.duration,
  });
}

class OnboardingPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String baseImage;
  final Size baseSize;
  final Offset baseOffset;
  final List<AnimatedImage> animatedImages;
  final bool isLastPage;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.baseImage,
    required this.baseSize,
    required this.baseOffset,
    required this.animatedImages,
    required this.isLastPage,
  });

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late List<AnimationController> _svgAnimationControllers;
  late List<Animation<Offset>> _svgAnimations;

  @override
  void initState() {
    super.initState();
    _svgAnimationControllers = widget.animatedImages.map((animatedImage) {
      return AnimationController(
        vsync: this,
        duration: animatedImage.duration,
      )..forward();
    }).toList();

    _svgAnimations = widget.animatedImages.asMap().entries.map((entry) {
      int idx = entry.key;
      AnimatedImage animatedImage = entry.value;
      return Tween<Offset>(
        begin: animatedImage.initialOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _svgAnimationControllers[idx],
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _svgAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _onboardingScreenState =
        context.findAncestorStateOfType<_OnboardingScreenState>()!;
    // Check if this is the "Connect with the unique community" screen
    bool isPngScreen = widget.title == 'Connect with the unique community.';

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: widget.baseOffset.dx,
                          top: widget.baseOffset.dy,
                          child: isPngScreen
                              ? Image.asset(
                                  widget.baseImage, // PNG for this screen
                                  width: widget.baseSize.width,
                                  height: widget.baseSize.height,
                                  fit: BoxFit.contain,
                                )
                              : SvgPicture.asset(
                                  widget.baseImage, // SVG for other screens
                                  width: widget.baseSize.width,
                                  height: widget.baseSize.height,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        ...widget.animatedImages.asMap().entries.map((entry) {
                          int idx = entry.key;
                          AnimatedImage animatedImage = entry.value;
                          return Positioned(
                            left: isPngScreen
                                ? animatedImage.finalOffset.dx *
                                    widget.baseSize.width // Scale for PNG
                                : animatedImage.finalOffset.dx, // Absolute for SVG
                            top: isPngScreen
                                ? animatedImage.finalOffset.dy *
                                    widget.baseSize.height // Scale for PNG
                                : animatedImage.finalOffset.dy, // Absolute for SVG
                            child: SlideTransition(
                              position: _svgAnimations[idx],
                              child: isPngScreen
                                  ? Image.asset(
                                      animatedImage.path, // PNG for this screen
                                      width: animatedImage.size.width,
                                      height: animatedImage.size.height,
                                      fit: BoxFit.contain,
                                    )
                                  : SvgPicture.asset(
                                      animatedImage.path, // SVG for other screens
                                      width: animatedImage.size.width,
                                      height: animatedImage.size.height,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              4, (index) => _onboardingScreenState.buildDot(index)),
        ),
        const SizedBox(height: 20),
        Container(
          height: 350,
          decoration: const BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _onboardingScreenState._fadeAnimation,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.backgroundColor),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _onboardingScreenState._fadeAnimation,
                child: Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w200,
                      fontSize: 14,
                      color: AppColors.backgroundColor),
                ),
              ),
              const SizedBox(height: 50),
              Obx(() => flagToFetchData.value
                  ? getGestTap(_onboardingScreenState)
                  : getGestTap(_onboardingScreenState)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'By moving forward, you consent to our TERMS OF SERVICE & PRIVACY POLICY',
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w300,
                      fontSize: 12,
                      color: AppColors.backgroundColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getGestTap(_onboardingScreenState) {
    return Stack(alignment: Alignment.center, children: [
      if (!widget.isLastPage) // Only show progress indicator for non-last pages
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
             value: _onboardingScreenState._currentPage == 0 
          ? 0.25 
          : _onboardingScreenState._currentPage == 1 
              ? 0.5 
              : _onboardingScreenState._currentPage == 2 
                  ? 0.75 
                  : 0.0,
            strokeWidth: 4,
            backgroundColor: AppColors.accentColor,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      GestureDetector(
          onTap: () {
            if (_onboardingScreenState._currentPage == 2) {
              // Navigator.pushReplacementNamed(context, '/home');
              if (flagToFetchData.value) {
                clearStack(context);
                Navigator.pushNamed(context, "/home");
              }
            } else {
              _onboardingScreenState._pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          child: !widget.isLastPage
              ? Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 17, bottom: 30),
                  child: flagToFetchData.value
                      ? Center(child: getButton(context, 'Let\'s Go'))
                      : getButton(context, 'Let\'s Go', Colorcodes.greyLight,
                          Colorcodes.black),
                )),
    ]);
  }
}


