import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/userAvatar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserListScreen extends StatefulWidget {
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    //getUserLend(context);
    getRemainders(context);

    //duesPaid(context,index);
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
                
                child: Container(
                height: 30,
                width: MediaQuery.sizeOf(context).width * 0.12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                       AppColors.button
                      
                ),
                child: Center(
                  child: Text(
                    'more',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.primaryColor),
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
        Obx(() => !getlendUsers.value ? getUser() : getUser2())
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

  Widget getUser2() {
    return Visibility(
      visible: dueAmountRemainders.isNotEmpty,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: dueAmountRemainders
              .take(2)
              .map((data) => _buildListTile(context, data, true))
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
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.24,
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
            ),
          ],
        ),
      ),
    );
  }
}

Widget userslist() {
  return Obx(() => ListView.builder(
        itemCount: lendAmountRemainders.length,
        itemBuilder: (context, index) =>
            _buildListTile(context, lendAmountRemainders[index], false),
      ));
}

Widget usersDuelist() {
  return Obx(() {
    final itemCount = dueAmountRemainders.length;
    if (itemCount == 0) {
      return const Center(child: Text('No payable dues found.'));
    }
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _buildListTile(context, dueAmountRemainders[index], true);
      },
    );
  });
}

// Reusable method to build ListTile for both Userslist and UsersDuelist
Widget _buildListTile(
    BuildContext context, Map<String, dynamic> data, bool isDue) {
 
  return ListTile(
    leading: Container(
      height: MediaQuery.of(context).size.height/15,
      width: MediaQuery.of(context).size.width/7,
      child: UserAvatar(
        url:  data['avatarType'] ?? 'assets/avatar/menp4.svg',
        width: 1,
        height: 1,
      ),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
            (  !isDue ? data["name"] : data["name"]) ?? data['userName'] ?? "",
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
                data["category"] ?? "Untagged",
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
            if (isDue) {
              int index = dueAmountRemainders.indexWhere((element) => element['_id'] == data['_id']);
              if (index != -1) {
                duesPaid(context, index);
              }
            }
            sendNotificationsToDevice(
                data['_id'],
                context,
                isDue
                    ? "Successfully paid your bill of ${data['amount'] ?? "0000"} to ${userName.value}."
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
          formatDateTime(data["createdAt"]),
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w300, fontSize: 8, color: Colors.green),
        )
        
      ],
    ),
  );
}

String formatDateTime(String dateString) {
  DateTime dateTime = DateTime.parse(dateString).toLocal();
  // print("dateString");
  // print(dateString);
  String formattedDate = DateFormat("dd MMM yyyy hh:mm a").format(dateTime);
  //print(formattedDate);
  return formattedDate;
}

Future<String?> getToken() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");

  if (accessToken == null) {
    return null;
  } else {
    return accessToken;
  }
}

Future<http.Response> updateDataApiCall(String url) async {
  try {
    var accessToken = await getToken();
    final response = await http.patch(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    return response;
  } catch (error) {
    //  print("Error in updateDataApiCall: $error");
    rethrow;
  }
}

void duesPaid(BuildContext context, int index) async {
  final due = dueAmountRemainders[index];
  final dueId = due['_id']?.toString();
  final type = due['type'];

  if (dueId == null) {
    //  print("Error: Transaction ID is null");
    return;
  }

  final apiUrl = "$url/reminders/settle/$type/$dueId";
  try {
    final response = await updateDataApiCall(apiUrl);
    if (response.statusCode == 200) {
      // Remove the item from the observable list
      dueAmountRemainders.removeAt(index);
      // This triggers the UI update automatically
      snackBarCalled(context, "Due settled successfully");
    } else {
      //  print("Failed to settle due: ${response.statusCode} - ${response.body}");

      snackBarCalled(context,
          "Failed to settle due: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    snackBarCalled(context, "Error settling due");
    // print("Error in duesPaid: $e");
  }
}
