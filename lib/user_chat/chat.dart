import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/exploreCard.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/Tribe/userDetails.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart';
import 'package:flutter_application_code_stakeplot/user_chat/fullScreen.dart';
import 'package:get/get_rx/get_rx.dart';
// import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

late IO.Socket socket;

class Chat extends StatefulWidget {
  var data;
  var myprofile;
  String myId;
  Chat(
      {Key? key,
      required this.data,
      required this.myId,
      required this.myprofile})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _textController =
      TextEditingController(); // Controller for text input
  TextEditingController search = TextEditingController();
  var data;
  int counter = 0;
  Timer? timer;
  RxString roomId = "".obs;
  RxBool online = false.obs;

  FocusNode myFocusNode = FocusNode();

  String path = "assets/avatar/menp1.svg";
  ValueNotifier<bool> onlineUser = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    data = widget.data;
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    String room1 = userName.value + data['name'];
    String room2 = data['name'] + userName.value;

    roomId.value = (room1.compareTo(room2) <= 0) ? room1 : room2;

    getChats(data);
    path = avatar.value; //widget.myprofile['avatarType'];
    // socket=SocketIOManager().createSocketIO(
    //     urlWithLocallHost, '/',
    //     query: 'chatID=${data['_id']}');
    // socket = IO.io("https://stakeplot.in/",IO.OptionBuilder().setTransports(['websocket']).enableForceNewConnection().build());
    // if (socket.connected) {
    //     socket.disconnect();
    //     socket.close();
    //  }
    // socket = IO.io(urlWithLocallHost, IO.OptionBuilder()
    //   .setQuery({'chatID': data['_id']})
    //   .setTransports(['websocket'])
    //   .disableAutoConnect()
    //   .build());
    // socket=IO.io(url,IO.OptionBuilder().setTransports(['websocket']).setPath("/io").disableAutoConnect().build());

