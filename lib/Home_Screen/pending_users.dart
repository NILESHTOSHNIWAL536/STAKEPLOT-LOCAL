// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/profile.dart';
// import 'package:flutter_application_code_stakeplot/userAvatar.dart';
// import 'package:get/get.dart';
// import 'package:home_widget/home_widget.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class UserListScreen extends StatefulWidget
// {
//   final bool isPayable; // true for payables, false for oweds

//   const UserListScreen({Key? key, required this.isPayable}) : super(key: key);

//   @override
//   State<UserListScreen> createState() => _UserListScreenState();

// }

// class _UserListScreenState extends State<UserListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     getRemainders(context);
   
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         elevation: 0,
//         title: Text(
//           widget.isPayable ? 'Amounts to pay' : 'Amounts to receive',
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.bold,
//             fontSize: 18,
//             color: AppColors.accentColor,
//           ),
//         ),
//       ),
//       body: Obx(() {
//         final dataList = widget.isPayable ? dueAmountRemainders : lendAmountRemainders;
//         if (dataList.isEmpty) {
//           return Center(
//             child: Text(
//               widget.isPayable ? 'No payable dues found.' : 'No amounts owed to you.',
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.w400,
//                 fontSize: 16,
//                 color: AppColors.accentColor,
//               ),
//             ),
//           );
//         }
//         return ListView.builder(
//           padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
//           itemCount: dataList.length,
//           itemBuilder: (context, index) => _buildListTile(
//             context,
//             dataList[index],
//             widget.isPayable,
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildListTile(BuildContext context, Map<String, dynamic> data, bool isDue) {
//     return Row(
//       children: [
//         Container(
//           height: MediaQuery.of(context).size.height / 15,
//           width: MediaQuery.of(context).size.width / 7,
//           child: UserAvatar(
//             url:avaterUrlPath(data['name'] ?? 'assets/avatar/menp4.svg'),
//             width: 1,
//             height: 1,
//           ),
//         ),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     data['name'] ?? data['userName'] ?? '',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: AppColors.accentColor,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Flexible(
//                     child: Text(
//                       data['category'] ?? 'Untagged',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.bold,
//                         fontSize: 8,
//                         color: AppColors.accentColor,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(data['amount'] ?? 0),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 10,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             InkWell(
//               onTap: () async {
//                 if ((data['isPaid'] ?? false)) {
//                   return;
//                 }
//                 if (isDue) {
//                   int index = dueAmountRemainders.indexWhere((element) => element['_id'] == data['_id']);
//                   if (index != -1) {
//                      duesPaid(context, index); 
//                     dueAmountRemainders[index]['isPaid'] = true;
//                     dueAmountRemainders[index]['billApproved'] = true;
//                     dueAmountRemainders.refresh();
//                   }
//                 } else {
//                   int index = lendAmountRemainders.indexWhere((element) => element['_id'] == data['_id']);
//                   if (index != -1) {
//                     lendAmountRemainders.refresh();
//                   }
//                 }
//                 sendNotificationsToDevice(
//                   data['payerId'] ?? data['receiverId'],
//                   context,
//                   isDue
//                       ? 'Successfully paid your bill of ${data['amount'] ?? "0000"} to ${userName.value}.'
//                       : 'You need to pay ${data['amount'] ?? "0000"} to ${userName.value}.',
//                    "/remainder"
//                 );
//               },
//               child: Container(
//                 height: MediaQuery.sizeOf(context).height * 0.03,
//                 width: (data['billApproved'] ?? true)
//                     ? MediaQuery.sizeOf(context).width * 0.25
//                     : MediaQuery.sizeOf(context).width * 0.30,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: AppColors.button,
//                 ),
//                 child: Center(
//                   child: Text(
//                     (data['isPaid'] ?? false)
//                         ? 'Requested'
//                         : (data['billApproved'] ?? true)
//                             ? (isDue ? 'Settle now' : 'Remind now')
//                             : (isDue ? 'Didn\'t settle' : 'Didn\'t approve'),
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 12,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               formatDateTime(data['createdAt']),
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.w300,
//                 fontSize: 8,
//                 color: Colors.green,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/userAvatar.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        final dataList = widget.isPayable ? dueAmountRemainders : lendAmountRemainders;
        if (dataList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Text(
                widget.isPayable ? 'No pending payments.' : 'No amounts owed to you.',
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
          padding: const EdgeInsets.all(16.0),
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

  Widget _buildCard(BuildContext context, Map<String, dynamic> data, bool isDue) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.accentColor.withOpacity(0.15)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final avatarSize = maxWidth * 0.12 > 48 ? 48.0 : maxWidth * 0.12;
            final buttonWidth = maxWidth * 0.35 > 120 ? 120.0 : maxWidth * 0.35;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  height: avatarSize,
                  width: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentColor.withOpacity(0.2)),
                  ),
                  child: ClipOval(
                    child: UserAvatar(
                      url: avaterUrlPath(data['name'] ?? 'assets/avatar/menp4.svg'),
                      width: 1,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                SizedBox(
                  width: maxWidth * 0.45, // Constrain details section
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
                            fontSize: 14,
                            color: AppColors.accentColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data['category'] ?? 'Untagged',
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
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth * 0.2),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                NumberFormat.currency(symbol: '₹', decimalDigits: 2)
                                    .format(data['amount'] ?? 0),
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: isDue ? Color.fromARGB(255, 207, 118, 113) : Colors.green,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action Button and Date
                SizedBox(
                  width: buttonWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () async {
                          if ((data['isPaid'] ?? false)) return;
                          if (isDue) {
                            int index = dueAmountRemainders
                                .indexWhere((element) => element['_id'] == data['_id']);
                            if (index != -1) {
                              duesPaid(context, index);
                              dueAmountRemainders[index]['isPaid'] = true;
                              dueAmountRemainders[index]['billApproved'] = true;
                              dueAmountRemainders.refresh();
                              
                            }
                          } else {
                            int index = lendAmountRemainders
                                .indexWhere((element) => element['_id'] == data['_id']);
                            if (index != -1) {
                              lendAmountRemainders.refresh();
                              
                            }
                          }
                          sendNotificationsToDevice(
                            data['payerId'] ?? data['receiverId'],
                            context,
                            isDue
                                ? 'Successfully paid your bill of ${data['amount'] ?? "0000"} to ${userName.value}.'
                                : 'You need to pay ${data['amount'] ?? "0000"} to ${userName.value}.',
                            "/remainder",
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: (data['isPaid'] ?? false)
                                ? AppColors.button.withOpacity(0.5)
                                : AppColors.button,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.button.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            (data['isPaid'] ?? false)
                                ? 'Requested'
                                : (data['billApproved'] ?? true)
                                    ? (isDue ? 'Settle Now' : 'Send Reminder')
                                    : (isDue ? 'Awaiting Settlement' : 'Awaiting Approval'),
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
                      const SizedBox(height: 6),
                      Text(
                        formatDateTime(data['createdAt']),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 10,
                          color: AppColors.accentColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}