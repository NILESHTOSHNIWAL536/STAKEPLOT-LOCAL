
import 'index_route.dart';

class RewardRoutes {
  static final String _urlPath = "${API.mainBackendUrl}/reward";
  static final String reward = "${API.mainBackendUrl}/reward";

  static String claimCoupon({
    required String couponId,
    required String category,
  }) =>
      "$_urlPath/claim/$couponId/$category";

  static String couponRequest = "$_urlPath/coupon-request";

  static String couponRequestNotification(String userId) =>
      "$_urlPath/coupon-request-notification/$userId";

  static String incrementViewCount({
    required String type,
    required String couponId,
  }) =>
      "$_urlPath/coupon-view-increment/$type/$couponId";

  static String searchByCategory(String category) =>
      "$_urlPath/search/$category";

  static String getClaimedCoupons = "$_urlPath/";

  static String couponsCount = "$_urlPath/iscoupons/count";

  static String getUserActivity = "$_urlPath/getUserActivity";

  static String getBrandsByCategory(String category) =>
      "$_urlPath/$category";
}