    // initFunt();
    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    socket.connect();
    setUpSocketListener();
  }

  @override
  void dispose() {
    // Close the socket connection when the widget is disposed
    if (socket != null) {
      socket.disconnect();
      socket.destroy();
    }
    super.dispose();
  }

  setUpSocketListener() {
    socket.onConnect((_) {
      socket.emit("joinRoom", roomId.value);
      socket.emit("online", roomId.value);
    });

    socket.onConnectError((data) {});

    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
            });

    socket.on(
        'online',
        (res) => {
              onlineUser.value = true,
            });

    socket.on(
        "message",
        (data2) => {
              if (roomId == data2['roomId'])
                messages.insert(
                    0,
                    Message(
                        text: data2['message'] ?? "",
                        isMe: false,
                        type: data2['messageType'] ?? "message",
                        image: data2['image'] ?? "",
                        poll: data2['poll'] ?? "poll",
                        split: data2['split'] ?? "",
                        post: data2['messageType'] == "post"
                            ? data2['post']['postLocation']
                            : ""
                        // post:  postData,//data2['messageType']=="post"? (data2['post']['postLocation'])??"":"",
                        )),
              unSeenChat(context, data['_id']),
              getChatLoader(),
              getChats(widget.data),
            });
  }

  void _handleSubmitted(String text) {
    _textController.clear();

    var jsonData = {
      "messageType": "message",
      "receiver": data['_id'],
      "sender": widget.myId,
      "receiverChatID": data['_id'],
      "senderChatID": widget.myId,
      "message": text,
      "image": null,
      "poll": null,
      "post": null,
      "split": null,
      "roomId": roomId.value,
    };

    messages.insert(
        0,
        Message(
            text: text,
            isMe: true,
            type: "message",
            image: data['image'] ?? "",
            poll: ""));

    search.clear();
    // socket.emit('register',  data['_id']);

    socket.emit("message", jsonData);
    socket.emit("LoadCharts", {
      "roomId": data['name'] + "" + data['name'],
    });
    
  }

  Widget getDataWidget(Message message) {
    if (message.type == "message") {
      return text(message.text, message.isMe);
    } else if (message.type == "poll") {
      return polled(
        message.isMe,
        message.poll,
      );
    } else if (message.type == "image") {
      return imageDisplay(message.text, message.isMe, message.image);
    } else if (message.type == "post") {
      // var dataObj = jsonDecode(message.post);

      // if (dataObj['isPoll'])
      //   return polled(
      //     message.isMe,
      //     dataObj['pollData'],
      //   );

      return postDisplay(message.text, message.isMe, message.image, message);
    } else if (message.type == "split") {
      return spliDisplay(message.text, message.isMe, message.image, message);
    }

    return Text("polled");
  }

  Widget postDisplay(msg, bool, url, Message message) {
    return bool
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uploadData((message.post)),
              // PostCard(data: message.post),
              profilepath(bool),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profilepath(bool),
              uploadData((message.post)),
              //  PostCard(data: message.post),
            ],
          );
  }

  Widget spliDisplay(msg, bool, url, Message message) {
    return bool
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spliData(message),
              profilepath(bool),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profilepath(bool),
              spliData(message),
            ],
          );
  }

  Widget spliData(Message message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width / 1.8,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 1, color: AppColors.primaryColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.receipt, color: AppColors.primaryColor, size: 24),
                SizedBox(width: 10),
                Text(
                  message.split['BillName'],
                  style: FontManager().getTextStyle(context,
                      fontSize: 16,
                      lWeight: FontWeight.bold,
                      color: AppColors.bg1),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "₹", // Rupee symbol
                      style: TextStyle(color: AppColors.bg2, fontSize: 16),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Total expense: " +
                          doubleToFixed(message.split['Amount'].toString()),
                      style: FontManager().getTextStyle(context,
                          fontSize: 12, color: AppColors.bg2),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.group, color: AppColors.bg2, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      "Share: " +
                          doubleToFixed(message.split['Share'].toString())
                              .toString(),
                      style: FontManager().getTextStyle(context,
                          fontSize: 12, color: AppColors.bg2),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Icon(
                    message.split['isPaid']
                        ? Icons.check_circle
                        : Icons.pending,
                    color: message.split['isPaid'] ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    message.split['isPaid']
                        ? "Settled Successfully"
                        : "Pending",
                    style: FontManager().getTextStyle(context,
                        fontSize: 12,
                        lWeight: FontWeight.w400,
                        color: message.split['isPaid']
                            ? Colors.green
                            : Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getImage() async {
    final _picker = ImagePicker();
    final imageData = await _picker.pickImage(source: ImageSource.gallery);

    if (imageData != null) {
      //  addMessage(context,"image",search.text,data['_id'],data);
      showData(imageData);
      // addMessageImage(context, "image","None",data['_id'],File(imageData.path),widget.data,widget.myId,socket,widget.myId,roomId.value,);

      // navigate();
      // setState(() {
      //       messages.insert(0,Message(isMe: true,url: File(imageData.path),type: "image")); // Add the message to the list
      //   });
    }
  }

  // Function to build a message bubble
  Widget _buildMessage(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          getDataWidget(message),
        ],
      ),
    );
  }

  void navigate() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          data: widget.data,
          myId: widget.myId,
          myprofile: widget.myprofile,
        ),
      ),
    );
  }

  // void clear(){
  //   int index=0;
  //                 chatList.forEach((element) {
  //                        if(element['_id']==data['_id']){
  //                           chatList[index]['count']=0;
  //                        }
  //                        index++;
  //                 },);
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        clearChatData();
        getChatLoader();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          // leading:
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: ValueListenableBuilder<bool>(
              valueListenable: onlineUser,
              builder: (context, snapshot, child) {
                return Container(
                  // color: AppColors.backgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          clearChatData();
                          getChatLoader();
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      GestureDetector(
                          onTap: () {
                            pushDetails();
                          },
                          child: AvatarProfileImage(
                              url: data['avatar'] ?? "assets/avatar/menp3.svg",
                              width: 8,
                              height: 17)),
                      GestureDetector(
                        onTap: () {
                          
                          pushDetails();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.7,
                          child: Text(
                            data['name'],
                            style: FontManager().getTextStyle(context,
                                fontSize: 18, lWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              //  height: MediaQuery.of(context).size.height/1.28,
              // List of messages
              Obx(() => Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildMessage(messages[index]);
                      },
                    ),
                  )),
              // Text input and send button
              Container(
                // margin: EdgeInsets.all(8.0),

                decoration: BoxDecoration(
                   
                    //borderRadius: BorderRadius.circular(24),
                    ),
                //       decoration: InputDecoration(
                //   prefixIcon: Icon(Icons.search),
                //   // prefixIconColor: Colorcodes.budgetDarkGreen,
                //   filled: true,

                //   fillColor: AppColors.button,
                //   border: InputBorder.none,
                // ),
                child: InputDate("Message", TextInputType.name, search),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearChatData() {
    socket.close();
    chatOfUserList.remove(data['_id']);
    clear(data);
    unSeenChat(context, data['_id']);
    // getChatLoader();
    Navigator.pop(context);
  }

  Widget polled(isme, pollObj) {
    return !isme
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              profilepath(isme),
              poll(pollObj),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              poll(pollObj),
              profilepath(isme),
            ],
          );
  }

  Widget polled2(isme, poll) {
    Future<String> getPolled() async {
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      var accessToken = _pref.getString("accessToken");
      final response = await http.get(
        Uri.parse('${url}/poll/${poll}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken",
        },
      );
      return response.body;
    }

    return FutureBuilder<String>(
      future: getPolled(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While data is being fetched, display a loading indicator
          return !isme
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    profilepath(isme),
                    demiData(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    demiData(),
                    profilepath(isme),
                  ],
                );
        } else if (snapshot.hasError) {
          // If an error occurs during fetching, display an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // When data is fetched successfully, display the result
          return calledData(isme, (snapshot.data));
        }
      },
    );
  }

  Widget calledData(isme, data) {
    var obj = jsonDecode(data);

    if (obj['data'].isEmpty) return SizedBox.shrink();

    return !isme
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              profilepath(isme),
              poll(obj['data'][0]),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              poll(obj['data'][0]),
              profilepath(isme),
            ],
          );
  }

  Widget text(msg, isme) {
    return !isme
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              profilepath(isme),
              textIsme(msg, isme),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              textIsme(msg, isme),
              profilepath(isme),
            ],
          );
  }

  Widget imageDisplay(msg, bool, url) {
    return bool
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image(url),
              profilepath(bool),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profilepath(bool),
              image(url),
            ],
          );
  }

  Widget profilepath(boolFlag) {
    return chatAvatartImage(
        url: boolFlag ? path : data['avatar'], width: 20, height: 20);
  }

  Widget textIsme(msg, bool isme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.4,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isme ? AppColors.primaryColor : null,
          borderRadius: BorderRadius.only(
            bottomRight: isme ? Radius.zero : Radius.circular(10),
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
            bottomLeft: !isme ? Radius.zero : Radius.circular(10),
          ),
          gradient: !isme
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.mt,
                    AppColors.mt,
                  ],
                )
              : null,

          //  border: Border.all(
          //     width: .5,
          //     color: Colorcodes.poll1
          // )
        ),
        child: Text(msg,
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w400,
                fontSize: 15,
                letterSpacing: 0.0,
                color: isme ? AppColors.backgroundColor : AppColors.bg1)),
      ),
    );
  }

  Widget InputDate(
    String labelText,
    TextInputType keyboardType,
    TextEditingController textController,
  ) {
    return Container(
      color: AppColors.chatcolor,
      width: MediaQuery.of(context).size.width,
      child: TextField(
        keyboardType: keyboardType,
        focusNode: myFocusNode,
        controller: textController,
        maxLines: null, // Allow multiple lines
        maxLength: 150,
       
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _handleSubmitted(value);
          } else {
            snackBarCalled(context, "Please enter message");
          }
          textController.clear();
          getChatLoader();
          myFocusNode.requestFocus();
        },
        decoration: InputDecoration(
          hintText: labelText,
          filled: true,
          // prefixIcon: IconButton(
          //   icon: Icon(
          //     Icons.emoji_emotions,
          //     size: 25,
          //     color: AppColors.primaryColor,
          //   ),
          //   onPressed: () {
          //     // Implement emoji picker or logic here
          //   },
          // ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min, // Takes minimum space needed
            children: [
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: AppColors.primaryColor,
                  size: 25,
                ),
                onPressed: getImage,
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: AppColors.primaryColor,
                  size: 25,
                ),
                onPressed: () {
                  String value = textController.text;
                  if (value.isNotEmpty) {
                    _handleSubmitted(value);
                  } else {
                    snackBarCalled(context, "Please enter valid data");
                  }
                  textController.clear();
                  getChatLoader();
                  myFocusNode.requestFocus();
                },
              ),
            ],
          ),
          counterText: "",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  Widget image(url) {
    if (url == "" || url == "None") return SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to full image screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullImageScreen(imageUrl: url),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            url,
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 5,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.0),
            colorBlendMode: BlendMode.exclusion,
          ),
        ),
      ),
    );
  }

  // Widget image(url) {
  //   if (url == "" || url == "None") return SizedBox.shrink();

  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(20),

  //       // border: Border.all(
  //       //    width: .5,
  //       //    color: Colorcodes.poll1
  //       // )
  //     ),
  //     padding: const EdgeInsets.symmetric(vertical: 3.0),
  //     child: Image.network(
  //       url,
  //       width: MediaQuery.of(context).size.width / 2,
  //       height: MediaQuery.of(context).size.height / 5,
  //       fit: BoxFit.cover,
  //       color: Colors.black.withOpacity(0.0),
  //       colorBlendMode: BlendMode.exclusion,
  //     ),
  //     // child: GFImageOverlay(
  //     //                   width: MediaQuery.of(context).size.width / 1.5,
  //     //                   height: MediaQuery.of(context).size.height/3.5,
  //     //                   // shape: BoxShape.values,
  //     //                   image: NetworkImage(url!),
  //     //                   borderRadius:BorderRadius.circular(10),
  //     //                   colorFilter:ColorFilter.mode(Colors.black.withOpacity(0.0),
  //     //                   BlendMode.exclusion),
  //     //              ),
  //   );
  // }
