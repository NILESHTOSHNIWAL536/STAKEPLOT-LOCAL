

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';


void  getChats(data)async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
      // //print(data);
      // //print(data['_id']);
    final response = await http.get(
    
    Uri.parse('${url}/chat/${data['_id']}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
    
      if(response.statusCode==200)
      {
                  var  his=jsonDecode(response.body);
                  List obj=his['data'];

                  // //print("chat data");
                  // //print(obj);
                 messagesTemp.clear();
                 messages.clear();
              obj.forEach((element){ 
                var postData = element['messageType']=="post"? element['post']['postLocation']:"";
        
                 messages.insert(0, 
                 Message(
                  text: element['message'], 
                  isMe: element['sender']!=data['_id'],
                  type: element['messageType'],
                  image: element['image'] ??"",
                  poll:element['poll'] ?? "poll",
                  post: postData ,
                  split: element['split']??""

                 ));  

                
              });      
    
         messagesTemp.addAll(messages);
       
      }
      else{
         
      }
 
}


void upvote(context,String str,String objectId)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     
    final response = await http.post(
    Uri.parse('${url}/upvote/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'onModel': str.toString(),
            'objectId':objectId,
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
             snackBarCalled(context,"Liked!",Colors.black);
            //  sets
            //  Navigator.pop(context); 
            //  Navigator.pushNamed(context, '/TribeHome'); 
            
      }else{
           snackBarCalled(context,"error while Liked!",Colors.red);
      }

}

void downvote(context,String str,String objectId)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     
    final response = await http.post(
    Uri.parse('${url}/downvote/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'onModel': str.toString(),
            'objectId':objectId,
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
             snackBarCalled(context,"DisLiked!",Colors.black);

            //  Navigator.pop(context); 
            //  Navigator.pushNamed(context, '/home'); 
            
      }else{
           snackBarCalled(context,"error while DisLiked!",Colors.red);
      }

}

void mute(context,String type,String id)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
    final response = await http.post(
    Uri.parse('https://stakeplot.in/api/v1/user/mute'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'type': type,
            'id':id,
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
             snackBarCalled(context,"Muted...!",Colors.black);
      }else{
           snackBarCalled(context,"error while muting...!",Colors.red);
      }

}


void exitRoom(context,String id)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     //print("account");
    final response = await http.patch(
    Uri.parse('${url}/room/exit/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );
     printData(response, context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
              // Navigator.pushReplacement(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => RoomHome(),
              //         ),
              //     );
             getUserInfomations();
            //  room.clear();
             snackBarCalled(context,"exited from room...!",Colors.black);
      }else{
           snackBarCalled(context,"error while exiting...!",Colors.red);
      }

}

void createRoom(context,List expenses,List user,String name)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");

     
   var body={
            'name': name.toString(),
            'users':user,
            'expenses':expenses,
       };

       
    
   
    final response = await http.post(
    Uri.parse('${url}/room/add'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'name': name.toString(),
            'users':user,
            'expenses':expenses,
       }),
  );
      printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            snackBarCalled(context,"Room Is Created!",Colors.black);

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
            
      }else{
            final body = json.decode(response.body);
            String msg=body['error']['explanation'];
           snackBarCalled(context,msg,Colors.red);
      }
}



