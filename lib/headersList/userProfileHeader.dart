import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/customNoti.dart';
import 'package:flutter_application_code_stakeplot/userAvatar.dart';


// ignore: must_be_immutable
class UserProfileHeader extends StatefulWidget {
  String name;
  bool flag;
  bool isBack;
  UserProfileHeader(
      {Key? key, required this.name, this.flag = true, this.isBack = true})
      : super(key: key);

  @override
  _UserProfileHeaderState createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Column(
        children: [
          Center(
            child: Container(
              color: AppColors.backgroundColor,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: widget.isBack
                          ? () {
                              Navigator.pop(context);
                            }
                          : null,
                      child: Icon(
                        Icons.arrow_back_sharp,
                        color: widget.isBack
                            ? Colorcodes.black
                            : Colors.transparent,
                      )),
                  Text((widget.name),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: 22,
                          color: AppColors.accentColor)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            //  String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

                            if (currentPage2(context) != "/Notifications")
                              Navigator.pushNamed(context, '/Notifications');
                          },
                          child: NotificationsBudget(
                            child: CircleAvatar(
                                backgroundColor: Colorcodes.budgetLightGreen,
                                child: Center(
                                    child: AvatarProfileImage(
                                        url: svgIconPath.notifications,
                                        width: 10,
                                        height: 20))),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (currentPage2(context) == "/Profile") return;
                            widget.flag
                                ? Navigator.pushNamed(context, "/Profile")
                                : null;
                          },
                          child: Center(
                              child: UserAvatar(
                                  url: widget.flag
                                      ? userController.avatar.value
                                      : svgIconPath.money,height: 15,width: 10,)),
                        )
                      ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
