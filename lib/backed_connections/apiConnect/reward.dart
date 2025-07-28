


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:get/get.dart';

import '../apiAutomations/curd.dart';
import '../apis_connect.dart';

RxBool loadReaward=false.obs;
RxBool refreshCupon=false.obs;
RxList<CouponModel> claimedCoupons = <CouponModel>[].obs;
RxList<CouponModel> categoryCoupons = <CouponModel>[].obs;

Future<void> fetchCategoryCoupons(String category) async {
    try {
      loadReaward.value = true;
      // Trim spaces and replace with no spaces
      final formattedCategory = category.replaceAll(' ', '');
      final response = await getDataApiCall('$url/reward/search/$formattedCategory');

      if (getFlagOfResponse(response))
      {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        categoryCoupons.assignAll(CouponModel.listFromJson(data));

      }

    } catch (e) {
      // Handle error silently as per your code
    } finally {
      loadReaward.value = false;
    }
  }


 Future<void> fetchClaimedCoupons() async {
    try {
      loadReaward.value = true;
      
      final response = await getDataApiCall(
       '$url/reward/'
      );

      if (getFlagOfResponse(response)) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        claimedCoupons.clear();
        claimedCoupons.addAll(CouponModel.listFromJson(data));
        claimedCoupons.refresh();
        refreshCupon.value = !refreshCupon.value;
        // claimedCoupons.assignAll(CouponModel.listFromJson(data));
      }
    } catch (e) {
      // Handle error silently as per your code
    } finally {
      loadReaward.value = false;
    }
  }


   Future<void> claimCoupon(BuildContext context,String id,widget) async {
    try {
      var response=await updateDataApiCall('$url/reward/claim/${id}');
      if (getFlagOfResponse(response)) {
        userController.coupons.value--;
        widget.onClaim(); 
        fetchClaimedCoupons();
      }
    } catch (e) {
      // Handle error silently as per your code
    }
  }