// poll card display in community
  Widget poll(e) {
    List options = e['options'] ?? [];
    int index = 0; // e['selectedOption'];
    int s = -1;

    return Padding(
      padding: const EdgeInsets.only(right: 0.0, top: 5),
      child: Container(
        padding: EdgeInsets.only(right: 5.0, left: 5.0, top: 10, bottom: 3.0),
        width: MediaQuery.of(context).size.width / 1.4,
        decoration: BoxDecoration(
          //  color: Colorcodes.appBarColor,
          color: AppColors.mt,
          // border: Border.all(width: .5, color: Colorcodes.poll1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(e['question'] + "?",
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.bg1)),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((op) {
                  s++;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: BoxDecoration(
                          color: index == s ? null : Colorcodes.white,
                          borderRadius:
                              BorderRadius.circular(Colorcodes.borderRadius),
                          gradient: index == s
                              ? LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppColors.pollSelected,
                                    AppColors.pollSelected,
                                  ],
                                )
                              : null,
                          border: index == s
                              ? Border.all(color: Colorcodes.poll1)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(op['option'].toString(),
                               maxLines: null,
                                            softWrap: true,
                                             textWidthBasis: TextWidthBasis.longestLine,
                                            overflow: TextOverflow.visible,
                                 
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: index == s
                                          ? Colorcodes.white
                                          : Colors.black)),
                            ),

                            //  myvote ? Text(cal=="0.00"?'0%':cal=="100.00"?"100%":cal+"%",
                            //     style: FontManager().getTextStyle(context,
                            //             lWeight: FontWeight.w400,
                            //             fontSize: 14,
                            //             color: Colors.black)):SizedBox.shrink(),
                          ],
                        )),
                  );
                }).toList()),
          ],
        ),
      ),
    );
  }

  Widget demiData() {
    var options = [1, 2, 3, 4];
    return Padding(
      padding: const EdgeInsets.only(right: 0.0, top: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: MediaQuery.of(context).size.width / 1.4,
        decoration: BoxDecoration(
          //  color: Colorcodes.appBarColor,
          border: Border.all(width: .5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("",
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.black)),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((op) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          // border: Border.all()
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("",
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.black)),
                          ],
                        )),
                  );
                }).toList()),
          ],
        ),
      ),
    );
  }

  void showData(imageData) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.2,
            height: MediaQuery.of(context).size.height / 3.2,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
                color: Colorcodes.white,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Do you want to send this?",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.bg1,
                    lWeight: FontWeight.bold,
                    //  fontFamily: AutofillHints.birthdayDay
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 7,
                      child: Image.file(File(imageData.path))),
                ),

                //  const SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textStyleColor(
                        "Cancel", AppColors.accentColor, data, imageData),
                    const SizedBox(
                      width: 5,
                    ),
                    textStyleColor(
                        " Send ", AppColors.primaryColor, data, imageData),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget textStyleColor(str, color, data, imageData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
          if (str == " Send ") {
            addMessageImage(
              context,
              "image",
              "None",
              data['_id'],
              File(imageData.path),
              widget.data,
              widget.myId,
              socket,
              widget.myId,
              roomId.value,
            );
          }
          getChatLoader();
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(12)),
          child: Text(
            str,
            style: FontManager().getTextStyle(context,
                fontSize: 14, lWeight: FontWeight.w500, color: Colorcodes.white
                //  fontStyle: FontStyle.italic
                ),
          ),
        ),
      ),
    );
  }

  Widget uploadData(dataObj2) {
    var dataObj = jsonDecode(dataObj2);
    bool isExploria = dataObj['postType'] == "explore";
    var extractdata = isExploria
        ? dataObj['description']['message']
        : {}; //  dataObj.containsKey('place') && dataObj.containsKey('tripHighlight')

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
             
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  duration: Durations.long1,
                  child: TribeUnique(
                    id: dataObj["_id"],
                    dataObj: dataObj,
                  ),
                  isIos: true,
                ),
              );
            },
            //poll in chat code
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: AppColors.mt,
                  border: Border.all(width: .5, color: Colorcodes.poll1),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            AvatarProfileImage(
                              url: dataObj["author"]['avatar'],
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text((dataObj["author"]['name']),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // var dataObj = jsonDecode(message.post);

                  isExploria
                      ? SizedBox.shrink()
                      : dataObj['isPoll']
                          ? poll(
                              dataObj['pollData'],
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width / 1.3,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text((dataObj['title']),
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black)),
                            ),

                  isExploria
                      ? ExploreCard(extractdata: extractdata, dataObj: dataObj)
                      : (dataObj['chartType'] == "bargraph" ||
                              dataObj['chartType'] == "piechart")
                          ? dataObj['chartType'] == "bargraph"
                              ? barGraph(dataObj)
                              : pieChart(dataObj)
                          : getMessage(dataObj),

                  isExploria
                      ? SizedBox.shrink()
                      : dataObj['image'] != null &&
                              dataObj['image'] != "none" &&
                              dataObj['image'] != ""
                          ? Image.network(
                              dataObj['image'],
                              width: MediaQuery.of(context).size.width / 1.3,
                              height: MediaQuery.of(context).size.height / 5,
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.0),
                              colorBlendMode: BlendMode.exclusion,
                            )
                          : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getMessage(dataObj) {
    if (dataObj['isPoll'] ?? false) return SizedBox.shrink();

    try {
      return Container(
        width: MediaQuery.of(context).size.width / 1.62,
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text((dataObj['description']['message']),
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w400, fontSize: 13, color: Colors.black)),
      );
    } catch (e) {
      return Container(
        width: MediaQuery.of(context).size.width / 1.62,
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text((dataObj['description']),
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w400, fontSize: 13, color: Colors.black)),
      );
    }
  }

  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 30,
    );
  }

  Widget barGraph(item) {
    //  return Text("bargraph");
    List<SalesData> chartData = <SalesData>[];
    List list = item['description']['itemlist'];

    int j = 0;
    list.forEach(
      (element) {
        String t1 = element['item'];
        String t2 = element['amount'].toString();
        if (j == color.length) j = 0;
        String b = t2 == "" ? "0" : t2;

        chartData.add(
          SalesData(t1, double.parse(b)),
        );
      },
    );

    var barSeries = BarSeries<SalesData, String>(
      dataSource: chartData,
      xValueMapper: (SalesData sales, _) => sales.month,
      yValueMapper: (SalesData sales, _) => sales.sales,
    );
    return Container(
      // width: MediaQuery.of(context).size.width/2,
      // width: 300,
      // height:170,
      width: MediaQuery.of(context).size.width / 1.62,
      height: MediaQuery.of(context).size.height / 5,

      child: GestureDetector(
          child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        isTransposed: true,
        series: <CartesianSeries>[barSeries],
      )),
    );
  }

  Widget popupMenuItemList() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Perform actions based on the selected value
        if (value == 'Report') {
          // Handle Report action
        } else if (value == 'Block user') {
          // Handle Block action
        } else if (value == 'Mute notification') {
          // Handle Mute notification action
        } else if (value == 'Clear chat') {
          // Handle Clear chat action
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 'Report',
            child: Text('Report',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 14,
                    color: AppColors.primaryColor)),
          ),
          PopupMenuItem(
            value: 'Block user',
            child: Text('Block user',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 14,
                    color: AppColors.primaryColor)),
          ),
          PopupMenuItem(
            value: 'Mute notification',
            child: Text('Mute notification',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 14,
                    color: AppColors.primaryColor)),
          ),
          PopupMenuItem(
            value: 'Clear chat',
            child: Text('Clear chat',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 14,
                    color: AppColors.primaryColor)),
          ),
        ];
      },
      child: Icon(Icons.more_vert), // Replace this with your desired icon
    );
  }

  Widget pieChart(item) {
    final List<ChartData> chartData = [];

    List list = item['description']['itemlist'];

    int j = 0;

    list.forEach((element) {
      String t1 = element['item'];
      String t2 = element['amount'].toString();
      if (j == color.length) j = 0;
      String b = t2 == "" ? "0" : t2;
      chartData.add(
        ChartData(t1, list.length == 1 ? 100 : double.parse(b), color[j++], t1),
      );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
          //  width: 30,
          width: MediaQuery.of(context).size.width / 1.62,
          height: MediaQuery.of(context).size.height / 5,
          child: SfCircularChart(series: <CircularSeries>[
            // Render pie chart
            PieSeries<ChartData, String>(
              dataSource: chartData,

              radius: "100",
              explodeOffset: "4%",

              dataLabelMapper: (ChartData data, _) => '${data.name}',
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              onPointTap: (pointInteractionDetails) {},
              // strokeWidth: 5.0,
              dataLabelSettings: DataLabelSettings(
                isVisible: true, // Show labels
              ),
            )
          ])),
    );
  }

  void pushDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityUserProfile(data: data, ids: ids),
      ),
    );
  }
}

