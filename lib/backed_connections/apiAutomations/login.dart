
import 'dart:convert';
import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


  // FinvuManager finvuManager = FinvuManager();
  String otpReference = "";
  String displayText = '';
  RxString number="8459177562".obs;//  9347064783
  //double numericValue = double.tryParse(number.value) ?? 0.0;

  String custId="${number.value}@finvu";
  RxString mobileNo="".obs;
  RxString handleId="".obs;
  RxString consentUserId="".obs;
  RxBool fetchedData=false.obs;
  late FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo;
  late List<FinvuLinkedAccountDetailsInfo> finvuLinkedAccountDetailsInfo;
  List<String> fiTypes=[];
 

