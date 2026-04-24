import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constants/colors.dart';
import '../Constants/font_manager.dart';
import '../Constants/loader.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Home_Screen/history/collections/invitations_list.dart';
import '../Tribe/tribe_one.dart';
import '../backed_connections/apis_connect.dart';
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
    collectionsController.getPendingInvitations();
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
            return Spinner();
          }

          if (notificationList.isEmpty) {
            return _emptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Column(
              children: [
                GetInvitationsList(),
                const SizedBox(height: AppSizes.p16),
                Column(
                  children: _buildGroupedNotifications(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget GetInvitationsList() {
    if (collectionsController.invitationsList.isEmpty)
      return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // light grey bg
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 HEADER
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Invitations",
              style: FontManager().getTextStyle(
                context,
                fontSize: 15,
                lWeight: FontWeight.w600,
                color: AppColors.accentColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 🔥 DIVIDER (optional but looks premium)
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 10),

          /// 🔥 LIST
          InvitationsList(),
        ],
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: AppColors.grey),
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
      if (n['type'] != "COLLECTION_INVITATION") {
        final String key = n['dateGroup'] ?? "Others";
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(n);
      }
    }

    List<Widget> ListNotications = grouped.entries.map((entry) {
      return _buildDateSection(entry.key, entry.value);
    }).toList();

    return ListNotications;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ---------------- DATE SECTION ----------------

  Widget _buildDateSection(String title, List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
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
      key: Key(n["id"]),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(n['id']),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.redColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: AppColors.backgroundColor),
      ),
      child: _notificationCard(n),
    );
  }

  void handleNotificationAction(
    String actionKey,
    Map<String, dynamic> notification,
  ) async {
    final String type = notification['type'];
    final Map<String, dynamic> payload = notification['payload'] ?? {};
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
                      final bool isPrimary =
                          a['key'] == 'accept' || a['key'] == 'approve';

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
                                  : Border.all(
                                      color: AppColors
                                          .notificationCardBorderColor),
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
    final Map<String, dynamic> payload = notification['payload'] ?? {};

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
