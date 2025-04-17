
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/profile.dart';
// import 'package:flutter_application_code_stakeplot/userAvatar.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserListScreen extends StatefulWidget {
//   final bool isPayable; // true for payables, false for oweds

//   const UserListScreen({Key? key, required this.isPayable}) : super(key: key);

//   @override
//   State<UserListScreen> createState() => _UserListScreenState();
// }

// class _UserListScreenState extends State<UserListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     getRemainders(context); // Fetch data for both payables and oweds
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         elevation: 0,
//         title: Text(
//           widget.isPayable ? 'Payables' : 'Oweds',
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
//             url: data['avatarType'] ?? 'assets/avatar/menp4.svg',
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
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class UserListScreen extends StatefulWidget {
  final bool isPayable; // true for payables, false for oweds

  const UserListScreen({Key? key, required this.isPayable}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    getRemainders(context);
    //  WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   try {
    //     print('Initializing HomeWidget with group: group.com.stakeplot.adnan.dev');
    //     await HomeWidget.setAppGroupId('group.com.stakeplot.adnan.dev');
    //     getRemainders(context);
    //     await _updateWidget();
    //   } catch (e) {
    //     print('Error initializing HomeWidget: $e');
    //   }
    // });
    // ever(lendAmountRemainders, (_) => _updateWidget());
    // ever(dueAmountRemainders, (_) => _updateWidget()); // Fetch data for both payables and oweds
  }
// Future<void> _updateWidget() async {
//     try {
//       String toReceive = 'None: ₹0';
//       String toPay = 'None: ₹0';
//       print('lendAmountRemainders: $lendAmountRemainders');
//       print('dueAmountRemainders: $dueAmountRemainders');
//       if (lendAmountRemainders.isNotEmpty && lendAmountRemainders.first != null) {
//         final data = lendAmountRemainders.first;
//         toReceive =
//             '${data["name"] ?? "Unknown"}: ₹${(data["amount"] ?? 0).toStringAsFixed(2)}';
//       }
//       if (dueAmountRemainders.isNotEmpty && dueAmountRemainders.first != null) {
//         final data = dueAmountRemainders.first;
//         toPay =
//             '${data["name"] ?? "Unknown"}: ₹${(data["amount"] ?? 0).toStringAsFixed(2)}';
//       }
//       print('Updating PayableWidget: toReceive=$toReceive, toPay=$toPay');
//       await HomeWidget.saveWidgetData<String>('to_receive', toReceive);
//       await HomeWidget.saveWidgetData<String>('to_pay', toPay);
//       print('Calling HomeWidget.updateWidget for PayableWidgetProvider');
//       await HomeWidget.updateWidget(
//         name: 'PayableWidgetProvider',
//         androidName: 'PayableWidgetProvider',
//         iOSName: 'PayableWidget',
//       );
//       print('HomeWidget.updateWidget completed successfully');
//     } catch (e) {
//       print('Error updating widget: $e');
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          widget.isPayable ? 'Payables' : 'Oweds',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.accentColor,
          ),
        ),
      ),
      body: Obx(() {
        final dataList = widget.isPayable ? dueAmountRemainders : lendAmountRemainders;
        if (dataList.isEmpty) {
          return Center(
            child: Text(
              widget.isPayable ? 'No payable dues found.' : 'No amounts owed to you.',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: 16,
                color: AppColors.accentColor,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          itemCount: dataList.length,
          itemBuilder: (context, index) => _buildListTile(
            context,
            dataList[index],
            widget.isPayable,
          ),
        );
      }),
    );
  }

  Widget _buildListTile(BuildContext context, Map<String, dynamic> data, bool isDue) {
    return Row(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 15,
          width: MediaQuery.of(context).size.width / 7,
          child: UserAvatar(
            url: data['avatarType'] ?? 'assets/avatar/menp4.svg',
            width: 1,
            height: 1,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    data['name'] ?? data['userName'] ?? '',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.accentColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      data['category'] ?? 'Untagged',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 8,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(data['amount'] ?? 0),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                if ((data['isPaid'] ?? false)) {
                  return;
                }
                if (isDue) {
                  int index = dueAmountRemainders.indexWhere((element) => element['_id'] == data['_id']);
                  if (index != -1) {
                     duesPaid(context, index); 
                    dueAmountRemainders[index]['isPaid'] = true;
                    dueAmountRemainders[index]['billApproved'] = true;
                    dueAmountRemainders.refresh();
                  }
                } else {
                  int index = lendAmountRemainders.indexWhere((element) => element['_id'] == data['_id']);
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
                );
              },
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.03,
                width: (data['billApproved'] ?? true)
                    ? MediaQuery.sizeOf(context).width * 0.25
                    : MediaQuery.sizeOf(context).width * 0.30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.button,
                ),
                child: Center(
                  child: Text(
                    (data['isPaid'] ?? false)
                        ? 'Requested'
                        : (data['billApproved'] ?? true)
                            ? (isDue ? 'Settle now' : 'Remind now')
                            : (isDue ? 'Didn\'t settle' : 'Didn\'t approve'),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formatDateTime(data['createdAt']),
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w300,
                fontSize: 8,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}