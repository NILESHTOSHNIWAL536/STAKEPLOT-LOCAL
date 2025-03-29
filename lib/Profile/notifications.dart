// import "dart:convert";
// import "package:flutter/cupertino.dart";
// import "package:flutter/material.dart";
// import "package:flutter/widgets.dart";
// import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
// import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
// import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
// import "package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart";
// import "package:flutter_application_code_stakeplot/avatarProfile.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
// import "package:flutter_application_code_stakeplot/colorcodes.dart";
// import "package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart";
// import "package:flutter_application_code_stakeplot/headersList/userProfileHeader.dart";
// import "package:flutter_application_code_stakeplot/loader.dart";
// import "package:flutter_application_code_stakeplot/userAvatar.dart";
// import "package:get/get.dart";
// import 'package:http/http.dart' as http;
// import "package:shared_preferences/shared_preferences.dart";

// class Notifications extends StatefulWidget {
//   const Notifications({Key? key}) : super(key: key);

//   @override
//   _NotificationsState createState() => _NotificationsState();
// }

// class _NotificationsState extends State<Notifications> {
//   RxBool flag = true.obs;

//   @override
//   void initState() {
//     super.initState();
//     getTransaction();
//     getNotifications(context);
//   }

//   void getTransaction() async {
//     String urlPath = '${url}/user/myNotifications';
//     var response = await getDataApiCall(urlPath);
//     if (response.statusCode == 200) {
//       if (response.body.isEmpty) {
//         snackBarCalled(context, "No Notifications");
//         return;
//       }
//       var his = jsonDecode(response.body);
//       notificationList.clear();
//       notificationList.addAll(his['data']);
//       notificationList.forEach((req) {
//         String type = req['notificationMessage']['type'];
//         var e = req['notificationMessage'];
//         if (type == "friendRequest") {
//           friendRequestList.add(e['from_id']);
//         }
//       });
//       flag.value = false;
//       hasGetNewNotifications.value = false;
//       myNotificationBool.value != myNotificationBool.value;
//     } else {}
//   }

//   Future<void> deleteNotification(String notifyId) async {
//     String urlPath = '${url}/user/deleteNotifications/${notifyId}';
//     var response = await getDataApiCall(urlPath);
//     if (response.statusCode != 200) {
//       snackBarCalled(context, "Failed to delete notification");
//     } else {
//       // print("Notification deleted successfully."); // Debug statement
//     }
//   }

//   int index = -1;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           appBar: AppBar(
//             backgroundColor: AppColors.backgroundColor,
//             title: textStyle(
//                 context: context,
//                 text: "Notifications",
//                 fontsize: 18,
//                 fontWeight: FontWeight.w600),
//           ),
//           backgroundColor: AppColors.backgroundColor,
//           body: Column(children: [
//             // UserProfileHeader(name: "Notifications",),

//             Expanded(
//               child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height / 1.165,
//                   //margin:  EdgeInsets.only(top: Colorcodes.paddingTopDesign),
//                   padding: EdgeInsets.symmetric(
//                       vertical: Colorcodes.paddingTopScroll),
//                   //  decoration: BoxDecoration(
//                   //     color: Colorcodes.white,
//                   //       borderRadius: BorderRadius.only(
//                   //           topLeft: Radius.circular(Colorcodes.borderCut),
//                   //           topRight: Radius.circular(Colorcodes.borderCut),
//                   //          )

//                   //  ),
//                   child: Obx(() => myNotificationBool.value
//                       ? notifiableElement()
//                       : notifiableElement())),
//             )
//           ])),
//     );
//   }

//   Widget notifiableElement() {
//     return notificationList.length == 0 && flag.value
//         ? Loader()
//         : notificationList.length == 0
//             ? Center(
//                 child: Container(
//                     height: MediaQuery.of(context).size.height / 1.1,
//                     child: Text("No Notifications",
//                         style: FontManager().getTextStyle(context,
//                             lWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: AppColors.accentColor))))
//             : ListView(
//                 children: notificationList.map((e) {
//                   var notifyId = e['_id'];
//                   return Dismissible(
//                       key: Key(notifyId),
//                       direction: DismissDirection.endToStart,
//                       onDismissed: (direction) {
//                         delete(notifyId);
//                       },
//                       background: Container(
//                         decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(10)),
//                         alignment: Alignment.centerRight,
//                         padding: EdgeInsets.only(right: 20),
//                         child: Icon(Icons.delete, color: Colors.white),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(0.0),
//                         child: Container(
//                           margin:
//                               EdgeInsets.symmetric(vertical: 4, horizontal: 2),
//                           padding:
//                               EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//                           decoration: BoxDecoration(
//                               color: AppColors.mt,
//                               borderRadius: BorderRadius.circular(10)),
//                           child: getContainer(e),
//                         ),
//                       ));
//                 }).toList(),
//               );
//   }