class SalesData {
  final String month;
  final double sales;

  SalesData(this.month, this.sales);
}
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:mime/mime.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:stakeplot/homeScreens/topHeader.dart';
// import 'package:uuid/uuid.dart';

// class ChatApp extends StatelessWidget {
//   const ChatApp({super.key});

//   @override
//   Widget build(BuildContext context) => const MaterialApp(
//         home: ChatPage(),
//       );
// }

// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   List<types.Message> messages = [];
//   final _user = const types.User(
//     id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
//   );

//   @override
//   void initState() {
//     super.initState();
//     _loadMessages();
//   }

//   void _addMessage(types.Message message) {
//     setState(() {
//       messages.insert(0, message);
//     });
//   }

//   void _handleAttachmentPressed() {
//     showModalBottomSheet<void>(
//       context: context,
//       builder: (BuildContext context) => SafeArea(
//         child: SizedBox(
//           height: 144,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _handleImageSelection();
//                 },
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('Photo'),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _handleFileSelection();
//                 },
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('File'),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('Cancel'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleFileSelection() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.any,
//     );

//     if (result != null && result.files.single.path != null) {
//       final message = types.FileMessage(
//         author: _user,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         id: const Uuid().v4(),
//         mimeType: lookupMimeType(result.files.single.path!),
//         name: result.files.single.name,
//         size: result.files.single.size,
//         uri: result.files.single.path!,
//       );

//       _addMessage(message);
//     }
//   }

//   void _handleImageSelection() async {
//     final result = await ImagePicker().pickImage(
//       imageQuality: 70,
//       maxWidth: 1440,
//       source: ImageSource.gallery,
//     );

//     if (result != null) {
//       final bytes = await result.readAsBytes();
//       final image = await decodeImageFromList(bytes);

//       final message = types.ImageMessage(
//         author: _user,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         height: image.height.toDouble(),
//         id: const Uuid().v4(),
//         name: result.name,
//         size: bytes.length,
//         uri: result.path,
//         width: image.width.toDouble(),
//       );

//       _addMessage(message);
//     }
//   }

//   void _handleMessageTap(BuildContext _, types.Message message) async {
//     if (message is types.FileMessage) {
//       var localPath = message.uri;

//       if (message.uri.startsWith('http')) {
//         try {
//           final index =
//               messages.indexWhere((element) => element.id == message.id);
//           final updatedMessage =
//               (messages[index] as types.FileMessage).copyWith(
//             isLoading: true,
//           );

//           setState(() {
//             messages[index] = updatedMessage;
//           });

//           final client = http.Client();
//           final request = await client.get(Uri.parse(message.uri));
//           final bytes = request.bodyBytes;
//           final documentsDir = (await getApplicationDocumentsDirectory()).path;
//           localPath = '$documentsDir/${message.name}';

//           if (!File(localPath).existsSync()) {
//             final file = File(localPath);
//             await file.writeAsBytes(bytes);
//           }
//         } finally {
//           final index =
//               messages.indexWhere((element) => element.id == message.id);
//           final updatedMessage =
//               (messages[index] as types.FileMessage).copyWith(
//             isLoading: null,
//           );

//           setState(() {
//             messages[index] = updatedMessage;
//           });
//         }
//       }

//       await OpenFilex.open(localPath);
//     }
//   }

//   void _handlePreviewDataFetched(
//     types.TextMessage message,
//     types.PreviewData previewData,
//   ) {
//     final index = messages.indexWhere((element) => element.id == message.id);
//     final updatedMessage = (messages[index] as types.TextMessage).copyWith(
//       previewData: previewData,
//     );

//     setState(() {
//       messages[index] = updatedMessage;
//     });
//   }

//   void _handleSendPressed(types.PartialText message) {
//     final textMessage = types.TextMessage(
//       author: _user,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: const Uuid().v4(),
//       text: message.text,
//     );

//     _addMessage(textMessage);
//   }

//   void _loadMessages() async {
//     final response = await rootBundle.loadString('assets/messages.json');
//     final messages = (jsonDecode(response) as List)
//         .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
//         .toList();

//     setState(() {
//       messages = messages;
//     });
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         // appBar:Top,
//         body: Chat(
//           messages: messages,
//           onAttachmentPressed: _handleAttachmentPressed,
//           onMessageTap: _handleMessageTap,
//           onPreviewDataFetched: _handlePreviewDataFetched,
//           onSendPressed: _handleSendPressed,
//           showUserAvatars: true,
//           showUserNames: true,
//           user: _user,
//           theme: const DefaultChatTheme(
//             seenIcon: Text(
//               'read',
//               style: TextStyle(
//                 fontSize: 10.0,
//               ),
//             ),
//           ),
//         ),
//       );
// }



// void  getTransactions()async
// {
    
//     final SharedPreferences _pref = await SharedPreferences.getInstance();
//     var  accessToken=_pref.getString("accessToken");
//     final response = await http.get(
//     Uri.parse('https://stakeplot.in/api/v1/chat/${data['_id']}'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       "Authorization": "$accessToken",
//     },
//   );
//      messages.clear();
//       if(response.statusCode==200)
//       {
//                   var  his=jsonDecode(response.body);
//                   List obj=his['data'];
              
//               obj.forEach((element){ 
//                  messages.insert(0, 
//                  Message(
//                   text: element['message'], 
//                   isMe: element['sender']!=data['_id'],
//                   type: element['messageType'],
//                   image: element['image'],
//                   poll:element['poll'] ?? "poll"
    
//                  ));  

//               });
             
//              setState(() {
               
//              });


//       }
//       else{
//       }
 
// }


// List of messages
  // Function to send a message