import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_search.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/user_chat/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import 'package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart';
import 'package:flutter_application_code_stakeplot/user_chat/message.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../routes/index_route.dart';
import 'componets/chat_index.dart';

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
  ValueNotifier<bool> isUploading =ValueNotifier<bool>(false); // Declare isUploading here

  @override
  void initState() {
    super.initState();
    data = widget.data;
    UserController userController = ControllerManagement.userController;

    roomId.value = generateRoomId(
      userName: userController.userName.value,
      maskedName: userController.maskedName.value,
      otherName: data['name'],
      isMasked: ismaskedUsers.value,
    );

    getChats(data);
    path = userController.avatar.value;

    socket = IO.io(API.urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    socket.connect();
    setUpSocketListener();
  }

  setUpSocketListener() {
    socket.onConnect((_) {
      socket.emit("joinRoom", roomId.value);
      socket.emit("online", {"id":roomId.value,"flag":true});
    });

    socket.onConnectError((data) {});

    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
              setState(() {
                onlineUser.value = false;
              })
            });

    socket.on(
        'online',
        (res) => {
          if(res['id']==roomId.value)
          {
              setState(() {
                    onlineUser.value = res['flag'];
                  })
          }
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
                            : "")),
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
    socket.emit("message", jsonData);
    socket.emit("LoadCharts", {
      "roomId": data['name'] + "" + data['name'],
      'isMasked': ismaskedUsers.value,
    });
  }

  void getImage(context) async {
    final _picker = ImagePicker();
    final imageData = await _picker.pickImage(source: ImageSource.gallery);

    if (imageData != null) {
      showData(imageData, context);
    }
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
                    child: Row(
                      children: [
                        // online/offline dot
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: onlineUser.value ? Colors.green :  AppColors.redColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                         SizedBox(width: AppSizes.w6),

                        // username text
                        Text(
                          data['name'],
                          style: FontManager().getTextStyle(
                            context,
                            color: AppColors.backgroundColor,
                            fontSize: 16,
                            lWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    )
                    // child: Text(
                    //   onlineUser.value data['name'],
                    //   style: FontManager().getTextStyle(context,
                    //       color: AppColors.backgroundColor,
                    //       fontSize: 16,
                    //       lWeight: FontWeight.bold),
                    //   overflow: TextOverflow.ellipsis,
                    //   maxLines: 1,
                    // ),
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
                        itemBuilder: (BuildContext context2, int index) {
                          return buildMessage(messages[index], context);
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
    socket.emit("online", {"id":roomId.value,"flag":false});
    chatOfUserList.remove(data['_id']);
    clear(data);
    unSeenChat(context, data['_id']);
    socket.close();
    Navigator.pop(context);
  }

  Widget profilepath(boolFlag) {
    return AvatarProfile(
      name: data['name'],
      width: 1,
      height: 1,
      background: userController.avatarBackGround.value,
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
              const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p12),
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

// poll card display in community

  void showData(imageData, BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context2) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.2,
            height: MediaQuery.of(context).size.height / 3.2,
            padding: EdgeInsets.symmetric(vertical: AppSizes.p20, horizontal: 10),
            decoration: BoxDecoration(
                color: AppColors.backgroundColor,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 7,
                      child: Image.file(File(imageData.path))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textStyleColor("Cancel", AppColors.accentColor, data,
                        imageData, context2),
                    const SizedBox(
                      width: 5,
                    ),
                    textStyleColor(" Send ", AppColors.primaryColor, data,
                        imageData, context2),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget textStyleColor(
      str, Color color, data, imageData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
          try {
            if (str.toString().trim().toLowerCase() == "Send".toLowerCase()) {
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
            } else {
              getChatLoader(ismaskedUsers.value);
              Navigator.pop(context);
            }
          } catch (e) {}
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: AppSizes.p10),
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

  void pushDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityUserProfile(data: data, ids: ids),
      ),
    );
  }
}
