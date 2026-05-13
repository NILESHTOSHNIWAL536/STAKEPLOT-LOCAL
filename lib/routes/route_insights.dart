import 'index_route.dart';

class InsightRoutes {
  static final String _urlPath = "${API.BankApiUrl}/insights";

  static String catalog = "$_urlPath/catalog";
  static String summary = "$_urlPath/summary";
  static String categories = "$_urlPath/categories";
  static String merchants = "$_urlPath/merchants";
  static String timePatterns = "$_urlPath/time-patterns";
  static String paymentModes = "$_urlPath/payment-modes";
  static String cashVsBank = "$_urlPath/cash-vs-bank";
  static String recurring = "$_urlPath/recurring";
  static String anomalies = "$_urlPath/anomalies";
  static String actionItems = "$_urlPath/action-items";
  static String dailyTrend = "$_urlPath/daily-trend";
  static String largestTransactions = "$_urlPath/largest-transactions";
  static String balanceTrend = "$_urlPath/balance-trend";
  static String spendVelocity = "$_urlPath/spend-velocity";
  static String categoryHealth = "$_urlPath/category-health";
  static String incomeSources = "$_urlPath/income-sources";
  static String upcomingExpensePrediction =
      "$_urlPath/upcoming-expense-prediction";

  static String withQuery(
    String url, {
    int days = 60,
    int limit = 10,
  }) {
    return Uri.parse(url).replace(queryParameters: {
      "days": days.toString(),
      "limit": limit.toString(),
    }).toString();
  }
}
