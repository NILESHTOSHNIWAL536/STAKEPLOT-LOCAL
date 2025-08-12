import 'package:hive/hive.dart';

part 'finance_model.g.dart';

@HiveType(typeId: 8)
class FinanceModel extends HiveObject {
  @HiveField(0) String period;
  @HiveField(1) String startDate;
  @HiveField(2) String? endDate;
  @HiveField(3) List<String> labels;
  @HiveField(4) List<double> debited;
  @HiveField(5) List<double> credited;
  @HiveField(6) double totalDebitValue;
  @HiveField(7) double totalDebitValuePercent;
  @HiveField(8) double maxYValue;

  FinanceModel({
    required this.period,
    required this.startDate,
    this.endDate,
    required this.labels,
    required this.debited,
    required this.credited,
    required this.totalDebitValue,
    required this.totalDebitValuePercent,
    required this.maxYValue,
  });
}