import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/bankSlider.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/resetPin.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:lottie/lottie.dart';
import '../Constants/core/app_component_sizes.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../backed_connections/bankServices/nextFetch.dart';
import '../components/shared_utils.dart';
import '../model/bank_model.dart';
import 'quick_check/monthly_quick_check.dart';

RxInt firstDigit = 0.obs;
RxInt secondDigit = 0.obs;
RxBool digitLoad = false.obs;

class NumberPickerScreen extends StatefulWidget {
  @override
  State<NumberPickerScreen> createState() => _NumberPickerScreenState();
}

class _NumberPickerScreenState extends State<NumberPickerScreen> {
  final FixedExtentScrollController firstDigitController =
      FixedExtentScrollController(initialItem: 0);
  final FixedExtentScrollController secondDigitController =
      FixedExtentScrollController(initialItem: 0);

  final Map<String, int> _emojiMap = {};

  List lock = HomepageStringsDart().lockPatterns;

  late PageController _pageController;
  int activeIndex = 0;
  bool showFlipSlider = false;
  int flipToIndex = 0;

  @override
  void initState() {
    super.initState();

    activeIndex = _safeBankIndex(scrollBankPage.value);

    _pageController = PageController(
      initialPage: activeIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    firstDigitController.dispose();
    secondDigitController.dispose();
    super.dispose();
  }

  int _safeBankIndex(int index) {
    if (bankAccountLinkedList.isEmpty) return 0;
    if (index < 0 || index >= bankAccountLinkedList.length) return 0;
    return index;
  }

  void _selectBank(int index) {
    final safeIndex = _safeBankIndex(index);
    setState(() => activeIndex = safeIndex);
    bankInfoController.selectBankAccount(safeIndex, context);
  }

  void _flipToBank(int index) {
    final safeIndex = _safeBankIndex(index);
    _selectBank(safeIndex);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(safeIndex);
    }
    setState(() {
      flipToIndex = safeIndex;
      showFlipSlider = true;
    });

    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) setState(() => showFlipSlider = false);
    });
  }

  int getEmojiIndex(String accountId) {
    return _emojiMap.putIfAbsent(
      accountId,
      () => Random().nextInt(lock.length),
    );
  }

  String _displayMaskedAccount(BankAccountModel data) {
    final masked = data.maskedAccNumber.trim();
    final hasVisibleDigit = RegExp(r'\d').hasMatch(masked);
    final isOnlyMaskChars =
        masked.isNotEmpty && RegExp(r'^[xX*]+$').hasMatch(masked);

    if (masked.isNotEmpty && hasVisibleDigit && !isOnlyMaskChars) {
      return masked;
    }

    if (data.type.trim().isNotEmpty) {
      return '${data.bankName} ${data.type}';
    }

    return data.bankName.isNotEmpty ? data.bankName : 'Linked account';
  }

  @override
  Widget build(BuildContext context) {
    // Check for zero to avoid division by zero
    return Obx(() {
      if (loadBanks.value) return const BankSlider();

      return showFlipSlider
          ? avatarSlider2() // 🔥 flip UI
          : avatarSlider(); // 👈 normal swipe UI
    });
  }

  Widget avatarSlider() {
    if (bankAccountLinkedList.isEmpty) return connectBankAccount(context);

    activeIndex = _safeBankIndex(activeIndex);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: AppComponentSizes.h4,
          child: PageView.builder(
            itemCount: bankAccountLinkedList.length,
            controller: _pageController,
            onPageChanged: (index) {
              _selectBank(index);
            },
            itemBuilder: (context, index) {
              final account = bankAccountLinkedList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p10),
                child: getListViewBankInfo(account),
              );
            },
          ),
        ),
        SizedBox(height: AppSizes.h6),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bankAccountLinkedList.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                  height: 8,
                  width: 8, // active dot grows
                  decoration: BoxDecoration(
                    color: scrollBankPage.value == index
                        ? context.appColors.primary
                        : context.appColors.secondaryText.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget avatarSlider2() {
    if (bankAccountLinkedList.isEmpty) return connectBankAccount(context);
    activeIndex = _safeBankIndex(activeIndex);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            // color:  AppColors.redColor,
            height: MediaQuery.sizeOf(context).height / 4,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height / 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// 🔥 MAIN CARD (VISIBLE)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 650),
                    transitionBuilder: (child, animation) {
                      final rotate = Tween(begin: pi, end: 0.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOutCubic, // 🔥 much smoother
                        ),
                      );

                      return AnimatedBuilder(
                        animation: rotate,
                        child: child,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(-rotate.value),
                            child: child,
                          );
                        },
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(activeIndex),
                      child: getListViewBankInfo(
                        bankAccountLinkedList[activeIndex],
                      ),
                    ),
                  ),

                  /// 🧠 HIDDEN PageView (LOGIC ONLY)
                  IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: 0,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: bankAccountLinkedList.length,
                        onPageChanged: (index) {
                          setState(() {
                            activeIndex = index;
                            scrollBankPage.value = index;
                          });
                        },
                        itemBuilder: (_, __) => const SizedBox(),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        SizedBox(height: AppSizes.h6),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bankAccountLinkedList.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: 8, // active dot grows
                  decoration: BoxDecoration(
                    color: scrollBankPage.value == index
                        ? context.appColors.primary
                        : context.appColors.secondaryText.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget getListViewBankInfo(BankAccountModel data) {
    int randomIndex = getEmojiIndex(data.accountId);

    if (randomIndex == lock.length) randomIndex = 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height / 3.6,
        child: Stack(
          children: [
            /// 🔵 BACKGROUND
            Positioned.fill(
              child: AvatarProfileImageZero(
                url: HomePageIcons.bankContainerBg,
                width: 1,
                height: 1,
              ),
            ),

            /// 🔤 MAIN CONTENT
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.p14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizes.h40), // space for top-right logos

                  /// NEXT FETCH
                  Nextfetch(),

                  SizedBox(height: AppSizes.h10),

                  /// ACCOUNT NUMBER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.network(
                        data.bankLogo,
                        width: 28,
                        height: 28,
                        fit: BoxFit.fitWidth,
                        errorBuilder: getErrorBankLogo(),
                      ),
                      SizedBox(width: AppSizes.w8),
                      Expanded(
                        child: Text(
                          _displayMaskedAccount(data),
                          overflow: TextOverflow.ellipsis,
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 16,
                            lWeight: FontWeight.w700,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.h10),

                  /// LABEL
                  Text(
                    "Available balance",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 12,
                      lWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),

                  SizedBox(height: AppSizes.h10),

                  /// BALANCE
                  Obx(() {
                    final String pin = userController.cupertinoPin.value;
                    final bool hide = hideBackAccountPassword.value;
                    final double balance = data.currentBalance;
                    final bool showBalance =
                        (pin == "0" || pin == "00" || hide);

                    return Text(
                      '\u{20B9} ${showBalance ? formatMoneyIndian(balance.toString(), lock[randomIndex]) : lock[randomIndex]}',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.backgroundColor,
                          lineHeight: 24 / fontSize),
                    );
                  }),

                  SizedBox(height: AppSizes.h10),

                  /// QUICK CHECK
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BalanceScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Image.network(
                          data.bankLogo,
                          width: 18,
                          height: 18,
                          errorBuilder: getErrorBankLogo(),
                        ),
                        const SizedBox(width: AppSizes.w6),
                        Text(
                          "Quick check",
                          style: FontManager()
                              .getTextStyle(context,
                                  fontSize: 12,
                                  lWeight: FontWeight.w500,
                                  color: AppColors.grey,
                                  lineHeight: 18 / fontSize)
                              .copyWith(
                                // decoration: TextDecoration.underline,
                                decorationThickness: 1.2,
                                decorationColor: AppColors.grey,
                              ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            /// 🔁 TOP-RIGHT OTHER BANK LOGOS (CORRECT POSITION)
            if (bankAccountLinkedList.length > 1)
              Positioned(
                top: AppSizes.p2,
                right: 0,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(6),
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: bankAccountLinkedList
                        .asMap()
                        .entries
                        .where((e) => e.value.accountId != data.accountId)
                        .map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: InkWell(
                          onTap: () {
                            _flipToBank(entry.key);
                          },
                          child: Image.network(
                            entry.value.bankLogo,
                            height: 22,
                            width: 22,
                            fit: BoxFit.contain,
                            errorBuilder: getErrorBankLogo(),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            /// 🔐 SET PIN BUTTON
            Positioned(
              right: AppSizes.p16,
              bottom: 30,
              child: setPinForAccountHide(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget locker(context) {
    return Row(
      children: [
        _buildPicker("firstDigit", context),
        Container(
          width: 1.2,
          height: 15,
          color: AppColors.backgroundColor,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.m4),
        ),
        _buildPicker("secondDigit", context),
      ],
    );
  }

  void setBack() {
    setState(() {
      firstDigit.value = 0;
      secondDigit.value = 0;
      firstDigitController.jumpToItem(0);
      secondDigitController.jumpToItem(0);
    });
  }

  Widget _buildPicker(String controllerValue, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.10, // 10% of screen width (~40px)
      height: MediaQuery.of(context).size.height *
          0.05, // 5% of screen height (~40px)
      decoration: BoxDecoration(
        color: AppColors.transparentColor,
      ),

      child: CupertinoPicker(
        backgroundColor: Colors.transparent,
        itemExtent: 30,
        scrollController: controllerValue == "firstDigit"
            ? firstDigitController
            : secondDigitController,
        onSelectedItemChanged: (index) {
          if (controllerValue == "firstDigit") {
            firstDigit.value = index;
          } else {
            secondDigit.value = index;
          }
          pinPasswordVerifyDebounced(
              firstDigit.value.toString() + "" + secondDigit.value.toString(),
              context,
              setBack);
        },
        children: List<Widget>.generate(
          10,
          (index) => Center(
            child: Text(
              index.toString(),
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: 16,
                  color: AppColors.backgroundColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget setPinForAccountHide(context) {
    return Obx(() {
      if (userController.cupertinoPin.value == "0" ||
          userController.cupertinoPin.value == "00" ||
          userController.cupertinoPin.value.isEmpty ||
          userController.cupertinoAttemptCount.value) {
        // Handle empty case too
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
          child: InkWell(
              onTap: () {
                if (userController.cupertinoAttemptCount.value) {
                  resetCupertinoPin(context);
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colorcodes.appBarColor,
                  builder: (context) {
                    return setPassword(context);
                  },
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AvatarProfileImageZero(
                    url: HomePageIcons.setPin,
                    width: 20,
                    height: 26,
                  ),
                  Text(
                    "Set Pin",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.backgroundColor,
                        lineHeight: 24 / fontSize),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
        );
      } else {
        return Stack(
          alignment: Alignment.center,
          children: [
            AvatarProfileImageZero(
              url: HomePageIcons.setPin,
              width: 20,
              height: 20,
            ),
            locker(context),
          ],
        );
      }
    });
  }

  Widget setPassword(context) {
    double height = MediaQuery.of(context).size.height;
    RxInt selectedNumber1 = 0.obs; // Make first digit reactive
    RxInt selectedNumber2 = 0.obs; // Second selected number

    return SafeArea(
      child: Container(
        //  color: AppColors.backgroundColor,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          color: context.appColors.surface,
        ),
        width: MediaQuery.of(context).size.width,
        height: height > 0 ? height / 3.8 : 100, // Fallback height
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: AppSizes.p10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.p20),
              child: textStyle(
                  context: context,
                  text: HomepageStringsDart().setLockTitle,
                  fontsize: 20,
                  fontWeight: FontWeight.bold),
            ),
            // First Cupertino Picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 6,
                      height: MediaQuery.of(context).size.height /
                          16, // Adjust height as needed
                      child: CupertinoPicker(
                        itemExtent: 26.0, // Height of each item
                        onSelectedItemChanged: (int index) {
                          selectedNumber1.value = index; // Update first number
                        },
                        children: List<Widget>.generate(10, (int index) {
                          return Center(child: Text(index.toString()));
                        }), // Numbers 0-99
                      ),
                    ),

                    // Second Cupertino Picker
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 6,
                      height: MediaQuery.of(context).size.height /
                          16, // Adjust height as needed
                      child: CupertinoPicker(
                        itemExtent: 26.0, // Height of each item
                        onSelectedItemChanged: (int index) {
                          selectedNumber2.value = index; // Update second number
                        },
                        children: List<Widget>.generate(10, (int index) {
                          return Center(child: Text(index.toString()));
                        }), // Numbers 0-99
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Obx(() {
                  String combinedInput =
                      '${selectedNumber1.value}${selectedNumber2.value}';
                  bool isInvalidPin = combinedInput == "00";

                  return InkWell(
                    onTap: isInvalidPin
                        ? null
                        : () {
                            setPasswordApiCalled(context, combinedInput);
                          },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: AppSizes.p20),
                      decoration: BoxDecoration(
                        color: isInvalidPin
                            ? context.appColors.secondaryText
                            : context.appColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          HomepageStringsDart().confirmButton,
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuEntry<String> getItemOfListPopupMenuItem(
      String bankName, String fipId, var data, String id) {
    return PopupMenuItem<String>(
      value: id, // Ensure value is of type String
      child: Text(bankName),
    );
  }

  Widget connectBankAccount(BuildContext context) {
    return Container(
      color: context.appColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Center(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShareAccountLogin(),
              ),
            );
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Lottie.asset("assets/splashScreen/fetchLoad.json"),
                  ),
                  textStyle(
                      context: context,
                      text: HomepageStringsDart().noBankLinked,
                      fontsize: 11,
                      fontWeight: FontWeight.bold),
                ],
              ),
              Card(
                elevation: 2,
                color: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AvatarProfileImage(
                        width: 2,
                        height: 10,
                        url: bankImage,
                      ),
                      SizedBox(height: AppSizes.h10),
                      Text(
                        "Securely connect your bank account",
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppColors.backgroundColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSizes.h10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
