import 'package:hive/hive.dart';

part 'consent_detail_model.g.dart';

@HiveType(typeId: 2)
class ConsentDetailModel extends HiveObject {
  @HiveField(0) String consentId;
  @HiveField(1) String consendHandleId;
  @HiveField(2) String sessionId;
  @HiveField(3) String custId;
  @HiveField(4) String lastFetch;
  @HiveField(5) String nextFetch;
  @HiveField(6) String fetchCount;

  ConsentDetailModel({
    required this.consentId,
    required this.consendHandleId,
    required this.sessionId,
    required this.custId,
    required this.lastFetch,
    required this.nextFetch,
    required this.fetchCount,
  });
}
