class BudgetModel {
  final List<dynamic> transactions;
  final List<Map<String, dynamic>> categorySpendings;
  final List<Map<String, dynamic>> pieGraphData;
  final List<String> insights;

  BudgetModel({
    required this.transactions,
    required this.categorySpendings,
    required this.pieGraphData,
    required this.insights,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final finalResult = data['finalResult'] ?? {};

    final categorySpendings =
        List<Map<String, dynamic>>.from(data['categoryWiseSpendings'] ?? []);

    return BudgetModel(
      transactions: finalResult['transactions'] ??
          data['transactions'] ??
          [],

      categorySpendings: categorySpendings,

      pieGraphData: categorySpendings.map((item) {
        return {
          'title':
              '${item['category']} ${(item['percentage'] ?? 0).toString()}%',
          'value': (item['spending'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList(),

      insights: List<String>.from(data['data'] ?? []),
    );
  }
}