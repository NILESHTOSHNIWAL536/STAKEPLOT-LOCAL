import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:http/http.dart' as http;

 DateTime? _lastSent;

class AppLifecycleHandler extends WidgetsBindingObserver {
  final String userId;

  AppLifecycleHandler(this.userId);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
     if (state == AppLifecycleState.paused) 
    {
        final now = DateTime.now();
        if (_lastSent == null || now.difference(_lastSent!) > Duration(seconds: 20))
        {
          _lastSent = now;
          sendCloseEvent(userId);
        }
   }
  }

  Future<void> sendCloseEvent(String userId) async {
    try 
    {
      await storeDeviceInfo();
      String? userid=await getToken();
      await ScreenTimeTracker().setUser(userid.toString(),true);
      await screenDataLocalStorage();

      sendNotificationsToDevice(userId,"App closed","The app has been closed. Please check your app for any updates or issues.",);
    } catch (e){
      print('Error sending close event: $e');
    }
  }
}



void resentCodeLocaldata()
{
   
}