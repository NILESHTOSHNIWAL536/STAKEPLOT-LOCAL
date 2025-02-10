import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class NumberPickerController extends GetxController {
  var firstDigit = 0.obs;
  var secondDigit = 0.obs;
}

class NumberPickerScreen extends StatelessWidget {
  final NumberPickerController controller = Get.put(NumberPickerController());

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
                  const SizedBox(height: 8),
                  Text(
                    "Account Name",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 16,
                        color: AppColors.backgroundColor),
                  ),
                  const SizedBox(height: 10),
                  Text('Available Balance',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: AppColors.backgroundColor)),
                  //const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Obx(()=> Text(
                        '\u{20B9}${ hideBackAccountPassword.value? "1200.0":"******"}',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.normal,
                            fontSize: 16,
                            color: AppColors.backgroundColor),
                      )),
                      Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  // First Digit Picker
                                  _buildPicker(controller.firstDigit, context),
                                  const Divider(),
                                  // Second Digit Picker
                                  _buildPicker(controller.secondDigit, context),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Obx(
                  //   () => Text(
                  //     "Selected: ${controller.firstDigit.value}${controller.secondDigit.value}",
                  //     style: FontManager().getTextStyle(context,
                  //         lWeight: FontWeight.normal,
                  //         fontSize: 14,
                  //         color: AppColors.backgroundColor),
                  //   ),
                  // ),
                ],
            
         ))));
  }

  Widget _buildPicker(RxInt controllerValue, BuildContext context) {
    return SizedBox(
      width: 60,
      height: 70,
      child: CupertinoPicker(
        itemExtent: 30,
        onSelectedItemChanged: (index) {
            controllerValue.value=index;
          //  controller.secondDigit.value =index; // Update using GetX
           PinPasswordVerify(controller,controller.firstDigit.value.toString()+""+controller.secondDigit.value.toString(),context);
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
}
