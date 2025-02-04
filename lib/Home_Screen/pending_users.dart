import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:get/get.dart';
import './colors.dart';

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
        SizedBox(
          height: 10,
        ),
        Obx(() => getlendUsers.value ? getUser() : getUser()),
      ],
    );
  }

  Widget getUser() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 5.0,

      // color: Colorcodes.billHeader,
      child: ListView.builder(
        
        itemCount:
            lendAmountRemainders.length <= 3 ? lendAmountRemainders.length : 3,
        itemBuilder: (context, index) {
          var data = lendAmountRemainders[index];

          return ListTile(
            leading: CircleAvatar(
                backgroundColor: Colorcodes.budgetLightGreen,
                child: ProfileImage(
                    url: data['Avatar'] ?? 'assets/avatar/menp4.svg')),
            title: Text(data["userName"] ?? "Unknown User"),
            trailing: InkWell(
              onTap: () {
                print(data);
                sendNotificationsToDevice(data['_id'], context,
                    "You need to pay lend To ${userName.value} of ${data['amount'] ?? "0000"}");
                // print(currentId.value);
              },
              child: Text(
                (data["billApproved"] ?? true)
                    ? "Remind now"
                    : "Didn't approve",
                style: TextStyle(color: AppColors.primaryColor, fontSize: 15),
              ),
            ),
          );
        },
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
        appBar: AppBar(
          title: Text('Dues to receive',
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.accentColor)),
        ),
        body: Expanded(
          child: ListView.builder(
            itemCount: lendAmountRemainders.length,
            itemBuilder: (context, index) {
              var data = lendAmountRemainders[index];
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colorcodes.budgetLightGreen,
                    child: ProfileImage(
                        url: data['Avatar'] ?? 'assets/avatar/menp4.svg')),
                title: Text(data["userName"] ?? "Unknown User"),
                trailing: InkWell(
                  onTap: () {
                    sendNotificationsToDevice(data['_id'], context,
                        "You Need To Pay Lend To ${userName.value} of ${data['amount'] ?? "0000"}");
                    // print(currentId.value);
                  },
                  child: Text(
                    (data["billApproved"] ?? true)
                        ? "Remind now"
                        : "Didn't approve",
                    style:
                        TextStyle(color: AppColors.primaryColor, fontSize: 15),
                  ),
                ),
              );
            },
          ),
        ));
  }
}

//
