import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart";
import "package:flutter_application_code_stakeplot/headersList/userProfileHeader.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
import "package:flutter_application_code_stakeplot/userAvatar.dart";
import "package:get/get.dart";
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  RxBool flag = true.obs;

  @override
  void initState() {
    super.initState();
    getTransaction();
    getNotifications(context);
  }

  void getTransaction() async {
    String urlPath = '${url}/user/myNotifications';
    var response = await getDataApiCall(urlPath);
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        snackBarCalled(context, "No Notifications");
        return;
      }
      var his = jsonDecode(response.body);
      notificationList.clear();
      notificationList.addAll(his['data']);
      notificationList.forEach((req) {
        String type = req['notificationMessage']['type'];
        var e = req['notificationMessage'];
        if (type == "friendRequest") {
          friendRequestList.add(e['from_id']);
        }
      });
      flag.value = false;
      hasGetNewNotifications.value = false;
      myNotificationBool.value != myNotificationBool.value;
    } else {}
  }

  Future<void> deleteNotification(String notifyId) async {
    String urlPath = '${url}/user/deleteNotifications/${notifyId}';
    var response = await getDataApiCall(urlPath);
    if (response.statusCode != 200) {
      snackBarCalled(context, "Failed to delete notification");
    } else {
      // print("Notification deleted successfully."); // Debug statement
    }
  }

  int index = -1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            title: textStyle(
                context: context,
                text: "Notifications",
                fontsize: 18,
                fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.backgroundColor,
          body: Column(children: [
            // UserProfileHeader(name: "Notifications",),

            Expanded(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.165,
                  //margin:  EdgeInsets.only(top: Colorcodes.paddingTopDesign),
                  padding: EdgeInsets.symmetric(
                      vertical: Colorcodes.paddingTopScroll),
                  //  decoration: BoxDecoration(
                  //     color: Colorcodes.white,
                  //       borderRadius: BorderRadius.only(
                  //           topLeft: Radius.circular(Colorcodes.borderCut),
                  //           topRight: Radius.circular(Colorcodes.borderCut),
                  //          )

                  //  ),
                  child: Obx(() => myNotificationBool.value
                      ? notifiableElement()
                      : notifiableElement())),
            )
          ])),
    );
  }

  Widget notifiableElement() {
    return notificationList.length == 0 && flag.value
        ? Loader()
        : notificationList.length == 0
            ? Center(
                child: Container(
                    height: MediaQuery.of(context).size.height / 1.1,
                    child: Text("No Notifications",
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.accentColor))))
            : ListView(
                children: notificationList.map((e) {
                  var notifyId = e['_id'];
                  return Dismissible(
                      key: Key(notifyId),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        delete(notifyId);
                      },
                      background: Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                          decoration: BoxDecoration(
                              color: AppColors.mt,
                              borderRadius: BorderRadius.circular(10)),
                          child: getContainer(e),
                        ),
                      ));
                }).toList(),
              );
  }

  Widget getContainer(e) {
    var notifyId = e['_id'];
    var time = e['createdAt'] ?? "";
    String type = e['notificationMessage']['type'];
    e = e['notificationMessage'];
    index++;
    print(e);
    if (type == "friendRequest" &&
        e['status'] != null &&
        e['status'] == 'accepted') {
      return messageChannelProfile(
          "${e['from_name']} accepted your friend request",
          e['from_id'].toString(),
          e['avatarType'] ?? "",
          time);
    }
    if (type == "friendRequest") {
      return friends(e['from_name'], e['from_id'].toString(), e['avatarType'],
          e, index, notifyId, time);
    } else if (type == "split") {
      return messageChannelProfile(
          "${e['username']} has shared the bill for ${e['billname']} of ₹${(double.tryParse(e['amount'].toString()) ?? 400).toStringAsFixed(1)}",
          e['id'].toString(),
          e['avatarType'] ?? "",
          time);
    } else if (type == "roomBill") {
      return messageChannelProfile(
          "${e['from_name']}, has shared the bill in Room",
          e['from_id'].toString(),
          e['avatarType'] ?? "",
          time);
    } else if (type == "room") {
      return messageChannelProfile(
          "${e['from_name']}, has added in the room  ${e['roomName']}",
          e['from_id'].toString(),
          e['avatarType'] ?? "",
          time);
    } else if (type == "comment") {
      return messageChannelProfile(
          "${e['username']} has commented on your post",
          e['id'].toString(),
          e['avatarType'] ?? "",
          time);
    } else if (type == "lendRequest") {
      return lendRequest(e['from_name'], e['from_id'].toString(),
          e['avatarType'], e, index, e['name'] ?? "", notifyId, time);
    } else if (type == "lendAccepted" || type == "rejectedLend") {
      type = type == "lendAccepted" ? "accepted" : "rejected";

      return messageChannelProfile(
          "${e['username']} ${type} your Lent request for ${e['name']}, worth ₹${e['amount'] ?? '400'}",
          e['from_id'].toString(),
          e['avatarType'] ?? "",
          time);
    } else if (type == "lendSettled") {
      return messageChannelProfile(
          "${e['from_name']} has settled your loan of ${e['amount']} for the item: ${e['name']}.",
          e['id'].toString(),
          e['avatarType'] ?? "",
          time);
    } else if (type == "splitSettled") {
      return messageChannelProfile(
          "${e['from_name']} has settled your Split of ${e['amount'].toStringAsFixed(1)} for the item: ${e['name']}.",
          e['id'].toString(),
          e['avatarType'] ?? "",
          time);
    } else if (type == "FetchedData") {
      return messageChannelProfile(
          "🔥 Data has been successfully fetched!", "", "", time);
    } else if (type == "lendApprovalRequest") {
      String msg =
          "${e['from_name']} has requested approval for settling ${e['name']} with an amount of ${e['amount'] ?? '00'}.";

      return splitOrLendApprove(
          msg, e['bill_id'] ?? "", e['avatarType'] ?? "", time, "bill", "");
    } else if (type == "splitApprovalRequest") {
       String msg =
          "${e['from_name']} has requested approval for settling ${e['name']} with an amount of ${e['amount'] ?? '00'}.";

      return splitOrLendApprove(
          msg,
          e['split_id'] ?? "",
          e['avatarType'] ?? "",
          time,
          "split",
          e['from_to']);
    } else if (type == "clearLend" || type == "clearSplit") {
      String ty = type == "clearLend" ? "lend" : "split";
      return messageChannelProfile(
          "You has clear your ${ty} of ${e['amount'].toStringAsFixed(1)} for the item: ${e['name']}.",
          e['id'].toString(),
          e['avatarType'] ?? "",
          time);
    }

    return SizedBox(
      child: Text("hello"),
    );
  }

  Widget lendRequest(String name, String id, String avatar, e, int index,
      String itemName, String notifyId, time) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Define fixed width for avatar (adjust based on your getAvatarh implementation)
    const double avatarWidth =
        60.0; // Example: adjust this based on getAvatarh size
    const double horizontalPadding = 10.0; // 5 on each side
    const double spacingBetweenAvatarAndContent = 5.0;

    // Calculate the available width for the content (text and buttons)
    double contentWidth = screenWidth -
        (avatarWidth + horizontalPadding + spacingBetweenAvatarAndContent);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.circular(10),
        ),
        // width: screenWidth,
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align items at the top
              children: [
                // Avatar with a fixed width
                getAvatarh(avatar),
                const SizedBox(width: spacingBetweenAvatarAndContent),
                // Content area with calculated width
                Container(
                  width: contentWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${name} has lent you ₹${e['amount'] ?? '500'} for $itemName",
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 13,
                          lineHeight: 1.3,
                          color: AppColors.bg1,
                        ),
                        maxLines: 2, // Allow wrapping if text is too long
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              approveBill(context, e['bill_id'] ?? "", "accept",
                                  notifyId);
                              delete(notifyId);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "Approve",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: AppColors.bg5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              // Optimistic update
                              approveBill(context, e['bill_id'] ?? "", "reject",
                                  notifyId);
                              delete(notifyId);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "Reject",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: AppColors.bg3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: divider(time),
            ),
          ],
        ),
      ),
    );
  }

  void delete(notifyId) {
    notificationList.removeWhere((item) => item['_id'] == notifyId);
    deleteNotification(notifyId);
  }

  Widget friends(String name, String id, String avatar, e, int index,
      String notifyId, time) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double avatarWidth = 60.0;
    const double horizontalPadding = 10.0;
    const double spacingBetweenAvatarAndContent = 5.0;
    double contentWidth = screenWidth -
        (avatarWidth + horizontalPadding + spacingBetweenAvatarAndContent);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
            color: AppColors.mt, borderRadius: BorderRadius.circular(10)),
        //width: screenWidth/0.8,
        child: Column(
          children: [
            Row(
              children: [
                getAvatarh(avatar),
                const SizedBox(width: spacingBetweenAvatarAndContent),
                Container(
                  width: contentWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "$name",
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w600,
                                fontSize: 13,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "sent you a friend request",
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: 12,
                                maxLines: 2,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              addUserAsFrd(id, context);
                              delete(notifyId);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 7),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text("Accept",
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: () async {
                              rejectFrdRequest(e, context);
                              delete(notifyId);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 7),
                              decoration: BoxDecoration(
                                  color: AppColors.button,
                                  //border: Border.all(width: 0.5),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text("Reject",
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: divider(time),
            ),
          ],
        ),
      ),
    );
  }

  Widget divider(time) {
    return Container(
      alignment: Alignment.centerRight,
      child: textStyle(
          text: formatWhatsAppDate(DateTime.parse(time)),
          context: context,
          fontsize: 10,
          fontWeight: FontWeight.bold,
          c: AppColors.accentColor),
    );
  }

  Widget messageChannel(name, id, time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width / 1.1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (name),
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 5,
              ),
              divider(time)
            ],
          ),
        ),
      ),
    );
  }

  Widget messageChannelProfile(name, id, avatar, time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
          decoration: BoxDecoration(
              //  color:const Color.fromRGBO(249, 246, 238, 1),
              borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                children: [
                  avatar != "" ? getAvatarh(avatar) : SizedBox.shrink(),
                  const SizedBox(
                    width: 2,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.4,
                    //  color: Colorcodes.blue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (name),
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w600,
                              fontSize: 13,
                              lineHeight: 1.1,
                              color: Colors.black),
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                        //  const SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ],
              ),
              divider(time)
            ],
          ),
        ),
      ),
    );
  }

  Widget getAvatarh(avatar) {
    return UserAvatar(url: avatar, width: 15, height: 20);
  }

  Widget splitOrLendApprove(String name, String id, String avatar, time,
      String type, String endUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
          decoration: BoxDecoration(
              //  color:const Color.fromRGBO(249, 246, 238, 1),
              borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                children: [
                  avatar != "" ? getAvatarh(avatar) : SizedBox.shrink(),
                  const SizedBox(
                    width: 2,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.4,
                    //  color: Colorcodes.blue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (name),
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w600,
                              fontSize: 13,
                              lineHeight: 1.1,
                              color: Colors.black),
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                try {
                                  settleAmount(context, id, type, endUser);
                                } catch (e) {
                                  print(e);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 7),
                                decoration: BoxDecoration(
                                  color:  AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "Approve",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.bg5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 0.5),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "Reject",
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.bg3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        //  const SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ],
              ),
              divider(time)
            ],
          ),
        ),
      ),
    );
  }
}
