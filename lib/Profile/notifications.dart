
// import "package:flutter/cupertino.dart";
// import "package:flutter/material.dart";
// import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
// import "package:flutter_application_code_stakeplot/Constants/colors.dart";
// import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
// import "package:flutter_application_code_stakeplot/repository/group_Api.dart";
// import "package:flutter_application_code_stakeplot/repository/notification_repository.dart";
// import "package:flutter_application_code_stakeplot/components/helper.dart";
// import "package:flutter_application_code_stakeplot/finance_screen/finanace_dashboard/pending_users.dart";
// import "package:flutter_application_code_stakeplot/Profile/autocategroies.dart";
// import "package:flutter_application_code_stakeplot/Tribe/tribe_one.dart";
// import "package:flutter_application_code_stakeplot/image_service/avatarProfile.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
// import "package:flutter_application_code_stakeplot/repository/friends_apis.dart";
// import "package:flutter_application_code_stakeplot/repository/profileUser.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
// import "package:flutter_application_code_stakeplot/Constants/loader.dart";
// import "package:flutter_application_code_stakeplot/model/post_model.dart";
// import "package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart";
// import "package:flutter_application_code_stakeplot/repository/payables_repository.dart";


// import "package:get/get.dart";

// import "../Constants/core/app_padding_sizes.dart";
// import "../components/shared_utils.dart";



// RxBool notificationsFlag = true.obs;

// class Notifications extends StatefulWidget {
//   const Notifications({Key? key}) : super(key: key);

//   @override
//   _NotificationsState createState() => _NotificationsState();
// }

// class _NotificationsState extends State<Notifications> {
//   @override
//   void initState() {
//     super.initState();
//     getNotifications(context);

//     // Debug notification list on init
//   }

 

 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(72),
//         child: AppBar(
//           backgroundColor: AppColors.newbg,
//           elevation: 0,
//           leading: IconButton(
//             icon: globalbackArrow(),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           title: Text(
//             "Notifications",
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.w500,
//               fontSize: 18,
//               color: AppColors.accentColor,
//             ),
//           ),
//           centerTitle: true,
//         ),
//       ),
//       backgroundColor: AppColors.border,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return Container(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               padding: EdgeInsets.symmetric(
//                 horizontal: constraints.maxWidth * 0.04,
//                 vertical: constraints.maxHeight * 0.01,
//               ),
//               child: SingleChildScrollView(
//                 child: Obx(() {
//                    return myNotificationBool.value
//                       ? _buildNotificationList()
//                       : _buildNotificationList();
//                 }),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// Map<String, List<Map<String, dynamic>>> groupNotificationsByDate() {
//   Map<String, List<Map<String, dynamic>>> grouped = {};

//   for (var n in notificationList) {
//     final createdAt = DateTime.parse(n['createdAt']);
//     final now = DateTime.now();

//     String key;
//     if (isSameDay(createdAt, now)) {
//       key = "Today";
//     } else if (isSameDay(createdAt, now.subtract(const Duration(days: 1)))) {
//       key = "Yesterday";
//     } else {
//       key = formatDateHeader(createdAt); // e.g. Nov 16
//     }

//     grouped.putIfAbsent(key, () => []);
//     grouped[key]!.add(n);
//   }

//   return grouped;
// }

// bool isSameDay(DateTime a, DateTime b) {
//   return a.year == b.year && a.month == b.month && a.day == b.day;
// }

// String formatDateHeader(DateTime date) {
//   return "${monthNames[date.month - 1]} ${date.day}";
// }

// final monthNames = [
//   "Jan","Feb","Mar","Apr","May","Jun",
//   "Jul","Aug","Sep","Oct","Nov","Dec"
// ];

