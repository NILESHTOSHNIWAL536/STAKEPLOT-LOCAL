class QuickCheckModel {
  final List<QuickCheckBankData> banks;

  final double currentBalance;
  final double credit;
  final double debit;
  final double outstanding;

  final double creditPercent;
  final double debitPercent;
  final double outstandingPercent;

  QuickCheckModel({
    required this.banks,
    required this.currentBalance,
    required this.credit,
    required this.debit,
    required this.outstanding,
    required this.creditPercent,
    required this.debitPercent,
    required this.outstandingPercent,
  });

  factory QuickCheckModel.fromJson(Map<String, dynamic> json) {
    final combined = json['combined'] ?? {};
    final percentages = combined['percentages'] ?? {};

    return QuickCheckModel(
      banks: (json['banks'] ?? [])
          .map<QuickCheckBankData>((e) => QuickCheckBankData.fromJson(e))
          .toList(),

      currentBalance:
          (combined['currentBalance'] ?? 0).toDouble(),

      credit: (combined['credit'] ?? 0).toDouble(),
      debit: (combined['debit'] ?? 0).toDouble(),
      outstanding:
          (combined['outstanding'] ?? 0).toDouble(),

      creditPercent:
          (percentages['creditPercent'] ?? 0).toDouble(),
      debitPercent:
          (percentages['debitPercent'] ?? 0).toDouble(),
      outstandingPercent:
          (percentages['outstandingPercent'] ?? 0).toDouble(),
    );
    
  }
}

class QuickCheckBankData {
  final String bankName;
  final double currentBalance;
  final double credit;
  final double debit;
  final double outstanding;

  final double creditPercent;
  final double debitPercent;
  final double outstandingPercent;

  final List<Map<String, dynamic>> months; // keep raw for now

  QuickCheckBankData({
    required this.bankName,
    required this.currentBalance,
    required this.credit,
    required this.debit,
    required this.outstanding,
    required this.creditPercent,
    required this.debitPercent,
    required this.outstandingPercent,
    required this.months,
  });

  factory QuickCheckBankData.fromJson(Map<String, dynamic> json) {
    final percentages = json['percentages'] ?? {};

    return QuickCheckBankData(
      bankName: json['bankName'] ?? '',

      currentBalance:
          (json['currentBalance'] ?? 0).toDouble(),

      credit: (json['credit'] ?? 0).toDouble(),
      debit: (json['debit'] ?? 0).toDouble(),
      outstanding: (json['outstanding'] ?? 0).toDouble(),

      creditPercent:
          (percentages['creditPercent'] ?? 0).toDouble(),
      debitPercent:
          (percentages['debitPercent'] ?? 0).toDouble(),
      outstandingPercent:
          (percentages['outstandingPercent'] ?? 0).toDouble(),

      months: List<Map<String, dynamic>>.from(
          json['months'] ?? []),
    );
  }
}