//   Widget getContainer(e) {
//     var notifyId = e['_id'];
//     var time = e['createdAt'] ?? "";
//     String type = e['notificationMessage']['type'];
//     e = e['notificationMessage'];
//     index++;
//     print(e);
//     if (type == "friendRequest" &&
//         e['status'] != null &&
//         e['status'] == 'accepted') {
//       return messageChannelProfile(
//           "${e['from_name']} accepted your friend request",
//           e['from_id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     }
//     if (type == "friendRequest") {
//       return friends(e['from_name'], e['from_id'].toString(), e['avatarType'],
//           e, index, notifyId, time);
//     } else if (type == "split") {
//       return messageChannelProfile(
//           "${e['username']} has shared the bill for ${e['billname']} of ₹${(double.tryParse(e['amount'].toString()) ?? 400).toStringAsFixed(1)}",
//           e['id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     } else if (type == "roomBill") {
//       return messageChannelProfile(
//           "${e['from_name']}, has shared the bill in Room",
//           e['from_id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     } else if (type == "room") {
//       return messageChannelProfile(
//           "${e['from_name']}, has added in the room  ${e['roomName']}",
//           e['from_id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     } else if (type == "comment") {
//       return messageChannelProfile(
//           "${e['username']} has commented on your post",
//           e['id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     } else if (type == "lendRequest") {
//       return lendRequest(e['from_name'], e['from_id'].toString(),
//           e['avatarType'], e, index, e['name'] ?? "", notifyId, time);
//     } else if (type == "lendAccepted" || type == "rejectedLend") {
//       type = type == "lendAccepted" ? "accepted" : "rejected";

//       return messageChannelProfile(
//           "${e['username']} ${type} your Lent request for ${e['name']}, worth ₹${e['amount'] ?? '400'}",
//           e['from_id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     } else if (type == "lendSettled") {
//       return messageChannelProfile(
//           "${e['from_name']} has settled your loan of ${e['amount']} for the item: ${e['name']}.",
//           e['id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     } else if (type == "splitSettled") {
//       return messageChannelProfile(
//           "${e['from_name']} has settled your Split of ${e['amount'].toStringAsFixed(1)} for the item: ${e['name']}.",
//           e['id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     } else if (type == "FetchedData") {
//       return messageChannelProfile(
//           "🔥 Data has been successfully fetched!", "", "", time);
//     } else if (type == "lendApprovalRequest") {
//       String msg =
//           "${e['from_name']} has requested approval for settling ${e['name']} with an amount of ${e['amount'] ?? '00'}.";

//       return splitOrLendApprove(
//           msg, e['bill_id'] ?? "", e['avatarType'] ?? "", time, "bill", "");
//     } else if (type == "splitApprovalRequest") {
//        String msg =
//           "${e['from_name']} has requested approval for settling ${e['name']} with an amount of ${e['amount'] ?? '00'}.";

//       return splitOrLendApprove(
//           msg,
//           e['split_id'] ?? "",
//           e['avatarType'] ?? "",
//           time,
//           "split",
//           e['from_to']);
//     } else if (type == "clearLend" || type == "clearSplit") {
//       String ty = type == "clearLend" ? "lend" : "split";
//       return messageChannelProfile(
//           "You has clear your ${ty} of ${e['amount'].toStringAsFixed(1)} for the item: ${e['name']}.",
//           e['id'].toString(),
//           e['avatarType'] ?? "",
//           time);
//     }

//     return SizedBox(
//       child: Text("hello"),
//     );
//   }

