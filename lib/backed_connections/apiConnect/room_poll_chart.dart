import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoadFeed.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/user_chat/message.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void getChats(data) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.get(
    Uri.parse('${url}/chat/${data['_id']}/${ismaskedUsers.value}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    List obj = his['data'];
    messagesTemp.clear();
    messages.clear();
    obj.forEach((element) {
      var postData = element['messageType'] == "post"
          ? element['post']['postLocation']
          : "";

      messages.insert(
          0,
          Message(
              text: element['message'],
              isMe: element['sender'] != data['_id'],
              type: element['messageType'],
              image: element['image'] ?? "",
              poll: element['poll'] ?? "poll",
              post: postData,
              split: element['split'] ?? ""));
    });

    messagesTemp.addAll(messages);
  } else {}
}

void upvote(context, String str, String objectId) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/upvote/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'onModel': str.toString(),
      'objectId': objectId,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "You liked this!", Colors.black);
  } else {
    snackBarCalledfail(context, "An error occurred while liking!", Colors.red);
  }
}

void downvote(context, String str, String objectId) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/downvote/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'onModel': str.toString(),
      'objectId': objectId,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "You disliked this!", Colors.black);
  } else {
    snackBarCalledfail(context, "An error occurred while disliking!", Colors.red);
  }
}

void mute(context, String type, String id) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.post(
    Uri.parse('https://stakeplot.in/api/v1/user/mute'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'type': type,
      'id': id,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "You have muted this user.", Colors.black);
  } else {
    snackBarCalledfail(context, "An error occurred while muting!", Colors.red);
  }
}

void exitRoom(context, String id) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse('${url}/room/exit/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    userController.fetchUserInfo();    
    snackBarCalled(context, "You have exited the room.", Colors.black);
  } else {
    snackBarCalledfail(
        context, "An error occurred while exiting the room!", Colors.red);
  }
}

void createRoom(context, List expenses, List user, String name) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  var body = {
    'name': name.toString(),
    'users': user,
    'expenses': expenses,
  };

  final response = await http.post(
    Uri.parse('${url}/room/add'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'name': name.toString(),
      'users': user,
      'expenses': expenses,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(
        context, "The room has been created successfully!", Colors.black);

    //  Navigator.pop(context);
    //   Navigator.push(
    //   context,
    //   PageTransition(
    //     type: PageTransitionType.fade,
    //      duration: Durations.long1,
    //     child: RoomHome(),
    //     isIos: true,
    //   ),
    // );
  } else {
    final body = json.decode(response.body);
    String msg = body['error']['explanation'];
    snackBarCalled(context, msg, Colors.red);
  }
}

