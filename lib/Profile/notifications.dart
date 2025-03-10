import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
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
   
    String urlPath='${url}/user/myNotifications';
    var response=await getDataApiCall(urlPath);
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
        if (type == "friendRequest")
        {
          friendRequestList.add(e['from_id']);
        }
      });
      flag.value = false;
      hasGetNewNotifications.value = false;
      myNotificationBool.value != myNotificationBool.value;
    } else {
      
    }
  }

  Future<void> deleteNotification(String notifyId) async
  {
    String urlPath='${url}/user/deleteNotifications/${notifyId}';
    var response=await getDataApiCall(urlPath);
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
                    direction:
                        DismissDirection.endToStart, 
                    onDismissed: (direction)
                    {
                        delete(notifyId);
                      
                     
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: getContainer(e),
                  );
                }).toList(),
              );
  }

  Widget getContainer(e) {
    var notifyId = e['_id'];
    String type = e['notificationMessage']['type'];
    e = e['notificationMessage'];
    index++;
    if (type == "friendRequest" &&
        e['status'] != null &&
        e['status'] == 'accepted') {
      return messageChannelProfile(
          "${e['from_name']} accepted your friend request",
          e['from_id'].toString(),
          e['avatarType'] ?? "");
    }
    if (type == "friendRequest") {
      return friends(
          e['from_name'], e['from_id'].toString(), e['avatarType'], e, index,notifyId);
    } else if (type == "split") {
      return messageChannelProfile(
          "${e['username']}, has shared the bill of ${e['billname']} of ₹${e['amount'] ?? "400"}",
          e['id'].toString(),
          e['avatarType'] ?? "");
    } else if (type == "roomBill") {
      return messageChannelProfile(
          "${e['from_name']}, has shared the bill in Room",
          e['from_id'].toString(),
          e['avatarType'] ?? "");
    } else if (type == "room") {
      return messageChannelProfile(
          "${e['from_name']}, has added in the room  ${e['roomName']}",
          e['from_id'].toString(),
          e['avatarType'] ?? "");
    } else if (type == "comment") {
      return messageChannelProfile(
          "${e['username']} has commented on your post",
          e['id'].toString(),
          e['avatarType'] ?? "");
    } else if (type == "lendRequest") {
      return lendRequest(e['from_name'], e['from_id'].toString(),
          e['avatarType'], e, index, e['name'] ?? "", notifyId);
    } else if (type == "lendAccepted" || type == "rejectedLend") {
      type = type == "lendAccepted" ? "Accepted" : "Rejected";

      return messageChannelProfile(
          "${e['username']} ${type} your Lended Request of ${e['name']} of worth ..₹${e['amount'] ?? '400'}",
          e['from_id'].toString(),
          e['avatarType'] ?? "");
    }

    return SizedBox(
      child: Text("hello"),
    );
  }

  Widget lendRequest(String name, String id, String avatar, e, int index,
      String itemName, String notifyId) {
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
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        width: screenWidth,
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align items at the top
              children: [
                // Avatar with a fixed width
                SizedBox(
                  width: avatarWidth,
                  height: 50, // Adjust height as needed
                  child: getAvatarh(avatar),
                ),
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
                          fontSize: 14,
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
                           
                              approveBill(context, e['bill_id'] ?? "", "accept",notifyId);
                              delete(notifyId);
                            
                             
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(97, 143, 214, 1),
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
                              approveBill(context, e['bill_id'] ?? "", "reject",notifyId);
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
            divider(),
          ],
        ),
      ),
    );
  }

  void delete(notifyId){
      notificationList.removeWhere((item) =>item['_id'] ==notifyId);
       deleteNotification(notifyId);
  }

  Widget friends(String name, String id, String avatar, e, int index,String notifyId) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double avatarWidth = 60.0;
    const double horizontalPadding = 10.0;
    const double spacingBetweenAvatarAndContent = 5.0;
    double contentWidth = screenWidth -
        (avatarWidth + horizontalPadding + spacingBetweenAvatarAndContent);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        width: screenWidth,
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                    width: avatarWidth, height: 50, child: getAvatarh(avatar)),
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
                                lWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Colors.black),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "sent you a friend request",
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w600,
                                fontSize: 14,
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
                                  color: const Color.fromRGBO(97, 143, 214, 1),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text("Accept",
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 14,
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
                                  color: Colors.white,
                                  border: Border.all(width: 0.5),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text("Reject",
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 14,
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
            divider(),
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(
        // thickness: 2,
        // indent: 10,
        // color: Colorcodes.budgetDarkGreen,
        );
  }

  Widget messageChannel(name, id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
              //  color:const Color.fromRGBO(249, 246, 238, 1),
              borderRadius: BorderRadius.circular(10)),
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
              divider()
            ],
          ),
        ),
      ),
    );
  }

  Widget messageChannelProfile(name, id, avatar) {
   
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
                  getAvatarh(avatar),
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
                              fontSize: 14,
                              lineHeight: 1.3,
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
              divider()
            ],
          ),
        ),
      ),
    );
  }

  Widget poll(e) {
    // List options=e['options'];
    // String s="2";//e['myVote'];
    // bool myvote=e['myVote']!="none";
    // int len=4;

    return Text("Poll");

    // options.forEach((element) {
    //     List ll=element['votes'];
    //      len += ll.length ;
    // });

//  return Padding(
//    padding: const EdgeInsets.all(10.0),
//    child: Container(
//        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
//         width: MediaQuery.of(context).size.width/1.1,
//        decoration: BoxDecoration(
//            color: Colorcodes.appBarColor,
//            borderRadius: BorderRadius.circular(5),

//        ),
//        child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(e['question'],style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w500,
//                                   fontSize: 16,
//                                   color: Colors.black)),
//                       ),
//                      Column(
//                        mainAxisAlignment: MainAxisAlignment.start,
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                       children:options.map((op) {
//                         List ll=[20];//op['votes'];
//                         String cal=((ll.length/len)* 100).toStringAsFixed(2);
//                         // len += ll.length ;
//                         return  Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4.0),
//                         child: InkWell(
//                           onTap: myvote? null:(){
//                               //  votePoll(context,e['_id'],options.indexOf(op));
//                           },
//                           child: Container(
//                               padding: EdgeInsets.symmetric(vertical: 13,horizontal: 10),
//                               width: MediaQuery.of(context).size.width/1.3,
//                              decoration: BoxDecoration(
//                                  color: s.endsWith((options.indexOf(op)+1).toString())? Colors.grey[100]:Colors.white,
//                                   borderRadius: BorderRadius.circular(5),
//                                   // border: Border.all()
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(op['option'],
//                                   style: FontManager().getTextStyle(context,
//                                           lWeight: FontWeight.w400,
//                                           fontSize: 14,
//                                           color: Colors.black)),
//                                myvote ? Text(cal=="0.00"?'0%':cal=="100.00"?"100&":cal+"%",
//                                   style: FontManager().getTextStyle(context,
//                                           lWeight: FontWeight.w400,
//                                           fontSize: 14,
//                                           color: Colors.black)):SizedBox.shrink(),
//                                 ],
//                               )
//                                              ),
//                         ),
//                  );
//                  }
//                  ).toList()),
// ],
//        ),
//    ),
//  );
  }

  Widget getAvatarh(avatar) {
    return UserAvatar(url: avatar, width: 12, height: 18);
  }
}
