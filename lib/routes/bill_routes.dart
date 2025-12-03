import 'index_route.dart';

class BillRoutes {
  static final String _urlPath = "${API.mainBackendUrl}/bill";

  static String addBill = "$_urlPath/";

  static String acceptBill({
    required String id,
    required String accept,
    required String notificationsId,
  }) =>
      "$_urlPath/acceptBill/$id/$accept/$notificationsId";

  static String getLendBills = "$_urlPath/lend";

  static String getBills = "$_urlPath/";

  static String updateBillStatus(String id) => "$_urlPath/$id";
}