//   // Widget _buildNotificationList() {
//   //   return notificationList.isEmpty && notificationsFlag.value
//   //       ? Spinner()
//   //       : (notificationList.isEmpty && autoTransactionList.isEmpty)
//   //           ? Container(
//   //               width: MediaQuery.sizeOf(context).width / 1.1,
//   //               height: MediaQuery.sizeOf(context).height / 1.3,
//   //               child: Column(
//   //                 mainAxisAlignment: MainAxisAlignment.center,
//   //                 crossAxisAlignment: CrossAxisAlignment.center,
//   //                 children: [
//   //                   AvatarProfileImage(
//   //                     url: HomePageIcons.none,
//   //                     height: 8,
//   //                     width: 10,
//   //                   ),
//   //                   SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//   //                   Text(
//   //                     "No Notifications",
//   //                     style: FontManager().getTextStyle(
//   //                       context,
//   //                       lWeight: FontWeight.bold,
//   //                       fontSize: 18,
//   //                       color: AppColors.accentColor,
//   //                     ),
//   //                   ),
//   //                   SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//   //                   Text(
//   //                     "You're all caught up!",
//   //                     style: FontManager().getTextStyle(
//   //                       context,
//   //                       lWeight: FontWeight.normal,
//   //                       fontSize: 14,
//   //                       color: AppColors.bg3,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             )
//   //           : Column(
//   //               children: [
//   //                 AutocategroiesTransactions(),
//   //                 Container(
//   //                   child: ListView.builder(
//   //                     shrinkWrap: true,
//   //                     physics: const NeverScrollableScrollPhysics(),
//   //                     itemCount: notificationList.length,
//   //                     itemBuilder: (context, index) {
//   //                       var e = notificationList[index];
//   //                       var notifyId = e['_id'] as String?;
//   //                       return Dismissible(
//   //                         key: Key(notifyId ?? index.toString()),
//   //                         direction: DismissDirection.endToStart,
//   //                         onDismissed: (direction) {
//   //                           _deleteNotification(notifyId);
//   //                         },
//   //                         background: Container(
//   //                           margin: EdgeInsets.symmetric(
//   //                               vertical:
//   //                                   MediaQuery.of(context).size.height * 0.008),
//   //                           decoration: BoxDecoration(
//   //                             color: Colors.redAccent,
//   //                             borderRadius: BorderRadius.circular(12),
//   //                             boxShadow: [
//   //                               BoxShadow(
//   //                                 color: Colors.grey.withOpacity(0.1),
//   //                                 blurRadius: 6,
//   //                                 offset: const Offset(0, 2),
//   //                               ),
//   //                             ],
//   //                           ),
//   //                           padding: EdgeInsets.all(
//   //                               MediaQuery.of(context).size.width * 0.03),
//   //                           alignment: Alignment.centerRight,
//   //                           child: const Padding(
//   //                             padding: EdgeInsets.only(right:AppSizes.p20),
//   //                             child: Icon(Icons.delete, color: AppColors.backgroundColor),
//   //                           ),
//   //                         ),
//   //                         child: _buildNotificationCard(e),
//   //                       );
//   //                     },
//   //                   ),
//   //                 ),
//   //               ],
//   //             );
//   // }
// Widget _buildNotificationList() {
//   if (notificationList.isEmpty && notificationsFlag.value) {
//     return Spinner();
//   }

//   if (notificationList.isEmpty && autoTransactionList.isEmpty) {
//     return SizedBox.shrink();
//   }

//   final grouped = groupNotificationsByDate();

//   return Column(
//     children: [
//       // AutocategroiesTransactions(),

//       ...grouped.entries.map((entry) {
//         final dateTitle = entry.key;
//         final items = entry.value;

//         return _buildDateSection(dateTitle, items);
//       }).toList(),
//     ],
//   );
// }


