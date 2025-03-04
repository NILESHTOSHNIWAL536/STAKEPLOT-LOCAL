import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

// class NumberPickerController extends GetxController {
RxInt firstDigit = 0.obs;
RxInt secondDigit = 0.obs;
RxBool digitLoad = false.obs;
// }

class NumberPickerScreen extends StatefulWidget {
  @override
  State<NumberPickerScreen> createState() => _NumberPickerScreenState();
}

class _NumberPickerScreenState extends State<NumberPickerScreen> {
  // final NumberPickerController controller = Get.put(NumberPickerController());
  final FixedExtentScrollController firstDigitController =
      FixedExtentScrollController(initialItem: 0);
  final FixedExtentScrollController secondDigitController =
      FixedExtentScrollController(initialItem: 0);

  final PageController _pageController = PageController(viewportFraction: 0.7);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // Check for zero to avoid division by zero
    return Scaffold(
        // Wrap content with SingleChildScrollView
        body: SafeArea(
            child: SizedBox(
                width: width,
                height: height > 0 ? height / 2.5 : 100, // Fallback height
                child: avatarSlider2())));
  }

  Widget avatarSlider2() {
    return GFCarousel(
      // aspectRatio: ,
      viewportFraction: 1.0,
      reverse: false,
      enlargeMainPage: false,
      autoPlay: false,
      items: bankAccountLinkedList.map(
        (data) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: getListViewBankInfo(data),
          );
        },
      ).toList(),
      onPageChanged: (index) {
        accountId.value = bankAccountLinkedList[index]['accountId'] ?? "";
        calledFunctionToFetchData(context);
      },
    );
  }

  Widget getListViewBankInfo(data) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: Colorcodes.paddingHorizontal,
            vertical: Colorcodes.paddingHorizontal / 4),
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: Colorcodes.borderRadius30 / 2),
            Text(
              data['bankName'],
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: 18,
                  color: AppColors.backgroundColor),
            ),
            SizedBox(height: Colorcodes.borderRadius30 / 2),
            Text(
              "Acc No : " + data['maskedAccNumber'],
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.backgroundColor),
            ),
            SizedBox(height: Colorcodes.borderRadius30 / 2),
            Text('Available balance',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.backgroundColor)),
            SizedBox(height: Colorcodes.borderRadius30 / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\u{20B9} ${!hideBackAccountPassword.value ? data['currentBalance'] : "*********"}',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.backgroundColor),
                ),
                //  locker(context),
                setPinForAccountHide(context)
              ],
            ),
          ],
        ));
  }

  Widget locker(context) {
    return Row(
      children: [
        _buildPicker("firstDigit", context),
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
    double height = MediaQuery.of(context).size.height;

    return SizedBox(
      width: MediaQuery.of(context).size.width / 6,
      height: height > 0 ? height / 18 : 50, // Fallback height
      child: CupertinoPicker(
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
          PinPasswordVerify(
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

  //  Widget setPinForAccountHide(context) {
  //   return Obx(() => cupertinoPin.value == "0"
  //       ? Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 10),
  //         child: InkWell(
  //             onTap: () {
  //               showModalBottomSheet(
  //                 context: context,
  //                 backgroundColor: Colorcodes.appBarColor,
  //                 builder: (context) {
  //                   return setPassword(context);
  //                 },
  //               );
  //             },
  //             child: Container(
  //               padding: const EdgeInsets.all(8.0),
  //               decoration: BoxDecoration(
  //                borderRadius: BorderRadius.circular(6),
  //                   color: Colorcodes.textFeild,
  //               ),
  //               child: textStyle(
  //                   text: "Set pin",
  //                   context: context,
  //                   fontsize: 10,
  //                   fontWeight: FontWeight.bold),
  //             )),
  //       )
  //       : digitLoad.value?  locker(context): locker(context));
  // }
  Widget setPinForAccountHide(context) {
    return Obx(() => cupertinoPin.value == "0"
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colorcodes.appBarColor,
                    builder: (context) {
                      return setPassword(context);
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.bg3,
                  ),
                  child: Center(
                    child: Text(
                      'Set Pin',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal,
                          fontSize: 12,
                          color: AppColors.backgroundColor),
                    ),
                  ),
                  // child: textStyle(
                  //     text: "Set pin",
                  //     context: context,
                  //     fontsize: 10,

                  //     fontWeight: FontWeight.bold),
                )),
          )
        : digitLoad.value
            ? locker(context)
            : locker(context));
  }

  Widget setPassword(context) {
    double height = MediaQuery.of(context).size.height;
    int selectedNumber1 = 0; // First selected number
    int selectedNumber2 = 0; // Second selected number

    return Container(
      //  color: AppColors.backgroundColor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: AppColors.backgroundColor,
      ),
      width: MediaQuery.of(context).size.width,
      height: height > 0 ? height / 3.8 : 100, // Fallback height
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: textStyle(
                context: context,
                text: "Set lock",
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
                        selectedNumber1 = index; // Update first number
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
                        selectedNumber2 = index; // Update second number
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
              InkWell(
                  onTap: () {
                    String combinedInput = '$selectedNumber1$selectedNumber2';
                    setPasswordApiCalled(context, combinedInput);
                  },
                  child: getButton(context, "Confirm")),
            ],
          ),
        ],
      ),
    );
  }

  Widget popUpBox(BuildContext context) {
    return PopupMenuButton<String>(
      // Specify the expected value type
      initialValue: selectedBank.value,
      color: AppColors.backgroundColor,
      child: Center(
        child: Icon(
          Icons.more_vert_outlined,
          size: 25,
          color: AppColors.backgroundColor, // Ensure the icon is visible
        ),
      ),
      onSelected: (value) {
        // Handle selection
        selectedBank.value = value;
        accountId.value = value;
        seletedBankUpdateInfo(value, context);
        updateInfo();
      },
      itemBuilder: (context) {
        return bankAccountLinkedList.map<PopupMenuEntry<String>>((e) {
          print(e);
          return getItemOfListPopupMenuItem(
              e['bankName'], e['fipId'], e, e['bankId']);
        }).toList(); // Ensure it returns List<PopupMenuEntry<String>>
      },
    );
  }

  PopupMenuEntry<String> getItemOfListPopupMenuItem(
      String bankName, String fipId, var data, String id) {
    return PopupMenuItem<String>(
      value: id, // Ensure value is of type String
      child: Text(bankName),
    );
  }
}
