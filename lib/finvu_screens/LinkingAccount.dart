import 'dart:convert';

import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/access.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/verifyOTP.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

RxMap<String, List<FinvuDiscoveredAccountInfo>> listOfAccountAdded =
    <String, List<FinvuDiscoveredAccountInfo>>{}.obs;
RxMap<String, FinvuFIPDetails> FinvuFIPDetailsList =
    <String, FinvuFIPDetails>{}.obs;
RxMap<String, int> accountCountList = <String, int>{}.obs;
RxList accountAdded = [].obs;
RxList accountLinked = [].obs;
RxInt count = 0.obs;
List<FinvuFIPInfo> fipDis = [];
List<FinvuFIPInfo> fipDisOrginal = [];
RxList isSeletedBankAccout = [].obs;
RxMap<String, String> bankImageAndid = RxMap();
RxList<FinvuFIPInfo> listOfBankAccount = <FinvuFIPInfo>[].obs;
// RxBool getBanks=false.obs;
RxBool addBank = false.obs;
RxBool addCheck = false.obs;
List<FinvuLinkedAccountDetailsInfo> fetchAccountData = [];
List<FinvuLinkedAccountDetailsInfo> seletedAccountInfomations = [];
List<String> seletedAccountIds = [];
RxBool getBanks = false.obs;
RxBool addAccount = false.obs;
RxBool getFetch = false.obs;
RxBool directFetch = false.obs;
