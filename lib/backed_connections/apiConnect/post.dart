import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:http/http.dart' as http;

void addReply(context, String data, String commentId, String postId) async {
  var body = {'comment': commentId, 'reply': data, 'post': postId};
  var response = await postDataApiCall('${url}/reply/', body);
  if (!getFlagOfResponse(response)) {
    snackBarCalledfail(context, SnackbarData().unableToAddReply, Colors.red);
  }
}

void deletePost(id, context) async {
  var responce = await deleteDataApiCall("${url}/post/${id}");

  if (getFlagOfResponse(responce)) {
    snackBarCalled(context, "Deleted Post");
  } else {
    snackBarCalledfail(context, SnackbarData().errorWhileDeletingPost);
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
      snackBarCalledfail(context, SnackbarData().imageUploadFailed, Colors.red);
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

void reportPost(context, String id, String spam, String type, int index) async {
  var response =
      await postDataApiCall('${url}/user/report/${type}/$id', {'reason': spam});

  if (getFlagOfResponse(response)) {
    snackBarCalled(
        context,
        spam == "hide post"
            ? SnackbarData().postHidden
            : SnackbarData().reportedSuccessfully,
        );

    clearPostReportHide(index,context);
  } else {
    snackBarCalledfail(context, SnackbarData().errorWhileReporting, Colors.red);
  }
  // getPost();
}

Future<Map<String, dynamic>> createPost(
  BuildContext context,
  String title,
  String description,
  File imageFile,
  bool cropShape,
) async {
  try {
    String urlPath = await addImageToCloud2(imageFile);

    final TagList = [...selectedSubCategories, ...selectedCategories];

    var body = {
      'description': description,
      'image': urlPath,
      'tags': TagList,
      'postType': 'image',
      'isSquareImage': cropShape,
    };

    String apiCall = '${url}/post';

    var response = await postDataApiCall(apiCall, body);

    if (getFlagOfResponse(response)) {
      clearInterest();
      var postData = jsonDecode(response.body);
      uploadRefreshCall(postData, context);
      return {
        'success': true,
        'data': postData,
      };
    } else {
      snackBarCalledfail(
          context, SnackbarData().errorCreatingPost, Colors.red);
      return {
        'success': false,
        'error': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    clearInterest();
    snackBarCalledfail(context, SnackbarData().errorCreatingPost, Colors.red);
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}

void createPostWithOutImage(context, String title, String description) async {
  var urlPath = '${url}/post/';
  final TagList = [...selectedSubCategories, ...selectedCategories];

  var body = {
    'title': title,
    'description': description,
    'tags': TagList,
    "postType": "write"
  };

  var response = await postDataApiCall(urlPath, body);

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    uploadRefreshCall(his, context);
  } else {}
  clearInterest();
  Navigator.pop(context);
}

void createPollOfCommunity(context, String title, String description) async {
  var urlPath = '${url}/createPollPost';
  final TagList = [...selectedSubCategories, ...selectedCategories];

  var body = {
    'title': title,
    'description': {
      'message': description,
    },
    'isPoll': true,
    'tags': TagList
  };

  var response = await postDataApiCall(urlPath, body);

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    uploadRefreshCall(his, context);
  } else {}

  clearInterest();
  postController.postDis.value = false;
}

Future<void> getPost(context) async {
  var response =
      await getDataApiCall('${url}/post/feed/${postController.currentPageFeed.value}');
  expire(response, context);
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];

    historyListData.clear();
    historyListData.addAll(obj);
    // getTrendingData.clear();
    // postController.getTrendingData.addAll(obj);
    List<PostModel> postList= PostModel.listFromJson(historyListData);
    postController.feedPostList.addAll(postList);

    if (historyListData.length < 5) {
      postController.hasMorePostFeed.value = false;
    }
    postController.currentPageFeed.value++;
    historyListData.forEach((element) {
      postController.postData[element["_id"]] = true;
      postController.postCount[element["_id"]] = element['upvotes'];
      postController.postCommentCount[element["_id"]] = element['comments'];
    });
    postController.isPostloading.value = false;
    postController.isPost.value = true;
  } else {}
}

Future<void> getTranding(context) async {
  var response =
      await getDataApiCall('${url}/post/trending/${postController.currentPageTranding.value}');
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    historyListData.clear();
    historyListData.addAll(obj);
    List<PostModel> postList= PostModel.listFromJson(historyListData);
    postController.trandingPostList.addAll(postList);

    if (historyListData.length < 5) {
      postController.hasMorePostTranding.value = false;
    }
    postController.currentPageTranding.value++;
    historyListData.forEach((element) {
      postController.postData[element["_id"]] = true;
      postController.postCount[element["_id"]] = element['upvotes'];
      postController.postCommentCount[element["_id"]] = element['comments'];
    });
    postController.isPostloading.value = false;
    postController.isPostTranding.value = true;
  }
}

void savePostData(context,PostModel data) async {
  var urlPath = "${url}/post/save/${data.id}";
  var body = {"postId": data.id};
  var response = await postDataApiCall(urlPath, body);
  var decodedResponse = json.decode(response.body);

  if (getFlagOfResponse(response) ) {
    snackBarCalled(context, decodedResponse['data'].toString());
    getSaved();
  } else {
    snackBarCalledfail(context, SnackbarData().failedToSavePost, Colors.red);
  }
}

Future<List<dynamic>> savePostGetData(context) async {
  try {
    var urlPath = "${url}/post/saved";

    var response = await getDataApiCall(urlPath);

    if (getFlagOfResponse(response)) {
      var responseData = jsonDecode(response.body); // Decode the response body

      return responseData['data'] ?? [];
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}


  void getpost(id) async
  {
    var response=await getDataApiCall('${url}/post/${id}');
    if (getFlagOfResponse(response))
     {
      var his = jsonDecode(response.body);
      var obj = his['data'];
       postController.uniquePostDeatils = PostModel.fromJson(obj[0]);
    } else {}   
  }