import 'dart:convert';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TribeShare extends StatefulWidget {
  var data;
  var dataObj;
  TribeShare({Key? key, required this.data, required this.dataObj})
      : super(key: key);

  @override
  _TribeHomeState createState() => _TribeHomeState();
}

class _TribeHomeState extends State<TribeShare> {
  RxBool frdsThere = false.obs;
  List addedUser = [];
  List nameList = [];
  late IO.Socket socket;
  RxString roomId = "".obs;

  @override
  void initState() {
    super.initState();
    getTransaction();
    socket = IO.io(urlWithLocallHost,IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
  }

  void getTransaction() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('https://stakeplot.in/api/v1/user/info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
      frdsList.clear();
      frdsListOrigin.clear();
      frdsList.addAll(obj['friendsList']);
      frdsListOrigin.addAll(frdsList);
      frdsThere = false.obs;
    } else {}
  }

  TextEditingController Textcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return commentedData();
  }

  setUpSocketListener() {
    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
            });
  }

  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 30,
    );
  }

  Widget commentedData() {
    double height = MediaQuery.of(context).size.height / 3;
    return Container(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 12),
        decoration: BoxDecoration(
            color: AppColors.unSelectedOption,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(36),topRight: Radius.circular(36))),
        child: Column(
          children: [
            InputDate('Search', TextInputType.name, Textcontroller),
            frdsThere.value
                ? Container(height: height, child: Center(child: Loader()))
                : frdsList.isEmpty
                    ? Container(
                        height: height,
                        child: Center(child: Text("No Friend Found")))
                    : listOfUsers(height),
            shareButton()
          ],
        ),
      ),
    );
  }

  Widget shareButton() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (frdsList.isEmpty) {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/TribeSearch');
              return;
            }

            if (addedUser.isEmpty) {
              snackBarCalled(context, SnackbarData().noFriendsAdded);
              return;
            }

            int index = 0;
            addedUser.forEach((rec) {
              String room1 = nameList[index] + userName.value;
              String room2 = userName.value + nameList[index];

              String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

              // socketConnection();
              var jsonData = {
                "messageType": "post",
                "receiver": rec,
                "sender": currentId.value,
                "message": null,
                "image": null,
                "poll": null,
                "post": {
                  "postTitle": widget.dataObj['title'],
                  "postDescription": widget.dataObj['description'].toString(),
                  "postImage": widget.dataObj['image'],
                  "postId": widget.dataObj['_id'],
                  "postLocation": jsonEncode(widget.dataObj),
                },
                "split": null,
                "roomId": roomId,
              };
              socket.emit("joinRoom", roomId);
              socket.emit("message", jsonData);

              String userToSend = nameList[index] + "" + nameList[index];
              socket.emit("LoadCharts", {
                "roomId": userToSend,
              });
              index++;
              sendNotificationsToDevice(
                  rec,
                  context,
                  "Hey there! 👋, ${userName.value} has shared a post 📩. Please check it out 🛒 ",
                  "/chat/${currentId.value}",
                  widget.dataObj['title'],
                  widget.dataObj['image']);
            });
            Navigator.pop(context);
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 1.1,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                color:
                    addedUser.isEmpty ? AppColors.bg6 : AppColors.finSpaceColor,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text((frdsList.isEmpty ? "Add Friends" : "Continue"),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 18,
                      color: AppColors.mt)),
            ),
          ),
        ),
        SizedBox(height:6),
        InkWell(
          onTap:(){
            Navigator.pop(context);
          },
         child: Container(
            width: MediaQuery.of(context).size.width / 1.1,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                color:
                     AppColors.unSelectedOption,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(("Cancel"),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 18,
                      color: AppColors.bg3)),
            ),
          ),
        )
      ],
    );
  }

  Widget listOfUsers(height) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: SizedBox(
      height: height,
      child: GridView.builder(
        itemCount: frdsList.length, // +1 for loading more indicator
        itemBuilder: (context, index) {
          String values = frdsList[index]['_id'];
          String name = frdsList[index]['name'];
          return InkWell(
            onTap: () {},
            child: GestureDetector(
              onTap: () {
                setState(() {
                  addedUser.contains(values)
                      ? addedUser.remove(values)
                      : addedUser.add(values);
                  nameList.contains(name)
                      ? nameList.remove(name)
                      : nameList.add(name);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: addedUser.contains(values)
                      ? Border.all(
                          color: AppColors.buttonBorder,
                          width: 1.0,
                        )
                      : Border.all(
                          color: Colors.transparent,
                          width: 0.0,
                        ),
                  borderRadius: BorderRadius.circular(8.0), // Optional: for rounded corners
                ),
                padding: const EdgeInsets.all(4.0), // Optional: padding inside the border
                child: Column(
                  children: [
                    AvatarProfile(
                      name: frdsList[index]['name'],
                      width: 21,
                      height: height,
                      background: frdsList[index]['avatarBackGround'] ??
                          defaultBackGround.value,
                    ),
                    Text(
                      frdsList[index]['name'],
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.bg1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of columns
          crossAxisSpacing: 0.0, // Spacing between columns
          mainAxisSpacing: 0.0, // Spacing between rows
        ),
      ),
    ),
  );
}
  void sendPost(context, jsonData) async {
    var responce = await postDataApiCall("${url}/chat/", jsonData);
    if (getFlagOfResponse(responce)) {
      snackBarCalled(context, SnackbarData().postSentSuccessfully);
      Navigator.pop(context);
    } else {
      snackBarCalled(context, SnackbarData().cantAdd, Colors.red);
    }
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        width: MediaQuery.of(context).size.width / 1.1,
         height: MediaQuery.of(context).size.width / 9,
        child: Center(
          child: TextFormField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            onChanged: (value) {
              //  setState((){
              frdsList.clear();
              frdsList.addAll(getSearchDataRx(value, frdsListOrigin));
              //  });
            },
            decoration: InputDecoration(
              //contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              filled: true,
              prefixIcon: Icon(Icons.search),
              hintText: lableText,
              hintStyle:FontManager().getTextStyle(context,
                              lWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppColors.likesharecommentCount),
              fillColor: AppColors.backgroundColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
              
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8), // Add your desired radius here
               borderSide:
                      BorderSide(color: AppColors.buttonBorder) // Keep the border invisible if needed
              ),
            ),
          ),
        ),
      ),
    );
  }
}
