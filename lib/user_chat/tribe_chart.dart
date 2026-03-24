import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/app_styles.dart";
import "package:flutter_application_code_stakeplot/Constants/colors.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Constants/search.dart";
import "package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart";
import "package:flutter_application_code_stakeplot/Utils/snackBar.dart";
import "package:flutter_application_code_stakeplot/image_service/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/routes/route_post.dart";
import "package:flutter_application_code_stakeplot/user_chat/room_poll_chart.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/Constants/colorcodes.dart";
import "package:flutter_application_code_stakeplot/controllers/controllerManagement.dart";
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import "package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart";
import "package:flutter_application_code_stakeplot/Constants/loader.dart";
import "package:flutter_application_code_stakeplot/user_chat/chat.dart";
import "package:get/get.dart";
import 'package:socket_io_client/socket_io_client.dart' as IO;
import "../Constants/core/app_padding_sizes.dart";
import "../routes/index_route.dart";
import "../routes/route_user_login.dart";
import "group_chat.dart";

RxBool load = true.obs;
RxBool reloadCharts = true.obs;
RxBool reloadMaskedCharts = true.obs;
RxBool ismaskedUsers = false.obs;
RxBool countOpen = false.obs;
late IO.Socket socket;
RxInt totalUnopenedMessages = 0.obs;

class TribeChats extends StatefulWidget {
  const TribeChats({Key? key}) : super(key: key);

  @override
  _TribeSearchState createState() => _TribeSearchState();
}

class _TribeSearchState extends State<TribeChats> {
  TextEditingController search = TextEditingController();

  List frdsList = [];
  List frdsListOrigin = [];
  bool frdsThere = true;
  String myId = "";
  var myprofile;
  RxBool getChatData = false.obs;
  //Added for chat split
  List<dynamic> chatSplitAccount = [];
  ValueNotifier<bool> getChatSplit = ValueNotifier<bool>(false);
  final CommunityScreenStrings strings = CommunityScreenStrings();
  UserController userController = ControllerManagement.userController;
   String demoGroupId = "demo_group_flutter";

  @override
  void initState() {
    super.initState();
    totalUnopenedMessages.value = 0;
    // ismaskedUsers.value = false;
    getChatLoader(ismaskedUsers.value);
    getTransactions();
    getChatsSplitAccounts(context, myId);
    socket = IO.io(
        API.urlWithLocallHost,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNewConnection()
            .build());
    socket.connect();
    setUpSocketListener();
  }

  setUpSocketListener() {
    socket.onConnect((_) {
      socket.emit("joinRoom",
          userController.userName.value + userController.userName.value);
      if (userController.maskedName.value != "")
        socket.emit("joinRoom",
            userController.maskedName.value + userController.maskedName.value);
    });

    socket.onConnectError((data) {});

    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
            });

    socket.on(
        "LoadCharts",
        (loadData) => {
              if (loadData['isMasked'] == ismaskedUsers.value)
                getChatLoader(ismaskedUsers.value),
            });
  }

  void getTransactions() async {
    var response = await getDataApiCall(UserRoutes.getInfo);
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
      setState(() {
        frdsList = obj['friendsList'];
        frdsThere = false;
        myId = obj['_id'];
        myprofile = obj;
        frdsListOrigin = frdsList;
        getChatData.value = true;
        load.value = false;
      });
    } else {}
  }

  int getTotalUnopenedMessages() {
    return chatList.fold<int>(
        0, (total, item) => total + (item['count']?.toInt() ?? 0) as int);
  }

  void getChatsSplitAccounts(BuildContext context, String id) async {
    var response = await getDataApiCall(SplitRoutes.splitpending);
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
      setState(() {
        chatSplitAccount.clear();
        chatSplitAccount.addAll(obj);
        getChatSplit.value = !getChatSplit.value; // Trigger UI update
      });
    } else {}
  }
  List<Map<String, dynamic>> groupList = [
  {
    "groupId": "demo_group_flutter",
    "name": "Flutter Learners",
    "members": 5,
  }
];

