
// import 'package:get/get.dart';

// // import '../backed_connections/apis_connect.dart';
// import '../repository/finora_repository.dart';
// import '../routes/route_transactions.dart';

// class FinoraController extends GetxController {

//   /// ---------------- STATE ----------------

//   final isLoading = false.obs;

//   final selectedPeriod = 'Month'.obs;

//   final frequentPayments = <Map<String, dynamic>>[].obs;
//   final moreDrasticChange = <Map<String, dynamic>>[].obs;
//   final moreDrasticChangeWeek = <Map<String, dynamic>>[].obs;

//   final totalDebitThisMonth = 0.0.obs;
// RxList categoriesList = [].obs;

// RxDouble totalDebitThisWeek = 0.0.obs;
// RxList categoriesListWeek = [].obs;

// RxList frequentPaymentsWeek = [].obs;
// RxList mostSpentCategoryInMonth = [].obs;
// RxList mostSpentDayInMonth = [].obs;
// RxList weeklyTrend = [].obs;
// final isFinoraVisible = false.obs;
// RxBool setDonectChat = false.obs;

//   /// ---------------- LIFECYCLE ----------------

 
//   void togglePeriod() {
//     selectedPeriod.value =
//         selectedPeriod.value == "Month" ? "Week" : "Month";
//   }

//   List<Map<String, dynamic>> get drasticList =>
//       selectedPeriod.value == "Month"
//           ? moreDrasticChange
//           : moreDrasticChangeWeek;

//   /// ---------------- API ----------------

 
// }

