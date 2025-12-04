import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/components/textfeild.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../backed_connections/apis_connect.dart';
import '../repository/transactions_repository.dart';

RxString cateName = "".obs;

void openShowModalCate(
    BuildContext context,
     TextEditingController nameController,
      String narr,
      void Function(dynamic e) callBack,
    )
  {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the modal to resize with the keyboard
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      // Flexible height to accommodate keyboard
      height: MediaQuery.of(context).size.height / 3 +
          MediaQuery.of(context).viewInsets.bottom,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        // Makes content scrollable when keyboard appears
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Adjusts for keyboard
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Only take needed space
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              TextFeildWidget(
                textEditingController: nameController,
                heading: "Category Name",
                keyBoard: TextInputType.emailAddress,
                lableText: "Enter Category Name",
                icon: Icons.category,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: customCategoryUnUsedList.map((urlPathImage)=> getImageContainer(urlPathImage)).toList()
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              InkWell(
                onTap: () {
                  //need to chnage the local vai
                  var e={
                     'name':nameController.text,
                     'imageUrl':cateName.value,
                  };
                  callBack(e);
                  postCustomCategory(context, nameController.text, cateName.value, narr);
                },
                child: getButton(context, "Add Category"),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ), // Extra space for padding
            ],
          ),
        ),
      ),
    ),
  );
}

Widget getImageContainer(String imagePath) {
  return Obx(() => InkWell(
        onTap: () {
          cateName.value = imagePath;
        },
        child: Container(
          height: 50,
          width: 50,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: cateName.value == imagePath ? Colorcodes.greyLight : Colorcodes.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AvatarProfileImage(url: imagePath, width: 10, height: 10),
        ),
      ));
}