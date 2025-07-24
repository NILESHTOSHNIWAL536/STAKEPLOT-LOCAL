import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart';
import 'package:flutter_application_code_stakeplot/user_chat/fullScreen.dart';
import 'package:flutter_application_code_stakeplot/user_chat/message.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'package:get/get_rx/get_rx.dart';
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
    UserController userController=ControllerManagement.userController;
    String room1 = userController.userName.value + data['name'];
    String room2 = data['name'] +userController.userName.value;

    String room3 = userController.maskedName.value + data['name'];
    String room4 = data['name'] + userController.maskedName.value;

    roomId.value = ismaskedUsers.value
        ? (room3.compareTo(room4) <= 0)
            ? room3
            : room4
        : (room1.compareTo(room2) <= 0)
            ? room1
            : room2;

    getChats(data);
    path = userController.avatar.value;

    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    socket.connect();
    setUpSocketListener();
  }

  @override
  void dispose() {
    // Close the socket connection when the widget is disposed
    // if (socket != null) {
    //   socket.disconnect();
    //   socket.destroy();
    // }
    // super.dispose();
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
              getChatLoader(ismaskedUsers.value),
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
      'isMasked': ismaskedUsers.value,
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
      'isMasked': ismaskedUsers.value,
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
              uploadData((message.post),message ),
              // PostCard(data: message.post),
              // profilepath(bool),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //profilepath(bool),
              uploadData((message.post), message),
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
              //  profilepath(bool),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //   profilepath(bool),
              spliData(message),
            ],
          );
  }

  Widget spliData(Message message) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width / 1.8,
      decoration: BoxDecoration(
        color: message.isMe ? AppColors.appIcon : AppColors.mt,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16), // Circular radius for top left
          topRight: Radius.circular(16), // Circular radius for top right
          bottomLeft: message.isMe
              ? Radius.circular(16)
              : Radius
                  .zero, // Circular radius for bottom left (for other messages)
          bottomRight: message.isMe
              ? Radius.zero
              : Radius.circular(
                  16), // No radius for bottom right (for my messages)
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.receipt,
                  color: message.isMe
                      ? AppColors.backgroundColor
                      : AppColors.appIcon,
                  size: 24),
              SizedBox(width: 10),
              Text(
                message.split['BillName'],
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.bold,
                  color:
                      message.isMe ? AppColors.backgroundColor : AppColors.bg1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                    style: TextStyle(
                        color: message.isMe
                            ? AppColors.backgroundColor
                            : AppColors.bg2,
                        fontSize: 16),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Total expense: " +
                        doubleToFixed(message.split['Amount'].toString()),
                    style: FontManager().getTextStyle(context,
                        fontSize: 12,
                        color: message.isMe
                            ? AppColors.backgroundColor
                            : AppColors.bg2),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.group,
                      color: message.isMe
                          ? AppColors.backgroundColor
                          : AppColors.appIcon,
                      size: 20),
                  const SizedBox(width: 5),
                  Text(
                    "Share: " +
                        doubleToFixed(message.split['Share'].toString())
                            .toString(),
                    style: FontManager().getTextStyle(context,
                        fontSize: 12,
                        color: message.isMe
                            ? AppColors.backgroundColor
                            : AppColors.bg2),
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
                  message.split['isPaid'] ? Icons.check_circle : Icons.pending,
                  color: message.split['isPaid'] ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  message.split['isPaid'] ? "Settled Successfully" : "Pending",
                  style: FontManager().getTextStyle(context,
                      fontSize: 12,
                      lWeight: FontWeight.w400,
                      color:
                          message.split['isPaid'] ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void getImage(context) async {
    final _picker = ImagePicker();
    final imageData = await _picker.pickImage(source: ImageSource.gallery);

    if (imageData != null) {
      showData(imageData,context);
    }
  }

  Widget _buildMessage(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Padding(
            padding: !message.isMe
                ? EdgeInsets.only(left: 14)
                : EdgeInsets.only(right: 14),
            child: getDataWidget(message),
          ),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        clearChatData();
        getChatLoader(ismaskedUsers.value);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.appIcon,
        appBar: AppBar(
          backgroundColor: AppColors.appIcon,
          // leading:
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              clearChatData();
              getChatLoader(ismaskedUsers.value);
            },
            child:
                const Icon(Icons.arrow_back, color: AppColors.backgroundColor),
          ),
          title: ValueListenableBuilder<bool>(
              valueListenable: onlineUser,
              builder: (context, snapshot, child) {
                return GestureDetector(
                  onTap: () {
                    pushDetails();
                  },
                  child: Text(
                    data['name'],
                    style: FontManager().getTextStyle(context,
                        color: AppColors.backgroundColor,
                        fontSize: 16,
                        lWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }),
        ),
        body: GestureDetector(
           onTap: () {
          // Dismiss the keyboard when tapping anywhere on the screen
          FocusScope.of(context).unfocus();
        },
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius:
                  BorderRadius.circular(24), // Specify the border radius
            ),
            child: Column(
              children: [
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
                Container(
                  child: SafeArea(
                      child: InputDate("Message", TextInputType.name, search)),
                ),
              ],
            ),
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
    Navigator.pop(context);
  }

  Widget polled(isme, pollObj) {
    return !isme
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //  profilepath(isme),
              poll(pollObj),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              poll(pollObj),
              // profilepath(isme),
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
                    //   profilepath(isme),
                    demiData(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    demiData(),
                    // profilepath(isme),
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
              //   profilepath(isme),
              poll(obj['data'][0]),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              poll(obj['data'][0]),
              //  profilepath(isme),
            ],
          );
  }

  Widget text(msg, isme) {
    return !isme
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // profilepath(isme),
              textIsme(msg, isme),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              textIsme(msg, isme),
              // profilepath(isme),
            ],
          );
  }

  Widget imageDisplay(msg, bool, url) {
    return bool
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image(url),
              // profilepath(bool),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // profilepath(bool),
              image(url),
            ],
          );
  }

  Widget profilepath(boolFlag) {
    return AvatarProfile(
      name: data['name'],
      width: 1,
      height: 1,
      background: userController.avatarBackGround.value,
    );
    // return chatAvatartImage(
    //     url: boolFlag ? path : avaterUrlPath(data['name']),
    //     width: 17,
    //     height: 16);
  }

  Widget textIsme(String msg, bool isme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.4,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isme ? AppColors.appIcon : null,
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
        ),
        child: SelectableText(
          msg,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w400,
            fontSize: 14,
            letterSpacing: 0.0,
            color: isme ? AppColors.backgroundColor : AppColors.bg1,
          ),
          textAlign: TextAlign.left,
          onTap: () {
            // Optional: Handle tap if needed
          },
          contextMenuBuilder: (context, editableTextState) {
            return AdaptiveTextSelectionToolbar(
              anchors: editableTextState.contextMenuAnchors,
              children: [
                TextSelectionToolbarTextButton(
                  padding: EdgeInsets.all(8),
                  child: Text('Copy'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: msg));
                    //Navigator.of(context).pop(); // Close the context menu
                  },
                ),
                // Add more options like 'Select All' if needed
              ],
            );
          },
        ),
      ),
    );
  }

  Widget InputDate(
    String labelText,
    TextInputType keyboardType,
    TextEditingController textController,
  ) {
    return Container(
      color: Colors.grey,
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
            snackBarCalledfail(context, SnackbarData().pleaseEnterMessage);
          }
          textController.clear();
          getChatLoader(ismaskedUsers.value);
          myFocusNode.requestFocus();
        },
        decoration: InputDecoration(
          hintText: labelText,
          filled: true,
          fillColor: AppColors.mt,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min, // Takes minimum space needed
            children: [
              IconButton(
                  icon: Icon(
                    Icons.image,
                    color: AppColors.appIcon,
                    size: 25,
                  ),
                  onPressed: () {
                    getImage(context);
                  }),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: AppColors.appIcon,
                  size: 25,
                ),
                onPressed: () {
                  String value = textController.text;
                  if (value.isNotEmpty) {
                    _handleSubmitted(value);
                  } else {
                    snackBarCalledfail(
                        context, SnackbarData().pleaseEnterValidData);
                  }
                  textController.clear();
                  getChatLoader(ismaskedUsers.value);
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
                          color: index == s ? null : AppColors.backgroundColor,
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
                                          ? AppColors.backgroundColor
                                          : AppColors.accentColor)),
                            ),
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
                          color: AppColors.backgroundColor,
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

  void showData(imageData,BuildContext context) {
    showDialog(
      context: context,
      builder: (context2) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.2,
            height: MediaQuery.of(context).size.height / 3.2,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(color: AppColors.backgroundColor,borderRadius: BorderRadius.circular(12)),
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
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 7,
                      child: Image.file(File(imageData.path))),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textStyleColor("Cancel", AppColors.accentColor, data, imageData,context2),
                    const SizedBox(width: 5,),
                    textStyleColor(" Send ", AppColors.primaryColor, data, imageData,context2),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget textStyleColor(str,Color color, data, imageData,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
          try{
          if (str.toString().trim().toLowerCase() == "Send".toLowerCase())
          {
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
             
          }else
          {
              getChatLoader(ismaskedUsers.value);
              Navigator.pop(context);
          }
          }catch(e){
             print(e);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(12)),
          child: Text(
            str,
            style: FontManager().getTextStyle(context,
                fontSize: 14,
                lWeight: FontWeight.w500,
                color: AppColors.backgroundColor
                //  fontStyle: FontStyle.italic
                ),
          ),
        ),
      ),
    );
  }


 Widget uploadData(String dataObj2, Message message) {
  PostModel dataObj = PostModel.fromJson(jsonDecode(dataObj2));
  bool isExploria =dataObj.postType.name == "exploria";
  bool isPoll =  dataObj.postType.name == "poll";
  bool isImage = dataObj.postType.name == "image";
  bool isWrite = dataObj.postType.name == "write";

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    child: GestureDetector(
      onTap: () async{
        getpost(dataObj.id);
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: Durations.long1,
            child: TribeUnique(
              id: dataObj.id,
              dataObj: dataObj,
              popBox: false.obs,

            ),
            isIos: true,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.4,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: message.isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Section
            Row(
              children: [
                
               
                Expanded(
                  child: Text(
                    (dataObj.author.maskedName==''?  dataObj.author.name: dataObj.author.maskedName),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 15,
                      color:  AppColors.bg1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Content Preview
            if (isPoll && dataObj.pollData != null && dataObj.pollData!.question!= null)
              Text(
                "${dataObj.pollData!.question}?",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 14,
                  color:  AppColors.bg1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (isWrite)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dataObj.title.isNotEmpty)
                    Text(
                      dataObj.title,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        fontSize: 14,
                        color:  AppColors.bg1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (dataObj.title.isNotEmpty) const SizedBox(height: 6),
                  Text(
                    (dataObj.description is Map ? dataObj.description.message : dataObj.description),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 13,
                      color: AppColors.bg1.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            if (isImage)
              Text(
                (dataObj.description is Map ? dataObj.description.message : dataObj.description) ?? '',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 13,
                  color: AppColors.bg1.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (isExploria)
              Text(
                (dataObj.description is Map ? dataObj.description.message : dataObj.description) ?? '',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 13,
                  color: AppColors.bg1.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            // Image Thumbnail (if applicable)
            if (isImage &&  dataObj.image != "none" && dataObj.image != "")
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                   dataObj.image,
                    width: MediaQuery.of(context).size.width / 1.6,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: MediaQuery.of(context).size.width / 1.6,
                      height: 120,
                      color: AppColors.grey.withOpacity(0.2),
                      child:  Icon(Icons.error, size: 40, color: AppColors.grey),
                    ),
                  ),
                ),
              ),
            if (isExploria && dataObj.images != null && dataObj.images.isNotEmpty && dataObj.images[0] != "none" && dataObj.images[0] != "")
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    dataObj.images[0],
                    width: MediaQuery.of(context).size.width / 1.6,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: MediaQuery.of(context).size.width / 1.6,
                      height: 120,
                      color: AppColors.grey.withOpacity(0.2),
                      child:  Icon(Icons.error, size: 40, color: AppColors.grey),
                    ),
                  ),
                ),
              ),
            // Tags (Show only one or hint)
            if (dataObj.tag.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.finSpaceColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "#${dataObj.tag[0]}",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.finSpaceColor,
                    ),
                  ),
                ),
              ),
            // Timestamp
            if (dataObj.createdAt.toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  formatDateToIST(dataObj.createdAt.toString()),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget getMessage(dataObj) {
    if (dataObj['postType'] == "poll") return SizedBox.shrink();

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