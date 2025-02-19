// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/profile.dart';
// import 'package:get/get.dart';
// import './colors.dart';
// import 'package:intl/intl.dart';

// class UserListScreen extends StatefulWidget {
//   @override
//   State<UserListScreen> createState() => _UserListScreenState();
// }

// class _UserListScreenState extends State<UserListScreen> {
//   @override
//   @override
//   void initState() {
//     super.initState();
//     getUserLend(context);
//     getRemainders(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Dues to receive',
//                 style: FontManager().getTextStyle(context,
//                     lWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: AppColors.accentColor),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   // Navigate to the "Show All Users" page
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ShowAllUsersScreen(),
//                     ),
//                   );
//                 },
//                 child: Text('more',
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.normal,
//                         fontSize: 14,
//                         color: AppColors.primaryColor)),
//               ),
//             ],
//           ),
//         ),
//         // Obx(() => getlendUsers.value ? getUser() : getUser()),
//         Obx(() => getlendUsers.value ? getUser() : Container())
//       ],
//     );
//   }

//   Widget getUser() {
//     return Visibility(
//       visible: lendAmountRemainders
//           .isNotEmpty, // Show only if there are pending dues
//       child: Container(
//         width: MediaQuery.of(context).size.width / 1.1,
//         padding: EdgeInsets.symmetric(vertical: 6),
//         child: Column(
//           children: lendAmountRemainders
//               .take(2) // Show up to 3 users
//               .map((data) => ListTile(
//                     leading: CircleAvatar(
//                         backgroundColor: Colorcodes.budgetLightGreen,
//                         child: ProfileImage(
//                             url: data['Avatar'] ?? 'assets/avatar/menp4.svg')),
//                     title: Text(
//                       data["userName"] ?? "Unknown User",
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: AppColors.accentColor),
//                     ),
//                     trailing: InkWell(
//                       onTap: () {
//                         sendNotificationsToDevice(data['_id'], context,
//                             "You need to pay lend To ${userName.value} of ${data['amount'] ?? "0000"}");
//                       },
//                       child: Text(
//                         (data["billApproved"] ?? true)
//                             ? "Remind now"
//                             : "Didn't approve",
//                         style: FontManager().getTextStyle(context,
//                             lWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: AppColors.primaryColor),
//                       ),
//                     ),
//                   ))
//               .toList(),
//         ),
//       ),
//     );
//   }
// }

// // Screen showing all users
// class ShowAllUsersScreen extends StatelessWidget {
//   const ShowAllUsersScreen({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         title: Text('Payable overview',
//             style: FontManager().getTextStyle(context,
//                 lWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: AppColors.accentColor)),
//       ),
//       body: DefaultTabController(
//         length: 2, // Number of tabs
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
//               child: DecoratedBox(
//                 decoration: const BoxDecoration(),
//                 child: TabBar(
//                   indicator: BoxDecoration(
//                     // Rounded corners

//                     color: AppColors.tab,

//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   // Padding for labels
//                   labelColor:
//                       AppColors.primaryColor, // Text color for selected tab
//                   unselectedLabelColor:
//                       AppColors.bg1, // Text color for unselected tabs

//                   tabs: const [
//                     Tab(child: Text('Payable')),
//                     Tab(text: 'Owed'),
//                     // Tab(text: 'Exploria'),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.height /
//                   1.609, // Adjust as needed for TabBarView
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
//                 child: TabBarView(
//                   children: [
//                     Center(
//                       child: Column(
//                         children: [
//                           Expanded(child: UsersDuelist()),
//                         ],
//                       ),
//                     ),
//                     Center(
//                       child: Column(
//                         children: [
//                           Expanded(child: Userslist()),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget Userslist() {
//   return Expanded(
//     child: ListView.builder(
//       itemCount: lendAmountRemainders.length,
//       itemBuilder: (context, index) {
//         var data = lendAmountRemainders[index];

//         return ListTile(
//           leading: CircleAvatar(
//               backgroundColor: Colorcodes.budgetLightGreen,
//               child: ProfileImage(
//                   url: data['Avatar'] ?? 'assets/avatar/menp4.svg')),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     data["userName"] ?? "Unknown User",
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: AppColors.accentColor),
//                   ),
//                   // Text(
//                   //   DateFormat('dd MMM yyyy hh:mm a')
//                   //       .format(DateTime.parse(data["createdAt"])),
//                   //   style: FontManager().getTextStyle(context,
//                   //       lWeight: FontWeight.w300,
//                   //       fontSize: 8,
//                   //       color: AppColors.accentColor),
//                   // ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Text(
//                     data["name"] ?? "Untagged",
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.bold,
//                         fontSize: 12,
//                         color: AppColors.accentColor),
//                   ),
//                   SizedBox(width: 10),
//                   Text(
//                     '${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(data["amount"])}',
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.bold,
//                         fontSize: 12,
//                         color: Colors.green),
//                   )
//                 ],
//               ),
//             ],
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               InkWell(
//                 onTap: () {
//                   sendNotificationsToDevice(data['_id'], context,
//                       "You Need To Pay Lend To ${userName.value} of ${data['amount'] ?? "0000"}");
//                   // print(currentId.value);
//                 },
//                 child: Text(
//                   (data["billApproved"] ?? true)
//                       ? "Remind now"
//                       : "Didn't approve",
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 13,
//                       color: AppColors.primaryColor),
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 DateFormat('dd MMM yyyy hh:mm a')
//                     .format(DateTime.parse(data["createdAt"])),
//                 style: FontManager().getTextStyle(context,
//                     lWeight: FontWeight.w300, fontSize: 8, color: Colors.green),
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }
// //

