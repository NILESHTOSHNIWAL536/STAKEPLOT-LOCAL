import 'package:hive/hive.dart';

// Hive model for ChartData
part 'chart_data_model.g.dart';

@HiveType(typeId: 10)
class ChartDataModel extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  String percentage;

  @HiveField(2)
  double value;

  @HiveField(3)
  String color;

  ChartDataModel({
    required this.category,
    required this.percentage,
    required this.value,
    required this.color,
  });
}