void createPoll(context,String question,List options,roomDetails,members,String type)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
   
    final response = await http.post(
    Uri.parse('${url}/poll/add'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'question': question,
            'options':options,
            'pollType':  type, //roomDetails.length!=0?'room':'casual',
            'roomDetails':roomDetails,
            'myVote':'none',
            'members':members
       }),
  );
  
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            var snackBar = SnackBar(
                    duration: Durations.long1,
                   content: Text('sending polls to Friends..!!',style: FontManager().getTextStyle(context,
                         color: Colors.white,
                         fontSize: 15,
                        
                   ),),
                   backgroundColor: Colors.black,
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              
              // //print(response.body);
              var obj=jsonDecode(response.body);
            // //print(obj['data']);

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
            
      }else{

           var snackBar = SnackBar(
                    duration: Durations.medium4,
                   content: Text('error while uploading...!',style: FontManager().getTextStyle(context,
                         color: Colors.white,
                         fontSize: 15,
                        
                   ),),
                   backgroundColor: Colors.red,
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
}

void createPollOfCommunityPost(context,String question,List options,roomDetails,members,String type)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
       var urlPath = Uri.parse('${url}/post/createPollPost');
    //  print(urlPath);
    final response = await http.post(
    Uri.parse('${urlPath}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode(
          {
            'question': question,
            'options':options,
            'pollType':  type, //roomDetails.length!=0?'room':'casual',
            'roomDetails':roomDetails,
            'myVote':'none',
            'title': "Poll is Added in the Post",
            'description':
            {
              'message':"description",
            },
            'isPoll':true,
          }
       ),
  );
  
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            var snackBar = SnackBar(
                    duration: Durations.long1,
                   content: Text('sending polls to Friends..!!',style: FontManager().getTextStyle(context,
                         color: Colors.white,
                         fontSize: 15,
                        
                   ),),
                   backgroundColor: Colors.black,
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              
              // //print(response.body);
              var obj=jsonDecode(response.body);
            // //print(obj['data']);

              questionRoom.add(obj['data']);
              getPost();

               Navigator.pop(context);
              //  Navigator.pop(context);
           
            Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.topToBottom,
               duration: Durations.long1,
              child: Community(),
              isIos: true,
            ),
          ); 
            
      }else{
           printData(response);
           var snackBar = SnackBar(
                    duration: Durations.medium4,
                   content: Text('error while uploading...!',style: FontManager().getTextStyle(context,
                         color: Colors.white,
                         fontSize: 15,
                        
                   ),),
                   backgroundColor: Colors.red,
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
}



void votePoll(context,String id,int index)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
    
    final response = await http.post(
    Uri.parse('${url}/poll/votePoll/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'optionIndex':index
       }),
  );
      printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            var snackBar = SnackBar(
                    duration: Durations.long1,
                   content: Text('Added Your Vote...!',style:FontManager().getTextStyle(context,
                         color: Colors.white,
                         fontSize: 15,
                        
                   ),),
                   backgroundColor: Colors.black,
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
 
            
      }else{
      }
}

void votePollInPost(context,String id,int index)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
    
    final response = await http.post(
    Uri.parse('${url}/poll/votePollInPost/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'optionIndex':index
       }),
  );
      printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            var snackBar = SnackBar(
                    duration: Durations.long1,
                   content: Text('Added Your Vote...!',style:FontManager().getTextStyle(context,
                         color: Colors.white,
                         fontSize: 15,
                        
                   ),),
                   backgroundColor: Colors.black,
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
 
            
      }else{
      }
}




void updateRoom(context,List expenses,List user,String name,String id,admin)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");

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
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            snackBarCalled(context,"Room Is Updated!",Colors.black);

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
            
      }else{

           snackBarCalled(context,"can't update  room error!",Colors.red);
      }
}

  void  getChatLoader()async
{
  
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    // //print("getChatLoader");
    final response = await http.get(
    Uri.parse(url+'/chat/users/order'),
    // Uri.parse(url+'/chat/un/viewed'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
    
    //  printData(response);
    print(userId);
    print(currentId.value);
    print(friendsListDetails);
      if(response.statusCode==200 || response.statusCode==201)
      {
                  var  his=jsonDecode(response.body);
                  List obj=his['data'];
                  // print(obj);
                 
                 chatList.clear();
                 chatListOriginal.clear();
               obj.forEach((element){
                   print(element);
                   try{
                      var userInfo=element['chats']['details']['_id'];
                      String key=userInfo['sender']==currentId.value?userInfo['receiver']:userInfo['sender'];
                      var typed=element['chats']['details']['messageType'];
                      String type="message...";
                      try{
                       type=typed==null?"message...":typed=="message"?
                      element['chats']['details']['message']:typed=="post"?"send a post...":typed=="image"?"send a image...":typed=="poll"?"send a poll...":"message...";
                      }catch(e){}

                    var data=
                    {
                         '_id':key,
                         'name':friendsListDetails[key]['name'],
                         'avatar':friendsListDetails[key]['avatar'],
                         'count': element['chats']['unseenCount'],
                         'type':type,
                    };
                     chatList.add(data);
                     chatListOriginal.add(data);
                  
                    
                   }catch(e){
                      print("error............in charts");
                      print(e);
                   }

                });
                
                // load.value=false;
                // reloadCharts.value=!reloadCharts.value;
         
      }
      else{
         
      }
 
}



void addMessage(context,String messageType,String message,String id,var data) async {
   var urlPath = Uri.parse('${url}/chat/');
  final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");

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
          "poll":id
    }),

  );


  if (response.statusCode == 200 || response.statusCode==201){
    // //print('Post created successfully')
  }else{
    // //print('Failed to create post: ${response.reasonPhrase}');
  }
  
}


// Future<String> addImageToCloud(imageFile)async
// {
  
          
            
//           String urlPath=jsonMap['secure_url'];

//    return urlPath;    
// }

