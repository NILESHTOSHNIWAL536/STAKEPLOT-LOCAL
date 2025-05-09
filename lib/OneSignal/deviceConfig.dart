// import 'package:flutter/widgets.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:http/http.dart' as http;
// import 'package:onesignal_flutter/onesignal_flutter.dart';


//  DateTime? _lastSent;

// class AppLifecycleHandler extends WidgetsBindingObserver {
//   final String userId;

//   AppLifecycleHandler(this.userId);

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//      if (state == AppLifecycleState.resumed) {
//       // 👇 Call your reset logic here when user comes back to app
//       resentCodeLocaldata();
//     }
//    else  if (state == AppLifecycleState.paused) 
//     {
//         final now = DateTime.now();
//         if (_lastSent == null || now.difference(_lastSent!) > Duration(seconds: 20))
//         {
//           _lastSent = now;
//           sendCloseEvent(userId);
//         }
//     }
//   }

//   Future<void> sendCloseEvent(String userId) async {
//     try 
//     {
//       await storeDeviceInfo();
//       String? userid=await getToken();
//       await ScreenTimeTracker().setUser(userid.toString(),true);
//       await screenDataLocalStorage();
//       sendNotificationsToDevice(userId,"App closed","The app has been closed. Please check your app for any updates or issues.",);
//     } catch (e){
//       print('Error sending close event: $e');
//     }
//   }
// }



// void resentCodeLocaldata()
// {
//     OneSignal.Notifications.clearAll();
// }



import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


DateTime? _lastSent;

class AppLifecycleHandler extends WidgetsBindingObserver {
  final String userId;
  AppLifecycleState? _previousState;
  DateTime? _lastPausedTime;

  AppLifecycleHandler(this.userId);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AppLifecycleState changed: $state');

    if (state == AppLifecycleState.paused) 
    {
      _lastPausedTime = DateTime.now();
      final now = DateTime.now();
      if (_lastSent == null || now.difference(_lastSent!) > Duration(seconds: 20)) {
        _lastSent = now;
        sendCloseEvent(userId);
      }
  }
  else if (_previousState != AppLifecycleState.inactive && state != AppLifecycleState.inactive)
  {
        resentCodeLocaldata();
  }

    _previousState = state;
  }

  Future<void> sendCloseEvent(String userId) async {
    try {
      await storeDeviceInfo();
      String? userid = await getToken();
      await ScreenTimeTracker().setUser(userid.toString(), true);
      await screenDataLocalStorage();
      // sendNotificationsToDevice(
      //   userId,
      //   "App closed",
      //   "The app has been closed. Please check your app for any updates or issues.",
      // );
    } catch (e) {
      print('Error sending close event: $e');
    }
  }
}

void resentCodeLocaldata() {
  print("Clearing OneSignal notifications");
  OneSignal.Notifications.clearAll();
}


void setUpSocketListenerMainPage(BuildContext context) {
  try {
    
    if (currentId.value == "") return;

    // Initialize socket connection
    mainPageWebSocket = IO.io(
      urlWithLocallHost,
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableForceNewConnection()
        .build(),
    );

    // Connect the socket
    mainPageWebSocket.connect();

    // On successful connection
    mainPageWebSocket.onConnect((_) {
      mainPageWebSocket.emit("addUserToSocket", currentId.value);
    });

    // Listener for events from the socket
    mainPageWebSocket.on("addUserToSocket", (data) {
      if (data['type'] == "logoutUser") {
        logoutUserFromDevice(context);
      } else if (data['type'] == "fetchedApiCall") {
        isFected.value = false;
      }
    });

  } catch (e) {
    print("Socket connection error: $e");
  }
}
