part of 'init_hive.dart';

class HiveHelper {
  /// Safe adapter registration (won’t throw if already registered)
  static void registerAdapterSafe<T>(TypeAdapter<T> adapter) {
    try {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
    } catch (e) {}
  }

  /// Open a Hive box if not already open
  static Future<void> openBoxIfNot<T>(String boxName) async {
    try {
      final key = await getOrCreateKey();
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<T>(
          boxName,
          encryptionCipher: HiveAesCipher(key),
        );
      }
    } catch (e) {}
  }

  /// Generic Hive initializer
  static Future<void> initHiveBox<T>({
    required TypeAdapter<T> adapter,
    required String boxName,
    FutureOr<void> Function()? onLoaded,
  }) async {
    registerAdapterSafe(adapter);
    await openBoxIfNot<T>(boxName);
    if (Hive.isBoxOpen(boxName)) {
      onLoaded?.call();
    }
  }

  static Future<List<int>> getOrCreateKey() async {
     final secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    String? encodedKey = await secureStorage.read(key: "hive_key");
    if (encodedKey == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: "hive_key",
        value: base64Encode(key),
      );
      return key;
    }

    return base64Decode(encodedKey);
  }
}
