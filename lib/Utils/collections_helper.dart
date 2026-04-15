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
    "exit": false,
    "reopen": true,
    "editlimit": true
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
      "exit": true,
      "reopen": false,
      "editlimit": false
    },
    "CONTRIBUTE": {
      "accessPermission": true,
      "export": true,
      "personLimit": true,
      "rename": true,
      "duration": true,
      "close": true,
      "delete": true,
      "exit": true,
      "reopen": true,
      "editlimit": true
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
  required bool status,
}) {
  final details = collectionsController.collectionDetails.value;
  if (details == null) return false;
  final currentUser = collectionsController.currentUser;

  final bool isOwner = details.collection.ownerId == currentUser?.userId;
  List actionsList = ["delete", "exit", "export"];

  if (action == "reopen") {
    return isOwner && status;
  }

  if (status && !actionsList.contains(action)) {
    return false;
  }

  if (type == "PERSONAL") {
    return permissionJson["PERSONAL"]?[action] ?? false;
  }

  if (type == "SHARED") {
    if (role == null) return false;

    bool allowed = permissionJson["SHARED"]?[role]?[action] ?? false;

    if (["close", "delete", "accessPermission", "editlimit"].contains(action)) {
      return allowed && isOwner;
    }

    if (action == "exit") {
      return allowed && !isOwner;
    }

    return allowed;
  }

  return false;
}

bool checkAndCallSnackbar(context) {
  final status =
      collectionsController.collectionDetails.value?.collection.status;

  if (status == "CLOSED") {
    snackBarCalledfail(context, "This collection has already been closed.");
    return true;
  }
  return false;
}
