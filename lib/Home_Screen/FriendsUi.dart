
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../Constants/core/app_padding_sizes.dart';

RxList addedUser = [].obs;
RxList addedMembers = [].obs;

class FriendsUi extends StatefulWidget {
  bool flag=true;
   FriendsUi({Key? key,this.flag=true}) : super(key: key);

  @override
  _FriendsUiState createState() => _FriendsUiState();
}

class _FriendsUiState extends State<FriendsUi> {
  TextEditingController Textcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.9,
      child: Padding(
        padding: const EdgeInsets.only(top:AppSizes.p24, left:AppSizes.p18, right:AppSizes.p18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select people',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.bg1)),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p14),
                child: InputDat('Search', TextInputType.name, Textcontroller),
              ),
      
              Text('My friends',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.bg1)),
              SizedBox(
                height: 10,
              ),
      
              addedMembers.length > 0
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 5,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: addedMembers.map((element) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 6,
                            height: MediaQuery.of(context).size.width / 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(0.0),
                                      child: Center(
                                          child:  AvatarProfileImage(
                                              url: element['avatar'] ?? userController.avatar,
                                              width: 10,
                                              height: 20)),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: InkWell(
                                        onTap: () {
                                          List me = [];
                                          addedMembers.forEach((ele) {
                                            if (element['id'] != ele['id']) {
                                              me.add(ele);
                                            }
                                          });
      
                                          setState(() {
                                            addedMembers.clear();
                                            addedMembers.addAll(me);
                                            //  addedMembers=me;
                                            addedUser.remove(element['id']);
                                          });
      
                                        },
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: AppColors.accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                    child: Text(element['name'],
                                        style: FontManager().getTextStyle(
                                            context,
                                            fontSize: 12,
                                            maxLines: 1,
                                            ),overflow: TextOverflow.ellipsis,))
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : SizedBox.shrink(),
      
              //  const SizedBox(height: 50,),
      
              commentedData(),
      
            widget.flag?  Center(
                child: InkWell(
                  onTap: () {
                     // double amount = double.parse(
                        //     transactionList["amount"].toString());
                        // splitUserAmount(
                        //     context,
                        //     amount.toString(),
                        //     addedMembers,
                        //     transactionList["category"],
                        //     transactionList["subcategory"],
                        //     amount.toString());
                    Navigator.pop(context);
                    
                  },
                  child: getButton(context, "Continue"),
                ),
              ):SizedBox.shrink(),
      
              // InkWell(
              //   onTap: Navigator.pop(context),
              //   child: getButton(context, "Continue"))
            ],
          ),
        ),
      ),
    );
  }

  Widget commentedData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p10),
        decoration: BoxDecoration(
            // color: const Color.fromRGBO(249, 246, 238, 1),
            //  color: AppColors.button,
            borderRadius: BorderRadius.circular(4)),
        child: Column(
          children: [
            // InputDat('Search',TextInputType.name,Textcontroller),

            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 2),
              child: SizedBox(
                height: 70,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:  userController.friendsList.length, // +1 for loading more indicator
                  itemBuilder: (context, index) {
                    String values =  userController.friendsList[index]['_id'];
                    return InkWell(
                      onTap: () {},
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if(isLend.value){
                                  addedUser.clear();
                                  addedMembers.clear();
                              }
                              setState(() {
                                addedUser.contains(values)
                                    ? addedUser.remove(values)
                                    : addedUser.add(values);
                                if (addedUser.contains(values)) {
                                  addedMembers.add(
                                    {
                                      "name": userController.friendsList[index]['name'],
                                      "id": values,
                                      'avatar': userController.friendsList[index]['avatar'],
                                      "balance": 200,
                                      
                                    },
                                  );
                                } else {
                                  List f = [];
                                  addedMembers.forEach((element) {
                                    if (element['id'] != values) {
                                      f.add(element);
                                    }
                                  });

                                  // setState(() {
                                  //   addedMembers.clear();
                                  //   addedMembers.addAll(f);
                                  // });
                                }
                              });
                            },
                            child: Container(
                              // color:Colors.deepOrangeAccent,
                              width: MediaQuery.of(context).size.width / 5,
                              height: 50,
                              // backgroundColor:const Color.fromRGBO(249, 246, 238, 1),
                              child: Stack(
                                children: [
                                  Center(
                                      child: AvatarProfileImage(
                                          url: userController.friendsList[index]['avatar'] ??
                                          userController.avatar,
                                          width: 8,
                                          height: 18)),

                                  // const  Center(
                                  //      child: Icon(
                                  //           Icons.person_outline_sharp,
                                  //           size: 40,
                                  //           color: AppColors.accentColor,
                                  //         ),
                                  //    ),
                                  addedUser.contains(values)
                                      ? const Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Icon(
                                            Icons.check,
                                            size: 30,
                                            color: Colors.green
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                          Text((userController.friendsList[index]['name']),
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: AppColors.bg1))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget InputDat(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 5),
        color: Color.fromRGBO(246, 246, 246, 1),
        width: MediaQuery.of(context).size.width / 1.1,
        // height: 50,
        child: Center(
          child: TextFormField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            onChanged: (v) {
              var frdsList2 = [];

              if (v == "") {
                userController.friendsList.clear();
                userController.friendsList.addAll(userController.frdsListOrigin);
              }

             userController.frdsListOrigin.forEach((element) {
                if (element['name'].toString().contains(v)) {
                  frdsList2.add(element);
                }
              });

              setState(() {
                userController.friendsList.clear();
                userController.friendsList.addAll(frdsList2);
              });
            },
            decoration: InputDecoration(
              filled: true,
              hintText: lableText,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      // color:AppColors.backgroundColor
                      color: Color.fromRGBO(249, 246, 238, 1))),
              focusedBorder: OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(40),
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: Color.fromRGBO(246, 246, 246, 1))),
              fillColor: AppColors.button,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