void createPoll(context, String question, List options, roomDetails, members,
    String type) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/poll/add'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'question': question,
      'options': options,
      'pollType': type, //roomDetails.length!=0?'room':'casual',
      'roomDetails': roomDetails,
      'myVote': 'none',
      'members': members
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    var snackBar = SnackBar(
      duration: Durations.long1,
      content: Text(
        'Sending polls to friends...!!',
        style: FontManager().getTextStyle(
          context,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      backgroundColor: Colors.black,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    var obj = jsonDecode(response.body);

    questionRoom.add(obj['data']);

    Navigator.pop(context);
    Navigator.pop(context);

    //   Navigator.pushReplacement(
    //   context,
    //   PageTransition(
    //     type: PageTransitionType.topToBottom,
    //      duration: Durations.long1,
    //     child: Poll(),
    //     isIos: true,
    //   ),
    // );
  } else {
    var snackBar = SnackBar(
      duration: Durations.medium4,
      content: Text(
        'An error occurred while uploading...!',
        style: FontManager().getTextStyle(
          context,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

void createPollOfCommunityPost(context, String question, List options,
    roomDetails, members, String type) async {
  String urlPath = '${url}/post/';
final TagList = [...selectedSubCategories, ...selectedCategories];
  var body = {'question': question, 'options': options, 'postType': "poll", 'tags':TagList};

  final response = await postDataApiCall(urlPath, body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = (json.decode(response.body));
    uploadRefreshCall(data, context);
    // Navigator.pop(context);
  } else {
    snackBarCalledSignup(
        context, " 'An error occurred while uploading...!'", Colors.red);
  }
}

void uploadRefreshCall(var postData, BuildContext context) {
 postController.feedPostList.insert(0, PostModel.fromJson(postData));
 postController.postCount[postData['_id']] = 0;
 postController.postCommentCount[postData['_id']] = 0;
 postController.posting.value = false;
 postController.postDis.value = false;
 postController.getPosted.value = !postController.getPosted.value;
}

void votePoll(context, String id, int index) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/poll/votePoll/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({'optionIndex': index}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    var snackBar = SnackBar(
      duration: Durations.long1,
      content: Text(
        'Your vote has been added!',
        style: FontManager().getTextStyle(
          context,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      backgroundColor: Colors.black,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {}
}

void votePollInPost(context, String id, int index) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/poll/votePollInPost/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({'optionIndex': index}),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    var data = body['data'];
    for (int i = 0; i < postController.feedPostList.length; i++) {
      if (postController.feedPostList[i].id == data['_id'])
      {
        PostModel post = postController.feedPostList[i];
        postController.feedPostList[i]= PostModel.fromJson({...data,'author': post.author});
        postController.getPosted.value = !postController.getPosted.value;
        return; // Stops loop after update
      }
    }
  } else {}
}

void updateRoom(
    context, List expenses, List user, String name, String id, admin) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse('${url}/room/update/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      "admin": admin,
      "name": name,
      "users": user,
      "expenses": expenses,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(
        context, "The room has been updated successfully!", Colors.black);
  } else {
    snackBarCalled(
        context, "An error occurred while updating the room!", Colors.red);
  }
}

void getChatLoader(bool flag) async {

  var response =await getDataApiCall(url + '/chat/order/${flag}');
  
  if (response.statusCode == 200 || response.statusCode == 201) {
    var his = jsonDecode(response.body);
    List obj = his['data'];

    chatList.clear();
    chatListOriginal.clear();
    totalUnopenedMessages.value = 0;
    int count = 0;
    obj.forEach((element) {
      try {
        var userInfo = element['chats']['details']['_id'];
        String name = (element['chats']['details']['name'] == null ||
                element['chats']['details']['name'] == "null")
            ? ""
            : element['chats']['details']['name'];
        String key = userInfo['sender'] == userController.userId.value
            ? userInfo['receiver']
            : userInfo['sender'];
        var typed = element['chats']['details']['messageType'];
        String type = "message...";
         bool canMaskMessage = ismaskedUsers.value? (element['chats']['details']['canMaskMessage'] ?? true):true;
        try {
          type = typed == null
              ? "message"
              : typed == "message"
                  ? element['chats']['details']['message']
                  : typed == "post"
                      ? "Sent a post"
                      : typed == "image"
                          ? "Sent a image"
                          : typed == "poll"
                              ? "Sent a poll" :
                           typed == "split"
                              ? "Sent a split bill"
                              : "message";
        } catch (e) {
         print(e); 
        }
       
       var data = 
       {
          '_id': key,
          'name': name,
          'avatar': element['chats']['details']['avatarType'],
          'item':  defaultBackGround.value ,
          'count': element['chats']['unseenCount'],
          'type': type,
          'canMaskMessage':canMaskMessage
        };
        count +=  int.parse(data['count'].toString());
        chatList.add(data);
        chatListOriginal.add(data);
      } catch (e) {
        print(e);
      }
    });

    totalUnopenedMessages.value = count;
  } else {}
}

void addMessage(
    context, String messageType, String message, String id, var data) async {
  var urlPath = Uri.parse('${url}/chat/');
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${urlPath}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      "messageType": messageType,
      "receiver": id,
      "message": message,
      "image": "base",
      "poll": id
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
  } else {}
}

void addChatSplitAmount(
    context, String splitName, String amount, String id, List addedUser) async {
  var urlPath = Uri.parse('${url}/chat/');
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  try {
    var jsonData = {
      "messageType": "split",
      "receiver": id,
      "sender": userController.userId.value,
      "message": null,
      "image": null,
      "poll": null,
      "post": null,
      "split": {
        "BillName": splitName,
        "Amount": amount,
        "Share": ((double.parse(amount) / (addedUser.length + 1)).toString()),
        "isPaid": false,
        "splitId": splitID.value,
      },
      "roomId": "",
    };
    final response = await http.post(
      Uri.parse('${urlPath}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {}
  } catch (e) {}
}

Future<String> addImageToCloud2(imageFile) async {
  final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');

  final request = http.MultipartRequest('POST', url2)
    ..fields['upload_preset'] = 'zu3td0li'
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response2 = await request.send();

  final responseData = await response2.stream.toBytes();

  final responseString = String.fromCharCodes(responseData);

  final jsonMap = jsonDecode(responseString);

  String urlPath = jsonMap['secure_url'];

  return urlPath;
}

void addMessageImage(context, String messageType, String messageObj, String id,
    File imageFile, data, me, socket, myId, roomIdVal) async {
  String urlPath = await addImageToCloud2(imageFile);
   print(urlPath);
  messages.insert(
      0,
      Message(
          text: messageObj,
          isMe: true,
          type: messageType,
          image: urlPath.toString(),
          poll: id));

  var imageJson = {
    "messageType": messageType,
    "receiver": id,
    "sender": me,
    "message": null,
    "image": urlPath,
    "poll": null,
    "post": null,
    "split": null,
    "roomId": roomIdVal,
    'isMasked': ismaskedUsers.value,
  };

  socket.emit("message", imageJson);
  socket.emit("LoadCharts", {
    "roomId": data['name'] + "" + data['name'],
    'isMasked': ismaskedUsers.value,
  });

   getChatLoader(ismaskedUsers.value);
   Navigator.pop(context);
}

void getChats2(data, key) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.get(
    Uri.parse('${url}/chat/${data['_id']}/${ismaskedUsers.value}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    List obj = his['data'];

    messagesTemp.clear();
    //  messages.clear();
    obj.forEach((element) {
      var postData = element['messageType'] == "post"
          ? element['post']['postLocation']
          : "";

      messagesTemp.insert(
          0,
          Message(
              text: element['message'],
              isMe: element['sender'] != data['_id'],
              type: element['messageType'],
              image: element['image'] ?? "",
              poll: element['poll'] ?? "poll",
              post: postData,
              split: element['split'] ?? ""));
    });

    chatOfUserListData[key] = messagesTemp;
  } else {}
}

void unSeenChat(context, String id) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse('${url}/chat/${id}/${ismaskedUsers.value}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );
}



void clear(data) {
  int index = 0;
  chatList.forEach(
    (element) {
      if (element['_id'] == data['_id']) {
        chatList[index]['count'] = 0;
      }
      index++;
    },
  );
}
