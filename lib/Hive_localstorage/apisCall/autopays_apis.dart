import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../backed_connections/apis_connect.dart';
import '../../model/autopay_model.dart';
import '../autopays_data/cards_data.dart';
import '../hive_storage.dart';
import 'init_hive.dart';


class CardsLocalStorage {
  /// Save all cards to Hive
  static Future<void> saveCardsToHive({required List<CardData> cardList}) async {
    HiveHelper.openBoxIfNot<CardsData>(HiveStorage.autoPayBoxName);
    final box = await HiveStorage.autoPays; 
    await box.clear();

    const  gradients =  [
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B7ED8), Color(0xFF4A90E2)],
          ),
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8A80), Color(0xFFFF7043)],
          ),
        ];

    try {
      for (var element in cardList) {
        // Store index instead of LinearGradient
    
        // final gradientIndex = gradients.indexWhere((g) => g.colors.first == element.gradient.colors.first);
        box.add(CardsData(
          id: element.id,
          title: element.title,
          amount: element.amount,
          date: element.date,
          occuranceDate: element.occuranceDate,
          frequency: element.frequency,
          narration: element.narration,
          gradientIndex: 0,
          nextReminderAt: element.nextReminderAt,
          isActive: element.isActive,
          isDaily: element.isDaily,
        ));
      }
     
    } catch (e) {
      print("Error saving cards to Hive: $e");
    }
  }

  /// Load cards from Hive into RxList
  static Future<void> loadCardsFromHive() async {

    try {
     HiveHelper.openBoxIfNot<CardsData>(HiveStorage.autoPayBoxName);
    final box = await HiveStorage.autoPays;
    RxList<CardData> cardList=<CardData>[].obs;
   const   gradients =  [
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B7ED8), Color(0xFF4A90E2)],
        ),
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        ),
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8A80), Color(0xFFFF7043)],
        ),
      ];

      box.values.forEach((element) {
        cardList.add(CardData(
          id: element.id,
          title: element.title,
          amount: element.amount,
          date: element.date,
          occuranceDate: element.occuranceDate,
          frequency: element.frequency,
          narration: element.narration,
          gradient: gradients[0],
          nextReminderAt: element.nextReminderAt,
          isActive: element.isActive,
          isDaily: element.isDaily,
        ));
      });

      allAutoPayData.clear();
      allAutoPayData.addAll(cardList);
      isAutoPayFected.value=!isAutoPayFected.value;

    } catch (e) {
      print(e);
    }
  }
}
