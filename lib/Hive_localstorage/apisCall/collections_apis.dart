import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../hive_storage.dart';
import 'init_hive.dart';

class CollectionsLocalStorage {
  static const String collectionsKey = 'collections';
  static const String limitSummaryKey = 'limitSummary';
  static const String invitationsKey = 'invitations';
  static const String _detailsPrefix = 'collectionDetails_';
  static const String _splitsPrefix = 'splits_';
  static const String _balancesPrefix = 'balances_';

  static Future<void> ensureBox() async {
    await HiveHelper.openBoxIfNot<String>(HiveStorage.collectionsBoxName);
  }

  static Future<void> saveJson(String key, dynamic value) async {
    try {
      await ensureBox();
      if (!HiveStorage.isBoxOpen(HiveStorage.collectionsBoxName)) return;
      await HiveStorage.collectionsBox.put(key, jsonEncode(value));
    } catch (e) {
      debugPrint('CollectionsLocalStorage saveJson error: $e');
    }
  }

  static Future<dynamic> readJson(String key) async {
    try {
      await ensureBox();
      if (!HiveStorage.isBoxOpen(HiveStorage.collectionsBoxName)) return null;
      final cached = HiveStorage.collectionsBox.get(key);
      if (cached == null || cached.isEmpty) return null;
      return jsonDecode(cached);
    } catch (e) {
      debugPrint('CollectionsLocalStorage readJson error: $e');
      return null;
    }
  }

  static Future<void> remove(String key) async {
    try {
      await ensureBox();
      if (!HiveStorage.isBoxOpen(HiveStorage.collectionsBoxName)) return;
      await HiveStorage.collectionsBox.delete(key);
    } catch (e) {
      debugPrint('CollectionsLocalStorage remove error: $e');
    }
  }

  static String detailsKey(String collectionId) => '$_detailsPrefix$collectionId';
  static String splitsKey(String collectionId) => '$_splitsPrefix$collectionId';
  static String balancesKey(String collectionId) => '$_balancesPrefix$collectionId';

  static Future<void> clearCollection(String collectionId) async {
    await remove(detailsKey(collectionId));
    await remove(splitsKey(collectionId));
    await remove(balancesKey(collectionId));
  }
}
