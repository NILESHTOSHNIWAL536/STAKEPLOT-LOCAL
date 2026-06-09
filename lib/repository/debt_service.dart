
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';


Future<void> calculateInflation() async {
  try {
    isLoadingInflation.value = true;
    var body = {
      'amount': originalAmount.value,
      'years_ahead': inflatedYears.value,
    };

    var response=await postDataApiCall(UserRoutes.inflation,body);

    if (getFlagOfResponse(response))
    {
      final data = jsonDecode(response.body);
      if (data.containsKey('final_future_value') &&
          data.containsKey('predictions')) {
        inflatedFutureValue.value =
            data['final_future_value']?.toDouble() ?? 0.0;
        inflationPredictions.value =
            List<Map<String, dynamic>>.from(data['predictions'] ?? []);
        showResults.value = true;
      } else {}
    } else {}
  } catch (e) {
  } finally {
    isLoadingInflation.value = false;
  }
}
