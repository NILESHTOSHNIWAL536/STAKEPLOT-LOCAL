import 'package:hive/hive.dart';

part 'card_insights_model.g.dart';

@HiveType(typeId: 17)
class CardInsightsModel extends HiveObject {
  @HiveField(6)
  List<Map<String, dynamic>> categoriesList;

  CardInsightsModel({
    required this.categoriesList,
  });
}
