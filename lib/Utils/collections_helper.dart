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
      "exit": true
    },
    "CONTRIBUTE": {
      "accessPermission": true,
      "export": true,
      "personLimit": true,
      "rename": true,
      "duration": true,
      "close": true,
      "delete": true,
      "exit": true
    }
  }
};

bool isOwner() {
  final details = collectionsController.collectionDetails.value;
  final currentUser = collectionsController.currentUser;
  return details?.collection.ownerId == currentUser?.userId;
}

bool hasPermission({
  required String type,
  String? role,
  required String action,
}) {
  final details = collectionsController.collectionDetails.value;
  if (details == null) return false;
  final currentUser = collectionsController.currentUser;

  final bool isOwner = details.collection.ownerId == currentUser?.userId;

  if (type == "PERSONAL") {
    return permissionJson["PERSONAL"]?[action] ?? false;
  }

  if (type == "SHARED") {
    if (role == null) return false;

    bool allowed = permissionJson["SHARED"]?[role]?[action] ?? false;

    if (action == "close" || action == "delete") {
      return allowed && isOwner;
    }

    if (action == "exit") {
      return allowed && !isOwner;
    }

    return allowed;
  }

  return false;
}
