import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/route_constant.dart';

class RewardScreenStrings {
  static final RewardScreenStrings _instance = RewardScreenStrings._internal();

  // 2. Private constructor
  RewardScreenStrings._internal();

  // 3. Factory constructor
  factory RewardScreenStrings() => _instance;

  RxBool isRewardNeedToShow = false.obs;
  RxInt limitCount = 2.obs;
  RxString productUrl = "https://fishmydeal.com/".obs;
  RxString claimedAll =
      "All the coupons have been redeemed, please hold on while we gather more rewards for you"
          .obs;
  RxString outOfReaward =
      "All the coupons have been redeemed, please hold on while we gather more rewards for you."
          .obs;
  RxList rewardIntroList = [].obs;

  Future<void> fetchConstants() async {
    try {
      final response = await getDataApiCall(ConstantRoutes.rewardIntro);
      String key = "ShowReward";
      if (getFlagOfResponse(response)) {
        final SharedPreferences pref = await SharedPreferences.getInstance();
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};
        rewardIntroList.clear();
        rewardIntroList.addAll(data['slides']);
        productUrl.value = data['productUrl'] ?? productUrl.value;
        limitCount.value = data['limitCount'] ?? limitCount.value;
        claimedAll.value = data['claimedAll'] ?? claimedAll.value;
        outOfReaward.value = data['outOfReaward'] ?? outOfReaward.value;
        isRewardNeedToShow.value = false; //pref.containsKey(key) ? false :   data['showSliders'];
      }
    } catch (e) {}
  }
}
