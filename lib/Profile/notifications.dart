import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart";
import "package:flutter_application_code_stakeplot/Profile/autocategroies.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
import "package:flutter_application_code_stakeplot/userAvatar.dart";
import "package:get/get.dart";

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
    // getTransaction();
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
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
             
              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.04,vertical: constraints.maxHeight * 0.01,),
              child: SingleChildScrollView(
                
                  child: Obx(() => myNotificationBool.value
                      ? _buildNotificationList()
                      : _buildNotificationList()),
                
              ),
            );
          },
        ),
      ),
    );
  }

 Widget _buildNotificationList() {
  return notificationList.isEmpty && flag.value
      ? const Loader()
      :( notificationList.isEmpty && autoTransactionList.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AvatarProfileImage(
                    url: HomePageIcons.none,
                    height: 8,
                    width: 10,
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
          : Column(
            children: [
                AutocategroiesTransactions(),
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                          // Match the margin and decoration of the foreground card
                          margin: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height * 0.008),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          // Match padding with the foreground card
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                          alignment: Alignment.centerRight,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        child: _buildNotificationCard(e),
                      );
                    },
                  ),
              ),
            ],
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
           
            //SizedBox(width: MediaQuery.of(context).size.width * 0.03),
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
              e['from_name'] as String? ?? "",
              time);
        }
        return _buildFriendRequestCard(
            e['from_name'] as String? ?? "Unknown",
            e['from_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            e,
            notifyId,
            time);
      case "split":
        return _buildMessageCard(
            "${e['username'] ?? 'Someone'} has shared the bill for ${e['billname'] ?? 'unknown'} of ₹${(double.tryParse(e['amount']?.toString() ?? '400') ?? 400).toStringAsFixed(1)}",
            e['id'] as String? ?? "",
            e['username'] as String? ?? "",
            time);
      case "roomBill":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has shared the bill in Room",
            e['from_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time);
      case "room":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has added you to the room ${e['roomName'] ?? 'unknown'}",
            e['from_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time);
      case "comment":
        return _buildMessageCard(
            "${e['username'] ?? 'Someone'} has commented on your post",
            e['id'] as String? ?? "",
            e['username'] as String? ?? "",
            time);
      case "lendRequest":
        return _buildLendRequestCard(
            e['from_name'] as String? ?? "Unknown",
            e['from_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
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
            //modified here for user avtar from  -----
            e['username'] as String? ?? "", //from_name
            time);
      case "lendSettled":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has settled your loan of ${e['amount'] ?? '0'} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time);
      case "splitSettled":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has settled your Split of ${(double.tryParse(e['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(1)} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time);
      case "FetchedData":
        return _buildMessageCard("🔥 Data has been successfully fetched!", "", "", time);
      case "lendApprovalRequest":
        return _buildApprovalCard(
            "${e['from_name'] ?? 'Someone'} has requested approval for settling ${e['name'] ?? 'unknown'} with an amount of ${e['amount'] ?? '00'}",
            e['bill_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            "bill",
             e['from_to'] as String? ?? "",notifyId.toString());


      case "deleteAccountSplit":
        return _buildMessageCard(
            "${e['from_name'] ?? 'This user'} has deleted their account, but some split amounts are still pending.",
            e['bill_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time);

      case "deleteAccountLend":
        return _buildMessageCard(
            "${e['from_name'] ?? 'This user'} has deleted their account, but some lend amounts are still pending.",
            e['bill_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time);

      case "splitApprovalRequest":
        return _buildApprovalCard(
            "${e['from_name'] ?? 'Someone'} has requested approval for settling ${e['name'] ?? 'unknown'} with an amount of ${e['amount'] ?? '00'}",
            e['split_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            "split",
            e['from_to'] as String? ?? "",notifyId.toString());

      case "clearLend":
      case "clearSplit":
        String ty = type == "clearLend" ? "lend" : "split";
        return _buildMessageCard(
            "You have cleared your $ty of ${(double.tryParse(e['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(1)} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            // modified here from avatarType to from_name
            e['from_name'] as String? ?? "",
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
    //     print("-----------------------${(!isFetchedData && avatar.isNotEmpty)}");
        // UserAvatar(
        //   url: avaterUrlPath(avatar),
        //   width: 20,
        //   height:17,
        // )
        AvatarProfile(name: avatar, width: 20, height: 17, background: "")
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
        //  UserAvatar(
        //   url: avaterUrlPath(avatar),
        //   width: MediaQuery.of(context).size.width * 0.06,
        //   height: MediaQuery.of(context).size.width * 0.06,
        // ),
         AvatarProfile(name: avatar, width: 20, height: 17, background: ""),
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
        // UserAvatar(
        //   url: avaterUrlPath(avatar),
        //   width: MediaQuery.of(context).size.width * 0.06,
        //   height: MediaQuery.of(context).size.width * 0.06,
        // ),
         AvatarProfile(name: avatar, width: 20, height: 17, background: ""),
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
        avatar.isNotEmpty?
        //  UserAvatar(
        //         url: avaterUrlPath(avatar),
        //         width: MediaQuery.of(context).size.width * 0.06,
        //         height: MediaQuery.of(context).size.width * 0.06,
        //       )
         AvatarProfile(name: avatar, width: 20, height: 17, background: "")
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