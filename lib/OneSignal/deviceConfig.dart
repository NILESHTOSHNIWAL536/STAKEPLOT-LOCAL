
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoad.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
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
      print('Error sending close event: $e');
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


    // On successful connection
    // mainPageWebSocket.onConnect((_){
    //   try{
    //    mainPageWebSocket.emit("addUserToSocket", currentId.value);
    //   }catch(e){
    //     pritn(e);
    //   }
    // });
      mainPageWebSocket.onConnect((_) {
    print("Connected to socket server ✅");

    try {
      mainPageWebSocket.emit("addUserToSocket", currentId.value);
      print("User emitted to server");
    } catch (e) {
      print("Emit error: $e");
    }
  });

    // Listener for events from the socket
    mainPageWebSocket.on("addUserToSocket", (data) {
       print("data");
       print(data);
      if (data['type'] == "reactOnPost")
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
    print("Socket connection error: $e");
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
          print("error in adding....");
          print(e);
        }
}
