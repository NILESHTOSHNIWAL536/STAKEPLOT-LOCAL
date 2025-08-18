part of 'init_hive.dart';

class HiveHelper {
  /// Safe adapter registration (won’t throw if already registered)
  static void registerAdapterSafe<T>(TypeAdapter<T> adapter) {
    try {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
    } catch (e) {
      debugPrint("⚠️ Adapter already registered: ${adapter.runtimeType}");
    }
  }

  /// Open a Hive box if not already open
  static Future<void> openBoxIfNot<T>(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<T>(boxName);
      }
    } catch (e) {
      debugPrint("❌ Error opening Hive box [$boxName]: $e");
    }
  }

  /// Generic Hive initializer
  static Future<void> initHiveBox<T>({
    required TypeAdapter<T> adapter,
    required String boxName,
    FutureOr<void> Function()? onLoaded,
  }) async {
    registerAdapterSafe(adapter);
    await openBoxIfNot<T>(boxName);
    if (Hive.isBoxOpen(boxName))
    {
       onLoaded?.call();
    }
  }
}
