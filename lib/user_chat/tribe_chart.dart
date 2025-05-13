import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
import "package:flutter_application_code_stakeplot/userAvatar.dart";
import "package:flutter_application_code_stakeplot/user_chat/chat.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

RxBool load = true.obs;
RxBool reloadCharts = true.obs;
late IO.Socket socket;

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
  @override
  void initState() {
    super.initState();
    getUserInfomations();
    getChatLoader();
    getTransactions();
    getChatsSplitAccounts(context, myId);

    socket = IO.io(
        urlWithLocallHost,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNewConnection()
            .build());
    socket.connect();
    setUpSocketListener();
  }

  setUpSocketListener() {
    socket.onConnect((_) {
      socket.emit("joinRoom", userName.value + userName.value);
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
              getChatLoader(),
            });
  }

  void getTransactions() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/user/info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
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
    return chatList.fold<int>(0, (total, item) => total + (item['count']?.toInt() ?? 0) as int);
  }
void getChatsSplitAccounts(BuildContext context, String id) async {
    var response = await getDataApiCall("${url}/split/pending-user");
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
      setState(() {
        chatSplitAccount.clear();
        chatSplitAccount.addAll(obj);
        getChatSplit.value = !getChatSplit.value; // Trigger UI update
      });
    } else {
      print('Failed to fetch chat split accounts: ${response.statusCode}');
    }
  }

  // ... existing code ...
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // bottomNavigationBar: BottomNavigations(data: sizeRoom ? 3 : 2),
      extendBody: true,
      backgroundColor: AppColors.appIcon,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: AppColors.appIcon,
      //   title: Text('Messages',
      //           style: FontManager().getTextStyle(context,
      //               lWeight: FontWeight.bold,
      //               fontSize: 24,
      //               color: AppColors.backgroundColor)),
      //   leading: InkWell(
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //       child: Icon(
      //         Icons.arrow_back_sharp,
      //         color: AppColors.primaryColor,
      //         size: 30,
      //       )),
      // ),
                appBar: PreferredSize(
  preferredSize: chatSplitAccount.isNotEmpty?const Size.fromHeight(140):const Size.fromHeight(100),
  child: AppBar(
    automaticallyImplyLeading: true,
    backgroundColor: AppColors.appIcon,
    titleSpacing: 0,
    toolbarHeight:chatSplitAccount.isNotEmpty? 140:100,
    title: Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 20.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hi, ${myprofile != null ? myprofile['name'] ?? 'User' : 'User'}', // Null check for myprofile and myprofile['name']
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 24,
              color: AppColors.backgroundColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${getTotalUnopenedMessages() ?? 0} messages received', // Null check for chatList
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.normal,
              fontSize: 16,
              color: AppColors.backgroundColor,
            ),
          ),
          const SizedBox(height: 8),
          chatSplitAccount.isNotEmpty?SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chatSplitAccount?.length ?? 0, // Null check for frdsList
              itemBuilder: (context, index) {
                var friend = chatSplitAccount?[index]; // Safe access to frdsList[index]
                if (friend == null) {
                  return const SizedBox.shrink(); // Return empty widget if friend is null
                }
                return Row(
                  children: [
                    AvatarProfile(name: friend['name'], width: 9, height: 12,fontsize: 15, background: friend['avatarBackGround'],flag: true,),
                    const SizedBox(width: 2,),
                    Text(
                      friend['name'] ?? 'Unknown', // Null check for friend['name']
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.backgroundColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                );
              },
            ),
          ):SizedBox.shrink(),
        ],
      ),
    ),
    centerTitle: false,
    elevation: 0,
  ),
),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor, // Set your desired color here
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), // Adjust the radius as needed
            topRight: Radius.circular(24), // Adjust the radius as needed
          ),),
        child: Padding(
          padding: EdgeInsets.all(16),
        
          //padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                
              InputDate2("Search", TextInputType.name, search),
              const SizedBox(
                height: 16,
              ),
              Obx(() => reloadCharts.value ? getChatList() : getChatList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget getChatList() {
    return load.value
        ? Spinner(color: AppColors.primaryColor,)
        : chatList.isEmpty
            ? Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(
                      child: Text(StringConstant.chatText,
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              lineHeight: 1.2,
                              fontSize: 24,
                              color: Colorcodes.dropdown))),
                ),
              )
            : Column(
                children:
                    chatList.map((item) => profileContainer(item)).toList(),
              );
    // return   Column(
    //         children: frdsList.map((item) => profileContainer(item)).toList(),
    //    );
  }

  Widget InputDate2(lableText, keyBoard, Textcontroller) {
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
              prefixIcon: Icon(Icons.search),
              // prefixIconColor: Colorcodes.budgetDarkGreen,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
              hintText: lableText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              fillColor: AppColors.button,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 5),
        // color:  Color.fromRGBO(246, 246, 246, 1),
        width: MediaQuery.of(context).size.width / 1.1,
        height: 50,
        child: Center(
          child: TextField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            onChanged: (value) {
              setState(() {
                frdsList = getSearchData(value, frdsListOrigin);
              });
            },
            decoration: InputDecoration(
              filled: true,
              suffixIcon: Icon(Icons.search),
              hintText: lableText,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white
                      // color: Color.fromRGBO(249, 246, 238, 1)
                      )),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Color.fromRGBO(246, 246, 246, 1))),
              fillColor: Color.fromRGBO(246, 246, 246, 1),

              // border: InputBorder.none,
              // fillColor:
            ),
          ),
        ),
      ),
    );
  }

  Widget profileContainer(item) {
    var id = {'_id': item['_id']};
    String key = item['_id'];
    getChats2(id, key);
    double width = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          
          messages.clear();
          unSeenChat(context, item['_id']);
          getChatLoader();
          getChats(item);
          clear(item);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(data: item, myId: myId, myprofile: myprofile),
            ),
          );

        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              //width: width / 1,
              child: Row(
                children: [
                  // AvatarProfileImage(
                  //   url: item['avatar'] ?? userAvatar,
                  //   width: 10,
                  //   height: 16,
                  // ),
                  AvatarProfile(name: item['name'], width: 1, height: 1, background: item['avatar']),
                  const SizedBox(width: 8),
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
                        const SizedBox(height: 2),
                        Text(
                          item['type'] ?? 'No messages yet',
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                     
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 0.3,
                          color: Colorcodes.budgetDarkGreen,
                        ),
                      ),
                      child:  Center(
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
    );
  }

  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 25,
    );
  }
}
