import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../backed_connections/apis_connect.dart';

class UserController extends GetxController {
  RxString userId = ''.obs;
  RxString userName = ''.obs;
  RxBool isGoogleUser = false.obs;
  RxList<String> interestedTags = <String>[].obs;
  RxString maskedName = ''.obs;
  RxList maskedConnections = [].obs;
  RxList maskedConnected = [].obs;
  RxBool canMaskMessage = false.obs;
  RxString email = ''.obs;
  RxString dob = ''.obs;
  RxString password = ''.obs;
  RxString phone = ''.obs;
  RxString currency = 'INR'.obs;
  RxInt coins = 0.obs;
  RxString aboutMe = 'Hello'.obs;
  RxString avatar = ''.obs;
  RxString avatarBackGround = ''.obs;
  RxList<String> likedPosts = <String>[].obs;
  RxList<String> likedComments = <String>[].obs;
  RxList<String> likedProducts = <String>[].obs;
  RxInt expense = 0.obs;
  RxBool firstTimeLogin = true.obs;
  RxBool isBankAccountLinked = false.obs;
  RxBool fetchInProgress = false.obs;
  RxString cupertinoPin = ''.obs;
  RxBool cupertinoAttemptCount = false.obs;
  RxString selectedBank = ''.obs;
  RxString firstFetchedDate = ''.obs;

  // Lists of maps
  RxList<PostModel> savedList = <PostModel>[].obs;
  RxSet<String> savedPostIds = <String>{}.obs;

  RxList<PostModel> myPostList = <PostModel>[].obs;
  RxList friendsList = [].obs;
  RxList frdsListOrigin = [].obs;

  // Calculated
  RxInt income = 0.obs;
  var friendsListDetails = {}.obs;

  RxBool isLoading = false.obs;

  Future<void> fetchUserInfo() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null) return;

      final response = await http.get(
        Uri.parse('$url/user/info'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final obj = res['data'];

        userId.value = obj['_id'] ?? '';
        userName.value = obj['name'] ?? '';
        isGoogleUser.value = obj['isGoogleUser'] ?? false;
        maskedName.value = obj['maskedName'] ?? '';
        canMaskMessage.value = obj['canMaskMessage'] ?? false;
        email.value = obj['email'] ?? '';
        dob.value = obj['dob'];
        phone.value = (obj['phone'] is List && obj['phone'].isNotEmpty) ? obj['phone'][0] : '';
        currency.value = obj['currency'] ?? 'INR';
        coins.value = obj['coins'] ?? 0;
        aboutMe.value = obj['aboutMe'] ?? 'Hello';
        avatar.value = obj['avatarType'] ?? 'assets/avatar/menp1.svg';
        avatarBackGround.value = obj['avatarBackGround'] ?? '';
        expense.value = obj['expense'] ?? 0;
        firstTimeLogin.value = obj['firstTimeLogin'] ?? true;
        isBankAccountLinked.value = obj['isBankAccountLinked'] ?? false;
        fetchInProgress.value = obj['fetchInProgress'] ?? false;
        cupertinoPin.value = obj['cupertino_pin'].toString() ;
        cupertinoAttemptCount.value = obj['cupertinoAttemptCount'] != null ? obj['cupertinoAttemptCount'] > 5 : false;
        selectedBank.value = obj['selectedBank'] ?? '';
        firstFetchedDate.value = obj['firstFetchedDate'] ?? '';
        
        interestedTags.assignAll(List<String>.from(obj['interestedTags'] ?? []));
        likedPosts.assignAll(List<String>.from(obj['likedPosts'] ?? []));
        likedComments.assignAll(List<String>.from(obj['likedComments'] ?? []));
        likedProducts.assignAll(List<String>.from(obj['likedProducts'] ?? []));        
        savedPostIds.assignAll(List<String>.from(obj['saved'] ?? []));
        // Friends
        friendsList.assignAll(List<Map<String, dynamic>>.from(obj['friendsList'] ?? []));
        frdsListOrigin.assignAll(List<Map<String, dynamic>>.from(obj['friendsList'] ?? []));
        friendsListDetails.clear();
        for (var friend in friendsList) {
          final id = friend['_id'];
          friendsListDetails[id] = {
            'name': friend['name'] ?? '',
            'avatar': friend['avatar'] ?? '',
            'avatarBackGround': friend['avatarBackGround'] ?? '',
          };
        }

       getMaskendUsers(true);
       getMaskendUsers(false);
       getSaved();
       getuserPost(obj['_id']);
      
      }
    } catch (e)
    {
    } 
    finally {
      isLoading.value = false;
    }
  }
}
