import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

void store(response) {
  getPost();
}

void addReply(context, String data, String postId) async {
  var body = {
    'commentId': postId,
    'replyText': data,
  };
  var response = await postDataApiCall('${url}/reply/', body);
  if (!getFlagOfResponse(response)) {
    snackBarCalled(context, "Unable to add reply.", Colors.red);
  }
}

void addPost2(context, String title, String description, File obj) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  var link = Uri.parse('$url/post/');

  // Create a new multipart request
  var request = http.MultipartRequest('POST', link);

  // Add the image file
  request.files.add(await http.MultipartFile.fromPath(
    'image',
    obj.path,
    // contentType: MediaType('image', 'jpg'), // Specify the image content type
  ));

  // Add other form fields
  request.fields['title'] = title;
  request.fields['description'] = description;

  // Set the authorization header
  request.headers['Authorization'] = '$accessToken';

  try {
    // Send the request and get the response
    var streamedResponse = await request.send();

    // Handle the response
    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      // Request successful

      Navigator.pushNamed(context, '/TribeHome');
    } else {
      // Request failed

      final snackBar = SnackBar(
        duration: Duration(seconds: 4),
        content: Text(
          'Failed to upload the image: ${streamedResponse.reasonPhrase}.',
          style: FontManager().getTextStyle(context, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  } catch (e) {
    // Handle errors

    final snackBar = SnackBar(
      duration: Duration(seconds: 4),
      content: Text(
        'An error occurred while uploading the image: $e.',
        style: FontManager().getTextStyle(context, color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

void addPost(context, String title, String description, File obj) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  //   List<int> imageBytes = await obj.readAsBytes();
  //    var bytes = obj.readAsBytesSync();

  // // Encode image bytes to base64
  // String base64Image = base64Encode(imageBytes);

  var imageBytes = obj.readAsBytesSync();
  // var base64Image = compressImage(imageBytes);
  var base64Image = base64Encode(imageBytes);

  final response = await http.post(
    Uri.parse('${url}/post'),
    headers: <String, String>{
      'Content-Type': 'multipart/form-data',
      //  'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'title': title,
      'description': description,
      'imageBase64': base64Image,
      'fileName': 'file7'
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    var snackBar = SnackBar(
      duration: Durations.long1,
      content: Text(
        'Budget added successfully!',
        style: FontManager().getTextStyle(
          context,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      backgroundColor: Colors.black,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    //  Navigator.pop(context);
    Navigator.pushNamed(context, '/TribeHome');
  } else {
    var snackBar = SnackBar(
      duration: Durations.medium4,
      content: Text(
        'Invalid credentials provided.',
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

void reportPost(context, String id, String spam) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.post(
    Uri.parse('${url}/user/report/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({'reason': spam}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(
        context,
        spam == "hide post"
            ? "The post has been hidden from you."
            : "Reported successfully.",
        Colors.green);
    // Navigator.pop(context);
    // Get.back();
  } else {
    snackBarCalled(context, "An error occurred while reporting.", Colors.red);
  }

  getPost();
  getTrending();
}

void createPostCopy(
    context, String title, String description, File imageFile) async {
  var url = Uri.parse('https://stakeplot.in/api/v1/post');
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final bytes = io.File(imageFile.path).readAsBytesSync();
  String base64Image = base64Encode(bytes);

  String fileExtension = p.extension(imageFile.path);
  fileExtension = fileExtension.substring(1);
  // data:image/png;base64,
  String base = "data:image/${fileExtension};base64," + base64Image.toString();

  final response = await http.post(
    Uri.parse('${url}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'title': title,
      'description': {'message': description},
      'imageBase64':
          base, //"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA5CAYAAABqMUjBAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAADDSURBVHgB7dnLCcJAFEbh/44WYCm+3amlaAVqB3YgVqC1uHMhWIKNyDW+CnCERG/OB5NkE4bDwMAwEgAAAAD8qu5gvOkXQxVoqgJmtvTn50olS6oZgqMjODqCoyM4OoKjq12wKVNvNF4Uv7eVwzV7zb5XFj+fjoetMuSfltzWxbOlb7zDP/ZYp3KDr8k66aqpMpj57v52t7kypIYu+ie94cTvQxVgl46O4OgIjo7g6AiOjuDoKrlM85R3SgIAAACA0twANp8cFnCd2FoAAAAASUVORK5CYII=",
      'fileName': 'file7'
    }),
  );

  // Send a multipart request
  // var request = http.MultipartRequest('POST', url);
  // request.fields.addAll(requestBody);
  // request.files.add(await http.MultipartFile.fromPath('fileName', imageFile.path));

  // Send the request
  // var response = await request.send();

  // //print("response.statusCode");
  // //print(response.statusCode);
  // //print(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    // //print('Post created successfully');
  } else {
    // //print('Failed to create post: ${response.reasonPhrase}');
  }
}

Future<void> onUploadImage(
  File selectedImage,
  BuildContext context,
  String title,
  String description,
) async {
  try {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    final String? accessToken = _pref.getString("accessToken");
    if (accessToken == null) {
      throw Exception("Access token is missing.");
    }

    final Uri urlp = Uri.parse("${url}/post");

    final Uint8List imageBytes = await selectedImage.readAsBytes();

    var request = http.MultipartRequest('POST', urlp)
      ..headers['Authorization'] = '$accessToken'
      ..fields['title'] = title
      ..fields['description'] = description
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: selectedImage.path.split('/').last,
        contentType: MediaType('image', selectedImage.path.split('.').last),
      ));

    final http.StreamedResponse response = await request.send();

    // Handle the response
    if (response.statusCode == 201) {
      // print("Image uploaded successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully!")),
      );
    } else {
      // print("Failed to upload image. Status code: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Failed to upload image. Status code: ${response.statusCode}")),
      );
    }
  } catch (e) {
    // print("Error occurred: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("An error occurred while uploading the image.")),
    );
  }
}

void onUploadImage2(File selectedImage, BuildContext context, String title,
    String description) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final urlp = "${url}/post"; // Replace with your actual URL
  var request = http.MultipartRequest('POST', Uri.parse(urlp));

  // Add headers
  request.headers.addAll({
    "Content-type": "multipart/form-data",
    "Authorization": "$accessToken",
  });

  // Add fields
  request.fields['title'] = title;
  request.fields['description'] = description;

  request.files.add(
    await http.MultipartFile.fromPath(
      'image', // Backend expects 'image' as the key
      selectedImage.path,
    ),
  );
  // Send the request
  var res = await request.send();
  try {
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Failed to upload image. Status code: ${res.statusCode}")),
      );
    }
  } catch (e) {
    // print("Error occurred: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred while uploading the image.")),
    );
  }
}

void sn(res, context) {
  try {
    if (res.statusCode == 200) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Image uploaded successfully!")),
      // );
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content:
      //           Text("Failed to upload image. Status code: ${res.statusCode}")),
      // );
    }
  } catch (e) {
    // print("Error occurred: $e");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   // SnackBar(content: Text("An error occurred while uploading the image.")),
    // );
  }
}

// void createPost(context,String title, String description, File imageFile) async {

//    print("createPost.....");
//   var urlPathss = Uri.parse('${url}/post');
//   final SharedPreferences _pref = await SharedPreferences.getInstance();
//   var  accessToken=_pref.getString("accessToken");

// final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');

// final request = http.MultipartRequest('POST', url2)

// ..fields['upload_preset'] = 'zu3td0li' ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

// final response2 = await request.send();

// if (response2.statusCode == 200)
// {

//     final responseData = await response2.stream.toBytes();
//     final responseString = String.fromCharCodes(responseData);
//     final jsonMap = jsonDecode(responseString);

//  String urlPath=jsonMap['secure_url'];

//   print("url");
//  var body={
//            'title': title,
//            'description':
//           {
//             'message':description
//           },
//           'image':urlPath,// base,//"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA5CAYAAABqMUjBAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAADDSURBVHgB7dnLCcJAFEbh/44WYCm+3amlaAVqB3YgVqC1uHMhWIKNyDW+CnCERG/OB5NkE4bDwMAwEgAAAAD8qu5gvOkXQxVoqgJmtvTn50olS6oZgqMjODqCoyM4OoKjq12wKVNvNF4Uv7eVwzV7zb5XFj+fjoetMuSfltzWxbOlb7zDP/ZYp3KDr8k66aqpMpj57v52t7kypIYu+ie94cTvQxVgl46O4OgIjo7g6AiOjuDoKrlM85R3SgIAAACA0twANp8cFnCd2FoAAAAASUVORK5CYII=",
//           'fileName':'file7'
//        };
//   print(body);
//   print(urlPath);

//   final bytes = io.File(imageFile.path).readAsBytesSync();

//   String base64Image = base64Encode(bytes);

//   String fileExtension = p.extension(imageFile.path);
//   fileExtension=fileExtension.substring(1);
//   // data:image/png;base64,
//   String base="data:image/${fileExtension};base64,"+base64Image.toString();

//   final response = await http.post(
//     Uri.parse('${urlPathss}'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//        "Authorization": "$accessToken",
//     },
//     body: jsonEncode(body),
//   );

//   if (response.statusCode == 200 || response.statusCode==201) {
//             store(response);
//     // //print('Post created successfully');
//             //   Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
//             // getPost();
//             //  Navigator.pushReplacement(
//             //                         context,
//             //                         PageTransition(
//             //                           type: PageTransitionType.fade,
//             //                           alignment: Alignment.bottomRight,
//             //                           duration: Durations.long1,

//             //                           child:const TribeHome(),
//             //                           isIos: true,
//             //                         ));
//   } else {
//     // //print('Failed to create post: ${response.reasonPhrase}');
//   }

//   getPost();
//   getTrending();
//     postDis.value=false;

// }else{
//     snackBarCalled(context, "server error",Colors.red);
// }
// this code is without future
// void createPost(
//     context, String title, String description, File imageFile) async {
//   var urlp = Uri.parse('${url}/post');
//   final SharedPreferences _pref = await SharedPreferences.getInstance();
//   var accessToken = _pref.getString("accessToken");

//   final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');

//   final request = http.MultipartRequest('POST', url2)
//     ..fields['upload_preset'] = 'zu3td0li'
//     ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

//   final response2 = await request.send();

//   if (response2.statusCode == 200) {
//     final responseData = await response2.stream.toBytes();

//     final responseString = String.fromCharCodes(responseData);

//     final jsonMap = jsonDecode(responseString);

//     String urlPath = jsonMap['secure_url'];

//     var body = {
//       'title': title,
//       'description': {'message': description},
//       'image':urlPath,
//       'fileName': ''
//     };

//     final response = await http.post(
//       Uri.parse('${urlp}'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         "Authorization": "$accessToken",
//       },
//       body: jsonEncode(body),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201)
//      {
//       var his = jsonDecode(response.body);
//       getTrendingData.insert(0, his);
//       getPosted.value = ! getPosted.value;
//       postCount[his["_id"]] = 0;
//       postCommentCount[his["_id"]] = 0;
//     }

//     posting.value=false;
//     postDis.value = false;
//   } else {
//     snackBarCalled(context, "server error", Colors.red);
//   }

// }
Future<Map<String, dynamic>> createPost(BuildContext context, String title,
    String description, File imageFile) async {
  try {
    // Cloudinary upload URL
    final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var accessToken = pref.getString("accessToken");

    // Upload image to Cloudinary
    final request = http.MultipartRequest('POST', url2)
      ..fields['upload_preset'] = 'zu3td0li'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response2 = await request.send();

    if (response2.statusCode != 200) {
      snackBarCalled(context, "Image upload failed", Colors.red);
      return {'success': false, 'error': 'Image upload failed'};
    }

    final responseData = await response2.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonMap = jsonDecode(responseString);
    String urlPath = jsonMap['secure_url'];

    // Prepare post data
    var body = {
      'title': title,
      'description': {'message': description},
      'image': urlPath,
      'fileName': ''
    };

    // Make post request
    final urlp =
        Uri.parse('${url}/post'); // Make sure 'url' is defined somewhere
    final response = await http.post(
      urlp,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var postData = jsonDecode(response.body);

      // Update local state
      getTrendingData.insert(0, postData);
      getPosted.value = !getPosted.value;
      postCount[postData["_id"]] = 0;
      postCommentCount[postData["_id"]] = 0;

      posting.value = false;
      postDis.value = false;

      return {
        'success': true,
        'data': postData,
      };
    } else {
      snackBarCalled(
          context, "Server error: ${response.statusCode}", Colors.red);
      return {
        'success': false,
        'error': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    snackBarCalled(context, "Error creating post: $e", Colors.red);
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}

// Send a multipart request
// var request = http.MultipartRequest('POST', url);
// request.fields.addAll(requestBody);
// request.files.add(await http.MultipartFile.fromPath('fileName', imageFile.path));

// Send the request
// var response = await request.send();

// //print("response.statusCode");
// //print(response.statusCode);
// //print(response.body);

// }

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
    getTrendingData.insert(0, his);
    getPosted.value = !getPosted.value;
    postCount[his["_id"]] = 0;
    postCommentCount[his["_id"]] = 0;
  }
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
    getTrendingData.insert(0, his);
    getPosted.value = !getPosted.value;
    postCount[his["_id"]] = 0;
    postCommentCount[his["_id"]] = 0;
  } else {}
  postDis.value = false;
}

void getTrending() async {
  var response = await getDataApiCall('${url}/post/feed');

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    getTrendingData.clear();
    getTrendingData.addAll(obj);
    if (getTrendingData.length == 0) {
      findTranding = false;
    }
    getTrendingData.forEach((element) {
      postCount[element["_id"]] =
          element['upvotes'] < 0 ? 0 : element['upvotes'];
    });
  } else {}
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
    historyListData.forEach((element) {
      postCount[element["_id"]] = element['upvotes'];
      postCommentCount[element["_id"]] = element['comments'];
    });
  } else {}
}