@override
void dispose() {
  socket.disconnect();
  socket.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.appIcon,
      appBar: PreferredSize(
        preferredSize: chatSplitAccount.isNotEmpty
            ? const Size.fromHeight(140)
            : const Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: AppColors.appIcon,
          titleSpacing: 0,
          toolbarHeight:
              chatSplitAccount.isNotEmpty && !ismaskedUsers.value ? 140 : 100,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: AppColors.backgroundColor,
              size: 20,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left:AppSizes.p16, top:AppSizes.p20, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi, ${userController.userName.value}', // Null check for myprofile and myprofile['name']
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppColors.backgroundColor,
                  ),
                ),
                SizedBox(height: AppSizes.h4),
                Obx(() => Text(
                      countOpen.value
                          ? strings.messagesReceived.replaceFirst(
                              '{count}', totalUnopenedMessages.value.toString())
                          : strings.messagesReceived.replaceFirst(
                              '{count}',
                              totalUnopenedMessages.value
                                  .toString()), // Null check for chatList
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 16,
                        color: AppColors.backgroundColor,
                      ),
                    )),
                Obx(() => ismaskedUsers.value
                    ? SizedBox.shrink()
                    : SizedBox(height: AppSizes.h8)),
                chatSplitAccount.isNotEmpty && !ismaskedUsers.value
                    ? SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: chatSplitAccount.length,
                          itemBuilder: (context, index) {
                            var friend = chatSplitAccount[index];
                            if (friend == null) {
                              return const SizedBox.shrink();
                            }
                            return Row(
                              children: [
                                AvatarProfile(
                                  name: friend['name'],
                                  width: 9,
                                  height: 12,
                                  fontsize: 15,
                                  background: friend['avatarBackGround'] ?? "",
                                  flag: true,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  friend['name'] ??
                                      'Unknown', // Null check for friend['name']
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: AppColors.backgroundColor,
                                  ),
                                ),
                                SizedBox(width: AppSizes.w16),
                              ],
                            );
                          },
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor, // Set your desired color here
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), // Adjust the radius as needed
            topRight: Radius.circular(24), // Adjust the radius as needed
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: ListView(
            children: [
              InputDate(strings.searchHint, TextInputType.name, search),
              const SizedBox(
                height: 16,
              ),
              // Obx(()=>  ismaskedUsers.value? getTabs(context): getTabs(context) ),
              Obx(() => reloadCharts.value ? getChatList() : getChatList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTabs(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p20),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          child: InkWell(
              onTap: () {
                ismaskedUsers.value = false;
                reloadCharts.value = !reloadCharts.value;
                getChatLoader(false);
              },
              child: textStyleImage(
                  context: context,
                  text: strings.All,
                  fontsize: !ismaskedUsers.value ? 20 : 18,
                  fontWeight:
                      !ismaskedUsers.value ? FontWeight.bold : FontWeight.w500,
                  c: AppColors.accentColor)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          child: InkWell(
              onTap: () {
                reloadCharts.value = !reloadCharts.value;
                ismaskedUsers.value = true;
                getChatLoader(true);
              },
              child: textStyleImage(
                  context: context,
                  text: strings.maskeduser,
                  fontsize: ismaskedUsers.value ? 20 : 18,
                  fontWeight:
                      ismaskedUsers.value ? FontWeight.bold : FontWeight.w500,
                  c: AppColors.accentColor)),
        ),
      ]),
    );
  }

  Widget getChatList() {
    return load.value
        ? Spinner(
            color: AppColors.primaryColor,
          )
        : Column(
          children: [
              // buildGroupChats(),
            chatList.isEmpty
                ? Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AvatarProfileImage(
                              url: FinSpaceIcons.empty,
                              height: 4.5,
                              width: 4.5,
                            ),
                            Text(strings.noChatsAvailable,
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w400,
                                    lineHeight: 1.2,
                                    fontSize: 20,
                                    color: AppColors.grey)),
                          ],
                        ),
                      ),
                    ),
                  )
                : Column(
                    children:
                        chatList.map((item) => profileContainer(item)).toList(),
                  ),
          ],
        );
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.1,
        child: Center(
          child: TextFormField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            onChanged: (value) {
              setState(() {
                frdsList = getSearchData(value, frdsListOrigin);
                chatList = getSearchDataRx(value, chatListOriginal);
              });
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.p10, vertical: 0),
              filled: true,
              enabled: true,
              hintText: lableText,
              fillColor: AppColors.backgroundColor,
              hintStyle: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: 14,
                  color: AppColors.accentColor),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget profileContainer(item) {
    var id = {'_id': item['_id']};
    String key = item['_id'];
    bool canMaskMessage =
        ismaskedUsers.value ? (item['canMaskMessage'] ?? true) : true;
    getChats2(id, key);
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: GestureDetector(
        onTap: !canMaskMessage
            ? () {
                snackBarCalledfail(context, SnackbarData().offReplays);
              }
            : () {
                messages.clear();
                unSeenChat(context, item['_id']);
                getChatLoader(ismaskedUsers.value);
                getChats(item);
                clear(item);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chat(
                        data: item,
                        myId: userController.userId.value,
                        myprofile: myprofile),
                  ),
                );
              },
        child: Container(
          color: AppColors.backgroundColor,
          child: Column(
            children: [
              
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p2, horizontal: 2),
                color:
                    canMaskMessage ? AppColors.transparentColor : AppColors.grey,
                //width: width / 1,
                child: Row(
                  children: [
                    ismaskedUsers.value
                        ? AvatarProfile2(
                            url: item['avatar'], width: 20, height: 20)
                        : AvatarProfile(
                            name: item['name'].toString(),
                            width: 1,
                            height: 1,
                            background: item['avatar'] ?? ""),
                    SizedBox(width: AppSizes.w8),
                    SizedBox(
                      width: width >= 500
                          ? width / 2.2
                          : width >= 300
                              ? width / 2.5
                              : width / 3.1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item['name']),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w400,
                                fontSize: 18,
                                color: AppColors.message),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSizes.h2),
                          Text(
                            item['type'] ?? strings.noMessagesYet,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w400,
                                fontSize: 12,
                                color: AppColors.message.withOpacity(0.7)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (item['count'] != 0)
                      Container(
                        padding: const EdgeInsets.all(AppSizes.p10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          
                        ),
                        child: Center(
                          child: Text(
                            item['count'].toString(),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.bg5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildGroupChats() {
  if (groupList.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(
        "Groups",
        style: FontManager().getTextStyle(
          context,
          fontSize: 16,
          lWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
      ),
      const SizedBox(height: 8),
      ...groupList.map((group) => ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.group),
            ),
            title: Text(group['name']),
            subtitle: Text("${group['members']} members"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupChatScreen(
                    myId: userController.userId.value,
                    myName: userController.userName.value,
                    groupId: group['groupId'],
                    groupName: group['name'],
                  ),
                ),
              );
            },
          )),
      const Divider(),
    ],
  );
}

}
