import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/coupons/envelope_grid.dart';
import 'package:flutter_application_code_stakeplot/coupons/rewards_overview.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/model/user_activity_model.dart';
import 'package:get/get.dart';
import '../apiAutomations/curd.dart';
import '../apis_connect.dart';
import 'package:url_launcher/url_launcher.dart';

RxBool loadReaward = false.obs;
RxBool refreshCupon = false.obs;
RxBool couponAvalible = true.obs;
RxList<CouponModel> claimedCoupons = <CouponModel>[].obs;
RxList<CouponModel> categoryCoupons = <CouponModel>[].obs;

Future<void> fetchCouponsCounts() async {
  try {
    final response = await getDataApiCall('$url/reward/iscoupons/count');

    if (getFlagOfResponse(response)) {
      var json = jsonDecode(response.body);
      couponAvalible.value = json['data'] > 0;
    }
  } catch (e) {
    // Handle error silently as per your code
  } finally {
    loadReaward.value = false;
  }
}

Future<void> fetchCategoryCoupons(String category) async {
  print("no");
  try {
    print("yes");
    loadReaward.value = true;
    // Trim spaces and replace with no spaces
    final formattedCategory = category.trim();
    categorySelected.value = formattedCategory;
  print("formattedCategory $formattedCategory");
    final response =
        await getDataApiCall('$url/reward/search/$formattedCategory');
    print("response tap ${response.body}");

    if (getFlagOfResponse(response)) {
      final List<dynamic> data = jsonDecode(response.body)['data'];

      categoryCoupons.assignAll(CouponModel.listFromJson(data));
    }
  } catch (e) {
    // Handle error silently as per your code
  } finally {
    loadReaward.value = false;
  }
}

// this is to fetch claimed coupons
Future<void> fetchClaimedCoupons() async {
  try {
    loadReaward.value = true;

    final response = await getDataApiCall('$url/reward/');

    if (getFlagOfResponse(response)) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      claimedCoupons.clear();
      claimedCoupons.addAll(CouponModel.listFromJson(data));
      claimedCoupons.refresh();
      refreshCupon.value = !refreshCupon.value;
    }
  } catch (e) {
  } finally {
    loadReaward.value = false;
  }
}

// this is for claiming coupons
Future<void> claimCoupon(
    BuildContext context, String id, widget, CouponModel coupon) async {
  try {
    var body = {"category": categorySelected.value};
    claimedCoupons.add(coupon);
    userController.coupons.value--;
    refreshCupon.value = !refreshCupon.value;
    var response = await updateDataApiCall2('$url/reward/claim/${id}', body);
    if (getFlagOfResponse(response)) {
      widget.onClaim();
    }
  } catch (e) {
    // Handle error silently as per your code
  }
  getUserActity();
}

void redirectToUrl(BuildContext context, String path) async {
  String urlString = path.trim();
  if (urlString.isEmpty) {
    snackBarCalledfail(context, "No link provided");
    return;
  }

  try {
    final uri = Uri.tryParse(urlString);

    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      snackBarCalledfail(context, "Invalid or unsupported URL: $urlString");
    }
  } catch (e) {
    snackBarCalledfail(context, "Error: ${e.toString()}"); // Show in snackbar
  }
}

void callRewardApis(context) {
  fetchCouponsCounts();
  dialofBoxContext = context;
  CouponPopupUtils.showCouponPopup(context, (category) {
    fetchCategoryCoupons(category);
    CouponPopupUtils.showCouponSelectionPopup(context, category);
  });
}

void updateClickOrViewCount({required String type, required String id}) async {
  String urlPath = url + "/reward/coupon-view-increment/${type}/${id}";
  await updateDataApiCall(urlPath);
}

void getUserActity() async {
  try {
    String urlPath = url + "/reward/getUserActivity/";
    var response = await getDataApiCall(urlPath);
    if (getFlagOfResponse(response)) {
      var data = jsonDecode(response.body);
      userActivity = UserActivity.fromJson(data['data']);
    }
  } catch (e) {}
}

Future<void> getCouponRequestCheck(String category) async {
  try {
    var response = await getDataApiCall("${url}/reward/$category");
    print("response ${response.body}");

    if (getFlagOfResponse(response)) {
      var couponCall = jsonDecode(response.body);

      couponRequestMap[category] = couponCall['data']['data'] ?? [];
    } else {
      couponRequestMap[category] = [];
    }
  } catch (e) {
    couponRequestMap[category] = [];
  }
}

Future<void> requestCoupon(
    BuildContext context, String category, String brand) async {
  try {
    var response = await postDataApiCall(
      "${url}/reward/coupon-request",
      {"brand": brand, "category": category},
    );

    if (getFlagOfResponse(response)) {
      // Refresh request status
      await getCouponRequestCheck(category);
      // Show success snackbar
      snackBarCalled(context, "Coupon request submitted for $category");
    } else {
      snackBarCalledfail(context, "Failed to request coupon for $category");
    }
  } catch (e) {
    snackBarCalledfail(context, "Error requesting coupon");
  }
}
