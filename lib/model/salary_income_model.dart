import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';

class SalaryIncomeTransaction {
  final String id;
  final String narration;
  final String amount;
  final String date;
  final String mode;
  final DateTime? transactionTimestamp;

  const SalaryIncomeTransaction({
    required this.id,
    required this.narration,
    required this.amount,
    required this.date,
    required this.mode,
    required this.transactionTimestamp,
  });

  factory SalaryIncomeTransaction.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'];
    final rawTimestamp = json['transactionTimestamp'] is Map
        ? json['transactionTimestamp']['\$date']
        : json['transactionTimestamp'];
    final parsedDate = rawTimestamp != null
        ? DateTime.tryParse(rawTimestamp.toString())
        : null;

    return SalaryIncomeTransaction(
      id: rawId?.toString() ?? '',
      narration:
          (json['narration'] ?? json['name'] ?? 'Income credit').toString(),
      amount: "Rs ${formatMoneyIndian((json['amount'] ?? 0).toString())}",
      date: parsedDate != null ? formatWhatsAppDateWithoutTime(parsedDate) : '',
      mode: (json['mode'] ?? '').toString(),
      transactionTimestamp: parsedDate,
    );
  }
}

class SalaryIncomeSource {
  final String id;
  final String sourceName;
  final String incomeType;
  final String status;
  final double predictedAmount;
  final double averageMonthlyIncome;
  final double minMonthlyIncome;
  final double maxMonthlyIncome;
  final int expectedCreditDay;
  final DateTime? lastCreditedDate;
  final DateTime? nextExpectedSalaryDate;
  final double confidenceScore;
  final String confidenceLabel;
  final List<SalaryIncomeTransaction> transactions;

  const SalaryIncomeSource({
    required this.id,
    required this.sourceName,
    required this.incomeType,
    required this.status,
    required this.predictedAmount,
    required this.averageMonthlyIncome,
    required this.minMonthlyIncome,
    required this.maxMonthlyIncome,
    required this.expectedCreditDay,
    required this.lastCreditedDate,
    required this.nextExpectedSalaryDate,
    required this.confidenceScore,
    required this.confidenceLabel,
    required this.transactions,
  });

  factory SalaryIncomeSource.fromJson(Map<String, dynamic> json) {
    final transactionSource = (json['transactionIds'] as List<dynamic>?) ?? [];
    final transactions = transactionSource
        .whereType<Map<String, dynamic>>()
        .map(SalaryIncomeTransaction.fromJson)
        .toList()
      ..sort((a, b) {
        final aDate = a.transactionTimestamp;
        final bDate = b.transactionTimestamp;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    DateTime? parseDate(dynamic value) {
      final raw = value is Map ? value['\$date'] : value;
      return raw == null ? null : DateTime.tryParse(raw.toString());
    }

    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return SalaryIncomeSource(
      id: (json['_id'] is Map ? json['_id']['\$oid'] : json['_id'])
              ?.toString() ??
          '',
      sourceName: (json['sourceName'] ?? 'Income source').toString(),
      incomeType: (json['incomeType'] ?? 'recurring_income').toString(),
      status: (json['status'] ?? 'suggested').toString(),
      predictedAmount: asDouble(json['predictedAmount']),
      averageMonthlyIncome: asDouble(json['averageMonthlyIncome']),
      minMonthlyIncome: asDouble(json['minMonthlyIncome']),
      maxMonthlyIncome: asDouble(json['maxMonthlyIncome']),
      expectedCreditDay: (json['expectedCreditDay'] is num)
          ? (json['expectedCreditDay'] as num).round()
          : int.tryParse(json['expectedCreditDay']?.toString() ?? '') ?? 1,
      lastCreditedDate: parseDate(json['lastCreditedDate']),
      nextExpectedSalaryDate: parseDate(json['nextExpectedSalaryDate']),
      confidenceScore: asDouble(json['confidenceScore']),
      confidenceLabel: (json['confidenceLabel'] ?? '').toString(),
      transactions: transactions,
    );
  }

  String get predictedAmountText =>
      "Rs ${formatMoneyIndian(predictedAmount.toStringAsFixed(0))}";

  String get averageMonthlyIncomeText =>
      "Rs ${formatMoneyIndian(averageMonthlyIncome.toStringAsFixed(0))}";

  String get rangeText =>
      "Rs ${formatMoneyIndian(minMonthlyIncome.toStringAsFixed(0))} - Rs ${formatMoneyIndian(maxMonthlyIncome.toStringAsFixed(0))}";

  String get confidenceText => "${(confidenceScore * 100).round()}%";

  String get nextExpectedText => nextExpectedSalaryDate == null
      ? "Not predicted"
      : formatWhatsAppDateWithoutTime(nextExpectedSalaryDate!);

  String get lastCreditedText => lastCreditedDate == null
      ? "No credit yet"
      : formatWhatsAppDateWithoutTime(lastCreditedDate!);
}
