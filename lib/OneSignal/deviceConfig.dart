
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/invalidUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/firebase_options.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;



DateTime? _lastSent;

class AppLifecycleHandler extends WidgetsBindingObserver {
  final String userId;
  AppLifecycleState? _previousState;
  DateTime? _lastPausedTime;

  AppLifecycleHandler(this.userId);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state)
   {

    mainPageWebSocket.close();
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
      await storeDeviceInfoLocalBackState();
      String? userid = await getToken();
      await ScreenTimeTracker().setUser(userid.toString(), true);
      await screenDataLocalStorage();
      // sendNotificationsToDevice(
      //   userId,
      //   "App closed",
      //   "The app has been closed. Please check your app for any updates or issues.",
      // );
    } catch (e) {
    }
  }
}

void resentCodeLocaldata()
{
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
    mainPageWebSocket.onConnect((_) {
    try {
      mainPageWebSocket.emit("addUserToSocket", currentId.value);
    } catch (e) {
    }
  });

    // Listener for events from the socket
    mainPageWebSocket.on("addUserToSocket", (data) {
     
      if(data['type'] == "Notify")
      {
        hasGetNewNotifications.value=!hasGetNewNotifications.value;
        hasGetNewNotifications.value=!hasGetNewNotifications.value;
        myNotificationBool.value=!myNotificationBool.value;
        getNotifications(context);
      }
      else if (data['type'] == "reactOnPost")
      {
             onPostReactLikeAndCommentWebSocket(data['data'],context);
      }
      else if (data['type'] == "NewPost") {
          onPostDataCallWebSocket(data,context); 
      }
     else if (data['type'] == "logoutUser")
      {
        logoutUserFromDevice(context);
      } 
      else if (data['type'] == "fetchedApiCall")
      {
        isFected.value = false;
        getBankAccounts();
      }
    });

  } catch (e) {
  }
}



void onPostReactLikeAndCommentWebSocket(updatedPost,context)
{
    
    String id=updatedPost['_id'];   
    if(postData.containsKey(id)) postData[id] = ! (postData[id]??false);
    postCount[id] = updatedPost['upvotes'];
    postCommentCount[id] = updatedPost['comments'];
    uniquePostDeatils=updatedPost;
    reloadUniquePost.value = !reloadUniquePost.value;

}

void onPostDataCallWebSocket(data,context){
        try{
           var element=data['data'];
           uploadRefreshCall(element, context);
        }
        catch(e)
        {
        }
}



void checkFirebaseAndValidUser() async {
   WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  
  print('✔ Connected successfully');
  mainPageWebSocket = IO.io(urlWithLocallHost,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNewConnection()
            .build());
  mainPageWebSocket.connect();

  } catch (e) {
    print('❌ Firebase setup error: $e');
  }

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
      checkIsUserValid();
  });
}



Future<void> checkIsUserValid() async {
  try {

    if(kDebugMode){
         return runApp(const MyApp());
    }

    final isFromPlayStore = await InstallationChecker.isInstalledFromPlayStore();
    if (isFromPlayStore) {
      debugPrint('✅ App installed from official source');
      runApp(const MyApp());
    } else {
        debugPrint('⚠️ App not installed from official source');
        runApp( MyApp());
        // runApp( UnverifiedApp());
    }
  } catch (e) {
    debugPrint('Error in security check: $e');
    runApp(const MyApp());
  }
}


class InstallationChecker {
  static Future<bool> isInstalledFromPlayStore() async {
    if (!Platform.isAndroid) {
      return true; // iOS apps are generally from App Store
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      // Method 1: Check installer package name (if available)
      final installer = androidInfo.systemFeatures;
      if (installer.any((feature) => feature.contains('com.android.vending'))) {
        return true;
      }
      
      // Method 2: Check for Google Play Services
      final hasPlayServices = androidInfo.systemFeatures.any(
        (feature) => feature.contains('com.google.android.gms')
      );
      
      // Method 3: Check device characteristics
      final isOfficialDevice = androidInfo.isPhysicalDevice && 
                              !androidInfo.brand.toLowerCase().contains('generic');
      
      return hasPlayServices && isOfficialDevice;
      
    } catch (e) {
      debugPrint('Error checking installation source: $e');
      return false; // Assume not from Play Store if we can't verify
    }
  }
}


catWidgetBindUpdate(){
  WidgetsBinding.instance.addPostFrameCallback((_) async {
      await HomeWidget.setAppGroupId('group.com.stakeplot.pfa');
      getCategoryData();
      await updateWidgetSpendingCategories();
    });
    ever(chartData, (_) => updateWidgetSpendingCategories());
    ever(totalValue, (_) => updateWidgetSpendingCategories());
}

HomeWidgetBindUpdate()
{
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await HomeWidget.setAppGroupId('group.com.stakeplot.pfa');
        await updateWidget();
      } catch (e) {
      }
    });
    ever(lendAmountRemainders, (_) => updateWidget());
    ever(dueAmountRemainders, (_) => updateWidget());
}