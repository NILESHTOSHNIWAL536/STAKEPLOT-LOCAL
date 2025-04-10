import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class MultipleLogins extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const MultipleLogins({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return userProfileListTitle(
                  context,
                  users[index]['avatar'],
                  users[index]['userName'],
                  users[index]['token'],
                );
              },
            ),
          ),
          getButton(context, "Switch Account"),
        ],
      ),
    );
  }

  Widget userProfileListTitle(BuildContext context, String avatar, String name,String token) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: ()async{
          final SharedPreferences _pref = await SharedPreferences.getInstance();
          await _pref.remove("accessToken");
          clearGetX();
          _pref.setString("accessToken", token);
          Navigator.pop(context);
          Navigator.pushNamed(context, "/home");
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          child: ListTile(
            leading: Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 6,
              child: Center(
                child: AvatarProfileImage(url: avatar, width: 1, height: 1),
              ),
            ),
            title: textStyle(context: context, text: name, fontsize: 14),
            trailing: const Icon(
              Icons.logout_rounded,
              size: 30,
              color: AppColors.bg1,
            ),
          ),
        ),
      ),
    );
  }
}




class UserStorage {
  static const String userKey = "users";

  /// Store user details by ID
  static Future<void> storeUserDetails(String id, String userName, String avatar, String token) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Retrieve existing users map
    Map<String, dynamic> users = {};
    String? usersJson = prefs.getString(userKey);
    if (usersJson != null) {
      users = jsonDecode(usersJson);
    }
    
    // Add or update user data
    users[id] = {
      "userName": userName,
      "avatar": avatar,
      "token": token
    };

    // Save back to SharedPreferences
    await prefs.setString(userKey, jsonEncode(users));
  }

  /// Retrieve user details based on ID
  static Future<Map<String, dynamic>?> getUserDetails(String id) async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(userKey);
    
    if (usersJson != null) 
    {
      Map<String, dynamic> users = jsonDecode(usersJson);
      return users[id]; // Return user data if found
    }
    return null; // Return null if no data found
  }

  /// Retrieve all stored user IDs
  static Future<List<String>> getAllUserIds() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(userKey);
    
    if (usersJson != null) {
      Map<String, dynamic> users = jsonDecode(usersJson);
      return users.keys.toList(); // Return all stored user IDs
    }
    return [];
  }

   static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(userKey);
    
    if (usersJson != null) {
      Map<String, dynamic> users = jsonDecode(usersJson);
      return users.entries.map((e) {
        return {
          "_id": e.key,
          "userName": e.value["userName"],
          "avatar": e.value["avatar"],
          "token": e.value["token"],
        };
      }).toList();
    }
    return [];
  }
  
}
