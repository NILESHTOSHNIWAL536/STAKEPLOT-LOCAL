


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/coupons/envelope_grid.dart';
import 'package:flutter_application_code_stakeplot/model/coupon_model.dart';
import 'package:get/get.dart';

import '../apiAutomations/curd.dart';
import '../apis_connect.dart';
import 'package:url_launcher/url_launcher.dart';


RxBool loadReaward=false.obs;
RxBool refreshCupon=false.obs;
RxList<CouponModel> claimedCoupons = <CouponModel>[].obs;
RxList<CouponModel> categoryCoupons = <CouponModel>[].obs;

Future<void> fetchCategoryCoupons(String category) async {
    try {
      loadReaward.value = true;
      // Trim spaces and replace with no spaces
      final formattedCategory = category.trim();
      categorySelected.value=formattedCategory;
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
      }
    } catch (e) {
    } finally {
      loadReaward.value = false;
    }
  }


   Future<void> claimCoupon(BuildContext context,String id,widget,CouponModel coupon) async {
    try {
      var body={
         "category":categorySelected.value
      };
      claimedCoupons.add(coupon);
      userController.coupons.value--;
      refreshCupon.value = !refreshCupon.value;
      var response=await updateDataApiCall2('$url/reward/claim/${id}',body);
      if (getFlagOfResponse(response))
      {
        widget.onClaim(); 
      }
    } catch (e) {
      // Handle error silently as per your code
    }
  }



  void redirectToUrl(BuildContext context,String path)async{
                String urlString = path.trim();
                      if (urlString.isEmpty)
                       {
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