void getExploria() async {
  var response = await getDataApiCall('${url}/exploria/');
  print("exploria response: $response"); // Already present
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    print("exploria data: $obj"); // Add this to see the raw data
    historyExploriaListData.clear();
    historyExploriaListData.addAll(obj);
    getExploriaTrendingData.clear();
    getExploriaTrendingData.addAll(obj);
    historyExploriaListData.forEach((element) {
      print("exploria post: ${element['_id']} - place: ${element['place']}, tripHighlight: ${element['tripHighlight']}"); // Log each post’s keys
      postExploriaCount[element["_id"]] = element['upvotes'];
      postExploriaCommentCount[element["_id"]] = element['comments'];
    });
  } else {
    print("exploria fetch failed: ${response.statusCode}");
  }
}

void savePostData(context, data) async {
  var urlPath = "${url}/post/save";
  var body = {"postId": data['_id']};

  var response = await postDataApiCall(urlPath, body);

  if (getFlagOfResponse(response)) {
    snackBarCalled(context, 'Post saved successfully.');
  } else {
    snackBarCalled(context, 'Failed to save the post.', Colors.red);
  }
}

void postItenary(title, s, type, context) async {
  var urlPath = "${url}/post";
  var body = {
    "title": title,
    "description": {"itemlist": s},
    "chartType": type,
  };
  var response = await postDataApiCall(urlPath, body);
  if (getFlagOfResponse(response)) {
    store(response);
    snackBarCalled(context, 'Post created successfully.');
  } else {
    snackBarCalled(context, 'Failed To Save Post...!', Colors.red);
  }

  getPost();
  getTrending();
  postInter.value = false;
}

