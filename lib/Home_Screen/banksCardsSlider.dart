import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/animated/bankSlider.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/resetPin.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:lottie/lottie.dart';

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

  List lock = HomepageStringsDart().lockPatterns;

  void initializeData() {
    getBankAccounts();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // Check for zero to avoid division by zero
    return Container(
        // Wrap content with SingleChildScrollView
        child: SizedBox(
            width: width,
            height: height > 0 ? height / 2.5 : 100, // Fallback height
            child: Obx(() => loadBanks.value ? BankSlider() : loadBalance.value?  avatarSlider(): avatarSlider())));
  }

  Widget avatarSlider() {
    return bankAccountLinkedList.isEmpty
        ? connectBankAccount(context)
        :PageView.builder(
                  itemCount: bankAccountLinkedList.length,
                  controller: PageController(viewportFraction: 1.0,initialPage:scrollBankPage.value ),
                   onPageChanged: (index) {
                      if (bankAccountLinkedList.isEmpty) return;
                      accountId.value = bankAccountLinkedList[index]['accountId'] ?? "";
                      LastFetchDate.value = bankAccountLinkedList[index]['lastFetch'].toString();
                      nextFecthDate.value = bankAccountLinkedList[index]['nextFetch'].toString();
                      fetchCount.value = bankAccountLinkedList[index]['fetchCount'].toString();
                      BankName.value = bankAccountLinkedList[index]['bankName'].toString();
                      BankUrl.value = bankAccountLinkedList[index]['bankLogo'].toString();
                      scrollBankPage.value = index;
                      calledFunctionToFetchData(context);
                    },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: PageController(viewportFraction: 1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0, // customize scale effect
                          child: child,
                        );
                      },
                      child: Padding(
                        padding:  EdgeInsets.fromLTRB(0,2,2,2),
                        child: getListViewBankInfo(bankAccountLinkedList[index]),
                      ),
                    );
                  },
                );

  }

  Widget getListViewBankInfo(data) {
    int randomIndex = Random().nextInt(lock.length);
    if (randomIndex == lock.length) randomIndex = 0;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: Colorcodes.paddingHorizontal,vertical: Colorcodes.paddingHorizontal / 6),
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: Colorcodes.borderRadius10),
            Row(
              children: [
                 Image.network(
                          data['bankLogo'],
                          width: 30,
                          height: 30,
                          fit: BoxFit.fitWidth,
            ),
             SizedBox(width: Colorcodes.borderRadius10),
                Text(
                  data['bankName'],
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
                      fontSize: 18,
                      color: AppColors.backgroundColor),
                ),
              ],
            ),
            SizedBox(height: Colorcodes.borderRadius),
            Text(
              HomepageStringsDart().accountNumberLabel + data['maskedAccNumber'],
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.backgroundColor),
            ),
            SizedBox(height: Colorcodes.borderRadius10),
            Text(HomepageStringsDart().availableBalanceLabel,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.backgroundColor)),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               Obx(()=> Text(
                  '\u{20B9} ${(hideBackAccountPassword.value || userController.cupertinoPin.value == "0" || userController.cupertinoPin.value == "00") ? formatMoneyIndian(data['currentBalance'] ?? "null") : lock[randomIndex]}',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.backgroundColor),
               )),
                //  locker(context),
                setPinForAccountHide(context)
              ],
            ),
            SizedBox(height: Colorcodes.elevation5),
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
    if (userController.cupertinoPin.value == "0" || userController.cupertinoPin.value == "00" || userController.cupertinoPin.value.isEmpty ||  userController.cupertinoAttemptCount.value) { // Handle empty case too
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: InkWell(
          onTap: () {

            if(userController.cupertinoAttemptCount.value)
            {
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
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.bg3,
            ),
            child: Center(
              child: Obx(()=>  Text(
               !  userController.cupertinoAttemptCount.value?  HomepageStringsDart().setPinButton: HomepageStringsDart().resetCupertinoPin,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.normal,
                  fontSize: 12,
                  color: AppColors.backgroundColor,
                ),
              )),
            ),
          ),
        ),
      );
    } else {
      return locker(context);
    }
  });
}
 
  Widget setPassword(context) {
    double height = MediaQuery.of(context).size.height;
   RxInt selectedNumber1 = 0.obs; // Make first digit reactive
    RxInt selectedNumber2 = 0.obs;  // Second selected number

    return SafeArea(
      child: Container(
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
                  String combinedInput = '${selectedNumber1.value}${selectedNumber2.value}';
                  bool isInvalidPin = combinedInput == "00";
                
                  return InkWell(
                    onTap: isInvalidPin
                        ? null
                        : () {
                            setPasswordApiCalled(context, combinedInput);
                          },
                    child:  Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                      decoration: BoxDecoration(
                        color: isInvalidPin
                            ? AppColors.bg3
                            : AppColors.primaryColor, // Button color based on validity
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          HomepageStringsDart().confirmButton,
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.bg5,
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
      },
      itemBuilder: (context) {
        return bankAccountLinkedList.map<PopupMenuEntry<String>>((e) {
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
  
 Widget connectBankAccount(BuildContext context) {
   return Container(
  color: AppColors.backgroundColor,
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
        // Uncomment the line below if you want to fetch bank accounts after connecting
        // getBankAccounts();
      },
      child: Column(
        children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                              height: 30,
                              width: 30,
                              child: Lottie.asset("assets/splashScreen/fetchLoad.json"),
                 ),
                 textStyle(context: context, text: HomepageStringsDart().noBankLinked, fontsize: 11, fontWeight: FontWeight.bold),
                ],
              ),
          Card(
            elevation: 2,
            color: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  const SizedBox(height: 10),
                  Text(
                    "Securely connect your bank account",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colorcodes.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
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