// Widget _buildDateSection(
//   String title,
//   List<Map<String, dynamic>> items,
// ) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 16),
//     padding: const EdgeInsets.all(AppSizes.p12),
//     decoration: BoxDecoration(
//       color: AppColors.backgroundColor,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.grey.withOpacity(0.08),
//           blurRadius: 6,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// HEADER
//         Row(
//           children: [
//             Text(
//               title,
//               style: FontManager().getTextStyle(
//                 context,
//                 fontSize: 14,
//                 lWeight: FontWeight.w600,
//                 color: AppColors.accentColor,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 6, vertical: AppSizes.p2),
//               decoration: BoxDecoration(
//                 color: AppColors.mt,
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: Text(
//                 items.length.toString(),
//                 style: FontManager().getTextStyle(
//                   context,
//                   fontSize: 12,
//                   lWeight: FontWeight.w600,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 8),

//         /// NOTIFICATIONS (WITH DISMISSIBLE)
//         ...items.map((e) {
//           final notifyId = e['_id'] as String?;

//           return Dismissible(
//             key: Key(notifyId ?? UniqueKey().toString()),
//             direction: DismissDirection.endToStart,
//             onDismissed: (_) {
//               _deleteNotification(notifyId);
//             },
//             background: Padding(
//               padding: const EdgeInsets.only(top:AppSizes.p8),
//               child: Container(
//                 margin: const EdgeInsets.symmetric(vertical: AppSizes.p4),
//                 decoration: BoxDecoration(
//                   color: AppColors.redColor,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 alignment: Alignment.centerRight,
//                 padding: const EdgeInsets.only(right:AppSizes.p20),
//                 child: const Icon(
//                   Icons.delete,
//                   color: AppColors.backgroundColor,
//                 ),
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(top:AppSizes.p8),
//               child: _buildNotificationCard(e),
//             ),
//           );
//         }).toList(),
      
//       ],
//     ),
//   );
// }
// Widget buildNotificationIcon(
//   String notificationType,
//   Map<String, dynamic> data,
// ) {
//   // 🔹 Bank / system notifications
//   if (notificationType == "FetchedData" && data['avatarType'] != null) {
//     return Image.network(
//       data['avatarType'],
//       width: 24,
//       height: 24,
//       errorBuilder: (_, __, ___) => const Icon(
//         Icons.account_balance,
//         color: AppColors.primaryColor,
//       ),
//     );
//   }

//   // 🔹 User avatar image
//   if (data['avatarType'] != null &&
//       data['avatarType'].toString().startsWith("http")) {
//     return CircleAvatar(
//       radius: 18,
//       backgroundImage: NetworkImage(data['avatarType']),
//       backgroundColor: AppColors.backgroundColor,
//     );
//   }

//   // 🔹 Fallback → first letter avatar
//   final String name =
//       data['from_name'] ?? data['username'] ?? "U";

//   return CircleAvatar(
//     radius: 18,
//     backgroundColor: AppColors.primaryColor,
//     child: Text(
//       name[0].toUpperCase(),
//       style: FontManager().getTextStyle(
//         context,
//         fontSize: 16,
//         lWeight: FontWeight.w600,
//         color: AppColors.backgroundColor,
//       ),
//     ),
//   );
// }

// String getNotificationTitle(String type, Map<String, dynamic> e) {
//   switch (type) {
//     case "friendRequest":
//       return e['from_name'] ?? "Friend Request";

//     case "splitApprovalRequest":
//       return "Split Approval Request";

//     case "lendApprovalRequest":
//       return "Lend Approval Request";

//     case "split":
//       return "New Split";

//     case "splitSettled":
//       return "Split Settled";

//     case "clearSplit":
//       return "Split Cleared";

//     case "lendRequest":
//       return "Lend Request";

//     case "lendSettled":
//       return "Lend Settled";

//     case "clearLend":
//       return "Lend Cleared";

//     case "deleteAccountSplit":
//     case "deleteAccountLend":
//       return "Account Deleted";

//     case "comment":
//       return "New Comment";

//     case "like":
//       return "New Like";

//     case "FetchedData":
//       return "Bank Data Synced";

//     default:
//       return "Notification";
//   }
// }
// String getNotificationMessage(String type, Map<String, dynamic> e) {
//   switch (type) {
//     case "friendRequest":
//       return "has sent you a friend request";

//     case "splitApprovalRequest":
//       return "${e['from_name'] ?? 'Someone'} requested approval for ₹${e['amount'] ?? 0}";

//     case "lendApprovalRequest":
//       return "${e['from_name'] ?? 'Someone'} requested lend approval";

//     case "split":
//       return "${e['username'] ?? 'Someone'} shared a split of ₹${e['amount']}";

//     case "splitSettled":
//       return "${e['from_name'] ?? 'Someone'} settled ₹${e['amount']}";

//     case "clearSplit":
//       return "You cleared a split of ₹${e['amount']}";

//     case "lendRequest":
//       return "${e['from_name'] ?? 'Someone'} lent you ₹${e['amount']}";

//     case "lendSettled":
//       return "${e['from_name'] ?? 'Someone'} settled your lend";

//     case "clearLend":
//       return "You cleared a lend of ₹${e['amount']}";

//     case "deleteAccountSplit":
//       return "Pending split remains after account deletion";

//     case "deleteAccountLend":
//       return "Pending lend remains after account deletion";

//     case "comment":
//       return "${e['username'] ?? 'Someone'} commented on your post";

//     case "like":
//       return "${e['username'] ?? 'Someone'} liked your post";

//     case "FetchedData":
//       return e['message'] ?? "Bank data fetched successfully";

//     default:
//       return e['message'] ?? "You have a new notification";
//   }
// }
// List<Map<String, String>> getNotificationActions(
//   String type,
//   Map<String, dynamic> data,
// ) {
//   switch (type) {

//     case "friendRequest":
//       // Only pending friend requests
//       if (data['status'] != 'accepted') {
//         return [
//           { "key": "accept", "label": "Accept" },
//           { "key": "reject", "label": "Reject" },
//         ];
//       }
//       return [];

//     case "splitApprovalRequest":
//     case "lendApprovalRequest":
//       return [
//         { "key": "approve", "label": "Approve" },
//         { "key": "reject", "label": "Reject" },
//       ];

//     default:
//       return [];
//   }
// }
// void handleNotificationAction(
//   String action,
//   String type,
//   Map<String, dynamic> data,
//   String? notifyId,
// ) {
//   try {
//     switch (type) {

//       // -------- FRIEND REQUEST --------
//       case "friendRequest":
//         if (action == "accept") {
//           addUserAsFrd(data['from_id'], context);
//         } else {
//           rejectFrdRequest(data, context);
//         }
//         break;

//       // -------- SPLIT APPROVAL --------
//       case "splitApprovalRequest":
//         if (action == "approve") {
//           settleAmount(
//             context,
//             data['split_id'],
//             "split",
//             data['from_to'],
//           );
//         } else {
//           declineAmount(
//             context,
//             data['split_id'],
//             "split",
//             data['from_to'],
//           );
//         }
//         break;

//       // -------- LEND APPROVAL --------
//       case "lendApprovalRequest":
//         if (action == "approve") {
//           settleAmount(
//             context,
//             data['bill_id'],
//             "bill",
//             data['from_to'],
//           );
//         } else {
//           declineAmount(
//             context,
//             data['bill_id'],
//             "bill",
//             data['from_to'],
//           );
//         }
//         break;
//     }
//   } catch (e) {
//     snackBarCalledfail(context, "Action failed");
//   }

//   // 🔥 Always remove notification
//   _deleteNotification(notifyId);
// }

//  Widget _buildNotificationCard(Map<String, dynamic> e) {
//   final notifyId = e['_id'] as String?;
//   final time = e['createdAt'] as String? ?? "";

//   // ✅ declare FIRST
//   final Map<String, dynamic> data =
//       e['notificationMessage'] ?? {};

//   final String notificationType =
//       data['type'] ?? "unknown";

//   // ✅ use AFTER declaration
//   final String title =
//       getNotificationTitle(notificationType, data);

//   final String message =
//       getNotificationMessage(notificationType, data);
//         final actions = getNotificationActions(notificationType, e);

//   return GestureDetector(
//     onTap: () =>
//         _handleNotificationTap(notificationType, data, e),
//     child: Container(
//       margin: EdgeInsets.symmetric(vertical: AppSizes.p4),
//       decoration: BoxDecoration(
//         color: AppColors.notificationCardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: AppColors.notificationCardBorderColor,
//           width: 0.3,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(AppSizes.p8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             buildNotificationIcon(notificationType, data),
//              const SizedBox(width: AppSizes.w8),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//          children: [
//            Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: [
//                Text(
//                  title,
//                  style: FontManager().getTextStyle(
//                    context,
//                    fontSize: 14,
//                    lWeight: FontWeight.w600,
//                    color: AppColors.accentColor,
//                  ),
//                ),
//                 _buildTimeDivider(time),
//              ],
//            ),
//             const SizedBox(height: 4),
           
//                 /// MESSAGE
//                 Text(
//                   message,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                   style: FontManager().getTextStyle(
//                     context,
//                     fontSize: 13,
//                     color: AppColors.grey,
//                   ),
//                 ),
             
                
//                 if (actions.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: AppSizes.p8),
//                     child: Row(
//          children: actions.map((a) {
//            final bool primary =
//                 a['key'] == 'accept' || a['key'] == 'approve';
                
//            return Padding(
//              padding: const EdgeInsets.only(right: 8),
//              child: GestureDetector(
//                 onTap: () => handleNotificationAction(
//                   a['key']!,
//                   notificationType,
//                   e,
//                   notifyId,
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppSizes.p12,
//                     vertical: AppSizes.p6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: primary
//            ? AppColors.primaryColor
//            : AppColors.backgroundColor,
//                     borderRadius: BorderRadius.circular(6),
//                     border: primary
//            ? null
//            : Border.all(
//                color:
//                    AppColors.notificationCardBorderColor,
//              ),
//                   ),
//                   child: Text(
//                     a['label']!,
//                     style: FontManager().getTextStyle(
//          context,
//          fontSize: 13,
//          color: primary
//              ? AppColors.backgroundColor
//              : AppColors.grey,
//                     ),
//                   ),
//                 ),
//              ),
//            );
//          }).toList(),
//                     )
             
//                   )
//          ],
//                     ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

//   void _handleNotificationTap(String type, Map<String, dynamic> data,
//       Map<String, dynamic> notification) async {
//     switch (type) {
//       case "comment":
//         try {
//           if (data['id'] == null || data['id'].isEmpty) {
//             snackBarCalledfail(context, "Cannot navigate: Invalid post ID");
//             return;
//           }
//           PostModel? postModel = await fetchPostById(data['id'], context);
//           if (postModel == null) {
//             return;
//           }
//           Navigator.push(
//             context,
//             PageRouteBuilder(
//               pageBuilder: (context, animation, secondaryAnimation) =>
//                   TribeUnique(
//                 id: data['id'],
//                 dataObj: postModel,
//                 popBox: false.obs,
//               ),
//               transitionsBuilder:
//                   (context, animation, secondaryAnimation, child) {
//                 const begin = Offset(1.0, 0.0);
//                 const end = Offset.zero;
//                 const curve = Curves.easeInOut;
//                 var tween = Tween(begin: begin, end: end)
//                     .chain(CurveTween(curve: curve));
//                 var offsetAnimation = animation.drive(tween);
//                 return SlideTransition(
//                   position: offsetAnimation,
//                   child: child,
//                 );
//               },
//               transitionDuration: const Duration(milliseconds: 300),
//             ),
//           );
//         } catch (e) {
//           snackBarCalledfail(context, "Failed to navigate to post");
//         }
//         // No navigation for pending friend requests since they have buttons
//         break;
//       case "split":
//       case "roomBill":
//       case "splitApprovalRequest":
//       case "lendApprovalRequest":
//       case "deleteAccountSplit":
//       case "deleteAccountLend":
//       case "clearLend":
//       case "clearSplit":
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => UserListScreen(isPayable: true),
//           ),
//         );
//         break;
//       case "lendAccepted":
//       case "rejectedLend":
//       case "lendSettled":
//       case "splitSettled":
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => UserListScreen(isPayable: false),
//           ),
//         );
//         break;
//       case "friendRequest":
//         if (data['status'] == 'accepted') {
//           final userId = data['from_id'] as String? ?? "";

//           var dataObj = userController.maskedConnected
//               .firstWhere((e) => e['_id'] == userId);

//           if (userId.isNotEmpty &&
//               userId != "null" &&
//               data['isMaskedConnection'] == true) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CommunityUserProfile(
//                   data: dataObj,
//                   ids: [userId],
//                   flag: true,
//                   isMasked: true,
//                   isMaskedConnect: true,
//                 ),
//               ),
//             );
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(builder: (context) => Friends()),
//             // );
//           } else {
//             snackBarCalledfail(context, "Invalid user ID");
//           }
//         }
//         // No navigation for pending friend requests since they have buttons
//         break;
//     }
//   }

//   Widget _getNotificationContent(
//       String type, Map<String, dynamic> e, String? notifyId, String time) {
//     switch (type) {
//       case "friendRequest":
//         if (e['status'] == 'accepted') {
//           var notificationAvatar = e['isMaskedConnection']??false
//               ? e['avatarType']
//               : e['from_name'] as String?;
//           var msg = e['isMaskedConnection']??false
//               ? "connected to you"
//               : "accepted your friend request";
//           return _buildMessageCard(
//               "${e['from_name'] ?? 'Someone'} $msg",
//               e['from_id'] as String? ?? "",
//               notificationAvatar ?? '',
//               time,
//               e['isMaskedConnection']??false);
//         }
//         return _buildFriendRequestCard(
//             e['from_name'] as String? ?? "Unknown",
//             e['from_id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             e,
//             notifyId,
//             time);
//       case "split":
//         return _buildMessageCard(
//             "${e['username'] ?? 'Someone'} has shared the bill for ${e['billname'] ?? 'unknown'} of ₹${(double.tryParse(e['amount']?.toString() ?? '400') ?? 400).toStringAsFixed(1)}",
//             e['id'] as String? ?? "",
//             e['username'] as String? ?? "",
//             time,
//             false);
//       case "roomBill":
//         return _buildMessageCard(
//             "${e['from_name'] ?? 'Someone'} has shared the bill in Room",
//             e['from_id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             false);
//       case "room":
//         return _buildMessageCard(
//             "${e['from_name'] ?? 'Someone'} has added you to the room ${e['roomName'] ?? 'unknown'}",
//             e['from_id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             false);
//       case "comment":
//         return _buildMessageCard(
//             "${e['username'] ?? 'Someone'} has commented on your post",
//             e['id'] as String? ?? "",
//             e['avatarType'] ?? "",
//             time,
//             true);
//       case "lendRequest":
//         return _buildLendRequestCard(
//             e['from_name'] as String? ?? "Unknown",
//             e['from_id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             e,
//             e['name'] as String? ?? "unknown",
//             notifyId,
//             time);
//       case "lendAccepted":
//       case "rejectedLend":
//         String status = type == "lendAccepted" ? "accepted" : "rejected";
//         return _buildMessageCard(
//             "${e['username'] ?? 'Someone'} $status your Lent request for ${e['name'] ?? 'unknown'}, worth ₹${e['amount'] ?? '400'}",
//             e['from_id'] as String? ?? "",
//             e['username'] as String? ?? "",
//             time,
//             false);
//       case "lendSettled":
//         return _buildMessageCard(
//             "${e['from_name'] ?? 'Someone'} has settled your loan of ${e['amount'] ?? '0'} for the item: ${e['name'] ?? 'unknown'}",
//             e['id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             false);
//       case "splitSettled":
//         return _buildMessageCard(
//             "${e['from_name'] ?? 'Someone'} has settled your Split of ${(double.tryParse(e['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(1)} for the item: ${e['name'] ?? 'unknown'}",
//             e['id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             false);
//       case "FetchedData":
//         return _buildMessageCard(
//             e['message'] ?? "🔥 Data has been successfully fetched!",
//             "",
//             e['avatarType'],
//             time,
//             false);
//       case "lendApprovalRequest":
//         return _buildApprovalCard(
//             "${e['from_name'] ?? 'Someone'} has requested approval for settling ${e['name'] ?? 'unknown'} with an amount of ${e['amount'] ?? '00'}",
//             e['bill_id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             "bill",
//             e['from_to'] as String? ?? "",
//             notifyId.toString());
//       case "deleteAccountSplit":
//         return _buildMessageCard(
//             "${e['from_name'] ?? 'This user'} has deleted their account, but some split amounts are still pending.",
//             e['bill_id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             false);
//       case "deleteAccountLend":
//         return _buildMessageCard(
//             "${e['from_name'] ?? 'This user'} has deleted their account, but some lend amounts are still pending.",
//             e['bill_id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             false);
//       case "splitApprovalRequest":
//         return _buildApprovalCard(
//             "${e['from_name'] ?? 'Someone'} has requested approval for settling ${e['name'] ?? 'unknown'} with an amount of ${e['amount'] ?? '00'}",
//             e['split_id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             "split",
//             e['from_to'] as String? ?? "",
//             notifyId.toString());
//       case "clearLend":
//       case "clearSplit":
//         String ty = type == "clearLend" ? "lend" : "split";
//         return _buildMessageCard(
//             "You have cleared your $ty of ${(double.tryParse(e['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(1)} for the item: ${e['name'] ?? 'unknown'}",
//             e['id'] as String? ?? "",
//             e['from_name'] as String? ?? "",
//             time,
//             false);
//       default:
//         return const SizedBox(child: Text("Unknown notification type"));
//     }
//   }

//   Widget _buildMessageCard(
//       String message, String id, avatar, String time, bool isMasked) {
//     bool isFetchedData = message.contains("Data has been successfully fetched");

//     return Padding(
//        padding: EdgeInsets.only(
//                     top: AppSizes.p8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // if (isFetchedData)
//             SizedBox(width: AppSizes.w8),
//           isFetchedData
//               ? SizedBox(
//                   child: Image.network(
//                   avatar,
//                   width: 30,
//                   height: 30,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => const Icon(
//                     Icons.account_balance_outlined,
//                     size: 30,
//                     color: AppColors.primaryColor,
//                   ),
//                 ))
//               : const SizedBox.shrink(),
//           if (!isFetchedData && avatar.isNotEmpty)
//             if (!isMasked)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: AppSizes.p12),
//                 child: CircleAvatar(
//                   backgroundColor: AppColors.primaryColor,
//                   radius: 18,
//                   child:Text(avatar[0].toUpperCase(),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w500,
//                       fontSize: 16,
//                       color: AppColors.backgroundColor,
//                     ),
//                 )),
//               )
//               // AvatarProfile(name: avatar, width: 24, height: 20, background: "")
//             else
//               AvatarProfile2(url: avatar, width: 20, height: 20)
//           else if (!isFetchedData)
//             SizedBox(width:AppSizes.w10),
//           if (!isFetchedData)
//            SizedBox(width:AppSizes.w10),
//           if (isFetchedData)
//            SizedBox(width:AppSizes.w10),
//           SizedBox(
//         width: MediaQuery.of(context).size.width / 1.5,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   message,
//                   softWrap: true,
//                   maxLines: 4,
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.w400,
//                     fontSize: 14,
//                     color: AppColors.grey,
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//                 const SizedBox(height: AppSizes.h8),
//                 _buildTimeDivider(time),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFriendRequestCard(String name, String id, String avatar,
//       Map<String, dynamic> e, String? notifyId, String time) {
//     return Padding(
//       padding: EdgeInsets.only(
//                     top: AppSizes.p8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//              SizedBox(width: AppSizes.w8),
//           Padding(
//                   padding: const EdgeInsets.only(bottom: AppSizes.p12),
//                   child: CircleAvatar(
//                     backgroundColor: AppColors.primaryColor,
//                     radius: 18,
//                     child:Text(avatar[0].toUpperCase(),
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w500,
//                         fontSize: 16,
//                         color: AppColors.backgroundColor,
//                       ),
//                   )),
//                 ),
//           // AvatarProfile(name: avatar, width: 20, height: 17, background: ""),
//           SizedBox(width:AppSizes.w10),
//            SizedBox(
//           width: MediaQuery.of(context).size.width / 1.5,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "$name sent you a friend request",
//                   softWrap: true,
//                   maxLines: 4,
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.w400,
//                     fontSize: 14,
//                     color: AppColors.grey,
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//                   SizedBox(height: AppSizes.h8),
//                 Row(
//                   children: [
//                     _buildActionButton(
//                       "Accept",
//                       AppColors.primaryColor,
//                       AppColors.backgroundColor,
//                       () {
//                         addUserAsFrd(id, context);
//                         _deleteNotification(notifyId);
//                       },
//                     ),
//                     SizedBox(width: MediaQuery.of(context).size.width * 0.03),
//                     _buildActionButton(
//                       "Reject",
//                       AppColors.backgroundColor,
//                       AppColors.bg3,
//                       () {
//                         rejectFrdRequest(e, context);
//                         _deleteNotification(notifyId);
//                       },
//                       border: true,
//                     ),
//                   ],
//                 ),
//                   SizedBox(height: AppSizes.h8),
//                 _buildTimeDivider(time),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLendRequestCard(String name, String id, String avatar,
//       Map<String, dynamic> e, String itemName, String? notifyId, String time) {
//     return Padding(
//        padding: EdgeInsets.only(
//                     top: AppSizes.p8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // AvatarProfile(name: avatar, width: 20, height: 17, background: ""),
//             SizedBox(width: AppSizes.w8),
//           Padding(
//                   padding: const EdgeInsets.only(bottom: AppSizes.p12),
//                   child: CircleAvatar(
//                     backgroundColor: AppColors.primaryColor,
//                     radius: 18,
//                     child:Text(avatar[0].toUpperCase(),
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w500,
//                         fontSize: 16,
//                         color: AppColors.backgroundColor,
//                       ),
//                   )),
//                 ),
          
//           SizedBox(width:AppSizes.w10),
//            SizedBox(
//           width: MediaQuery.of(context).size.width / 1.5,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "$name has lent you ₹${e['amount'] ?? '500'} for $itemName",
//                    softWrap: true,
//                   maxLines: 4,
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.w400,
//                     fontSize: 14,
//                     color: AppColors.grey,
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//                  SizedBox(height: AppSizes.h8),
//                 Row(
//                   children: [
//                     _buildActionButton(
//                       "Approve",
//                       AppColors.primaryColor,
//                       AppColors.backgroundColor,
//                       () {
//                         approveBill(context, e['bill_id'] as String? ?? "",
//                             "accept", notifyId);
//                         _deleteNotification(notifyId);
//                       },
//                     ),
//                     SizedBox(width: MediaQuery.of(context).size.width * 0.03),
//                     _buildActionButton(
//                       "Reject",
//                       AppColors.backgroundColor,
//                       AppColors.bg3,
//                       () {
//                         approveBill(context, e['bill_id'] as String? ?? "",
//                             "reject", notifyId);
//                         _deleteNotification(notifyId);
//                       },
//                       border: true,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: AppSizes.h8),
//                 _buildTimeDivider(time),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildApprovalCard(String message, String id, String avatar,
//       String time, String type, String endUser, String notifyId) {
//     return Padding(
//         padding: EdgeInsets.only(
//                     top: AppSizes.p8, left: AppSizes.p8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
          
//           avatar.isNotEmpty
//               ? 
//                Padding(
//                   padding: const EdgeInsets.only(bottom: AppSizes.p12),
//                   child: CircleAvatar(
//                     backgroundColor: AppColors.primaryColor,
//                     radius: 18,
//                     child:Text(avatar[0].toUpperCase(),
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w500,
//                         fontSize: 16,
//                         color: AppColors.backgroundColor,
//                       ),
//                   )),
//                 )
//               // AvatarProfile(name: avatar, width: 20, height: 17, background: "")
//               : SizedBox(width: MediaQuery.of(context).size.width * 0.06),
//            SizedBox(width:AppSizes.w10),
//            SizedBox(
//           width: MediaQuery.of(context).size.width / 1.5,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   message,
//                   softWrap: true,
//                   maxLines: 4,
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.w400,
//                     fontSize: 14,
//                     color: AppColors.grey,
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//                SizedBox(height: AppSizes.h8),
//                 Row(
//                   children: [
//                     _buildActionButton(
//                       "Approve",
//                       AppColors.primaryColor,
//                       AppColors.backgroundColor,
//                       () {
//                         settleAmount(context, id, type, endUser);
//                         _deleteNotification(notifyId);
//                       },
//                     ),
//                     SizedBox(width: AppSizes.w16),
//                     _buildActionButton(
//                       "Reject",
//                       AppColors.backgroundColor,
//                       AppColors.bg1,
//                       () {
//                         declineAmount(context, id, type, endUser);
//                         _deleteNotification(notifyId);
//                       },
//                       border: true,
//                     ),
//                   ],
//                 ),
//                  SizedBox(height: AppSizes.h8),
//                 _buildTimeDivider(time),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(
//       String label, Color bgColor, Color textColor, VoidCallback onTap,
//       {bool border = false}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: AppSizes.p12,
//           vertical: AppSizes.p6,
//         ),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(5),
//           border: border ? Border.all(color: AppColors.notificationCardBorderColor, width: 1) : null,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Text(
//           label,
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w400,
//             fontSize: 14,
//             color: textColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeDivider(String time) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Text(
//         time.isNotEmpty
//             ? formatWhatsAppDate(DateTime.parse(time))
//             : "Unknown time",
//         style: FontManager().getTextStyle(
//           context,
//           lWeight: FontWeight.w400,
//           fontSize: 11,
//           letterSpacing: -0.2,
//           color: AppColors.accentColor
//         ),
//       ),
//     );
//   }

//   void _deleteNotification(String? notifyId) {
//     if (notifyId != null) {
//       setState(() {
//         notificationList.removeWhere((item) => item['_id'] == notifyId);
//       });
//       deleteNotification(notifyId, context);
//     }
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Constants/colors.dart';
import '../Constants/font_manager.dart';
import '../Constants/loader.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Tribe/tribe_one.dart';
import '../components/helper.dart';
import '../backed_connections/apis_connect.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../components/shared_utils.dart';
import '../finance_screen/finanace_dashboard/pending_users.dart';
import '../model/post_model.dart';
import '../repository/friends_apis.dart';
import '../repository/notification_repository.dart';
import '../repository/payables_repository.dart';

RxBool notificationsFlag = true.obs;
// RxBool myNotificationBool = false.obs;
// RxList<Map<String, dynamic>> notificationList = <Map<String, dynamic>>[].obs;

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
    getNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.border,
      appBar: AppBar(
        backgroundColor: AppColors.newbg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Notifications",
          style: FontManager().getTextStyle(
            context,
            fontSize: 18,
            lWeight: FontWeight.w500,
            color: AppColors.accentColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (notificationsFlag.value) {
            return  Spinner();
          }

          if (notificationList.isEmpty) {
            return _emptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Column(
              children: _buildGroupedNotifications(),
            ),
          );
        }),
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none,
              size: 80, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            "No Notifications",
            style: FontManager().getTextStyle(
              context,
              fontSize: 18,
              lWeight: FontWeight.w600,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              color: AppColors.grey,

            ),
          ),
        ],
      ),
    );
  }

  // ---------------- GROUP BY DATE ----------------

  List<Widget> _buildGroupedNotifications() {
  final Map<String, List<Map<String, dynamic>>> grouped = {};

  for (var n in notificationList) {
    final String key = n['dateGroup'] ?? "Others";

    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(n);
  }

  return grouped.entries.map((entry) {
    return _buildDateSection(entry.key, entry.value);
  }).toList();
}

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ---------------- DATE SECTION ----------------

  Widget _buildDateSection(
      String title, List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              lWeight: FontWeight.w600,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(_buildNotificationTile).toList(),
        ],
      ),
    );
  }

  // ---------------- NOTIFICATION TILE ----------------

  Widget _buildNotificationTile(Map<String, dynamic> n) {
    return Dismissible(
      key: Key(n['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(n['id']),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.redColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete,
            color: AppColors.backgroundColor),
      ),
      child: _notificationCard(n),
    );
  }
