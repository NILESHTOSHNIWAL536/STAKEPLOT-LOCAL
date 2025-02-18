import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
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
          padding:
              const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 0),
          //padding: const EdgeInsets.only(right: 8),

          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ),
                //  SizedBox(height: Colorcodes.paddingCard/2),
                 Obx(()=> Text(
                    accountName.value,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 16,
                        color: AppColors.backgroundColor),
                  )),
                 SizedBox(height: Colorcodes.paddingCard/2),
                 Obx(()=> Text(
                   "Acc No : "+ accountNo.value,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.backgroundColor),
                 )),
                SizedBox(height: Colorcodes.paddingCard/2),
               
                  SizedBox(height: Colorcodes.paddingCard/2),
                  Text('Available balance',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 10,
                          color: AppColors.backgroundColor)),
                  SizedBox(height: Colorcodes.paddingCard/2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Obx(()=> Text(
                        '\u{20B9}${ hideBackAccountPassword.value? balance.value:"******"}',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.normal,
                            fontSize: 16,
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

  Widget locker(context){
       return  Row(
         children: [
           _buildPicker("firstDigit", context),
           _buildPicker("secondDigit", context),

         ],
       );
  }

  void setBack(){
      setState(() {
           firstDigit.value=0;
           secondDigit.value=0;
            firstDigitController.jumpToItem(0);
            secondDigitController.jumpToItem(0);
      });
  }

  Widget _buildPicker(String controllerValue, BuildContext context) {
    return SizedBox(
      width:  MediaQuery.of(context).size.width/6,
      height: MediaQuery.of(context).size.height/18,
      child: CupertinoPicker(
        itemExtent: 30,
        scrollController: controllerValue == "firstDigit"
            ? firstDigitController
            : secondDigitController,
        onSelectedItemChanged: (index) {
          if(controllerValue=="firstDigit"){
                 firstDigit.value=index;
          }else{
                secondDigit.value=index;
          }
            PinPasswordVerify(firstDigit.value.toString()+""+secondDigit.value.toString(),context,setBack);
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
                decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(6),
                    color: Colorcodes.textFeild,
                ),
                child: textStyle(
                    text: "Set pin",
                    context: context,
                    fontsize: 10,
                    fontWeight: FontWeight.bold),
              )),
        )
        : digitLoad.value?  locker(context): locker(context));
  }

  Widget setPassword(context) {
    TextEditingController controller = TextEditingController();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.2,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        children: [
          TextFeildWidget(
              textEditingController: controller,
              heading: "Set Pin",
              keyBoard: TextInputType.visiblePassword,
              lableText: "Set Pin"),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              setPasswordApiCalled(context, controller.text);
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Text("Set Password click me")),
          ),
        ],
      ),
    );
  }
}
