
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
import "package:flutter_application_code_stakeplot/Constants/colors.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart";
import "package:flutter_application_code_stakeplot/components/helper.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/Home/home_page_apiCalls.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/pending_users.dart";
import "package:flutter_application_code_stakeplot/Profile/autocategroies.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_one.dart";

import "package:flutter_application_code_stakeplot/Utils/snackBar.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends_apis.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
import "package:flutter_application_code_stakeplot/model/post_model.dart";
import "package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart";
import "package:flutter_application_code_stakeplot/routes/route_user_login.dart";
import "dart:convert";

import "package:get/get.dart";

import "../routes/route_post.dart";

RxBool notificationsFlag = true.obs;

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
    getNotifications(context);

    // Debug notification list on init
  }

  Future<void> deleteNotification(String? notifyId) async {
    if (notifyId == null) return;
    String urlPath = '${UserRoutes.deleteNotifications}/$notifyId';
    var response = await getDataApiCall(urlPath);
    if (!getFlagOfResponse(response)) 
     
    {
      snackBarCalledfail(context, SnackbarData().deleteNotificationFailed);
    }
  }

  Future<PostModel?> fetchPostById(String postId, BuildContext context) async {
    try {
      final response = await getDataApiCall(
          '${PostRoutes.post}$postId'); // Adjust the endpoint based on your API);
      if (getFlagOfResponse(response)) {
        var jsonData = jsonDecode(response.body);
        // Adjust based on your API response structure, e.g., jsonData['data']
        return PostModel.fromJson(jsonData['data'][0] ?? jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
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
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.04,
                vertical: constraints.maxHeight * 0.01,
              ),
              child: SingleChildScrollView(
                child: Obx(() {
                   return myNotificationBool.value
                      ? _buildNotificationList()
                      : _buildNotificationList();
                }),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return notificationList.isEmpty && notificationsFlag.value
        ? Spinner()
        : (notificationList.isEmpty && autoTransactionList.isEmpty)
            ? Container(
                width: MediaQuery.sizeOf(context).width / 1.1,
                height: MediaQuery.sizeOf(context).height / 1.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.008),
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
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.03),
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: AppColors.backgroundColor),
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

    return GestureDetector(
      onTap: () => _handleNotificationTap(type ?? "unknown", data, e),
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.008),
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
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                  child: _getNotificationContent(
                      type ?? "unknown", data, notifyId, time),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(String type, Map<String, dynamic> data,
      Map<String, dynamic> notification) async {
    switch (type) {
      case "comment":
        try {
          if (data['id'] == null || data['id'].isEmpty) {
            snackBarCalledfail(context, "Cannot navigate: Invalid post ID");
            return;
          }
          PostModel? postModel = await fetchPostById(data['id'], context);
          if (postModel == null) {
            return;
          }
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TribeUnique(
                id: data['id'],
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
      case "split":
      case "roomBill":
      case "splitApprovalRequest":
      case "lendApprovalRequest":
      case "deleteAccountSplit":
      case "deleteAccountLend":
      case "clearLend":
      case "clearSplit":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserListScreen(isPayable: true),
          ),
        );
        break;
      case "lendAccepted":
      case "rejectedLend":
      case "lendSettled":
      case "splitSettled":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserListScreen(isPayable: false),
          ),
        );
        break;
      case "friendRequest":
        if (data['status'] == 'accepted') {
          final userId = data['from_id'] as String? ?? "";

          var dataObj = userController.maskedConnected
              .firstWhere((e) => e['_id'] == userId);

          if (userId.isNotEmpty &&
              userId != "null" &&
              data['isMaskedConnection'] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityUserProfile(
                  data: dataObj,
                  ids: [userId],
                  flag: true,
                  isMasked: true,
                  isMaskedConnect: true,
                ),
              ),
            );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => Friends()),
            // );
          } else {
            snackBarCalledfail(context, "Invalid user ID");
          }
        }
        // No navigation for pending friend requests since they have buttons
        break;
    }
  }

  Widget _getNotificationContent(
      String type, Map<String, dynamic> e, String? notifyId, String time) {
    switch (type) {
      case "friendRequest":
        if (e['status'] == 'accepted') {
          var notificationAvatar = e['isMaskedConnection']
              ? e['avatarType']
              : e['from_name'] as String?;
          var msg = e['isMaskedConnection']
              ? "connected to you"
              : "accepted your friend request";
          return _buildMessageCard(
              "${e['from_name'] ?? 'Someone'} $msg",
              e['from_id'] as String? ?? "",
              notificationAvatar ?? '',
              time,
              e['isMaskedConnection']);
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
            time,
            false);
      case "roomBill":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has shared the bill in Room",
            e['from_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            false);
      case "room":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has added you to the room ${e['roomName'] ?? 'unknown'}",
            e['from_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            false);
      case "comment":
        return _buildMessageCard(
            "${e['username'] ?? 'Someone'} has commented on your post",
            e['id'] as String? ?? "",
            e['avatarType'] ?? "",
            time,
            true);
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
            e['username'] as String? ?? "",
            time,
            false);
      case "lendSettled":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has settled your loan of ${e['amount'] ?? '0'} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            false);
      case "splitSettled":
        return _buildMessageCard(
            "${e['from_name'] ?? 'Someone'} has settled your Split of ${(double.tryParse(e['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(1)} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            false);
      case "FetchedData":
        return _buildMessageCard(
            e['message'] ?? "🔥 Data has been successfully fetched!",
            "",
            e['avatarType'],
            time,
            false);
      case "lendApprovalRequest":
        return _buildApprovalCard(
            "${e['from_name'] ?? 'Someone'} has requested approval for settling ${e['name'] ?? 'unknown'} with an amount of ${e['amount'] ?? '00'}",
            e['bill_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            "bill",
            e['from_to'] as String? ?? "",
            notifyId.toString());
      case "deleteAccountSplit":
        return _buildMessageCard(
            "${e['from_name'] ?? 'This user'} has deleted their account, but some split amounts are still pending.",
            e['bill_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            false);
      case "deleteAccountLend":
        return _buildMessageCard(
            "${e['from_name'] ?? 'This user'} has deleted their account, but some lend amounts are still pending.",
            e['bill_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            false);
      case "splitApprovalRequest":
        return _buildApprovalCard(
            "${e['from_name'] ?? 'Someone'} has requested approval for settling ${e['name'] ?? 'unknown'} with an amount of ${e['amount'] ?? '00'}",
            e['split_id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            "split",
            e['from_to'] as String? ?? "",
            notifyId.toString());
      case "clearLend":
      case "clearSplit":
        String ty = type == "clearLend" ? "lend" : "split";
        return _buildMessageCard(
            "You have cleared your $ty of ${(double.tryParse(e['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(1)} for the item: ${e['name'] ?? 'unknown'}",
            e['id'] as String? ?? "",
            e['from_name'] as String? ?? "",
            time,
            false);
      default:
        return const SizedBox(child: Text("Unknown notification type"));
    }
  }

  Widget _buildMessageCard(
      String message, String id, avatar, String time, bool isMasked) {
    bool isFetchedData = message.contains("Data has been successfully fetched");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFetchedData)
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        isFetchedData
            ? Container(
                child: Image.network(
                avatar,
                width: 30,
                height: 30,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance,
                  size: 30,
                  color: AppColors.primaryColor,
                ),
              ))
            : SizedBox.shrink(),
        if (!isFetchedData && avatar.isNotEmpty)
          if (!isMasked)
            AvatarProfile(name: avatar, width: 20, height: 17, background: "")
          else
            AvatarProfile2(url: avatar, width: 20, height: 20)
        else if (!isFetchedData)
          SizedBox(width: MediaQuery.of(context).size.width * 0.06),
        if (!isFetchedData)
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        if (isFetchedData)
          SizedBox(width: MediaQuery.of(context).size.width * 0.06),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.015),
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

  Widget _buildFriendRequestCard(String name, String id, String avatar,
      Map<String, dynamic> e, String? notifyId, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarProfile(name: avatar, width: 20, height: 17, background: ""),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.015),
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
                    AppColors.backgroundColor,
                    () {
                      addUserAsFrd(id, context);
                      _deleteNotification(notifyId);
                    },
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  _buildActionButton(
                    "Reject",
                    AppColors.backgroundColor,
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

  Widget _buildLendRequestCard(String name, String id, String avatar,
      Map<String, dynamic> e, String itemName, String? notifyId, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarProfile(name: avatar, width: 20, height: 17, background: ""),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.015),
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
                    AppColors.backgroundColor,
                    () {
                      approveBill(context, e['bill_id'] as String? ?? "",
                          "accept", notifyId);
                      _deleteNotification(notifyId);
                    },
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  _buildActionButton(
                    "Reject",
                    AppColors.backgroundColor,
                    AppColors.bg3,
                    () {
                      approveBill(context, e['bill_id'] as String? ?? "",
                          "reject", notifyId);
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

  Widget _buildApprovalCard(String message, String id, String avatar,
      String time, String type, String endUser, String notifyId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar.isNotEmpty
            ? AvatarProfile(name: avatar, width: 20, height: 17, background: "")
            : SizedBox(width: MediaQuery.of(context).size.width * 0.06),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.015),
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
                    AppColors.backgroundColor,
                    () {
                      settleAmount(context, id, type, endUser);
                      _deleteNotification(notifyId);
                    },
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  _buildActionButton(
                    "Reject",
                    AppColors.backgroundColor,
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

  Widget _buildActionButton(
      String label, Color bgColor, Color textColor, VoidCallback onTap,
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
        time.isNotEmpty
            ? formatWhatsAppDate(DateTime.parse(time))
            : "Unknown time",
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