//   Widget lendRequest(String name, String id, String avatar, e, int index,
//       String itemName, String notifyId, time) {
//     // Get the screen width
//     double screenWidth = MediaQuery.of(context).size.width;

//     // Define fixed width for avatar (adjust based on your getAvatarh implementation)
//     const double avatarWidth =
//         60.0; // Example: adjust this based on getAvatarh size
//     const double horizontalPadding = 10.0; // 5 on each side
//     const double spacingBetweenAvatarAndContent = 5.0;

//     // Calculate the available width for the content (text and buttons)
//     double contentWidth = screenWidth -
//         (avatarWidth + horizontalPadding + spacingBetweenAvatarAndContent);

//     return Center(
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           vertical: 4,
//         ),
//         decoration: BoxDecoration(
//           color: AppColors.mt,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         // width: screenWidth,
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start, // Align items at the top
//               children: [
//                 // Avatar with a fixed width
//                 getAvatarh(avatar),
//                 const SizedBox(width: spacingBetweenAvatarAndContent),
//                 // Content area with calculated width
//                 Container(
//                   width: contentWidth,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${name} has lent you ₹${e['amount'] ?? '500'} for $itemName",
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w600,
//                           fontSize: 13,
//                           lineHeight: 1.3,
//                           color: AppColors.bg1,
//                         ),
//                         maxLines: 2, // Allow wrapping if text is too long
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 5),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               approveBill(context, e['bill_id'] ?? "", "accept",
//                                   notifyId);
//                               delete(notifyId);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 7),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primaryColor,
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: Text(
//                                 "Approve",
//                                 style: FontManager().getTextStyle(
//                                   context,
//                                   lWeight: FontWeight.w400,
//                                   fontSize: 14,
//                                   color: AppColors.bg5,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           InkWell(
//                             onTap: () {
//                               // Optimistic update
//                               approveBill(context, e['bill_id'] ?? "", "reject",
//                                   notifyId);
//                               delete(notifyId);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 7),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(width: 0.5),
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: Text(
//                                 "Reject",
//                                 style: FontManager().getTextStyle(
//                                   context,
//                                   lWeight: FontWeight.w400,
//                                   fontSize: 14,
//                                   color: AppColors.bg3,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: divider(time),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void delete(notifyId) {
//     notificationList.removeWhere((item) => item['_id'] == notifyId);
//     deleteNotification(notifyId);
//   }

//   Widget friends(String name, String id, String avatar, e, int index,
//       String notifyId, time) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     const double avatarWidth = 60.0;
//     const double horizontalPadding = 10.0;
//     const double spacingBetweenAvatarAndContent = 5.0;
//     double contentWidth = screenWidth -
//         (avatarWidth + horizontalPadding + spacingBetweenAvatarAndContent);

//     return Center(
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 2),
//         decoration: BoxDecoration(
//             color: AppColors.mt, borderRadius: BorderRadius.circular(10)),
//         //width: screenWidth/0.8,
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 getAvatarh(avatar),
//                 const SizedBox(width: spacingBetweenAvatarAndContent),
//                 Container(
//                   width: contentWidth,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "$name",
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 overflow: TextOverflow.ellipsis,
//                                 color: Colors.black),
//                           ),
//                           const SizedBox(width: 2),
//                           Text(
//                             "sent you a friend request",
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.w500,
//                                 fontSize: 12,
//                                 maxLines: 2,
//                                 softWrap: false,
//                                 overflow: TextOverflow.ellipsis,
//                                 color: Colors.black),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 5),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               addUserAsFrd(id, context);
//                               delete(notifyId);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 7),
//                               decoration: BoxDecoration(
//                                   color: AppColors.primaryColor,
//                                   borderRadius: BorderRadius.circular(5)),
//                               child: Text("Accept",
//                                   style: FontManager().getTextStyle(context,
//                                       lWeight: FontWeight.w400,
//                                       fontSize: 12,
//                                       color: Colors.white)),
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           InkWell(
//                             onTap: () async {
//                               rejectFrdRequest(e, context);
//                               delete(notifyId);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 7),
//                               decoration: BoxDecoration(
//                                   color: AppColors.button,
//                                   //border: Border.all(width: 0.5),
//                                   borderRadius: BorderRadius.circular(5)),
//                               child: Text("Reject",
//                                   style: FontManager().getTextStyle(context,
//                                       lWeight: FontWeight.w400,
//                                       fontSize: 12,
//                                       color: Colors.black)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: divider(time),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget divider(time) {
//     return Container(
//       alignment: Alignment.centerRight,
//       child: textStyle(
//           text: formatWhatsAppDate(DateTime.parse(time)),
//           context: context,
//           fontsize: 10,
//           fontWeight: FontWeight.bold,
//           c: AppColors.accentColor),
//     );
//   }

//   Widget messageChannel(name, id, time) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
//           width: MediaQuery.of(context).size.width / 1.1,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 (name),
//                 style: FontManager().getTextStyle(context,
//                     lWeight: FontWeight.w500,
//                     fontSize: 14,
//                     color: Colors.black),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(
//                 height: 5,
//               ),
//               divider(time)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget messageChannelProfile(name, id, avatar, time) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
//           decoration: BoxDecoration(
//               //  color:const Color.fromRGBO(249, 246, 238, 1),
//               borderRadius: BorderRadius.circular(10)),
//           width: MediaQuery.of(context).size.width,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   avatar != "" ? getAvatarh(avatar) : SizedBox.shrink(),
//                   const SizedBox(
//                     width: 2,
//                   ),
//                   Container(
//                     width: MediaQuery.of(context).size.width / 1.4,
//                     //  color: Colorcodes.blue,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           (name),
//                           style: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.w600,
//                               fontSize: 13,
//                               lineHeight: 1.1,
//                               color: Colors.black),
//                           // maxLines: 1,
//                           // overflow: TextOverflow.ellipsis,
//                         ),
//                         //  const SizedBox(height: 5,),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               divider(time)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget getAvatarh(avatar) {
//     return UserAvatar(url: avatar, width: 15, height: 20);
//   }

//   Widget splitOrLendApprove(String name, String id, String avatar, time,
//       String type, String endUser) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
//           decoration: BoxDecoration(
//               //  color:const Color.fromRGBO(249, 246, 238, 1),
//               borderRadius: BorderRadius.circular(10)),
//           width: MediaQuery.of(context).size.width,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   avatar != "" ? getAvatarh(avatar) : SizedBox.shrink(),
//                   const SizedBox(
//                     width: 2,
//                   ),
//                   Container(
//                     width: MediaQuery.of(context).size.width / 1.4,
//                     //  color: Colorcodes.blue,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           (name),
//                           style: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.w600,
//                               fontSize: 13,
//                               lineHeight: 1.1,
//                               color: Colors.black),
//                           // maxLines: 1,
//                           // overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 2),

//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 try {
//                                   settleAmount(context, id, type, endUser);
//                                 } catch (e) {
//                                   print(e);
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 7),
//                                 decoration: BoxDecoration(
//                                   color:  AppColors.primaryColor,
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Text(
//                                   "Approve",
//                                   style: FontManager().getTextStyle(
//                                     context,
//                                     lWeight: FontWeight.w400,
//                                     fontSize: 14,
//                                     color: AppColors.bg5,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             InkWell(
//                               onTap: () {},
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 7),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   border: Border.all(width: 0.5),
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Text(
//                                   "Reject",
//                                   style: FontManager().getTextStyle(
//                                     context,
//                                     lWeight: FontWeight.w400,
//                                     fontSize: 14,
//                                     color: AppColors.bg3,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         //  const SizedBox(height: 5,),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               divider(time)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
import "package:flutter_application_code_stakeplot/userAvatar.dart";
import "package:get/get.dart";
import 'package:http/http.dart' as http;

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
      notificationList.addAll(his['data'] ?? []);
      notificationList.forEach((req) {
        String? type = req['notificationMessage']?['type'];
        var e = req['notificationMessage'];
        if (type == "friendRequest" && e?['from_id'] != null) {
          friendRequestList.add(e['from_id']);
        }
      });
      flag.value = false;
      hasGetNewNotifications.value = false;
      myNotificationBool.value = !myNotificationBool.value;
    }
  }

  Future<void> deleteNotification(String? notifyId) async {
    if (notifyId == null) return;
    String urlPath = '${url}/user/deleteNotifications/$notifyId';
    var response = await getDataApiCall(urlPath);
    if (response.statusCode != 200) {
      snackBarCalled(context, "Failed to delete notification");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          "Notifications",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.accentColor,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.04,
                vertical: constraints.maxHeight * 0.01,
              ),
              child: Obx(() => myNotificationBool.value
                  ? _buildNotificationList()
                  : _buildNotificationList()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return notificationList.isEmpty && flag.value
        ? const Loader()
        : notificationList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarProfileImage(
                      url: HomePageIcons.none,
                      height:8,
                      width: 10
),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      "No Notifications",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.accentColor,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      "You're all caught up!",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.bg3,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: notificationList.length,
                itemBuilder: (context, index) {
                  var e = notificationList[index];
                  var notifyId = e['_id'] as String?;
                  return Dismissible(
                    key: Key(notifyId ?? index.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteNotification(notifyId);
                    },
                    background: Container(
            
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: _buildNotificationCard(e),
                  );
                },
              );
  }

  Widget _buildNotificationCard(Map<String, dynamic> e) {
    var notifyId = e['_id'] as String?;
    var time = e['createdAt'] as String? ?? "";
    String? type = e['notificationMessage']?['type'];
    var data = e['notificationMessage'] ?? {};

    return Container(
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.008),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Container(
             width: MediaQuery.of(context).size.width * 0.015,
              decoration: BoxDecoration(
                 color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                child: _getNotificationContent(type ?? "unknown", data, notifyId, time),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getNotificationContent(
      String type, Map<String, dynamic> e, String? notifyId, String time) {
    switch (type) {
      case "friendRequest":
        if (e['status'] == 'accepted') {
          return _buildMessageCard(
              "${e['from_name'] ?? 'Someone'} accepted your friend request",
              e['from_id'] as String? ?? "",
              e['avatarType'] as String? ?? "",
              time);
        }
        return _buildFriendRequestCard(
            e['from_name'] as String? ?? "Unknown",
            e['from_id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            e,
            notifyId,
            time);
      case "split":
        return _buildMessageCard(
            "${e['username'] ?? 'Someone'} has shared the bill for ${e['billname'] ?? 'unknown'} of ₹${(double.tryParse(e['amount']?.toString() ?? '400') ?? 400).toStringAsFixed(1)}",
            e['id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time);
      case "roomBill":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has shared the bill in Room",
            e['from_id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time);
      case "room":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has added you to the room ${e['roomName'] ?? 'unknown'}",
            e['from_id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time);
      case "comment":
        return _buildMessageCard(
            "${e['username'] ?? 'Someone'} has commented on your post",
            e['id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time);
      case "lendRequest":
        return _buildLendRequestCard(
            e['from_name'] as String? ?? "Unknown",
            e['from_id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            e,
            e['name'] as String? ?? "unknown",
            notifyId,
            time);
      case "lendAccepted":
      case "rejectedLend":
        String status = type == "lendAccepted" ? "accepted" : "rejected";
        return _buildMessageCard(
            "${e['username'] ?? 'Someone'} $status your Lent request for ${e['name'] ?? 'unknown'}, worth ₹${e['amount'] ?? '400'}",
            e['from_id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time);
      case "lendSettled":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has settled your loan of ${e['amount'] ?? '0'} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time);
      case "splitSettled":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has settled your Split of ${(double.tryParse(e['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(1)} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time);
      case "FetchedData":
        return _buildMessageCard("🔥 Data has been successfully fetched!", "", "", time);
      case "lendApprovalRequest":
        return _buildApprovalCard(
            "${e['from_name'] ?? 'Someone'} has requested approval for settling ${e['name'] ?? 'unknown'} with an amount of ${e['amount'] ?? '00'}",
            e['bill_id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time,
            "bill",
             e['from_to'] as String? ?? "",notifyId.toString());

      case "splitApprovalRequest":
        return _buildApprovalCard(
            "${e['from_name'] ?? 'Someone'} has requested approval for settling ${e['name'] ?? 'unknown'} with an amount of ${e['amount'] ?? '00'}",
            e['split_id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time,
            "split",
            e['from_to'] as String? ?? "",notifyId.toString());
      case "clearLend":
      case "clearSplit":
        String ty = type == "clearLend" ? "lend" : "split";
        return _buildMessageCard(
            "You have cleared your $ty of ${(double.tryParse(e['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(1)} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            e['avatarType'] as String? ?? "",
            time);
      default:
        return const SizedBox(child: Text("Unknown notification type"));
    }
  }

  Widget _buildMessageCard(String message, String id, String avatar, String time) {
  bool isFetchedData = message.contains("🔥 Data has been successfully fetched!");
  
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!isFetchedData && avatar.isNotEmpty)
        UserAvatar(
          url: avatar,
          width: MediaQuery.of(context).size.width * 0.06,
          height: MediaQuery.of(context).size.width * 0.06,
        )
      else if (!isFetchedData)
        SizedBox(width: MediaQuery.of(context).size.width * 0.06),
      if (!isFetchedData) SizedBox(width: MediaQuery.of(context).size.width * 0.03),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
              child: Text(
                message,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.bg1,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            _buildTimeDivider(time),
          ],
        ),
      ),
    ],
  );
}
  Widget _buildFriendRequestCard(String name, String id, String avatar, Map<String, dynamic> e,
      String? notifyId, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          url: avatar,
          width: MediaQuery.of(context).size.width * 0.06,
          height: MediaQuery.of(context).size.width * 0.06,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
                child: Text(
                  "$name sent you a friend request",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.bg1,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Row(
                children: [
                  _buildActionButton(
                    "Accept",
                    AppColors.primaryColor,
                    Colors.white,
                    () {
                      addUserAsFrd(id, context);
                      _deleteNotification(notifyId);
                    },
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  _buildActionButton(
                    "Reject",
                    Colors.white,
                    AppColors.bg3,
                    () {
                      rejectFrdRequest(e, context);
                      _deleteNotification(notifyId);
                    },
                    border: true,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildTimeDivider(time),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLendRequestCard(String name, String id, String avatar, Map<String, dynamic> e,
      String itemName, String? notifyId, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          url: avatar,
          width: MediaQuery.of(context).size.width * 0.06,
          height: MediaQuery.of(context).size.width * 0.06,
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
                child: Text(
                  "$name has lent you ₹${e['amount'] ?? '500'} for $itemName",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.bg1,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Row(
                children: [
                  _buildActionButton(
                    "Approve",
                    AppColors.primaryColor,
                    Colors.white,
                    () {
                      approveBill(context, e['bill_id'] as String? ?? "", "accept", notifyId);
                      _deleteNotification(notifyId);
                    },
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  _buildActionButton(
                    "Reject",
                    Colors.white,
                    AppColors.bg3,
                    () {
                      approveBill(context, e['bill_id'] as String? ?? "", "reject", notifyId);
                      _deleteNotification(notifyId);
                    },
                    border: true,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildTimeDivider(time),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalCard(
      String message, String id, String avatar, String time, String type, String endUser,String notifyId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar.isNotEmpty
            ? UserAvatar(
                url: avatar,
                width: MediaQuery.of(context).size.width * 0.06,
                height: MediaQuery.of(context).size.width * 0.06,
              )
            : SizedBox(width: MediaQuery.of(context).size.width * 0.06),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.015),
                child: Text(
                  message,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.bg1,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Row(
                children: [
                  _buildActionButton(
                    "Approve",
                    AppColors.primaryColor,
                    Colors.white,
                    () {
                      settleAmount(context, id, type, endUser);
                        _deleteNotification(notifyId);
                    },
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  _buildActionButton(
                    "Reject",
                    Colors.white,
                    AppColors.bg3,
                    () {
                          declineAmount(context, id, type, endUser);
                          _deleteNotification(notifyId);
                    },
                    border: true,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildTimeDivider(time),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor, VoidCallback onTap,
      {bool border = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border ? Border.all(color: AppColors.bg3, width: 1) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 14,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDivider(String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        time.isNotEmpty ? formatWhatsAppDate(DateTime.parse(time)) : "Unknown time",
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w500,
          fontSize: 12,
          color: AppColors.accentColor.withOpacity(0.7),
        ),
      ),
    );
  }

  void _deleteNotification(String? notifyId) {
    if (notifyId != null) {
      setState(() {
        notificationList.removeWhere((item) => item['_id'] == notifyId);
      });
      deleteNotification(notifyId);
    }
  }
}