void handleNotificationAction(
  String actionKey,
  Map<String, dynamic> notification,
) async {
  final String type = notification['type'];
  final Map<String, dynamic> payload =
      notification['payload'] ?? {};
  final String notificationId = notification['id'];

  try {
    switch (type) {

      // ---------------- FRIEND REQUEST ----------------
      case "friendRequest":
        if (actionKey == "accept") {
          addUserAsFrd(payload['fromUserId'], context);
        } else if (actionKey == "reject") {
          rejectFrdRequest(payload, context);
        }
        break;

      // ---------------- SPLIT ----------------
      case "splitApprovalRequest":
        if (actionKey == "approve") {
           settleAmount(
            context,
            payload['splitId'],
            "split",
            payload['fromUserId'],
          );
        } else if (actionKey == "reject") {
           declineAmount(
            context,
            payload['splitId'],
            "split",
            payload['fromUserId'],
          );
        }
        break;

      // ---------------- LEND ----------------
      case "lendApprovalRequest":
        if (actionKey == "approve") {
           settleAmount(
            context,
            payload['lendId'],
            "lend",
            payload['fromUserId'],
          );
        } else if (actionKey == "reject") {
           declineAmount(
            context,
            payload['lendId'],
            "lend",
            payload['fromUserId'],
          );
        }
        break;

      // ---------------- COMMENT / LIKE ----------------
      case "comment":
      case "like":
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => TribeUnique(
        //       id: payload['postId'],
        //       popBox: false.obs,
        //     ),
        //   ),
        // );
        break;

      default:
        debugPrint("Unhandled action: $actionKey for $type");
    }
  } catch (e) {
    snackBarCalledfail(context, "Action failed");
  }

  // ✅ Always remove after action
  _deleteNotification(notificationId);
}

  // ---------------- CARD UI ----------------

  Widget _notificationCard(Map<String, dynamic> n) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.p8),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          color: AppColors.notificationCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.notificationCardBorderColor,
            width: 0.4,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _notificationIcon(n['icon']),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        n['title'],
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 14,
                          lWeight: FontWeight.w600,
                          color: AppColors.accentColor,
                        ),
                      ),
                        Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      (n['time']),
                      
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['message'],
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                Row(
  children: (n['actions'] as List).map<Widget>((a) {
    final bool isPrimary = a['key'] == 'accept' || a['key'] == 'approve';

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => handleNotificationAction(a['key'], n),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p12,
            vertical: AppSizes.p6,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.primaryColor
                : AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(6),
            border: isPrimary
                ? null
                : Border.all(color: AppColors.notificationCardBorderColor),
          ),
          child: Text(
            a['label'],
            style: FontManager().getTextStyle(
              context,
              fontSize: 13,
              color: isPrimary
                  ? AppColors.backgroundColor
                  : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }).toList(),
),

                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
void handleNotificationTap(Map<String, dynamic> notification) async {
  final String type = notification['type'];
  final Map<String, dynamic> payload =
      notification['payload'] ?? {};

  switch (type) {

    // ---------------- COMMENT / LIKE ----------------
    case "comment":
    case "like":
      try {
          if (payload['id'] == null || payload['id'].isEmpty) {
            snackBarCalledfail(context, "Cannot navigate: Invalid post ID");
            return;
          }
          PostModel? postModel = await fetchPostById(payload['id'], context);
          if (postModel == null) {
            return;
          }
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TribeUnique(
                id: payload['id'],
                dataObj: postModel,
                popBox: false.obs,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } catch (e) {
          snackBarCalledfail(context, "Failed to navigate to post");
        }
        // No navigation for pending friend requests since they have buttons
        break;
      
  

    // ---------------- FRIEND REQUEST ----------------
    case "friendRequest":
      // No auto-navigation
      // User must click Accept / Reject
      break;

    // ---------------- SPLIT / LEND ----------------
    case "splitApprovalRequest":
    case "lendApprovalRequest":
    case "split":
    case "lend":
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserListScreen(isPayable: true),
        ),
      );
      break;

    case "lendAccepted":
    case "lendSettled":
    case "splitSettled":
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserListScreen(isPayable: false),
        ),
      );
      break;

    // ---------------- FETCHED DATA ----------------
    case "FetchedData":
      // Optional: navigate to bank / analytics page
      // or do nothing
      break;

    default:
      debugPrint("No navigation defined for $type");
  }
}

  Widget _notificationIcon(String? icon) {
    if (icon != null && icon.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(icon),
        backgroundColor: AppColors.backgroundColor,
      );
    }
    return const Icon(Icons.notifications,
        size: 28, color: AppColors.primaryColor);
  }

  // ---------------- DELETE ----------------

  void _deleteNotification(String id) {
    notificationList.removeWhere((e) => e['id'] == id);
    deleteNotification(id, context);
  }
}
