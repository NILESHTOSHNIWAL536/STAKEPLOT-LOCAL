import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/navigateTo.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import '../Constants/app_styles.dart';
import '../Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/font_manager.dart';

class UserOnboarding extends StatefulWidget {
  const UserOnboarding({super.key});

  @override
  State<UserOnboarding> createState() => _UserOnboardingState();
}

class _UserOnboardingState extends State<UserOnboarding> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  final List<_OnboardingData> pages = [
    _OnboardingData(
      image: Sign.userOnboard,
      title: 'Stakeplot is more than just\ntracking numbers,',
      description:
          'it helps you understand your finances deeply and build smart, lasting habits. It turns money management into a mindful way of living.',
    ),
    _OnboardingData(
      image: Sign.userOnboard,
      title: 'Your financial world deserves a\nsafe space.',
      description:
          'Stakeplot keeps it private and secure while guiding you gently, one step at a time.',
    ),
    _OnboardingData(
      image: Sign.userOnboard,
      title:
          'We earn, spend, and save – but\noften lose sight of where our money really goes',
      description:
          'Stakeplot helps you see the story behind your spending and understand your money better.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height / 1.3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: pages[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? AppColors.primaryColor
                        : AppColors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.h24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      if (currentIndex < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        AppNavigator.popUntil(context, "/");
                        AppNavigator.pushNamed(context, "/ShareAccountLogin");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Dive In",
                      textAlign: TextAlign.center,
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.backgroundColor),
                    )),
              ),
            ),
            SizedBox(height: AppSizes.h30),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Center(
              child: Padding(
            padding: const EdgeInsets.only(left: AppSizes.p20),
            child:
                AvatarProfileImageZero(url: data.image, width: 1, height: 2.2),
          )),

          SizedBox(height: AppSizes.h40),

          RichText(
            text: TextSpan(
              children: [
                /// TITLE PART
                TextSpan(
                  text: '${data.title} ',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 22,
                    lineHeight: 34 / 24,
                    color: AppColors.primaryColor,
                  ),
                ),

                /// DESCRIPTION PART
                TextSpan(
                  text: data.description,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 16,
                    lineHeight: 24 / 18,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          )

          //     color: Color(0xFF7A7A7A),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String description;

  _OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
