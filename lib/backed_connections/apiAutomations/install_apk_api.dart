import 'dart:convert';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import '../../routes/route_user_login.dart';
import '../../services/secure_storage.dart';

Future<void> sendPendingInstallData() async {
  final data = await SecureStorageService().read("installData") ?? {};
  await sendInstallDataToBackend(data);
  await SecureStorageService().delete("installData");
}

Future<void> sendInstallDataToBackend(dataJson) async {
  try {
    final data = jsonDecode(dataJson);
    final response = await postDataApiCall(UserRoutes.addInstallUser, data);
    if (response.statusCode == 200) {
      appLog("✅ Install data sent successfully");
    } else {
      appLog("❌ Failed: ${response.body}");
    }
  } catch (e) {
    appLog("❌ Error sending install data: $e");
  }
}
