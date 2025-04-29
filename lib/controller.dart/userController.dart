import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  var userId = ''.obs;
  var userName = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var currency = 'INR'.obs;
  var avatar = ''.obs;
  var aboutMe = ''.obs;
  var score = 0.obs;
  var coins = 0.obs;
  var expenses = 0.obs;
  var isBankAccountLinked = false.obs;
  var income = 0.obs;
  
  var likedPosts = <String>[].obs;
  var likedComments = <String>[].obs;
  var likedProducts = <String>[].obs;
  var friendsList = <Map<String, dynamic>>[].obs;
  var friendsListDetails = {}.obs;

  Future<void> fetchUserInfo() async {
    try {
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      var accessToken = _pref.getString("accessToken");
      if (accessToken == null) return;

      final response = await http.get(
        Uri.parse('${url}/user/info'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        var his = jsonDecode(response.body);
        var obj = his['data'];

        likedPosts.assignAll(List<String>.from(obj["likedPosts"] ?? []));
        likedComments.assignAll(List<String>.from(obj["likedComments"] ?? []));
        likedProducts.assignAll(List<String>.from(obj["likedProducts"] ?? []));

        friendsList.assignAll(List<Map<String, dynamic>>.from(obj['friendsList'] ?? []));
        aboutMe.value = obj['aboutMe'] ?? "Hello";
        userId.value = obj['_id'];
        avatar.value = obj['avatarType'] ?? "assets/avatar/menp1.svg";
        userName.value = obj['name'];
        email.value = obj['email'];
        phone.value = obj['phone'];
        currency.value = obj['currency'] ?? "INR";
        score.value = obj['score'] ?? 0;
        coins.value = obj['coins'] ?? 10;
        expenses.value = obj['expense'] ?? 0;
        isBankAccountLinked.value = obj['isBankAccountLinked'] ?? false;

        income.value = 0;
        List accounts = obj['accounts'] ?? [];
        for (var account in accounts) {
          income.value += int.parse(account['income'].toString());
        }

        friendsListDetails.clear();
        for (var friend in friendsList) {
          friendsListDetails[friend['_id']] = {
            'name': friend['name'],
            'avatar': friend['avatar'],
          };
        }
      }
    } catch (e) {
     
    }
  }
}
