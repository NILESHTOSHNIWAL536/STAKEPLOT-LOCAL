import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/repository/payments.dart';
import 'package:flutter_application_code_stakeplot/repository/profileUser.dart';
import 'package:flutter_application_code_stakeplot/repository/reward_repository.dart';
import 'package:flutter_application_code_stakeplot/user_chat/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/firebase_options.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/widget_services/widget_updation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


DateTime? _lastSent;
Timer? snackbarTimer;

class AppLifecycleHandler extends WidgetsBindingObserver {
  final String userId;
  AppLifecycleState? _previousState;
  DateTime? _lastPausedTime;

  AppLifecycleHandler(this.userId);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    mainPageWebSocket.close();
    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
      final now = DateTime.now();
      if (_lastSent == null ||
          now.difference(_lastSent!) > Duration(seconds: 20)) {
        _lastSent = now;
        sendCloseEvent(userId);
      }
    } else if (_previousState != AppLifecycleState.inactive &&
        state != AppLifecycleState.inactive) {
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
    } catch (e) {}
  }
}

void resentCodeLocaldata() {
  OneSignal.Notifications.clearAll();
}

void setUpSocketListenerMainPage(BuildContext context) {
  try {
    if (userController.userId.value == "") return;
    mainPageWebSocket = IO.io(
      urlWithLocallHost,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .build(),
    );
    // Connect the socket
    mainPageWebSocket.onConnectError( (data) {
    });

    mainPageWebSocket.connect();

    mainPageWebSocket.onConnect((_) {
      try {
       
        mainPageWebSocket.emit("addUserToSocket", userController.userId.value);
      } catch (e) {}
    });


    // Listener for events from the socket
    mainPageWebSocket.on("addUserToSocket", (data) async {
      String type = data['type'];
      if (type == "Notify") {
        hasGetNewNotifications.value = !hasGetNewNotifications.value;
        hasGetNewNotifications.value = !hasGetNewNotifications.value;
        myNotificationBool.value = !myNotificationBool.value;
        getNotifications(context);
      } else if (type == "reactOnPost") {
        onPostReactLikeAndCommentWebSocket(data['data'], context);
      } else if (type == "NewPost") {
        onPostDataCallWebSocket(data, context);
      } else if (type == "logoutUser") {
        logoutUserFromDevice(context);
      } else if (type == 'Reward') {
        callRewardApis(context);
      } else if (type == "fetchedApiCall") {
        isFected.value = false;
        String message = data['data']['message'] ?? "";
        bool flag = data['data']['failed'] ?? false;

        if (flag) {
          snackBarCalledfail(context, message);
        } else {
          snackBarCalled(context, message);
        }

        getBankAccounts();
      } else if (type == "coupon") {
        snackbarTimer = Timer(Duration(hours: 48), () {
          if (userController.coupons.value > 0) {
            snackBarCalled(
              context,
              'You have ${userController.coupons.value} unclaimed coupon${userController.coupons.value > 1 ? 's' : ''}! Claim them now from rewards section!',
            );
          }
        });
      }
    });
  } catch (e) {}
}

void onPostReactLikeAndCommentWebSocket(updatedPost, context) {
  String id = updatedPost['_id'];
  if (postController.postData.containsKey(id))
    postController.postData[id] = !(postController.postData[id] ?? false);
  postController.postCount[id] = updatedPost['upvotes'];
  postController.postCommentCount[id] = updatedPost['comments'];
  postController.uniquePostDeatils = updatedPost;
  postController.reloadUniquePost.value =
      !postController.reloadUniquePost.value;
}

void onPostDataCallWebSocket(data, context) {
  try {
    var element = data['data'];
    uploadRefreshCall(element, context);
  } catch (e) {}
}


bool securityCheck(){
  assert(() {
    debugPrint = (String? message, {int? wrapWidth}) {
    };
    return true;
  }());
  return false;
}

Future<void> loadEnvs() async {
  try {
    await dotenv.load(fileName: ".env"); 
  } catch (e) {
  }
}



void checkFirebaseAndValidUser() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    mainPageWebSocket = IO.io(
        urlWithLocallHost,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNewConnection()
            .build());
    mainPageWebSocket.connect();
  } catch (e) {}

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
    if (kDebugMode) {
      return runApp(const MyApp());
    }

    final isFromPlayStore =
        await InstallationChecker.isInstalledFromPlayStore();
    if (isFromPlayStore) {
      runApp(const MyApp());
    } else {
      runApp(MyApp());
      // runApp( UnverifiedApp());
    }
  } catch (e) {
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
      final hasPlayServices = androidInfo.systemFeatures
          .any((feature) => feature.contains('com.google.android.gms'));

      // Method 3: Check device characteristics
      final isOfficialDevice = androidInfo.isPhysicalDevice &&
          !androidInfo.brand.toLowerCase().contains('generic');

      return hasPlayServices && isOfficialDevice;
    } catch (e) {
      return false; // Assume not from Play Store if we can't verify
    }
  }
}

catWidgetBindUpdate(context) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await HomeWidget.setAppGroupId('group.com.stakeplot.pfa');
    await updateWidgetSpendingCategories();
  });
  ever(spendingsOnCategories, (_) => updateWidgetSpendingCategories());
  ever(totalValue, (_) => updateWidgetSpendingCategories());
}

HomeWidgetBindUpdate() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await HomeWidget.setAppGroupId('group.com.stakeplot.pfa');
      await updateWidget();
    } catch (e) {}
  });
  ever(lendAmountRemainders, (_) => updateWidget());
  ever(dueAmountRemainders, (_) => updateWidget());
}
