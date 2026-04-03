class FinoraModel {
  final double totalDebitThisMonth;
  final double totalDebitThisWeek;

  final List<Map<String, dynamic>> frequentPayments;
  final List<Map<String, dynamic>> frequentPaymentsWeek;

  final List<Map<String, dynamic>> drasticChanges;
  final List<Map<String, dynamic>> drasticChangesWeek;

  final List<Map<String, dynamic>> categories;

  FinoraModel({
    required this.totalDebitThisMonth,
    required this.totalDebitThisWeek,
    required this.frequentPayments,
    required this.frequentPaymentsWeek,
    required this.drasticChanges,
    required this.drasticChangesWeek,
    required this.categories,
  });

  factory FinoraModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return FinoraModel(
      totalDebitThisMonth:
          double.tryParse(data['totalDebitThisMonth'].toString()) ?? 0.0,

      totalDebitThisWeek:
          double.tryParse(data['week']['totalDebitThisWeek'].toString()) ?? 0.0,

      frequentPayments: List<Map<String, dynamic>>.from(
          data['frequentPayments'] ?? []),

      frequentPaymentsWeek: List<Map<String, dynamic>>.from(
          data['week']['frequentPayments'] ?? []),

      drasticChanges: List<Map<String, dynamic>>.from(
          data['moreDrasticChange'] ?? []),

      drasticChangesWeek: List<Map<String, dynamic>>.from(
          data['week']['moreDrasticChange'] ?? []),

      categories: List<Map<String, dynamic>>.from(
          data['categorized'] ?? []),
    );
  }
}