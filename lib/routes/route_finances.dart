import '../backed_connections/apis_connect.dart';

class BudgetRoutes {
  static final String _urlPath = "$url/budget";

  // ➕ Create a new budget
  static String createBudget = "$_urlPath/";

  // ✏️ Edit an existing budget
  static String editBudget({required String id}) => "$_urlPath/edit/$id";

  // 📊 Get budgets for all categories
  static String getBudgetForCategories = "$_urlPath/budget-for-categories";

  // 📋 Get all budgets
  static String getAllBudgets = "$_urlPath/";

  // 🔍 Get budget by ID
  static String getBudgetById({required String bid}) => "$_urlPath/$bid";

  // 💸 Get budget spents by budget ID
  static String getBudgetSpents({required String bid}) =>
      "$_urlPath/get-budget-spents/$bid";

  // 📈 Get budget insights by budget ID
  static String getInsights({required String bid}) =>
      "$_urlPath/get-insights/$bid";

  // 🗑️ Delete a budget by ID
  static String deleteBudget({required String bid}) => "$_urlPath/$bid";
}