// Widget UsersDuelist() {
//   print("Entering UsersDuelist");
//   print("dueAmountRemainders length: ${dueAmountRemainders.length }");

//   // Check if dueAmountRemainders is not null before using its length
//   final itemCount = dueAmountRemainders?.length ?? 0;

//   return ListView.builder(
//     itemCount: itemCount,
//     itemBuilder: (context, index) {
//       if (itemCount == 0) {
//         // If there are no items, show a message
//         return Center(child: Text('No payable dues found.'));
//       }

//       var data2 = dueAmountRemainders[index];
//       //print("data for item $index: $data2");

//       return ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colorcodes.budgetLightGreen,
//           child: ProfileImage(url: data2['Avatar'] ?? 'assets/avatar/menp4.svg'),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   data2["userName"] ?? "Unknown User",
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: AppColors.accentColor),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Text(
//                   data2["name"] ?? "Untagged",
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 12,
//                       color: AppColors.accentColor),
//                 ),
//                 SizedBox(width: 10),
//                 Text(
//                   '${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(data2["amount"] ?? 0)}',
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 12,
//                       color: Colors.green),
//                 )
//               ],
//             ),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             InkWell(
//               onTap: () {
//                 sendNotificationsToDevice(data2['_id'], context,
//                    "You have successfully paid your bill of ${data2['amount'] ?? "0000"} to ${userName.value}."
// );
//               },
//               child: Text(
//                 (data2["billApproved"] ?? true) ? "Settle now" : "Didn't settle",
//                 style: FontManager().getTextStyle(context,
//                     lWeight: FontWeight.bold,
//                     fontSize: 13,
//                     color: AppColors.primaryColor),
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               DateFormat('dd MMM yyyy hh:mm a').format(DateTime.parse(data2["createdAt"] ?? DateTime.now().toIso8601String())),
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.w300, fontSize: 8, color: Colors.green),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/userAvatar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserListScreen extends StatefulWidget {
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    getUserLend(context);
    getRemainders(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payable overview',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.accentColor),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowAllUsersScreen(),
                    ),
                  );
                },
                child: Text('more',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.primaryColor)),
              ),
            ],
          ),
        ),
        Obx(() => getlendUsers.value ? getUser() : getUser())
      ],
    );
  }

  Widget getUser() {
    return Visibility(
      visible: lendAmountRemainders.isNotEmpty,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: lendAmountRemainders
              .take(2)
              .map((data) => _buildListTile(context, data, false))
              .toList(),
        ),
      ),
    );
  }
}

// Screen showing all users
class ShowAllUsersScreen extends StatelessWidget {
  const ShowAllUsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Payable overview',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.accentColor)),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TabBar(
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.bg1,
                tabs: const [Tab(text: 'Payable'), Tab(text: 'Owed')],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.609,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
                child: TabBarView(
                  children: [
                    Center(child: usersDuelist()),
                    Center(child: userslist()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget userslist() {
  return ListView.builder(
    itemCount: lendAmountRemainders.length,
    itemBuilder: (context, index) =>
        _buildListTile(context, lendAmountRemainders[index], false),
  );
}

Widget usersDuelist() {
  final itemCount = dueAmountRemainders?.length ?? 0;

  return ListView.builder(
    itemCount: itemCount,
    itemBuilder: (context, index) {
      if (itemCount == 0) {
        return Center(child: Text('No payable dues found.'));
      }
      return _buildListTile(context, dueAmountRemainders[index], true);
    },
  );
}

// Reusable method to build ListTile for both Userslist and UsersDuelist
Widget _buildListTile(
    BuildContext context, Map<String, dynamic> data, bool isDue) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colorcodes.budgetLightGreen,
      child: UserAvatar(url: data['Avatar'] ?? 'assets/avatar/menp4.svg',width: 1,height: 1,),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data["userName"] ?? "Unknown User",
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.accentColor),
            ),
          ],
        ),
        Row(
         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                data["name"] ?? "Untagged",
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 10,
                    color: AppColors.accentColor),
              ),
            ),
            SizedBox(width: 10),
            Text(
              '${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(data["amount"] ?? 0)}',
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
            )
          ],
        ),
      ],
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            sendNotificationsToDevice(
                data['_id'],
                context,
                isDue
                    ? "You have successfully paid your bill of ${data['amount'] ?? "0000"} to ${userName.value}."
                    : "You need to pay lend To ${userName.value} of ${data['amount'] ?? "0000"}");
          },
          child: Text(
            (data["billApproved"] ?? true)
                ? (isDue ? "Settle now" : "Remind now")
                : (isDue ? "Didn't settle" : "Didn't approve"),
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.primaryColor),
          ),
        ),
        SizedBox(height: 10),
        Text(
          DateFormat('dd MMM yyyy hh:mm a').format(DateTime.parse(
              data["createdAt"] ?? DateTime.now().toIso8601String())),
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w300, fontSize: 8, color: Colors.green),
        ),
      ],
    ),
  );
}
