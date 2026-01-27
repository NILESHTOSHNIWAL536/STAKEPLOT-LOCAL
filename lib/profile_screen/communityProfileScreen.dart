import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Profile/friends.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/tabBarUser.dart';

import '../Constants/core/app_padding_sizes.dart';

class CommunityProfileScreen extends StatefulWidget {
  String id;
  CommunityProfileScreen({super.key, required this.id});

  @override
  State<CommunityProfileScreen> createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityProfileScreen> {
   UserController userController=ControllerManagement.userController;

  @override
  void initState() {
    getuserPost(widget.id);
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              topUserProfile(userController),
              TabBarUser(userPostList:  userController.myPostList),
            ],
          ),
        ),
      ),
    );
  }

  Widget topUserProfile(UserController userController) {
    return Container(
      height: MediaQuery.of(context).size.height / 5.7,
      // height: 200,
      child: Column(
        children: [
          AvatarProfile2(
            url: userController.avatar.value,
            width: 4.4,
            height: 10,
            flag: true,
          ),
          Text(userController.maskedName.value.toString(),
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w600, color: AppColors.bg1)),
          SizedBox(
            height: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                networkFriends(ProfileScreenStrings().postsLabel,
                    userController.myPostList.length.toString(), Icons.post_add),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Friends(
                          isMasked: true,

                        ),
                      ),
                    );
                  },
                  child: networkFriends(
                      ProfileScreenStrings().networkLabel,
                     userController.maskedConnections.length.toString(),
                      Icons.person_2_outlined),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Friends(
                          isMasked: true,
                          isMaskedConnect: true,
                        ),
                      ),
                    );
                  },
                  child: networkFriends(
                      ProfileScreenStrings().networkLabelConnected,
                      userController.maskedConnected.length.toString(),
                      Icons.person_2_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget networkFriends(String network, String count, IconData icon) {
    return Container(
        // width: MediaQuery.sizeOf(context).width/2.4,
        padding: EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryColor, width: .5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textStyle(
                context: context,
                text: count.toString(),
                fontWeight: FontWeight.w500,
                c: AppColors.finSpaceColor,
                fontsize: 15),
            const SizedBox(
              width: 5,
            ),
            textStyle(
                context: context,
                text: network.toString(),
                fontWeight: FontWeight.w400,
                c: AppColors.finSpaceColor,
                fontsize: 15),
          ],
        ));
  }
}
