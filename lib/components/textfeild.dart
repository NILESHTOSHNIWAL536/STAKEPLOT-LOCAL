import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/signInOut/userName.dart';
import 'package:get/get.dart';


import '../Constants/core/app_padding_sizes.dart';
import '../Utils/signUp.dart';
import '../image_service/profile.dart';
import 'shared_utils.dart';

class TextFeildWidget extends StatelessWidget {
  TextEditingController textEditingController;
  String lableText;
  String heading;
  TextInputType keyBoard;
  bool flag;
  IconData icon;
  TextFeildWidget(
      {Key? key,
      required this.textEditingController,
      required this.heading,
      required this.keyBoard,
      required this.lableText,
      this.icon = Icons.email_outlined,
      this.flag = true})
      : super(key: key);

  RxBool show = false.obs;

  @override
  Widget build(BuildContext context) {
    //  return Text("data");
    return Center(
        child: Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: MediaQuery.of(context).size.width / 1.1,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           (heading=="tagSearch" || heading=="")? SizedBox.shrink():Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              child: Text(heading,
                  style: FontManager().getTextStyle(context,
                      fontSize: 16, lWeight: FontWeight.w600)),
            ),
           (heading=="tagSearch" || heading=="") ? SizedBox.shrink():   SizedBox(
              height: AppSizes.h10,
            ),
            TextFormField(
              keyboardType: keyBoard,
              controller: textEditingController,
              onChanged: (c) {
                acceptReset.value = false;
 if(heading=="tagSearch")
                 {
                     LoadTag.value = !LoadTag.value;
                 }
                 if(SignupData().usernameLabel==heading){
                      checkIsUserNameValid(c);
                 }
              },
              maxLength: heading == "PhoneNo" ? 10 : null,
              obscureText: flag ? false : show.value,
               inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    //  LowerCaseTextFormatter(),
                  ],
              decoration: InputDecoration(
                  // contentPadding: EdgeInsets.all(0),

                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  filled: true,
                  hintText: lableText,
                  // hintStyle: getStyle(context),


                 fillColor: AppColors.backgroundColor,
                    hintStyle: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.accentColor),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(color: AppColors.grey)
                    ),

                  suffixIcon:SignupData().usernameLabel==heading?
                      textEditingController.text.length==0?null:
                      isValidUser.value?Icon(Icons.check,size: 30,color: AppColors.green,):Container(width: 30,height: 30,child: Spinner())
                  : flag
                      ? null
                      : Obx(() => InkWell(
                          onTap: () {
                            show.value = !show.value;
                          },
                          child: Icon(
                              show.value
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.do_disturb_off_outlined,
                              color: AppColors.primaryColor)))),
            ),
          ],
        ),
      ),
    ));
  }
}

TextStyle getStyle(context) {
  return FontManager().getTextStyle(context,
      fontSize: 16, lWeight: FontWeight.w400, color: Colors.grey);
}
TextStyle getStyle2(context) {
  return FontManager().getTextStyle(context,
      fontSize: 18, lWeight: FontWeight.w400, color: Colors.grey);
}
TextStyle getStyle1(context) {
  return FontManager().getTextStyle(context,
      fontSize: 14, lWeight: FontWeight.w300, color: AppColors.bg6);
}



class TextFeildWidgetCustom extends StatelessWidget {
  TextEditingController textEditingController;
  String lableText;
  //String lableStyle;
  String heading;
  IconData icon;
  int? maxLines;
  int? maxLength;
  TextInputType keyBoard;
  bool flag;
  bool needAmountFormat = false;

  final FocusNode? focusNode;
  TextFeildWidgetCustom({
    Key? key,
    required this.textEditingController,
    required this.heading,
    required this.keyBoard,
    required this.lableText,
    required this.icon,
    this.flag = true,
    this.focusNode,
    this.maxLines,
    this.maxLength,
    this.needAmountFormat = false,
  }) : super(key: key);

  RxBool show = false.obs;

  @override
  Widget build(BuildContext context) {
    //  return Text("data");
    return Center(
        child: Container(
      padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
      width: MediaQuery.of(context).size.width / 1.1,
      // color: AppColors.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              child: Text(heading,
                  style: FontManager().getTextStyle(context,
                      fontSize: 16, lWeight: FontWeight.w500)),
            ),
             SizedBox(
              height: AppSizes.h10,
            ),
            TextFormField(
              keyboardType: keyBoard,
              controller: textEditingController,
              obscureText: flag ? false : show.value,
              //added focus node for expansion budget search
              focusNode: focusNode,
              maxLines: 1,
              maxLength: 30,
              inputFormatters: needAmountFormat?allowDecimalInput():[],
              decoration: InputDecoration(
                // contentPadding: EdgeInsets.all(0),
                contentPadding:EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                filled: true,
                hintText: lableText,
                hintStyle: getStyle1(context),
                labelStyle: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.bg3),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                   borderSide: BorderSide(color: AppColors.border),),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor),),
                fillColor: AppColors.mt,
                border: InputBorder.none,

                prefixIcon: flag
                    ? Icon(
                        icon,
                        size: 20,
                        color: AppColors.grey,
                      )
                    : Icon(Icons.search),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class TextFeildWidgetCustom2 extends StatelessWidget {
  TextEditingController textEditingController;
  String lableText;
  //String lableStyle;

  String icon;
  int? maxLines;
  int? maxLength;
  TextInputType keyBoard;
  bool flag;

  final FocusNode? focusNode;
  TextFeildWidgetCustom2({
    Key? key,
    required this.textEditingController,
    required this.keyBoard,
    required this.lableText,
    required this.icon,
    this.flag = true,
    this.focusNode,
    this.maxLines,
    this.maxLength,
  }) : super(key: key);

  RxBool show = false.obs;

  @override
  Widget build(BuildContext context) {
    //  return Text("data");
    return Center(
        child: Container(
      padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
      width: MediaQuery.of(context).size.width / 1.1,
      // color: AppColors.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              keyboardType: keyBoard,
              controller: textEditingController,
              obscureText: flag ? false : show.value,
              //added focus node for expansion budget search
              focusNode: focusNode,
              maxLines: 1,
              maxLength: 30,

              decoration: InputDecoration(
                // contentPadding: EdgeInsets.all(0),
                counterText: "",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                filled: true,
                hintText: lableText,
                hintStyle: getStyle1(context),
                labelStyle: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.bg3),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.accentColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.primaryColor)),
                fillColor: AppColors.budgetSearch,
                border: InputBorder.none,
                prefixIcon: flag
                    ? PrefixIcon(
                        url: icon,
                        height: 40,
                        width: 40,
                      )
                    : Icon(Icons.search),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

