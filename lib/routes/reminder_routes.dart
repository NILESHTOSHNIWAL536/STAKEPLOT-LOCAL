import '../backed_connections/apis_connect.dart';
import 'index_route.dart';

class ReminderRoutes {
  static final String _urlPath = "${API.mainBackendUrl}/reminders";

  static String sendNotificationToDevice =
      "$_urlPath/sendNotifications/ToDevice";

  static String sendSettleNotification =
      "$_urlPath/send-settle-notification";

  static String getReminders = "$_urlPath/";

  static String getFoodieFunds(String id) =>
      "$_urlPath/$id";

  static String settleReminder({
    required String type,
    required String id,
  }) =>
      "$_urlPath/settle/$type/$id";

  static String requestApproval({
    required String type,
    required String id,
  }) =>
      "$_urlPath/request-approval/$type/$id";

  static String declineRequest({
    required String type,
    required String id,
  }) =>
      "$_urlPath/decline-request/$type/$id";
}
