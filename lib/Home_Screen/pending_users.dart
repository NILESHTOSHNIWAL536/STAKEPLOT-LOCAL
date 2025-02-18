import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:get/get.dart';
import './colors.dart';
import 'package:intl/intl.dart';

class UserListScreen extends StatefulWidget {
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    getUserLend(context);
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
                'Dues to receive',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.accentColor),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the "Show All Users" page
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
        Obx(() => getlendUsers.value ? getUser() : getUser()),
      ],
    );
  }

//    Widget getUser() {
//   return Container(
//     width: MediaQuery.of(context).size.width / 1.1,
//     height: MediaQuery.of(context).size.height / 4.5,
//     child: Column(
//       children: List.generate(
//         lendAmountRemainders.length <= 3 ? lendAmountRemainders.length : 3,
//         (index) {
//           var data = lendAmountRemainders[index];
//           return ListTile(
//             leading: CircleAvatar(
//                 backgroundColor: Colorcodes.budgetLightGreen,
//                 child: ProfileImage(
//                     url: data['Avatar'] ?? 'assets/avatar/menp4.svg')),
//             title: Text(
//               data["userName"] ?? "Unknown User",
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: AppColors.accentColor),
//             ),
//             trailing: InkWell(
//               onTap: () {
//                 print(data);
//                 sendNotificationsToDevice(data['_id'], context,
//                     "You need to pay lend To ${userName.value} of ${data['amount'] ?? "0000"}");
//               },
//               child: Text(
//                 (data["billApproved"] ?? true)
//                     ? "Remind now"
//                     : "Didn't approve",
//                 style: FontManager().getTextStyle(context,
//                     lWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: AppColors.primaryColor),
//               ),
//             ),
//           );
//         },
//       ),
//     ),
//   );
// }
  Widget getUser() {
    return Visibility(
      visible: lendAmountRemainders
          .isNotEmpty, // Show only if there are pending dues
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: lendAmountRemainders
              .take(2) // Show up to 3 users
              .map((data) => ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colorcodes.budgetLightGreen,
                        child: ProfileImage(
                            url: data['Avatar'] ?? 'assets/avatar/menp4.svg')),
                    title: Text(
                      data["userName"] ?? "Unknown User",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.accentColor),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        sendNotificationsToDevice(data['_id'], context,
                            "You need to pay lend To ${userName.value} of ${data['amount'] ?? "0000"}");
                      },
                      child: Text(
                        (data["billApproved"] ?? true)
                            ? "Remind now"
                            : "Didn't approve",
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryColor),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// Screen showing all users
class ShowAllUsersScreen extends StatelessWidget {
  const ShowAllUsersScreen({
    Key? key,
  }) : super(key: key);

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
        length: 2, // Number of tabs
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: DecoratedBox(
                decoration: const BoxDecoration(),
                child: TabBar(
                  indicator: BoxDecoration(
                    // Rounded corners

                    color: AppColors.tab,

                    borderRadius: BorderRadius.circular(16),
                  ),
                  // Padding for labels
                  labelColor:
                      AppColors.primaryColor, // Text color for selected tab
                  unselectedLabelColor:
                      AppColors.bg1, // Text color for unselected tabs

                  tabs: const [
                    Tab(child: Text('Payable')),
                    Tab(text: 'Owed'),
                    // Tab(text: 'Exploria'),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height /
                  1.609, // Adjust as needed for TabBarView
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
                child: TabBarView(
                  children: [
                    Center(child: Userslist()),
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

Widget Userslist() {
  return Expanded(
    child: ListView.builder(
      itemCount: lendAmountRemainders.length,
      itemBuilder: (context, index) {
        var data = lendAmountRemainders[index];
        print("data mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm");
        print(data);
        return ListTile(
          leading: CircleAvatar(
              backgroundColor: Colorcodes.budgetLightGreen,
              child: ProfileImage(
                  url: data['Avatar'] ?? 'assets/avatar/menp4.svg')),
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
                  Text(
                    DateFormat('dd MMM yyyy hh:mm a')
                        .format(DateTime.parse(data["createdAt"])),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w300,
                        fontSize: 8,
                        color: AppColors.accentColor),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    data["name"] ?? "Untagged",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.accentColor),
                  ),
                  Text(
  '₹${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(data["amount"])}',
  style: FontManager().getTextStyle(context,
      lWeight: FontWeight.bold,
      fontSize: 12,
      color: AppColors.accentColor),
)
                ],
              ),
            ],
          ),
          trailing: InkWell(
            onTap: () {
              sendNotificationsToDevice(data['_id'], context,
                  "You Need To Pay Lend To ${userName.value} of ${data['amount'] ?? "0000"}");
              // print(currentId.value);
            },
            child: Text(
              (data["billApproved"] ?? true) ? "Remind now" : "Didn't approve",
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primaryColor),
            ),
          ),
        );
      },
    ),
  );
}
//
