import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


 RxString skipOrLets = "Let\'s Go".obs;
 RxString mess = "".obs;

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
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
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

             if(data['data']['data']=="error" || data['data']['data']=="account-data-not-found")
             {
                  skipOrLets.value="Skip",
             }else{
                skipOrLets.value="Let\'s Go",
             },
                mess.value=data['message'],
              flagToFetchData.value = true,
              fetchedData.value = true,
              fetchedTrsacntionList.clear(),
              fetchedTrsacntionList.addAll(data['data']['data']),


            });

    socket.onConnectError((data) {
      // print("error-----------");
      // print(data);
    });
  }

  void _updateProgress() {
    double targetValue;
    switch (_currentPage) {
      case 0:
        targetValue = 0.25;
        break;
      case 1:
        targetValue = 0.5;
        break;
      case 2:
        targetValue = 0.75;
        break;
      default:
        targetValue = 0.0;
    }
    _progressController.animateTo(targetValue,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
    // if (index < 2) {
    //   _progressController.forward(from: _currentPage / 2);
    // }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  OnboardingPage(
                    title: 'A powerful tool for expense tracking.',
                    subtitle: 'Your go-to tool for hassle-free expense management.',
                    baseImage: OnboardingImages.page11, // this week
                    baseSize: Size(
                        screenWidth * 0.02, screenHeight * 0.02), // Responsive size
                    baseOffset: Offset(
                        screenWidth * 0.1, screenHeight * 0.1), // Responsive offset
                    animatedImages: [
                      AnimatedImage(
                        path: OnboardingImages.page12, // graph
                        size: Size(screenWidth * 0.16,
                            screenHeight * 0.16), // Responsive size
                        initialOffset: Offset(0, 1.0),
                        finalOffset: Offset(screenWidth * 0.095,
                            screenHeight * 0.13), // Responsive offset
                        duration: const Duration(milliseconds: 600),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.page13,
                        size: Size(screenWidth * 0.05,
                            screenHeight * 0.05), // Responsive size
                        initialOffset: Offset(-1, 0),
                        finalOffset: Offset(screenWidth * 0.14,
                            screenHeight * 0.25), // Responsive offset
                        duration: const Duration(milliseconds: 1200),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.page14,
                        size: Size(screenWidth * 0.05,
                            screenHeight * 0.05), // Responsive size
                        initialOffset: Offset(1, 0),
                        finalOffset: Offset(screenWidth * 0.45,
                            screenHeight * 0.1), // Responsive offset
                        duration: const Duration(milliseconds: 1500),
                      ),
                    ],
                    isLastPage: false,
                  ),
                  OnboardingPage(
                    title: 'Plot your finances with our calculators',
                    subtitle: 'Use our EMI, Credit and 5+ calculators',
                    baseImage: OnboardingImages.page21,
                    baseSize: Size(
                        screenWidth * 0.23, screenHeight * 0.23), // Responsive size
                    baseOffset: Offset(
                        screenWidth * 0.3, screenHeight * 0.1), // Responsive offset
                    animatedImages: [
                      AnimatedImage(
                        path: OnboardingImages.page22,
                        size: Size(screenWidth * 0.05,
                            screenHeight * 0.05), // Responsive size
                        initialOffset: Offset(-1.0, -1.0),
                        finalOffset: Offset(screenWidth * 0.1,
                            screenHeight * 0.3), // Responsive offset
                        duration: const Duration(milliseconds: 600),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.page23,
                        size: Size(screenWidth * 0.05,
                            screenHeight * 0.05), // Responsive size
                        initialOffset: Offset(1.0, -1.0),
                        finalOffset: Offset(screenWidth * 0.38,
                            screenHeight * 0.1), // Responsive offset
                        duration: const Duration(milliseconds: 1000),
                      ),
                    ],
                    isLastPage: false,
                  ),
                  OnboardingPage(
                    title: 'Connect with the unique community.',
                    subtitle: 'Connect and engage with a community like no other.',
                    baseImage: OnboardingImages.p1,
                    baseSize: Size(
                        screenWidth * 0.9, screenHeight * 0.45), // Responsive size
                    baseOffset: Offset(screenWidth * 0.07,
                        screenHeight * 0.04), // Responsive offset
                    animatedImages: [
                      AnimatedImage(
                        path: OnboardingImages.p2,//beard man
                          size: Size(screenWidth * 0.15,
                            screenHeight * 0.15), 
                        initialOffset:
                            const Offset(-1.0, 0.0), // Start from top-right
                        finalOffset: const Offset(0.75, 0.25), // Responsive offset
                        duration: const Duration(milliseconds: 500),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.p3, //lady
                        size: Size(screenWidth * 0.15,
                            screenHeight * 0.15), // Responsive size
                        initialOffset: Offset(1.0, 0.0),
                        // finalOffset: Offset(screenWidth * 0.01,
                        //     screenHeight * 0.05), // Responsive offset
                        finalOffset: const Offset(0.2, 0.37),
                        duration: const Duration(milliseconds: 700),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.p4,//black hair
                        size: Size(screenWidth * 0.15,
                            screenHeight * 0.15), // Responsive size
                        initialOffset: Offset(0.0, 1.0),
                        // finalOffset: Offset(screenWidth * 0.05,
                        //     screenHeight * 0.3), // Responsive offset
                        finalOffset: const Offset(0.1, 0.65),
                        duration: const Duration(milliseconds: 900),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.p5,//specs lady
                        size: Size(screenWidth * 0.15,
                            screenHeight * 0.15), // Responsive size
                        initialOffset: Offset(1.0, -1.0),
                        // finalOffset: Offset(screenWidth * 0.3,
                        //     screenHeight * 0.3), // Responsive offset
                         finalOffset: const Offset(0.8, 0.6),
                        duration: const Duration(milliseconds: 1100),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.p6,
                        size: Size(screenWidth * 0.158,
                            screenHeight * 0.158), // Responsive size
                        initialOffset: Offset(0.0, 1.0),
                        // finalOffset: Offset(screenWidth * 0.15,
                        //     screenHeight * 0.25), // Responsive offset
                         finalOffset: const Offset(0.5, 0.45),
                        duration: const Duration(milliseconds: 1300),
                      ),
                    ],
                    isLastPage: false,
                  ),
                  OnboardingPage(
                    title: 'We look after your budgets and debts.',
                    subtitle: 'We manage your budgets and debts with care.',
                    baseImage: OnboardingImages.page41,
                    baseSize: Size(
                        screenWidth * 0.32, screenHeight * 0.3), // Responsive size
                    baseOffset: Offset(screenWidth * 0.07,
                        screenHeight * 0.02), // Responsive offset
                    animatedImages: [
                      AnimatedImage(
                        path: OnboardingImages.page42,
                        size: Size(screenWidth * 0.04,
                            screenHeight * 0.04), // Responsive size
                        initialOffset: Offset(-1.0, -1.0),
                        finalOffset: Offset(screenWidth * 0.1,
                            screenHeight * 0.1), // Responsive offset
                        duration: const Duration(milliseconds: 500),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.page43,
                        size: Size(screenWidth * 0.04,
                            screenHeight * 0.04), // Responsive size
                        initialOffset: Offset(1.0, -1.0),
                        finalOffset: Offset(screenWidth * 0.1,
                            screenHeight * 0.15), // Responsive offset
                        duration: const Duration(milliseconds: 900),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.page44,
                        size: Size(screenWidth * 0.04,
                            screenHeight * 0.04), // Responsive size
                        initialOffset: Offset(-1.0, 0.0),
                        finalOffset: Offset(screenWidth * 0.1,
                            screenHeight * 0.2), // Responsive offset
                        duration: const Duration(milliseconds: 1300),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.page45,
                        size: Size(screenWidth * 0.04,
                            screenHeight * 0.04), // Responsive size
                        initialOffset: Offset(1.0, 0.0),
                        finalOffset: Offset(screenWidth * 0.1,
                            screenHeight * 0.25), // Responsive offset
                        duration: const Duration(milliseconds: 1700),
                      ),
                      AnimatedImage(
                        path: OnboardingImages.page46,
                        size: Size(screenWidth * 0.15,
                            screenHeight * 0.16), // Responsive size
                        initialOffset: Offset(0.0, 1.0),
                        finalOffset: Offset(screenWidth * 0.6,
                            screenHeight * 0.11), // Responsive offset
                        duration: const Duration(milliseconds: 1200),
                      ),
                    ],
                    isLastPage: true,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02, // 5% of screen height
                  horizontal: screenWidth * 0.02, // 5% of screen width
                ),
                child: Obx(() => !flagToFetchData.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWidth * 0.07, // 10% of screen width
                            height: screenHeight * 0.07, // 10% of screen height
                            child: Spinner(
                                size: screenWidth * 0.08), // Responsive size
                          ),
                          SizedBox(width: screenWidth * 0.02), // 5% of screen width
                          Text(
                            "It will take around 10 minutes to fetch the data.",
                            style: TextStyle(
                                fontSize: screenWidth * 0.02), // 4% of screen width
                          ),
                        ],
                      )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            child: Text(
                              mess.value,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.02), // 4% of screen width
                            ),
                          ),
                      ],
                    )),
              ),
            ],
          ),
        ),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFFF5F5F5),
            padding: EdgeInsets.only(top: screenHeight * 0.05),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
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
                                : animatedImage
                                    .finalOffset.dx, // Absolute for SVG
                            top: isPngScreen
                                ? animatedImage.finalOffset.dy *
                                    widget.baseSize.height // Scale for PNG
                                : animatedImage
                                    .finalOffset.dy, // Absolute for SVG
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
                                      animatedImage
                                          .path, // SVG for other screens
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
        SizedBox(height: screenHeight * 0.02),
        Container(
          height: screenHeight * 0.45,
          decoration: const BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.01),
              FadeTransition(
                opacity: _onboardingScreenState._fadeAnimation,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.055,
                      color: AppColors.backgroundColor),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              FadeTransition(
                opacity: _onboardingScreenState._fadeAnimation,
                child: Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w200,
                      fontSize: screenWidth * 0.035,
                      color: AppColors.backgroundColor),
                ),
              ),
               SizedBox(height:screenHeight * 0.07),
              Obx(() => flagToFetchData.value
                  ? getGestTap(_onboardingScreenState)
                  : getGestTap(_onboardingScreenState)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                child: Text(
                  'By moving forward, you consent to our TERMS OF SERVICE & PRIVACY POLICY',
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w300,
                      fontSize: screenWidth * 0.03,
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(alignment: Alignment.center, children: [
      if (!widget.isLastPage) // Only show progress indicator for non-last pages
        SizedBox(
          width: screenWidth * 0.15, // 15% of screen width
          height: screenWidth * 0.15,
          child: AnimatedBuilder(
            animation: _onboardingScreenState._progressAnimation,
            builder: (context, child) {
              double targetValue;
              switch (_onboardingScreenState._currentPage) {
                case 0:
                  targetValue = 0.25;
                  break;
                case 1:
                  targetValue = 0.5;
                  break;
                case 2:
                  targetValue = 0.75;
                  break;
                default:
                  targetValue = 0.0;
              }
              double animatedValue =
                  _onboardingScreenState._progressAnimation.value * targetValue;
              return CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: 4,
                backgroundColor: AppColors.accentColor,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              );
            },
          ),
        ),
      GestureDetector(
        onTap: () {
          if (widget.isLastPage) {
            if (flagToFetchData.value) {
              clearStack(context);
              getBankAccounts();
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
                width: screenWidth * 0.15, // 15% of screen width
                height: screenWidth * 0.15,
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
                    ? Center(child: getButton(context, skipOrLets.value,
                        Colorcodes.greyLight, Colorcodes.black))
                    : getButton(context, skipOrLets.value, Colorcodes.greyLight,
                        Colorcodes.black),
              ),
      ),
    ]);
  }
}
