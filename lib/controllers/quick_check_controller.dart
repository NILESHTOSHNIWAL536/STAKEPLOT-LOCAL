import 'dart:convert';

import 'package:get/get.dart';

import '../backed_connections/apiAutomations/curd.dart';
import '../model/quick_check_model.dart';
import '../routes/route_transactions.dart';

class QuickCheckController extends GetxController {
  final Rxn<QuickCheckModel> quickCheck = Rxn<QuickCheckModel>();
  final RxBool isLoading = false.obs;

  Future<void> getQuickCheck({
    required String view,
    int? month,
    required int year,
  }) async {
    try {
      isLoading.value = true;

      final url = view == 'monthly'
          ? "${BankTransactionRoutes.getQuickCheck}?view=monthly&month=${month ?? DateTime.now().month}&year=$year"
          : "${BankTransactionRoutes.getQuickCheck}?view=yearly&year=$year";

      final response = await getDataApiCall(url);

      if (!getFlagOfResponse(response)) return;

      final data = jsonDecode(response.body)['data'];

      quickCheck.value = QuickCheckModel.fromJson(data);
    } catch (e, st) {
      print(e);
      print(st);
    } finally {
      isLoading.value = false;
    }
  }
}