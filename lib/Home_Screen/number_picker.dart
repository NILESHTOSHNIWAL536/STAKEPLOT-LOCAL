import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Wrap content with SingleChildScrollView
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 8, left: 16, right: 16, bottom: 0),
                //padding: const EdgeInsets.only(right: 8),

                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: popUpBox(context) ,
                        ),
                      ],
                    ),
                    //  SizedBox(height: Colorcodes.paddingCard/2),
                    Obx(() => Text(
                          accountName.value,
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: 16,
                              color: AppColors.backgroundColor),
                        )),
                    SizedBox(height: Colorcodes.paddingCard / 2),
                    Obx(() => Text(
                          "Acc No : " + accountNo.value,
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.backgroundColor),
                        )),
                    SizedBox(height: Colorcodes.paddingCard / 2),

                    SizedBox(height: Colorcodes.paddingCard / 2),
                    Text('Available balance',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 10,
                            color: AppColors.backgroundColor)),
                    SizedBox(height: Colorcodes.paddingCard / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                              '\u{20B9} ${!hideBackAccountPassword.value ? balance.value : "*********"}',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColors.backgroundColor),
                            )),

                        //  locker(context),
                        setPinForAccountHide(context)
                      ],
                    ),

                    // Container(
                    //   width: 200,
                    //   height: 200,
                    //   child: setPinForAccountHide(context))
                  ],
                ))));
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
    return SizedBox(
      width: MediaQuery.of(context).size.width / 6,
      height: MediaQuery.of(context).size.height / 18,
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
    return Obx(() => cupertinoPin.value == "0"?
     Padding(
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
        ): digitLoad.value?  locker(context): locker(context));
  }

  Widget setPassword(context) {
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
      height: MediaQuery.of(context).size.height / 3.8,
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
      height: MediaQuery.of(context).size.height / 16, // Adjust height as needed
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
      height: MediaQuery.of(context).size.height / 16, // Adjust height as needed
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
  return PopupMenuButton<String>(  // Specify the expected value type
    initialValue: bankAccountLinkedList.isNotEmpty?bankAccountLinkedList[0]['fipId']:"",
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
      print(value);
      seletedBankUpdateInfo(value,context);
      selectedBank.value=value;
    },
    itemBuilder: (context) {
      return bankAccountLinkedList.map<PopupMenuEntry<String>>((e) {
        return getItemOfListPopupMenuItem(e['bankName'], e['fipId'], e);
      }).toList(); // Ensure it returns List<PopupMenuEntry<String>>
    },
  );
}

PopupMenuEntry<String> getItemOfListPopupMenuItem(
    String bankName, String fipId, var data) {
  return PopupMenuItem<String>(
    value: fipId, // Ensure value is of type String
    child: Text(bankName),
  );
}
}
