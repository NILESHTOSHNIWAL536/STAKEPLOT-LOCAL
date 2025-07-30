import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:get/get.dart';

import '../../controllers/user-controller.dart';

void callApi(context)async
  {
    await Get.find<UserController>().fetchUserInfo();
    getBankAccounts();
    getPost(context);
    getTranding(context);
    getAck();
    getBudget();
    contextGlobal=context;
    setUpSocketListenerMainPage(context);
    getUserLend(context);
    getBudget();
    getHiddenTransactions(context);
    getCategoryData();
    getNotifications(context);
    getAllAutoTransactions();
    getAllContstant(context);
    getGroupTransactions();
    getCustomCategory(context);
    getAutoPayInfo();
    custom = getthelist();
    allOrGroupTransactionsName.value = StringConstant.allTransactions;
    clearAllFlags();
    await getRemainders(context);
    await updateWidget();
    lifecycleHandler = AppLifecycleHandler(userController.userId.value); // Replace with actual user ID
    WidgetsBinding.instance.addObserver(lifecycleHandler);
  }


    void initializeData(context,mounted)   
  {
    isLoginAlreadLogin(context,mounted);
    oneSignalAddClickListener(context);
    sectionReached.value=false;
  }
  
  void isLoginAlreadLogin(context,mounted)async{
       bool isHome=await check(context, "homeScreen");
       if(isHome)
       {
          await requestNotificationPermissionOncePerDay();
          if (!mounted) return;
          callApi(context);
       }
  }

  