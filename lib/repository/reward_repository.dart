import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/coupons/envelope_grid.dart';
import 'package:flutter_application_code_stakeplot/coupons/rewards_overview.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:flutter_application_code_stakeplot/model/user_activity_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_reward.dart';
import 'package:get/get.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../backed_connections/apis_connect.dart';
import 'package:url_launcher/url_launcher.dart';
// reward.dart (or backed_connections/reward.dart — file that contains callRewardApis)
import 'package:flutter_application_code_stakeplot/main.dart' show navigatorKey;

RxBool loadReaward = false.obs;
RxBool refreshCupon = false.obs;
RxBool couponAvalible = true.obs;
RxList<CouponModel> claimedCoupons = <CouponModel>[].obs;
RxList<CouponModel> categoryCoupons = <CouponModel>[].obs;

Future<void> fetchCouponsCounts() async {
  try {
    couponAvalible.value = true;
    final response = await getDataApiCall(RewardRoutes.couponsCount);
  
    if (getFlagOfResponse(response)) {
      var json = jsonDecode(response.body);
      couponAvalible.value = json['data'] > 0;
    }
  } 
  catch (e) {

  } finally {
    loadReaward.value = false;
  }
}

Future<void> fetchCategoryCoupons(String category) async {
  try {
    loadReaward.value = true;
    // Trim spaces and replace with no spaces
    final formattedCategory = category.trim();
    categorySelected.value = formattedCategory;

    final response =
        await getDataApiCall(RewardRoutes.searchByCategory(category));

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

    final response = await getDataApiCall(RewardRoutes.reward);
    if (getFlagOfResponse(response)) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      claimedCoupons.clear();
      claimedCoupons.addAll(CouponModel.listFromJson(data));
      // claimedCoupons.refresh();
      refreshCupon.value = !refreshCupon.value;
    }
  } catch (e) {
  } finally {
    loadReaward.value = false;
  }
}

Future<bool> claimCoupon(
    BuildContext context, String id, dynamic widget, CouponModel coupon) async {
  try {
    // var body = {"category": categorySelected.value};

    var response = await updateDataApiCallWithoutBody(RewardRoutes.claimCoupon(couponId: id, category: categorySelected.value));
    if (getFlagOfResponse(response)) {
      claimedCoupons.add(coupon);
      userController.coupons.value--;
      refreshCupon.value = !refreshCupon.value;
      //  widget.onClaim();
      return true; // Indicate success
    } else {
      return false; // Indicate failure
    }
  } catch (e) {
    // Handle error silently and return false
    return false;
  } finally {
    getUserActity(); // Ensure this is called regardless of success or failure
  }
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

void callRewardApis(BuildContext? context) async {
  await fetchCouponsCounts();
  BuildContext? safeContext = navigatorKey.currentContext ?? context;
  if (safeContext == null) {
    return;
  }
  if (MediaQuery.maybeOf(safeContext) == null) {
    return;
  }
  dialofBoxContext = safeContext;
  CouponPopupUtils.showCouponPopup(safeContext, (category) {
    fetchCategoryCoupons(category);
    CouponPopupUtils.showCouponSelectionPopup(safeContext, category);
  });
}

void updateClickOrViewCount({required String type, required String id}) async {
  String urlPath = RewardRoutes.incrementViewCount(type: type, couponId: id);
  await updateDataApiCall(urlPath);
}

void getUserActity() async {
  try {
    String urlPath = RewardRoutes.getUserActivity;
    var response = await getDataApiCall(urlPath);
    if (getFlagOfResponse(response)) {
      var data = jsonDecode(response.body);
      userActivity = UserActivity.fromJson(data['data']);
    }
  } catch (e) {}
}

Future<void> getCouponRequestCheck(String category) async {
  try {
    var response = await getDataApiCall(RewardRoutes.getBrandsByCategory(category));

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
    var response = await postDataApiCall( RewardRoutes.couponRequest,
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
