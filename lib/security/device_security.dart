// import 'package:root_check/root_check.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class DeviceSecurity {
//   static Future<bool> isDeviceSecure() async {
//     bool rooted = false;
//     try {
//       rooted = await RootCheck.isRooted ?? false;
//     } catch (_) {}

//     return !(rooted); // true if secure
//   }

//   static Future<void> checkAndWarn(BuildContext context) async {
//     bool secure = await isDeviceSecure();
//     if (!secure) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text("Security Warning"),
//           content: Text(
//               "Your device is rooted/jailbroken. Some features may be restricted for security reasons."),
//           actions: [
//             TextButton(
//               onPressed: () => SystemNavigator.pop(), // exit app
//               child: Text("Exit"),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
