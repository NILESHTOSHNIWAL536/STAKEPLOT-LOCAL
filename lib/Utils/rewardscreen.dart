

import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/rewardsplashscreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

class RewardScreenStrings
{

  static final RewardScreenStrings _instance = RewardScreenStrings._internal();

  // 2. Private constructor
  RewardScreenStrings._internal();

  // 3. Factory constructor
  factory RewardScreenStrings() => _instance;

  RxBool isRewardNeedToShow=false.obs;
  RxList rewardIntroList=[].obs;

  void fetchConstants() async {
    try {
      final response = await getDataApiCall("${url}/constant/rewardIntro");
      if (getFlagOfResponse(response)) {
        
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};
        rewardIntroList.clear();
        rewardIntroList.addAll(data['slides']); 
        isRewardNeedToShow.value=data['showSliders'];
      } 
    } catch (e) { 
    }
  }
  
}