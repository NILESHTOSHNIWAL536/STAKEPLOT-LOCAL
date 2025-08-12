import 'package:hive/hive.dart';

part 'insights_model.g.dart';

@HiveType(typeId: 9)
class InsightsModel extends HiveObject {
  @HiveField(0)
  List<Map<String, List<String>>> totalInSights;

  @HiveField(1)
  List<Map<String, List<String>>> totalInSightsMoneyMap;

  @HiveField(2)
  DateTime lastUpdated; // Add this field

  InsightsModel({
    required this.totalInSights,
    required this.totalInSightsMoneyMap,
    required this.lastUpdated,
  });
}