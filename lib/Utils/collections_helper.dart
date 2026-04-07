import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

final Map<String, dynamic> permissionJson = {
  "PERSONAL": {
    "accessPermission": false,
    "export": true,
    "personLimit": false,
    "rename": true,
    "duration": true,
    "close": true,
    "delete": true,
    "exit": false
  },
  "SHARED": {
    "VIEW": {
      "accessPermission": false,
      "export": true,
      "personLimit": true,
      "rename": false,
      "duration": false,
      "close": false,
      "delete": false,
      "exit": true && !isOwner
    },
    "CONTRIBUTE": {
      "accessPermission": true,
      "export": true,
      "personLimit": true,
      "rename": true,
      "duration": true,
      "close": true && isOwner,
      "delete": true && isOwner,
      "exit": true && !isOwner
    }
  }
};

bool isOwner =
    collectionsController.collectionDetails.value?.collection.ownerId ==
        collectionsController.currentUser?.id;

bool hasPermission({
  required String type, // personal / shared
  String? role, // view / contribute
  required String action,
}) {
  if (type == "PERSONAL") {
    return permissionJson["PERSONAL"]?[action] ?? false;
  }

  if (type == "SHARED") {
    return permissionJson["SHARED"]?[role]?[action] ?? false;
  }

  return false;
}
