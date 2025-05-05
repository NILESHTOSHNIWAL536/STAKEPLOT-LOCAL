import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';


RxString cateName="".obs;

void openShowModalCate(BuildContext context, TextEditingController nameController,String narr) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height /3,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child:Column(
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
                children: [
                    getImageContainer(Categories.link+Categories.alcohal),
                    getImageContainer(Categories.link+Categories.food),
                    getImageContainer(Categories.link+Categories.health),
                ],
              ),

               SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),

              InkWell(
                onTap: () {
                   postCustomCategory(context, nameController.text, cateName.value, narr);
                },
                child: getButton(context, "Add Category")),


          ],
      ) ,
    ),
  );
}


Widget getImageContainer(String imagePath) {
  return Obx(()=> InkWell(
    onTap: () => {
      cateName.value = imagePath,
      print(cateName.value),
    },
    child: Container(
      height: 50,
      width: 50,
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
         color: cateName.value==imagePath?Colorcodes.greyLight:Colorcodes.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AvatarProfileImage(url: imagePath, width: 10, height: 10),
    ),
  ));
}