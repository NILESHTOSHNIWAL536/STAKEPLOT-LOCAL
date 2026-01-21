import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:flutter_application_code_stakeplot/user_chat/message.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/route_chat.dart';
import '../routes/route_post.dart';

void getChats(data) async {
  final response = await getDataApiCall(ChatRoutes.retrieveChatMessages(
      Id: data['_id'], isMasked: ismaskedUsers.value));

  if (getFlagOfResponse(response)) {
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
  final response = await postDataApiCall(UpvoteRoute.upvote, {
    'onModel': str.toString(),
    'objectId': objectId,
  });

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "You liked this!", AppColors.accentColor);
  } else {
    snackBarCalledfail(context, "An error occurred while liking!", Colors.red);
  }
}

void downvote(context, String str, String objectId) async {
  final response = await postDataApiCall(DownvoteRoute.downvote, {
    'onModel': str.toString(),
    'objectId': objectId,
  });

  if (getFlagOfResponse(response)) {
    final body = json.decode(response.body);
    snackBarCalled(context, "You disliked this!", AppColors.accentColor);
  } else {
    snackBarCalledfail(
        context, "An error occurred while disliking!", Colors.red);
  }
}


void createPollOfCommunityPost(context, String question, List options,
    roomDetails, members, String type) async {
  String urlPath = PostRoutes.post;
  final TagList = [...selectedSubCategories, ...selectedCategories];
  var body = {
    'question': question,
    'options': options,
    'postType': "poll",
    'tags': TagList
  };

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

void votePollInPost(context, String id, int index) async {
  // final response = await postDataApiCall('${url}/poll/votePollInPost/${id}', {'optionIndex': index});
  final response = await postDataApiCall(pollRoute.votePollInPost(postId: id), {'optionIndex': index});

  if (getFlagOfResponse(response)) {
    final body = json.decode(response.body);

    var data = body['data'];
    for (int i = 0; i < postController.feedPostList.length; i++) {
      if (postController.feedPostList[i].id == data['_id']) {
        PostModel post = postController.feedPostList[i];
        postController.feedPostList[i] =
            PostModel.fromJson({...data, 'author': post.author});
        postController.getPosted.value = !postController.getPosted.value;
        return; // Stops loop after update
      }
    }
  } else {}
}

void getChatLoader(bool flag) async {
  var response = await getDataApiCall(ChatRoutes.chatsOrder(isMasked: flag));

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
        bool canMaskMessage = ismaskedUsers.value
            ? (element['chats']['details']['canMaskMessage'] ?? true)
            : true;
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
                              ? "Sent a poll"
                              : typed == "split"
                                  ? "Sent a split bill"
                                  : "message";
        } catch (e) {}

        var data = {
          '_id': key,
          'name': name,
          'avatar': element['chats']['details']['avatarType'],
          'item': defaultBackGround.value,
          'count': element['chats']['unseenCount'],
          'type': type,
          'canMaskMessage': canMaskMessage
        };
        count += int.parse(data['count'].toString());
        chatList.add(data);
        chatListOriginal.add(data);
      } catch (e) {}
    });

    totalUnopenedMessages.value = count;
  } else {}
}

void addMessage(
    context, String messageType, String message, String id, var data) async {
  var urlPath = ChatRoutes.sendMessage;
  await postDataApiCall(urlPath, {
    "messageType": messageType,
    "receiver": id,
    "message": message,
    "image": "base",
    "poll": id
  });
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
  // final response = await getDataApiCall('${url}/chat/${data['_id']}/${ismaskedUsers.value}');
  final response = await getDataApiCall(ChatRoutes.retrieveChatMessages(
      Id: data['_id'], isMasked: ismaskedUsers.value));

  if (getFlagOfResponse(response)) {
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
  String urlpath = ChatRoutes.updateUnseenMessages(friendId: id, isMasked: ismaskedUsers.value);
   await updateDataApiCall2(urlpath, {});
  // final response = await updateDataApiCall2('${url}/chat/${id}/${ismaskedUsers.value}', {});
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
