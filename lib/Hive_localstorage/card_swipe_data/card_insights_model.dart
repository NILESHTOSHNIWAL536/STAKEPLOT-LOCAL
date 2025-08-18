import 'package:hive/hive.dart';

part 'card_insights_model.g.dart';

@HiveType(typeId: 17)
class CardInsightsModel extends HiveObject {
  @HiveField(0)
  double totalDebitThisMonth;

  @HiveField(1)
  double totalDebitThisWeek;

  @HiveField(2)
  List<Map<String, dynamic>> moreDrasticChange;

  @HiveField(3)
  List<Map<String, dynamic>> moreDrasticChangeWeek;

  @HiveField(4)
  List<Map<String, dynamic>> frequentPayments;

  @HiveField(5)
  List<Map<String, dynamic>> frequentPaymentsWeek;
  @HiveField(6)
  List<Map<String, dynamic>> categoriesList;

  CardInsightsModel({
    required this.totalDebitThisMonth,
    required this.totalDebitThisWeek,
    required this.moreDrasticChange,
    required this.moreDrasticChangeWeek,
    required this.frequentPayments,
    required this.frequentPaymentsWeek,
    required this.categoriesList,
  });
}