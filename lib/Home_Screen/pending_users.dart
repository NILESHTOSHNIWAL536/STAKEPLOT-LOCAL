import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';

import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import 'package:get/get.dart';

import 'package:intl/intl.dart';

class UserListScreen extends StatefulWidget {
  final bool isPayable; // true for amounts to pay, false for amounts to receive

  const UserListScreen({Key? key, required this.isPayable}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    getRemainders(context);
    // getFoodieFundsDetails(context,id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          widget.isPayable ? 'Amounts to Pay' : 'Amounts to Receive',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.accentColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final dataList =
            widget.isPayable ? dueAmountRemainders : lendAmountRemainders;
        if (dataList.isEmpty) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Text(
                widget.isPayable
                    ? 'No pending payments.'
                    : 'No amounts owed to you.',
                textAlign: TextAlign.center,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 16,
                  color: AppColors.accentColor.withOpacity(0.7),
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: dataList.length,
          itemBuilder: (context, index) => _buildCard(
            context,
            dataList[index],
            widget.isPayable,
          ),
        );
      }),
    );
  }

  Widget _buildCard(
      BuildContext context, Map<String, dynamic> data, bool isDue) {
    final bool isLendAmount =
        data['category']?.toString().toLowerCase() == 'lend money';
    final foodieBill = data['billName']?.toString();
    final foodDetailsId = data["_id"];
    return GestureDetector(
      onTap: foodieBill == "foodie split"
          ? () {
              foodieFundsDetails(context, foodDetailsId);
            }
          : null,
      child: Column(
        children: [
          Container(
            color: AppColors.backgroundColor,

            // margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final avatarSize =
                      maxWidth * 0.12 > 48 ? 48.0 : maxWidth * 0.12;
                  final buttonWidth =
                      maxWidth * 0.35 > 120 ? 120.0 : maxWidth * 0.35;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      ClipOval(
                        child: AvatarProfile(
                            name: data['name'] ?? data['userName'] ?? 'Unknown',
                            width: 12,
                            height: 12,
                            background: data['avatarBackGround'] ??
                                defaultBackGround.value),
                      ),

                      // Details
                      Container(
                        child: SizedBox(
                          //width: maxWidth * 0.48, // Constrain details section
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  data['name'] ?? data['userName'] ?? 'Unknown',
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.accentColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),

                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    height: MediaQuery.sizeOf(context).height /
                                        28.0,
                                    width:
                                        MediaQuery.sizeOf(context).width / 5.0,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        foodieBill == "foodie split"
                                            ? data['billName']
                                            : data['category'] ?? 'Untagged',
                                        style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.w500,
                                          fontSize: 10,
                                          color: AppColors.accentColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  //here
                                  InkWell(
                                    onTap: () async {
                                      if (data['isPaid']) return;
                                      String message;
                                      if (isDue) {
                                        // Handle "Settle Now" for due amounts
                                        int index = dueAmountRemainders
                                            .indexWhere((element) =>
                                                element['_id'] == data['_id']);
                                        if (index != -1) {
                                          duesPaid(context, index);
                                          dueAmountRemainders[index]['isPaid'] =
                                              true;
                                          dueAmountRemainders[index]
                                              ['billApproved'] = true;
                                          dueAmountRemainders.refresh();
                                          message = SnackbarData().paymentsInit;
                                        } else {
                                          message =
                                              SnackbarData().paymentsError;
                                        }
                                      } else {
                                        // Handle "Send Reminder" for lend amounts
                                        int index = lendAmountRemainders
                                            .indexWhere((element) =>
                                                element['_id'] == data['_id']);
                                        if (index != -1) {
                                          lendAmountRemainders[index]
                                              ['reminderSent'] = true;
                                          lendAmountRemainders.refresh();
                                          message = SnackbarData()
                                              .remainder; //'Reminder sent successfully!';
                                        } else {
                                          message = SnackbarData()
                                              .remainderError; //'Error: Reminder not found.';
                                        }
                                      }

                                      // Send notification
                                      sendNotificationsToDevice(
                                        data['payerId'] ?? data['receiverId'],
                                        context,
                                        isDue
                                            ? 'Successfully paid your bill of ${data['amount'] ?? "0000"} to ${userController.userName.value}.'
                                            : 'You need to pay ${data['amount'] ?? "0000"} to ${userController.userName.value}.',
                                        "/remainder",
                                        "",
                                        "",
                                        message,
                                        data['_id'],
                                      );
                                    },
                                    child: Container(
                                      // width: Media,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              28.0,
                                      width:
                                          MediaQuery.sizeOf(context).width / 5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: (isDue &&
                                                    (data['isPaid'] ??
                                                        false)) ||
                                                (!isDue &&
                                                    (data['reminderSent'] ??
                                                        false))
                                            ? AppColors.button.withOpacity(0.5)
                                            : AppColors.button,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.button
                                                .withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          isDue
                                              ? (data['isPaid'] ?? false)
                                                  ? 'Requested'
                                                  : (data['billApproved'] ??
                                                          true)
                                                      ? 'Settle Now'
                                                      : 'Awaiting Settlement'
                                              : (data['reminderSent'] ?? false)
                                                  ? 'Remind now'
                                                  : (data['billApproved'] ??
                                                          true)
                                                      ? 'Remind now'
                                                      : 'Awaiting Approval',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.w600,
                                            fontSize: 10,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Due date display for lends only
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Action Button and Date
                      Container(
                        child: SizedBox(
                          width: buttonWidth / 1.1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 16),
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: maxWidth * 0.2),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      NumberFormat.currency(
                                              symbol: '₹', decimalDigits: 2)
                                          .format(data['amount'] ?? 0),
                                      style: FontManager().getTextStyle(
                                        context,
                                        lWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: isDue
                                            ? Color.fromARGB(255, 207, 118, 113)
                                            : Colors.green,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                              if (isLendAmount && data['dueDate'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  () {
                                    final dueDate =
                                        DateTime.parse(data['dueDate']);
                                    final today = DateTime.now();
                                    final isToday =
                                        dueDate.year == today.year &&
                                            dueDate.month == today.month &&
                                            dueDate.day == today.day;
                                    final isOverdue =
                                        dueDate.isBefore(today) && !isToday;

                                    if (isToday) {
                                      return 'Due: Today';
                                    } else if (isOverdue) {
                                      return 'Overdue: ${DateFormat('d MMM yyyy').format(dueDate)}';
                                    } else {
                                      return 'Due: ${DateFormat('d MMM yyyy').format(dueDate)}';
                                    }
                                  }(),
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 10,
                                    color:
                                        AppColors.accentColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void foodieFundsDetails(BuildContext context, String foodDetailsId) async {
    // Show loading dialog
    try {
      // Fetch data
      await getFoodieFundsDetails(context, foodDetailsId);

      // Show bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          final maxHeight = MediaQuery.of(context).size.height * 0.85;
          final animation = ModalRoute.of(context)!.animation!;
          return Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: const EdgeInsets.all(12.0),
            child: Obx(() {
              if (foodieFundsDetailsRemainders.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'No details available.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                );
              }

              final data = foodieFundsDetailsRemainders[0];
              final friends =
                  List<Map<String, dynamic>>.from(data['friends'] ?? []);
              final currentUser = data['currentUser'] ?? {};

              return SingleChildScrollView(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeIn,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(context, data, animation),
                        const SizedBox(height: 12),
                        const Divider(
                            color: AppColors.accentColor, thickness: 0.5),

                        // Current User
                        _buildSectionHeader(
                            context, 'Your Details', Icons.person, animation),
                        const SizedBox(height: 8),
                        _buildUserDetails(context, currentUser, animation),
                        const SizedBox(height: 12),
                        const Divider(
                            color: AppColors.accentColor, thickness: 0.5),

                        // Friends
                        _buildSectionHeader(
                            context, 'Friends', Icons.group, animation),
                        const SizedBox(height: 8),
                        friends.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'No friends in this split.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: friends.length,
                                itemBuilder: (context, index) {
                                  final friend = friends[index];
                                  return Column(
                                    children: [
                                      _buildUserDetails(
                                          context, friend, animation),
                                      if (index < friends.length - 1)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Divider(
                                            color: AppColors.accentColor,
                                            thickness: 0.2,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      );
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      snackBarCalledfail(context, SnackbarData().fetchingError);
    }
  }

// Reusable function for user details
  Widget _buildUserDetails(BuildContext context, Map<String, dynamic> user,
      Animation<double> animation) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20), // Space for the Paid status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Name
              Container(
                width: MediaQuery.sizeOf(context).width / 4,
                child: Text(
                  user['name'] ?? 'Unknown',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
              if (user['priorities'] != null) ...[
                Container(
                  width: MediaQuery.sizeOf(context).width / 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priorities:',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.accentColor,
                        ),
                      ),
                      if ((user['priorities']['Veg'] ?? 0) > 0)
                        Text(
                          'Veg: ${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(user['priorities']['Veg'])}',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColors.accentColor.withOpacity(0.7),
                          ),
                        ),
                      if ((user['priorities']['Non veg'] ?? 0) > 0)
                        Text(
                          'Non Veg: ${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(user['priorities']['Non veg'])}',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColors.accentColor.withOpacity(0.7),
                          ),
                        ),
                      if ((user['priorities']['Alcohol'] ?? 0) > 0)
                        Text(
                          'Alcohol: ${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(user['priorities']['Alcohol'])}',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColors.accentColor.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              // Amount Due
              Container(
                width: MediaQuery.sizeOf(context).width / 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due:',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.accentColor,
                      ),
                    ),
                    Text(
                      '${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(user['amountDue'] ?? 0)}',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Priorities
        ],
      ),
    );
  }

// Reusable function for section headers (unchanged)
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon,
      Animation<double> animation) {
    return Row(
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: Icon(icon, size: 18, color: AppColors.accentColor),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.accentColor,
          ),
        ),
      ],
    );
  }

// Reusable function for header (unchanged)
  Widget _buildHeader(BuildContext context, Map<String, dynamic> data,
      Animation<double> animation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 18,
                  color: AppColors.backgroundColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data['splitName'] ?? 'Foodie Split',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.backgroundColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subcategory: ${data['subcategory'] ?? 'N/A'}',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.backgroundColor.withOpacity(0.7),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Total Amount: ${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(data['totalAmount'] ?? 0)}',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.backgroundColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
