import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Secure storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // ---------------------------
  // BASIC CRUD OPERATIONS
  // ---------------------------

  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // ---------------------------
  // AES KEY MANAGEMENT (for Hive)
  // ---------------------------

  Future<List<int>> loadOrGenerateHiveKey() async {
    String? raw = await _storage.read(key: "hive_key");

    if (raw == null) {
      // Generate 32-byte AES key
      final key = List<int>.generate(32, (i) => Random.secure().nextInt(256));

      await _storage.write(key: "hive_key", value: key.join(','));
      return key;
    }

    return raw.split(',').map(int.parse).toList();
  }

  Future<void> saveHiveKey(List<int> key) async {
    await _storage.write(key: "hive_key", value: key.join(','));
  }

  Future<void> removeHiveKey() async {
    await _storage.delete(key: "hive_key");
  }
}