Future<String> addImageToCloud2(imageFile)async
{
  
          final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');

          final request = http.MultipartRequest('POST', url2)

          ..fields['upload_preset'] = 'zu3td0li' ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

          final response2 = await request.send();

          final responseData = await response2.stream.toBytes();

          final responseString = String.fromCharCodes(responseData);

          final jsonMap = jsonDecode(responseString);
            
          String urlPath=jsonMap['secure_url'];

   return urlPath;    
}


void addMessageImage(context,String messageType,String messageObj,String id,File imageFile,data,me,socket,myId,roomIdVal) async {
   var urlChat= Uri.parse('${url}/chat/');
  final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");

// final url2 = Uri.parse('https://api.cloudinary.com/v1_1/deus5rcgl/upload');

// final request = http.MultipartRequest('POST', url2)

// ..fields['upload_preset'] = 'zu3td0li' ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

// final response2 = await request.send();

// final responseData = await response2.stream.toBytes();

// final responseString = String.fromCharCodes(responseData);

// final jsonMap = jsonDecode(responseString);
  
//  String urlPath=jsonMap['secure_url'];
  

   var urlPathData=await addImageToCloud(imageFile,context);
   List urlLocalPath=urlPathData.split("futureImagepathNileshBhaijan");
  
  String urlPath=urlLocalPath[0];
  String urlPath2=urlLocalPath[1];

messages.insert(0, Message( 
                  text: messageObj, 
                  isMe: true,
                  type:messageType,
                  image: urlPath.toString(),
                  poll:id)
    );
    

    // {
//     "messageType": "image",
//     "receiver": "66376959a9d930859de4695d",
//     "message": null,
//     "image": "www.image.com",
//     "poll": null,
//     "post" : null,
//     "split" : null
// }

    var imageJson={
    "messageType":messageType,
    "receiver":id,
     "sender": me,
    "message": null,
    "image": urlPath2,
    "poll": null,
    "post" : null,
    "split" : null,
    "roomId":roomIdVal,

};

    //  var jsonData={
    //                'text': messageObj, 
    //               'isMe': true,
    //               'type':messageType,
    //               'image': urlPath,
    //               'poll':id,
    //  };

     

     socket.emit("message",imageJson);
 

  final response = await http.post(
    Uri.parse('${urlChat}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
          "messageType": messageType,
          "receiver": id,
          "message": messageObj,
          "image": urlPath,
          "poll":id
    }),

  );




  if (response.statusCode == 200 || response.statusCode==201) {
    // //print('Post created successfully');

    messages.insert(0, Message( 
                  text: messageObj, 
                  isMe: true,
                  type:messageType,
                  image: urlPath.toString(),
                  poll:id)
    );
       
    // Navigator.pushReplacement(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => Chat( data:data,myId:me ,),
    //                   ),
    //               );

  } else {
    // snackBarCalled(context, "payload limit increase pls, share image with less size",Colors.red);
  }
  
}




void  getChats2(data,key)async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
      // //print(data);
      // //print(data['_id']);
    final response = await http.get(
    
    Uri.parse('${url}/chat/${data['_id']}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
    
      if(response.statusCode==200)
      {
                  var  his=jsonDecode(response.body);
                  List obj=his['data'];

                  // //print("chat data");
                  // //print(obj);
                 messagesTemp.clear();
                //  messages.clear();
              obj.forEach((element){ 
                var postData = element['messageType']=="post"? element['post']['postLocation']:"";
        
                 messagesTemp.insert(0, 
                 Message(
                  text: element['message'], 
                  isMe: element['sender']!=data['_id'],
                  type: element['messageType'],
                  image: element['image'] ??"",
                  poll:element['poll'] ?? "poll",
                  post: postData ,
                  split: element['split']??""

                 ));  

                
              });      
    
       
         chatOfUserListData[key]=messagesTemp;
        //  //print("chatOfUserListData ------------------------------");
        //  //print(chatOfUserListData);
      }
      else{
         
      }
 
}


void unSeenChat(context,String id)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
   
    final response = await http.post(
    Uri.parse('${url}/chat/updateUnseen/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );
  //print(response.body);
}




  void  getPolls(id)async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    final response = await http.get(
    Uri.parse('https://stakeplot.in/api/v1/poll/room/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
      if(response.statusCode==200)
      {
                  var  his=jsonDecode(response.body);
                  var obj=his['data'];
                  
                    questionRoom.clear();
                    questionRoom.addAll(obj);

                  
                 
      }
      else{
      }
}


 void clear(data){
    int index=0;
                  chatList.forEach((element) {
                         if(element['_id']==data['_id']){
                            chatList[index]['count']=0;
                         }
                         index++;
                  },);
  }


