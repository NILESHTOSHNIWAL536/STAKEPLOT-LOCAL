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
          padding: EdgeInsets.all(AppSizes.p16),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
        : chatList.isEmpty
            ? Center(
                child: Container(
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
              );
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
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
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              filled: true,
              enabled: true,
              hintText: lableText,
              fillColor: AppColors.backgroundColor,
              hintStyle: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: 14,
                  color: AppColors.accentColor),
              prefixIcon: Icon(Icons.search),
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
                    canMaskMessage ? Colors.transparent : Colorcodes.greyLight,
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
                    Container(
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
                          border: Border.all(
                            width: 0.3,
                            color: Colorcodes.budgetDarkGreen,
                          ),
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
}