void addMessageImagePost(context, String name, String avatar, String id,
    File imageFile, String filenmae) async {
  var url = Uri.parse('https://stakeplot.in/api/v1/room/addroombills/$id');
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');

  final request = http.MultipartRequest('POST', url2)
    ..fields['upload_preset'] = 'zu3td0li'
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response2 = await request.send();

  final responseData = await response2.stream.toBytes();

  final responseString = String.fromCharCodes(responseData);

  final jsonMap = jsonDecode(responseString);

  String urlPath = jsonMap['secure_url'];

  // roomBills.add({
  //     '':urlPath,
  //     '':avatar,
  // });

  final response = await http.patch(Uri.parse('${url}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        "billName": filenmae,
        "billImage": urlPath,
        "author": name,
        "avatar": avatar
      }));

  if (response.statusCode == 200 || response.statusCode == 201) {
    var data = jsonDecode(response.body);
    roomBills.clear();
    roomBills.addAll(data['data']['bills']);
    snackBarCalled(context, "Added Bill To Room!", Colors.black);
  } else {
    snackBarCalled(context, "Can't Add Bill !", Colors.red);
  }
}

Future<String> addImageToCloud(
  File selectedImage,
  BuildContext context,
) async {
  Future<String> imageNameUrl = Future.value("");
  try {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    final String? accessToken = _pref.getString("accessToken");
    if (accessToken == null) {
      throw Exception("Access token is missing.");
    }

    final Uri urlp = Uri.parse("${url}/chat/post-image");

    final Uint8List imageBytes = await selectedImage.readAsBytes();

    var request = http.MultipartRequest('POST', urlp)
      ..headers['Authorization'] = '$accessToken'
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: selectedImage.path.split('/').last,
        contentType: MediaType('image', selectedImage.path.split('.').last),
      ));

    final http.StreamedResponse response = await request.send();

    // Handle the response
    if (response.statusCode == 201 || response.statusCode == 200) {
      //  var data=jsonDecode(response['data']);
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      imageNameUrl = Future.value(data['data']['imageUrl'] +
          "futureImagepathNileshBhaijan" +
          data['data']['filename']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully!")),
      );
    } else {
      // print("Failed to upload image. Status code: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Failed to upload image. Status code: ${response.statusCode}")),
      );
    }
  } catch (e) {
    // print("Error occurred: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("An error occurred while uploading the image.")),
    );
  }
  return imageNameUrl;
}

void deletePost(id, context) async {
  var responce = await deleteDataApiCall("${url}/post/delete/${id}");
  if (getFlagOfResponse(responce)) {
    snackBarCalled(context, "Deleted Post...");
  } else {
    snackBarCalled(context, "Error while Deleting Post...");
  }
}


Future<String> postImageToCloud(imageFile,context)async{

  try{
   final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');
    // Upload image to Cloudinary
    final request = http.MultipartRequest('POST', url2)
      ..fields['upload_preset'] = 'zu3td0li'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response2 = await request.send();

    if (response2.statusCode != 200) {
      snackBarCalled(context, "Image upload failed", Colors.red);
      return 'Image upload failed';
    }

    final responseData = await response2.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonMap = jsonDecode(responseString);
    String urlPath = jsonMap['secure_url'];
    return urlPath;
  }catch(e){
      return "";
  }
}
