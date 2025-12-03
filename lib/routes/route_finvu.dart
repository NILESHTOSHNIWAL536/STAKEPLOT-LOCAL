import 'index_route.dart';

class FinvuRoutes
{
  static final String _urlPath = "${API.BankApiUrl}/finvu";

  // Login and get handle ID
  static String login = "$_urlPath/login";

  // Fetch transactions
  static String fetchData = "$_urlPath/fetchData";

  // Add Finvu data
  static String addFinvuData = "$_urlPath/add";

  // Fetch weekly transactions
  static String fetchWeekly = "$_urlPath/fetchWeekly";

  // Get all latest FIPS metrics
  static String getFipsMetric = "$_urlPath/fipsmetric";

  // Get status by ID
  static String getStatus({required String id}) => "$_urlPath/status/$id";

  // Get FIPS details
  static String getFipDetails = "$_urlPath/fip-details";
}
