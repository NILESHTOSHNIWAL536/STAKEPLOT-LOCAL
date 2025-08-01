import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';

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
           (heading=="tagSearch" || heading=="") ? SizedBox.shrink():  const SizedBox(
              height: 10,
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
                        color: Colors.black),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                 
                  
                  suffixIcon: flag
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

class TextFeildWidgetPassword extends StatelessWidget {
  TextEditingController textEditingController;
  String lableText;
  String heading;
  TextInputType keyBoard;
  bool flag;
  IconData icon;
  final RxBool show = true.obs;
  TextFeildWidgetPassword(
      {Key? key,
      required this.textEditingController,
      required this.heading,
      required this.keyBoard,
      required this.lableText,
      this.icon = Icons.email_outlined,
      this.flag = true})
      : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    //  return Text("data");
    return Obx(() => Center(
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          width: MediaQuery.of(context).size.width / 1.1,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                  child: Text(heading,
                      style: FontManager().getTextStyle(context,
                          fontSize: 16, lWeight: FontWeight.w600)),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: TextFormField(
                    keyboardType: keyBoard,
                    controller: textEditingController,
                    obscureText: show.value,
                    onChanged: (s) {
                      acceptReset.value = false;
                    },
                     inputFormatters:
                     [
                       FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      
                    ],
                    decoration: InputDecoration(
                        // contentPadding: EdgeInsets.all(0),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        filled: true,
                        hintText: lableText,
                        hintStyle: getStyle(context),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colorcodes.textFeild)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colorcodes.textFeild)),
                        fillColor: Colorcodes.textFeild,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          icon,
                          size: 30,
                          color: AppColors.primaryColor,
                        ),
                        suffixIcon: flag
                            ? null
                            : Obx(() => InkWell(
                                  onTap: () {
                                    show.value = !show.value;
                                  },
                                  child: Icon(
                                    !show.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.primaryColor,
                                  ),
                                ))),
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class TextFeildWidget2 extends StatelessWidget {
  String lableText;
  String heading;
  TextFeildWidget2({Key? key, required this.heading, required this.lableText})
      : super(key: key);

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              child: Text(heading,
                  style: FontManager().getTextStyle(context,
                      fontSize: 18, lWeight: FontWeight.w600)),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.name,
              initialValue: lableText,
              readOnly: true,
              // controller: textEditingController,
              onChanged: (s) {
                acceptReset.value = false;
              },

              decoration: InputDecoration(
                // contentPadding: EdgeInsets.all(0),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                filled: true,
                hintText: lableText,
                hintStyle: getStyle(context),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colorcodes.textFeild)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colorcodes.textFeild)),
                fillColor: Colorcodes.textFeild,
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class TextFeildCalender extends StatelessWidget {
  TextEditingController textEditingController;
  String lableText;
  String heading;
  TextInputType keyBoard;
  bool flag;
  TextFeildCalender(
      {Key? key,
      required this.textEditingController,
      required this.heading,
      required this.keyBoard,
      required this.lableText,
      this.flag = true})
      : super(key: key);

  RxBool show = false.obs;

  @override
  Widget build(BuildContext context) {
    //  return Text("data");
    return Center(
        child: GestureDetector(
      onTap: () async {
        // Removed manual entry, only allow selection through suffix icon
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width / 1.1,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9.0),
                child: Text(heading,
                    style: FontManager().getTextStyle(context,
                        fontSize: 16, lWeight: FontWeight.w600)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.none, // Disable manual entry
                controller: textEditingController,
                obscureText: flag ? false : show.value,
                readOnly: true, 
                onChanged: (s) {
                  // Removed manual entry handling
                },
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    filled: true,
                    hintText: lableText,
                    hintStyle: getStyle2(context),
                    fillColor: Colorcodes.textFeild,
                     enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colorcodes.textFeild)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colorcodes.textFeild)),
                    border: InputBorder.none,
                    prefixIcon:  Icon(Icons.calendar_today,color: AppColors.primaryColor),
                    suffixIcon: GestureDetector(
                      onTap: () async {
                        DateTime? dateTime = await showDatePicker(
                            context: context,
                            initialDate:DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now());
                        if (dateTime != null) {
                          textEditingController.text = DateFormat('yyyy-MM-dd')
                              .format(dateTime)
                              .toString();
                        }
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: Colorcodes.paddingSize),
                          decoration:
                              BoxDecoration(color: AppColors.primaryColor,
                              
                                                       borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                       
                           
                           
                              ),
                          child: Icon(
                            Icons.arrow_drop_down_sharp,
                            color: Colorcodes.white,
                          )),
                    )),
              ),
            ],
          ),
        ),
      ),
    ));
  }
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
      padding: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width / 1.1,
      // color: Colorcodes.white,
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
            const SizedBox(
              height: 10,
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
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colorcodes.white)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colorcodes.white)),
                fillColor: Colorcodes.white,
                border: InputBorder.none,
              
                prefixIcon: flag
                    ? Icon(
                        icon,
                        size: 30,
                        color: AppColors.primaryColor,
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
      padding: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width / 1.1,
      // color: Colorcodes.white,
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
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.accentColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.primaryColor)),
                fillColor: AppColors.button,
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
