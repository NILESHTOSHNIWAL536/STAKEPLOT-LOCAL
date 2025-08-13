
import 'package:hive/hive.dart';

part 'finora_last_two_months_model.g.dart';

@HiveType(typeId: 19)
class FinoraLastTwoMonthsModel extends HiveObject {
  @HiveField(0)
  String? month1Name;

  @HiveField(1)
  String? month2Name;

  @HiveField(2)
  double? month1Avg;

  @HiveField(3)
  double? month2Avg;

  @HiveField(4)
  List<Map<String, dynamic>> month1DailySums;

  @HiveField(5)
  List<Map<String, dynamic>> month2DailySums;

  FinoraLastTwoMonthsModel({
    this.month1Name,
    this.month2Name,
    this.month1Avg,
    this.month2Avg,
    required this.month1DailySums,
    required this.month2DailySums,
  });
}
