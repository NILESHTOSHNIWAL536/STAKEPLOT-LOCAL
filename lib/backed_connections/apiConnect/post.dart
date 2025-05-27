import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:http/http.dart' as http;

void addReply(context, String data, String postId) async {
  var body = {
    'commentId': postId,
    'replyText': data,
  };
  var response = await postDataApiCall('${url}/reply/', body);
  if (!getFlagOfResponse(response)) {
    snackBarCalled(context, SnackbarData().unableToAddReply, Colors.red);
  }
}

void deletePost(id, context) async {
  var responce = await deleteDataApiCall("${url}/post/${id}");
  if (getFlagOfResponse(responce)) {
    snackBarCalled(context, "Deleted Post");
  } else {
    snackBarCalled(context,SnackbarData().errorWhileDeletingPost);
  }
}
Future<String> postImageToCloud(imageFile, context) async {
  try {
    final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');
    // Upload image to Cloudinary
    final request = http.MultipartRequest('POST', url2)
      ..fields['upload_preset'] = 'zu3td0li'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response2 = await request.send();

    if (response2.statusCode != 200) {
      snackBarCalled(context,SnackbarData().imageUploadFailed, Colors.red);
      return 'Image upload failed';
    }

    final responseData = await response2.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonMap = jsonDecode(responseString);
    String urlPath = jsonMap['secure_url'];
    return urlPath;
  } catch (e) {
    return "";
  }
}

void reportPost(context, String id, String spam, String type,int index) async {
  var response = await postDataApiCall('${url}/user/report/${type}/$id', {'reason': spam});
  
  if (getFlagOfResponse(response)){
   
    snackBarCalled(
        context,
        spam == "hide post"
            ? SnackbarData().postHidden
            : SnackbarData().reportedSuccessfully,
        Colors.green
      );

    if(index>-1)clearPostReportHide(index);

  } else {
    snackBarCalled(context,SnackbarData().errorWhileReporting, Colors.red);
  }
  // getPost();
}

Future<Map<String, dynamic>> createPost(BuildContext context, String title,
    String description, File imageFile) async {
  try {
    String urlPath = await addImageToCloud2(imageFile);

    var body = {
      'title': title,
      'description': {'message': description},
      'image': urlPath,
      'fileName': ''
    };

    String apiCall = '${url}/post';

    var response = await postDataApiCall(apiCall, body);

    if (getFlagOfResponse(response)) {
      var postData = jsonDecode(response.body);
      uploadRefreshCall(postData, context);
      return {
        'success': true,
        'data': postData,
      };
    } else {
      snackBarCalled( context, "Server error: ${response.statusCode}", Colors.red);
      return {
        'success': false,
        'error': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    snackBarCalled(context,SnackbarData().errorCreatingPost, Colors.red);
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}

void createPostWithOutImage(context, String title, String description) async {
  var urlPath = '${url}/post/withOutImage';

  var body = {
    'title': title,
    'description': {
      'message': description,
    },
    'isPoll': false,
  };

  var response = await postDataApiCall(urlPath, body);

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    uploadRefreshCall(his, context);
  } else {}
}

void createPollOfCommunity(context, String title, String description) async {
  var urlPath = '${url}/createPollPost';

  var body = {
    'title': title,
    'description': {
      'message': description,
    },
    'isPoll': true,
  };

  var response = await postDataApiCall(urlPath, body);

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    uploadRefreshCall(his, context);
  } else {}

  postDis.value = false;
}



void getPost() async {
  var response = await getDataApiCall('${url}/post/feed');
  if (getFlagOfResponse(response)) {
   
    var his = jsonDecode(response.body); 
    var obj = his['data'];
    historyListData.clear();
    historyListData.addAll(obj);
    getTrendingData.clear();
    getTrendingData.addAll(obj);
    historyListData.forEach((element){
      postData[element["_id"]]=true;
      postCount[element["_id"]] = element['upvotes'];
      postCommentCount[element["_id"]] = element['comments'];
    });
    isPost.value = true;
  } else {}
}

void savePostData(context, data) async {
  var urlPath = "${url}/post/save";
  var body = {"postId": data['_id']};

  var response = await postDataApiCall(urlPath, body);

  if (getFlagOfResponse(response)) {
    snackBarCalled(context,SnackbarData().postSavedSuccessfully);
  } else {
    snackBarCalled(context,SnackbarData().failedToSavePost, Colors.red);
  }
}


