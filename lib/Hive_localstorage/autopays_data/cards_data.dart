import 'package:hive/hive.dart';
part 'cards_data.g.dart';

@HiveType(typeId: 18) // Make sure this ID is unique in your app
class CardsData extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String amount;

  @HiveField(3)
  String date;

  @HiveField(4)
  List<String> occuranceDate;

  @HiveField(5)
  String frequency;

  @HiveField(6)
  String narration;

  @HiveField(7)
  int gradientIndex; // Store index instead of LinearGradient

  @HiveField(8)
  DateTime? nextReminderAt;

  @HiveField(9)
  bool isActive;

  @HiveField(10)
  bool isDaily;

  CardsData({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.occuranceDate,
    required this.frequency,
    required this.narration,
    required this.gradientIndex,
    this.nextReminderAt,
    required this.isActive,
    required this.isDaily,
  });
}
