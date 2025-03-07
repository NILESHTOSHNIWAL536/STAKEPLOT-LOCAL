import 'dart:convert';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_home.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_search.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_share.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart";
import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
import "package:flutter_application_code_stakeplot/model/comment.dart";
import "package:flutter_application_code_stakeplot/profile.dart";
import "package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart";
import "package:flutter_svg/svg.dart";
import "package:get/get.dart";
import "package:page_transition/page_transition.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:http/http.dart' as http;
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:syncfusion_flutter_charts/charts.dart";

RxBool toggle = false.obs;

class TribeUnique extends StatefulWidget {
  final String id;
  Map<String, dynamic> dataObj;
  TribeUnique({Key? key, required this.id, required this.dataObj})
      : super(key: key);

  @override
  _TribeHomeState createState() => _TribeHomeState();
}

class SalesData {
  final String month;
  final double sales;

  SalesData(this.month, this.sales);
}

class _TribeHomeState extends State<TribeUnique> {
  // int index = 0;
  List historyListData = [];
  List commentListData = [];
  List postList = [];
  // String avatar="assets/avatar/menp1.svg";

  // RxList<Comments> commentList=[].obs;

  RxList<Comments> commentList = <Comments>[].obs;
  RxList<int> indexArray = <int>[].obs;
  late Comments commentObj;

  bool onReply = false;
  String replyid = "";
  String name = "";
  String userId = "";
  var dataObj = {};

  List<RxInt> countLikes = [];
  int i = 0;

  RxBool boolVar = true.obs;
  List<Color> color = [
    Colors.blue,
    Colors.redAccent,
    Colors.green,
    Colors.amber,
    Colors.cyanAccent
  ];

  void addComment(context, String data, String postId, String authorId,
      String postName, String name) async {
    if (data == "") {
      FocusScope.of(context).requestFocus(_replyFocusNode);
      snackBarCalled(context, "Can't Add Empty Data....!");
      return;
    }

    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");

    Comments obj = Comments();
    Author auth = Author();
    PostDetails post = PostDetails();

    auth.id = authorId;
    auth.name = userName.value;
    auth.avatar = avatar.value;

    // post.authorId=auth.id;
    // post.name=auth.name;

    obj.replies = [];
    obj.author = auth;
    obj.commentText = data;
    obj.upvotes = 0;
    obj.downvotes = 0;
    obj.postDetails = post;

    commentList.add(obj);
    indexArray.add(i);
    i++;

    final response = await http.post(
      Uri.parse('${url}/comment/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        'postId': postId,
        'authorId': authorId,
        'commentText': data,
        'postName': postName,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);

      var id = body['data']['_id'];
      // Comments obj= Comments();
      //   Author auth=Author();
      //   PostDetails post=PostDetails();

      //   auth.id=authorId;
      //   auth.name=name;

      //   // post.authorId=auth.id;
      //   // post.name=auth.name;

      //   obj.replies=[];
      //   obj.author=auth;
      //   obj.commentText=data;
      //   obj.upvotes=0;
      //   obj.downvotes=0;
      //   obj.postDetails=post;
      //   obj.sId=id;
      //   commentList.add(obj);
      obj.sId = id;
      postCount[id] = 0;
      //  return obj;

      //  snackBarCalled(context,"Added Comment...!",Colors.black);

      //  Navigator.pop(context);
      //  Navigator.pushNamed(context, '/home');
    } else {
      snackBarCalled(context, "can't Add comment!", Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    dataObj = widget.dataObj;
    getpost(widget.id);
    getTransactionComments();
    getInfo();
  }

  void getpost(id) async {
    String url = "https://stakeplot.in/api/v1";
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/post/${widget.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];

      setState(() {
        dataObj = obj;
      });
    } else {}
  }

  void getInfo() async {
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
        postList = obj['saved'];
        fill.value = postList.contains(widget.id);
        name = obj['name'];
        userId = obj['_id'];
        avatar = obj['avatarType'];
      });
    } else {}
  }

  void getTransactionComments() async {
    // String url ="https://stakeplot.in/api/v1";
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/comment/${widget.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];

      // setState(() {
      // });
      historyListData = obj;

      commentList.clear();

      historyListData.forEach((e) {
        // Comments obj=Comments();
        //  historyListData.forEach((element) {
        postCount[e["_id"]] = e['upvotes'];
        //  });

        Comments obj = Comments.fromJson(e);
        indexArray.add(i);
        i++;
        // countLikes.add(obj.upvotes as RxInt);
        commentList.add(obj);
      });
    } else {}
  }

  TextEditingController calController1 = TextEditingController();
  TextEditingController replyController = TextEditingController();
  FocusNode _replyFocusNode = FocusNode();
  String str = "reply to comments.";
  final ScrollController _scrollController = ScrollController();
  // final ScrollController _scrollController2 = ScrollController();
  RxBool fill = false.obs;

  FocusNode _replyNode = FocusNode();
  RxBool autofocus = false.obs;

  @override
  void dispose() {
    calController1.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: BottomNavigations(data: sizeRoom ? 3 : 2),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                // Text(
                //   ("Tribe"),
                //   style: FontManager().getTextStyle(context,
                //       lWeight: FontWeight.bold,
                //       fontSize: 24,
                //       color: Colorcodes.services),
                // ),
                const Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            duration: Durations.long1,
                            child: TribeSearch(),
                            isIos: true,
                          ),
                        );
                      },
                      child: Container(
                          width: 30,
                          height: 40,
                          padding: EdgeInsets.all(0),
                          child: ProfileImage(url: svgIconPath.search)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: GestureDetector(
                        onTap: () {
                         Navigator.push(
                            context,
                            PageTransition(
                                  type: PageTransitionType.fade,
                                  duration: Durations.long1,
                                  child:TribeChats(),
                                  isIos: true,
                            ),
                          );
                        },
                        child: Container(
                            height: 40,
                            width: 30,
                            child: ProfileImage(url: svgIconPath.message)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: AppColors.backgroundColor,
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // tribeHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: PostCard(data: widget.dataObj, flag: true),
              ),
              uploadData(widget.dataObj),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 30,
    );
  }

  Widget uploadData(dataObj) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          commentedData(),
          InputComment(
            str,
            TextInputType.name,
            replyController,
            replyid,
          ),
        ],
      ),
    );
  }

  Widget commentedData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              // color: const Color.fromRGBO(249, 246, 238, 1),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              //  commentText:

              const SizedBox(
                height: 6,
              ),

              Obx(
                () => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      //  color: Colorcodes.budgetLightGreen,
                      border: Border.all(
                          width: .5, color: Colorcodes.budgetDarkGreen)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: indexArray
                            .map((index) =>
                                dataComments(commentList[index], index))
                            .toList(),
                      ),
                      replyid != ""
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      replyid = "";
                                      FocusScope.of(context)
                                          .requestFocus(_replyFocusNode);
                                      //  FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                                    });
                                  },
                                  child: Text("Add a comment")),
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ),

              replyid == ""
                  ? InputDate("Add a comment", TextInputType.name,
                      calController1, widget.id)
                  : SizedBox.shrink(),
            ],
          )),
    );
  }

  Widget dataComments(Comments data, int index) {
    //  RxList<Comments> data=data.obs;

    List<Replies> list = data.replies!;

    String idData = data.sId == null ? "" : data.sId.toString();
    double width = MediaQuery.of(context).size.width;

    return Obx(() => Column(
          children: [
            Container(
              // width: MediaQuery.of(context).size.width/1.2,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Icon(
                    //   Icons.person_pin_sharp,
                    //   size: 35,
                    //   color: Colors.black,
                    // ),
                    AvatarProfileImage(
                        url: data.author!.avatar.toString(),
                        width: 15,
                        height: 20),
                    const SizedBox(
                      width: 0,
                    ),
                    Container(
                      width: width <= 430
                          ? width / 1.4
                          : width <= 500
                              ? width / 1.3
                              : MediaQuery.of(context).size.width / 1.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text((data.author!.name ?? "name"),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black)),
                          ),
                          SizedBox(
                            // color: Colors.cyan,
                            // width: MediaQuery.of(context).size.width/1.4,
                            // width: width<=430?  width/1.6:  width<=500?  width/2 : width/1.7,
                            child: Text((data.commentText!),
                                //  overflow: TextOverflow.visible,
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black)),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            // width:  width<=430?  width/1.4: width<=500?  width/1.3: MediaQuery.of(context).size.width/1.3,
                            // color: Colorcodes.budgetDarkGreen,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          upvote2(
                                              context,
                                              "Comment",
                                              data.sId!,
                                              data,
                                              historyListData,
                                              data,
                                              index);

                                          String l1 = "liked" + idData;
                                          bool liked = likedList.contains(l1);

                                          String l2 = "disliked" + idData;
                                          bool disliked =
                                              likedList.contains(l2);
                                          // upvoteGlobal(context,"Post",dataObj["_id"],dataObj);
                                          // likedList.remove("liked"+dataObj["_id"])  :likedList.add("liked"+dataObj["_id"]);

                                          if (liked) {
                                            likedList.remove(l1);
                                            postCount[idData] =
                                                postCount[idData]! - 1;
                                            if (postCount[idData]! < 0) {
                                              postCount[idData] = 0;
                                            }
                                          } else {
                                            likedList.add(l1);
                                            postCount[idData] =
                                                postCount[idData]! + 1;
                                          }
                                          likedList.remove(l2);
                                          reRender.value = !reRender.value;
                                        },
                                        // child: const Icon(
                                        //   Icons.arrow_drop_up_outlined,
                                        //   size: 35,
                                        //   color: Colors.black,
                                        // ),
                                        child: likeIcon(context, likedList.contains("liked" + data.sId.toString()))),
                                      //   child: likedList.contains(
                                      //           "liked" + data.sId.toString())
                                      //       ? upvoteLiked(context, false)
                                      //       : upvoteLike(context, false),
                                      // ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Text(
                                            data.sId == null
                                                ? '0'
                                                : (reRender.value
                                                    ? postCount[data.sId]! < 0
                                                        ? postCount[
                                                                dataObj['_id']]
                                                            .toString()
                                                        : (postCount[data.sId]
                                                            .toString())
                                                    : (postCount[data.sId]
                                                        .toString())),
                                            // child: Text((data.upvotes.toString()),
                                            style: FontManager().getTextStyle(
                                                context,
                                                lWeight: FontWeight.w400,
                                                fontSize: 20,
                                                color: Colors.black)),
                                      ),
                                      // Text((data.upvotes.toString()),
                                      //     style: FontManager().getTextStyle(context,
                                      //         lWeight: FontWeight.w400,
                                      //         fontSize: 18,
                                      //         color: Colors.black)),

                                      // GestureDetector(
                                      //   onTap: () {
                                      //     downvote2(
                                      //         context,
                                      //         "Comment",
                                      //         data.sId!,
                                      //         data,
                                      //         historyListData,
                                      //         index);
                                      //     String l1 = "liked" + idData;
                                      //     bool liked = likedList.contains(l1);

                                      //     String l2 = "disliked" + idData;
                                      //     bool disliked =
                                      //         likedList.contains(l2);
                                      //     // likedList.remove("liked"+dataObj["_id"])  :likedList.add("liked"+dataObj["_id"]);
                                      //     reRender.value = !reRender.value;
                                      //     if (disliked) {
                                      //       if (liked) {
                                      //         postCount[idData] =
                                      //             postCount[idData]! - 1;
                                      //         if (postCount[idData]! < 0) {
                                      //           postCount[idData] = 0;
                                      //         }
                                      //         likedList.remove(l1);
                                      //       }
                                      //       likedList.remove(l2);
                                      //     } else {
                                      //       //  likedList.add(l1);
                                      //       if (liked) {
                                      //         postCount[idData] =
                                      //             postCount[idData]! - 1;
                                      //         if (postCount[idData]! < 0) {
                                      //           postCount[idData] = 0;
                                      //         }
                                      //         likedList.remove(l1);
                                      //       }

                                      //       //  postCount[idData]=postCount[idData]!-1;
                                      //       likedList.add(l2);
                                      //     }
                                      //   },
                                      //   child: likedList.contains("disliked" +
                                      //           data.sId.toString())
                                      //       ? downvoteLiked(context, false)
                                      //       : downvoteLike(context, false),
                                      //   // child: const Icon(
                                      //   //   Icons.arrow_drop_down_outlined,
                                      //   //   size: 35,
                                      //   //   color: Colors.black,
                                      //   // ),
                                      // ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // Request focus for the reply text field
                                    FocusScope.of(context)
                                        .requestFocus(_replyNode);
                                    _scrollToTextField();
                                    autofocus.value = true;
                                    setState(() {
                                      commentObj = data;
                                      str = "reply to " + data.commentText!;
                                      replyid = data.sId!;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: Text(('Reply'),
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colorcodes.reply)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: list
                                .map(
                                  (obj) => replyDatas(obj, data),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    )
                  ]),
            ),
            index + 1 == indexArray.length
                ? SizedBox.shrink()
                : Divider(
                    color: Colorcodes.budgetLightGreen,
                    thickness: index + 1 == indexArray.length ? 0 : .8,
                    endIndent: 5,
                    indent: 5,
                  )
          ],
        ));
  }

  // Widget dataComment(data) {

  //   List list = data['replies'];

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
  //     child: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Icon(
  //             Icons.person_pin_sharp,
  //             size: 35,
  //             color: Colors.black,
  //           ),
  //           const SizedBox(
  //             width: 10,
  //           ),
  //           Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(vertical: 10),
  //                 child: Text((data['author']["name"]?? "name"),
  //                     style: FontManager().getTextStyle(context,
  //                         lWeight: FontWeight.w400,
  //                         fontSize: 18,
  //                         color: Colors.black)),
  //               ),
  //               Text((data['commentText']),
  //                   style: FontManager().getTextStyle(context,
  //                       lWeight: FontWeight.w400,
  //                       fontSize: 18,
  //                       color: Colors.black)),
  //                Container(
  //                 child: Row(
  //                   children: [
  //                     GestureDetector(
  //                       onTap: (){

  //                           // upvote2(context,"Comment",data["_id"],data,historyListData,data);
  //                           //  getpost(widget.id);
  //                           getTransactionComments();
  //                           // navigate();
  //                       },
  //                       child: const Icon(
  //                         Icons.arrow_drop_up_outlined,
  //                         size: 35,
  //                         color: Colors.black,
  //                       ),
  //                     ),
  //                     Text((data['upvotes'].toString()),
  //                         style: FontManager().getTextStyle(context,
  //                             lWeight: FontWeight.w400,
  //                             fontSize: 18,
  //                             color: Colors.black)),
  //                     GestureDetector(
  //                         onTap: (){
  //                             //  downvote2(context,"Comment",data["_id"],data,historyListData);

  //                       },
  //                       child: const Icon(
  //                         Icons.arrow_drop_down_outlined,
  //                         size: 35,
  //                         color: Colors.black,
  //                       ),
  //                     ),
  //                     InkWell(
  //                       onTap: () {
  //                         // Request focus for the reply text field
  //                         FocusScope.of(context).requestFocus(_replyFocusNode);
  //                         _scrollToTextField();

  //                         setState(() {
  //                             str = "reply to " + data['commentText'];
  //                             replyid=data["_id"];
  //                         });

  //                       },
  //                       child: Text(('reply'),
  //                           style: FontManager().getTextStyle(context,
  //                               lWeight: FontWeight.w400,
  //                               fontSize: 18,
  //                               color: Colors.black)),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Column(
  //                 children: list
  //                     .map(
  //                       (obj) => replyData(obj,data),
  //                     )
  //                     .toList(),
  //               ),

  //             ],
  //           )
  //         ]),
  //   );
  // }

  Widget InputDate(lableText, keyBoard, TextEditingController Textcontroller,
      String postId) {
    return Center(
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 5),
        // height: 50,
        // color:  Color.fromRGBO(246, 246, 246, 1),
        width: MediaQuery.of(context).size.width / 1.1,
        child: Center(
          child: TextField(
            focusNode: _replyFocusNode,
            keyboardType: keyBoard,
            controller: Textcontroller,
            onSubmitted: (value) {
              addComment(context, value, postId, widget.dataObj['author']['id'],
                  widget.dataObj['title'], name);
              postCommentCount.putIfAbsent(
                  postId, () => widget.dataObj["comments"] ?? 0);
              postCommentCount.update(postId, (value) => value + 1);
              Textcontroller.clear();
            },
            decoration: InputDecoration(
              filled: true,
              suffixIcon: suffixcomment(Textcontroller, postId),
              hintText: lableText,
              enabledBorder: const OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(color: Colors.white
                      // color: Color.fromRGBO(249, 246, 238, 1)
                      )),
              focusedBorder: const OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(40),
                  borderSide:
                      BorderSide(color: Color.fromRGBO(246, 246, 246, 1))),
              fillColor: AppColors.button,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget InputComment(lableText, keyBoard, TextEditingController Textcontroller,
      String commentId) {
    if (commentId == "") return SizedBox.shrink();
    return Obx(() => Center(
          child: Container(
            // padding: EdgeInsets.symmetric(vertical: 5),
            height: 50,
            // color:  Color.fromRGBO(246, 246, 246, 1),
            width: MediaQuery.of(context).size.width / 1.1,
            child: Center(
              child: TextField(
                focusNode: _replyNode,
                autofocus: autofocus.value,
                keyboardType: keyBoard,
                controller: Textcontroller,
                readOnly: commentId == "",
                onSubmitted: (value) {
                  reply(value, commentId, Textcontroller);
                },
                decoration: InputDecoration(
                  filled: true,
                  hintText: lableText,
                  suffixIcon:
                      suffix(Textcontroller.text, commentId, Textcontroller),
                  enabledBorder: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.white
                          // color: Color.fromRGBO(249, 246, 238, 1)
                          )),
                  focusedBorder: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(40),
                      borderSide:
                          BorderSide(color: Color.fromRGBO(246, 246, 246, 1))),
                  fillColor: Colorcodes.textFeild,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ));
  }

  Widget suffix(value, commentId, Textcontroller) {
    return GestureDetector(
      onTap: () {
        reply(Textcontroller.text, commentId, Textcontroller);
      },
      child: Container(
          height: 10,
          width: 10,
          child: AvatarProfileImage(
            url: svgIconPath.sendMsg,
            height: 10,
            width: 10,
          )),
    );
  }

  Widget suffixcomment(TextEditingController Textcontroller, postId) {
    return GestureDetector(
      onTap: () {
        String value = Textcontroller.text;

        addComment(context, value, postId, widget.dataObj['author']['id'],
            widget.dataObj['title'], name);
        postCommentCount.putIfAbsent(
            postId, () => widget.dataObj["comments"] ?? 0);
        postCommentCount.update(postId, (value) => value + 1);
        Textcontroller.clear();
      },
      child: Container(
          height: 10,
          width: 10,
          child: AvatarProfileImage(
            url: svgIconPath.sendMsg,
            height: 10,
            width: 10,
          )),
    );
  }

  void _scrollToTextField() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
  }

  Widget replyDatas(Replies replayObj, Comments data) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      //  color: Colors.deepOrangeAccent,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarProfileImage(
                url: replayObj.author!.avatar.toString(),
                width: 15,
                height: 20),
            const SizedBox(
              width: 0,
            ),
            Container(
              width: width <= 430
                  ? MediaQuery.of(context).size.width / 2
                  : MediaQuery.of(context).size.width <= 500
                      ? width / 1.8
                      : MediaQuery.of(context).size.width / 1.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text((replayObj.author!.name.toString()),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black)),
                  ),
                  SizedBox(
                    //  color: Colors.cyan,
                    // width:  width<=430?  width/2.3: width<=500?  width/2 : width/1.7,
                    child: Text((replayObj.replyText!),
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black,
                        )),
                  ),
                ],
              ),
            )
          ]),
    );
  }

  Widget replyData(replayObj, data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.person_pin_sharp,
              size: 35,
              color: Colors.black,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text((data['author']['name']),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.black)),
                ),
                Text((replayObj['replyText']),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Colors.black)),
              ],
            )
          ]),
    );
  }

  void navigate() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TribeUnique(
          id: widget.id,
          dataObj: widget.dataObj,
        ),
      ),
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

    return Container(
      // width: MediaQuery.of(context).size.width/2,
      // width: 300,
      // height:170,
      height: MediaQuery.of(context).size.height / 4.7,

      child: GestureDetector(
          child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        isTransposed: true,
        series: <CartesianSeries>[
          BarSeries<SalesData, String>(
            dataSource: chartData,
            xValueMapper: (SalesData sales, _) => sales.month,
            yValueMapper: (SalesData sales, _) => sales.sales,
          )
        ],
      )),
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
          height: MediaQuery.of(context).size.height / 4.7,
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

  void upvote(context, String str, String objectId, dataObj) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.post(
      Uri.parse('${url}/upvote/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        'onModel': str.toString(),
        'objectId': objectId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);

      String msg = body['data']['status']['message'];

      bool flag = msg.contains("created");

      setState(() {
        if (flag) {
          dataObj["upvotes"]++;
          postListIds.add(objectId);
          snackBarCalled(context, "Liked!", Colors.black);
        } else {
          dataObj["upvotes"]--;
          if (dataObj["upvotes"] < 0) commentObj.upvotes = 0;
          postListIds.remove(objectId);
          snackBarCalled(context, "Removed Liked!", Colors.black);
        }
      });

      //  if(!postListIds.contains(objectId)){
      //        setState(() {
      //         dataObj["upvotes"]++;
      //       });
      //       postListIds.add(objectId);
      //         snackBarCalled(context,"Liked!",Colors.black);
      //  }else{
      //      setState(() {
      //         dataObj["upvotes"]--;
      //       });
      //       postListIds.remove(objectId);
      //         snackBarCalled(context,"Removed Liked!",Colors.black);
      //  }
      //  Navigator.pop(context);
      //  Navigator.pushNamed(context, '/TribeHome');
    } else {
      snackBarCalled(context, "error while Liked!", Colors.red);
    }
  }

  void upvote2(context, String str, String objectId, dataObj, historyListData2,
      Comments commentObj, int index) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    // boolVar.value=!boolVar.value
    final response = await http.post(
      Uri.parse('${url}/upvote/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        'onModel': str.toString(),
        'objectId': objectId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      String msg = body['data']['status']['message'];

      bool flag = msg.contains("created");

      setState(() {
        if (flag) {
          //  snackBarCalled(context,"Liked!",Colors.black);
          // commentList.forEach((element) {
          //       if(element.sId==commentObj.sId){
          //            element.upvotes= element.upvotes!+1;
          //       }
          // });
          // // commentObj.upvotes=commentObj.upvotes!+1;
          boolVar.value = !boolVar.value;
          commentList[index].upvotes = commentList[index].upvotes! + 1;
          postListIds.add(objectId);
          //  boolVar.value=!boolVar.value;
        } else {
          // snackBarCalled(context,"Removed Liked!",Colors.black);
          //  commentList.forEach((element) {
          //         if(element.sId==commentObj.sId){
          //             //  element.upvotes= element.upvotes!+1;

          //               element.upvotes= element.upvotes!-1 ;
          //               if(element.upvotes! < 0)element.upvotes=0;

          //         }
          //   });
          boolVar.value = !boolVar.value;
          commentList[index].upvotes = commentList[index].upvotes! - 1;
          postListIds.remove(objectId);
        }
      });

      commentList.add(dataObj);
      commentList.removeLast();
      // commentList.forEach((element) {
      //        if(element.)
      // },);

      // });

      //  if(!postListIds.contains(objectId)){

      //           int i=0;
      //          historyListData2.forEach((element){
      //                  if(element['_id']==dataObj['_id'])
      //                  {
      //                           historyListData2[i]['upvotes']++;
      //                  }
      //                  i++;
      //          });

      //         //  setState(() {
      //         //      historyListData=historyListData2;
      //         //  });

      //       // postListIds.add(objectId);
      //       snackBarCalled(context,"Liked!",Colors.black);
      //  }else{

      //         int i=0;
      //          historyListData2.forEach((element){
      //                  if(element['_id']==dataObj['_id'])
      //                  {
      //                           historyListData2[i]['upvotes']--;
      //                  }
      //                  i++;
      //          });

      //          setState(() {
      //              historyListData=historyListData2;
      //          });

      //       postListIds.remove(objectId);
      //       snackBarCalled(context,"Removed Liked!",Colors.black);
      //  }
      //  Navigator.pop(context);
      //  Navigator.pushNamed(context, '/TribeHome');
    } else {
      snackBarCalled(context, "error while Liked!", Colors.red);
    }
  }

  Widget votew(dataObj, data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
              border: Border.all(), borderRadius: BorderRadius.circular(100)),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  upvote(context, "Post", dataObj["_id"], dataObj);
                },
                child: upvoteLiked(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text((dataObj["upvotes"].toString()),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Colors.black)),
              ),
              GestureDetector(
                onTap: () {
                  downvote(context, "Post", dataObj["_id"], dataObj);
                },
                child: downvoteLike(context),
                // child: const Icon(
                //   Icons.arrow_drop_down_outlined,
                //   size: 35,
                //   color: Colors.black,
                // ),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //     Container(
              //      padding: EdgeInsets.symmetric(horizontal: 8,vertical: 6),
              //      decoration: BoxDecoration(
              //       border: Border.all(),
              //       borderRadius: BorderRadius.circular(100)
              //  ),
              //       child: Row(
              //         children: [
              //           Container(
              //             height: 25,
              //             child: ProfileImage(url: "assets/images/comment.svg",)
              //             ),
              //             const SizedBox(width: 6,),
              //     Text(dataObj["comments"].toString(),style: FontManager().getTextStyle(context,
              //                            lWeight: FontWeight.w400,
              //                            fontSize: 18,
              //                            color: Colors.black)),
              //      const SizedBox(width: 7),
              //         ],
              //       ),
              //     ),

              const SizedBox(width: 15),

              InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colorcodes.appBarColor,
                      builder: (context) {
                        return TribeShare(data: data, dataObj: dataObj);
                      },
                    );
                  },
                  child: imageurl('assets/images2/share.svg')),
            ],
          ),
        )
      ],
    );
  }

  void downvote(
    context,
    String str,
    String objectId,
    dataObj,
  ) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");

    final response = await http.post(
      Uri.parse('${url}/downvote/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        'onModel': str.toString(),
        'objectId': objectId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      snackBarCalled(context, "DisLiked!", Colors.black);

      if (postListIds.contains(objectId)) {
        setState(() {
          dataObj["upvotes"]--;
        });
        postListIds.remove(objectId);
      }
    } else {
      snackBarCalled(context, "error while DisLiked!", Colors.red);
    }
  }

  void downvote2(context, String str, String objectId, Comments dataObj,
      historyListData2, int index) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");

    final response = await http.post(
      Uri.parse('${url}/downvote/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        'onModel': str.toString(),
        'objectId': objectId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      String msg = body['data']['status']['message'];

      bool flag = msg.contains("created");

      //  snackBarCalled(context,"DisLiked!",Colors.black);

      if (postListIds.contains(objectId)) {
        // setState(() {
        //   dataObj["upvotes"]--;
        // });
        // dataObj.upvotes= dataObj.upvotes!-1;
        // if( dataObj.upvotes!<0) dataObj.upvotes=0;

        commentList[index].upvotes = commentList[index].upvotes! - 1;
        if (commentList[index].upvotes! < 0) commentList[index].upvotes = 0;
        postListIds.remove(objectId);
        boolVar.value = !boolVar.value;
      }
    } else {
      //  snackBarCalled(context,"error while DisLiked!",Colors.red);
    }
  }

  void reply(value, commentId, Textcontroller) {
    if (value == "") {
      FocusScope.of(context).requestFocus(_replyNode);
      snackBarCalled(context, "Can't Add Empty Data....!");
      return;
    }

    if (commentId == "") return;
    addReply(context, value, commentId);
    replyid = "";
    Replies rep = Replies();
    rep.commentId = replyid;
    rep.replyText = value;
    Author author = Author();
    author.name = name;
    author.id = name;
    author.avatar = userAvatar;
    author.name = userName.value;
    author.avatar = avatar.value;
    //  author.avatar=avatar;
    rep.author = author;
    commentObj.replies!.add(rep);
    Textcontroller.clear();
    autofocus.value = false;
    setState(() {});
  }
}

Widget imageurl(url) {
  return SvgPicture.asset(
    url,
    height: 30,
  );
}

Widget imageurlcard(url) {
  return SvgPicture.asset(
    url,
    height: 30,
    color: Colorcodes.white,
  );
}

Widget tribeHeader(context, [str = "tribeone"]) {
  return Container(
    color: Colorcodes.debtHeader,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(("Tribe"),
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.black)),
            // Obx(() => Switch(
            //          value: toggle.value,
            //           inactiveThumbColor: Colorcodes.white,
            //           inactiveTrackColor: Colorcodes.textFeild,

            //           onChanged: (c){
            //          toggle.value=c;
            //  })),
            const SizedBox(
              width: 10,
            ),
            //  "tribeone"!=str?  Obx(() => FlutterSwitch(
            //                 width: 60.0,
            //                 // height: 55.0,
            //                 // valueFontSize: 25.0,
            //                 // toggleSize: 45.0,
            //                 value: toggle.value,
            //                 // borderRadius: 30.0,
            //                 activeColor: Colorcodes.debtHeader,
            //                 inactiveColor: Colorcodes.chatBody,

            //                 inactiveIcon: ProfileImage(url: "assets/svgs/toggle-feed.svg",),
            //                 activeIcon:ProfileImage(url: "assets/svgs/toggle-trending.svg",),
            //                 // padding: 8.0,
            //                 onToggle: (val) {
            //                   toggle.value=val;
            //                   indexFlag.value = 1-indexFlag.value;
            //       },
            //   )):SizedBox(),
          ],
        ),
        Container(
          child: Row(
            children: [
              InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        duration: Durations.long1,
                        child: TribeSearch(),
                        isIos: true,
                      ),
                    );
                  },
                  child: imageurl("assets/images/Search.svg")),
              SizedBox(
                width: 20,
              ),
              InkWell(
                  onTap: () {
                    //  Navigator.push(
                    //       context,
                    //       PageTransition(
                    //             type: PageTransitionType.fade,
                    //             duration: Durations.long1,
                    //             child:TribeChats(),
                    //             isIos: true,
                    //       ),
                    //   );
                  },
                  child: imageurl("assets/images2/messages.svg")),
            ],
          ),
        )
      ],
    ),
  );
}

Widget popUpBox(id, context) {
  return PopupMenuButton(
    initialValue: 2,
    color: Colorcodes.appBarColor,
    child: const Center(
        child: Icon(
      Icons.more_vert_outlined,
      size: 25,
      color: Colors.black,
    )),
    onSelected: (value) {
      if (value == 1) {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return showModel(context, id);
          },
        );
      } else {
        reportPost(context, id, "hide post");
      }
    },
    itemBuilder: (context) {
      return [
        const PopupMenuItem(
          value: 0,
          child: Text("hide"),
        ),
        const PopupMenuItem(
          value: 1,
          child: Text("Report"),
        ),
      ];
    },
  );
}

// void addComment(context,String data,String postId,String authorId,String postName,String name)async
// {

//       final SharedPreferences _pref = await SharedPreferences.getInstance();
//      var  accessToken=_pref.getString("accessToken");

//     final response = await http.post(
//     Uri.parse('${url}/comment/'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//        "Authorization": "$accessToken",
//     },
//     body: jsonEncode({
//              'postId':postId,
//              'authorId':authorId,
//              'commentText':data,
//              'postName':postName,

//        }),
//   );
//       if(response.statusCode==200 || response.statusCode==201){
//             final body = json.decode(response.body);

//            var id=body['data']['_id'];
//             Comments obj= Comments();
//               Author auth=Author();
//               PostDetails post=PostDetails();

//               auth.id=authorId;
//               auth.name=name;

//               // post.authorId=auth.id;
//               // post.name=auth.name;

//               obj.replies=[];
//               obj.author=auth;
//               obj.commentText=data;
//               obj.upvotes=0;
//               obj.downvotes=0;
//               obj.postDetails=post;
//               obj.sId=id;
//               commentList.add(obj);
//           //  return obj;

//           //  snackBarCalled(context,"Adding Comment...!",Colors.black);

//             //  Navigator.pop(context);
//             //  Navigator.pushNamed(context, '/home');

//       }else{
//            snackBarCalled(context,"can't Add comment!",Colors.red);
// }

// }

// Container(
//   color: Colorcodes.appBarColor,
//   padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 6),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(("Tribe"),
//           style: FontManager().getTextStyle(context,
//               lWeight: FontWeight.w500,
//               fontSize: 22,
//               color: Colors.black)),
//       Container(
//         child: Row(
//           children: [
//             InkWell(
//                 onTap: (){
//                         // Navigator.pushNamed(context, '/TribeSearch');

//                         Navigator.push(
//                           context,
//                           PageTransition(
//                                 type: PageTransitionType.topToBottom,
//                                 duration: Durations.long1,
//                                 child:TribeSearch(),
//                                 isIos: true,
//                           ),
//                         );

//                 },
//                 child: imageurl("assets/Icons/Search.svg")
//               ),
//             SizedBox(
//               width: 20,
//             ),
//             InkWell(
//               onTap: (){
//                         // Navigator.pushNamed(context, '/TribeChats');

//                         Navigator.push(
//                         context,
//                         PageTransition(
//                               type: PageTransitionType.leftToRight,
//                               duration: Durations.long1,
//                               child:TribeChats(),
//                               isIos: true,
//                         ),
//                     );
//                 },
//               child: imageurl("/Chat.svg")),
//           ],
//         ),
//       )
//     ],
//   ),
// ),

Widget textStyleModel(context, str, id, [flag = false]) {
  bool f = str == "Helps us to understand the issue, and look into it.";
  return GestureDetector(
    onTap: () {
      reportPost(context, id, str);
      if (flag) {
        getPost();
        getTrending();
        Navigator.pop(context);
      }
      Navigator.pop(context);
    },
    child: Text(
      str,
      style: FontManager().getTextStyle(
        context,
        fontSize: f ? 18 : 15,
        lWeight: f ? FontWeight.bold : FontWeight.w500,
        color: AppColors.primaryColor,
        lineHeight: 1.3,
        //  fontStyle: FontStyle.italic
      ),
    ),
  );
}

Widget showModel(context, id, [flag = false]) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height / 2.3,
    decoration: BoxDecoration(
        color: Colorcodes.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    child: Column(
      // mainAxisAlignment: ,,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Report",
          style: FontManager().getTextStyle(
            context,
            fontSize: 20,
            lWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: textStyleModel(context,"Helps us to understand the issue, and look into it.", id, flag),
        ),
        const SizedBox(
          height: 20,
        ),
        textStyleModel(context, "I am not interested.", id, flag),
        dividerCalled(),
        textStyleModel(context, "Harassment or hateful speech", id, flag),
        dividerCalled(),
        textStyleModel(context, "Self-harm or suicide", id, flag),
        dividerCalled(),
        textStyleModel(context, "Adult content", id, flag),
        dividerCalled(),
        textStyleModel(context, "False information or misleading", id, flag),
        dividerCalled(),
        textStyleModel(context, "Spam", id, flag),
      ],
    ),
  );
}

Widget dividerCalled() {
  return Divider(
    thickness: .3,
    endIndent: 10,
    indent: 10,
    color: Colorcodes.black,
  );
}



     
      //     Container(
      //       padding: const EdgeInsets.fromLTRB(20,10,20,20),
      //       decoration: BoxDecoration(
      //           color: const Color.fromRGBO(249, 246, 238, 1),
      //           borderRadius: BorderRadius.circular(20)),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             children: [
      //               Container(
      //                 child: Row(
      //                   children: [
      //                     AvatarProfileImage(url:dataObj["author"]['avatar'] ,width: 8,height: 12,),
      //                     const SizedBox(width: 10,),
      //                     Text((dataObj["author"]['name']),
      //                         style: FontManager().getTextStyle(context,
      //                             lWeight: FontWeight.w400,
      //                             fontSize: 18,
      //                             color: Colors.black)),
      //                   ],
      //                 ),
      //               ),
      //               SizedBox(
      //                 child: Row(
      //                   children: [
                          // InkWell(
                          //   onTap: (){
                             
                          //            if(!fill.value)
                          //            {
                          //               savePostData(context,widget.dataObj);
                          //               snackBarCalled(context, "Post is Saved...!!");
                          //               fill.value=true;
                          //            }

                          //            else snackBarCalled(context, "Post is Already Saved...!!");
                              
                          //   },
                          //   child: Obx(() => SvgPicture.asset(
                          //             fill.value ? "assets/images/Saved.svg" : "assets/images/Save.svg",
                          //             height: 25,
                          //             width: 25,
                          //           )),
      //                       // child:SvgPicture.asset(
      //                       //               Obx (() =>!fill ?"assets/images/Save.svg":"assets/images/Saved.svg",));
      //                       //               height: 25,
      //                       //               width: 25,  
      //                       // )),
      //                       // child: SvgPicture.asset(
                                        
      //                       //               !fill ?"assets/images/Save.svg":"assets/images/Saved.svg",
      //                       //               height: 25,
      //                       //               width: 25,  
      //                       // ),
      //                     ),
      //                     const SizedBox(width: 20,),

      //                     // Icon(
      //                     //   Icons.more_vert_outlined,
      //                     //   size: 25,
      //                     //   color: Colors.black,
      //                     // ),
      //                      popUpBox(dataObj['_id'],context),
      //                   ],
      //                 ),
      //               )
      //             ],
      //           ),
      //           // Padding(
      //           //   padding: const EdgeInsets.symmetric(vertical: 10),
      //           //   child: Text((dataObj['title']),
      //           //       style: FontManager().getTextStyle(context,
      //           //           lWeight: FontWeight.w400,
      //           //           fontSize: 16,
      //           //           color: Colors.black)),
      //           // ),
      //              Readmore(str:dataObj['title'].toString(),),
      //           //  ReadMoreText(
      //           //     dataObj['title'].toString(),
      //           //     trimMode: TrimMode.Line,
      //           //     trimLines: 2,
                    
      //           //     colorClickableText: Colors.pink,
      //           //     trimCollapsedText: 'Show more',
      //           //     trimExpandedText: 'Show less',
      //           //     moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      //           // ),
      //           //  barGraph(dataObj):pieChart(dataObj)
      //  (dataObj['chartType']=="bargraph" ||  dataObj['chartType']=="piechart")?    
      //         dataObj['chartType']=="bargraph"?  barGraph(dataObj):pieChart(dataObj)
      //       // :Padding(
      //       //       padding: const EdgeInsets.only(bottom: 10.0),
      //       //       child: Text((dataObj['description']['message']),
      //       //           style: FontManager().getTextStyle(context,
      //       //               lWeight: FontWeight.w400,
      //       //               fontSize: 16,
      //       //               color: Colors.black)),
      //       //     ),
      //       :  Readmore(str:dataObj['description']['message']??"",), 
               
      //         dataObj['image'] != null && dataObj['image'] !="none"  ? GFImageOverlay(
      //                 width: MediaQuery.of(context).size.width / 1.1,
      //                 height: MediaQuery.of(context).size.height/3,
      //                 shape: BoxShape.rectangle, 
      //                 image: NetworkImage(dataObj['image']),
      //                 colorFilter:ColorFilter.mode(Colors.black.withOpacity(0.0),
      //                 BlendMode.exclusion),
      //            ): SizedBox.shrink(),
                 
      //           const SizedBox(
      //             height: 20,
      //           ),
      //           // Row(
      //           //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           //   crossAxisAlignment: CrossAxisAlignment.center,
      //           //   children: [
      //           //     Container(
                      
      //           //            decoration: BoxDecoration(
      //           //                 border: Border.all(),
      //           //                 borderRadius: BorderRadius.circular(100)
      //           //            ),
      //           //       child: Row(
      //           //         children: [
      //           //         GestureDetector(
      //           //               onTap: (){
      //           //                    upvote(context,"Post",widget.id,widget.dataObj);
      //           //                     getpost(widget.id);
                                 
      //           //               },
      //           //             child: const Icon(
      //           //               Icons.arrow_drop_up_outlined,
      //           //               size: 35,
      //           //               color: Colors.black,
      //           //             ),
      //           //           ),
      //           //           Text((dataObj["upvotes"].toString()),
      //           //               style: FontManager().getTextStyle(context,
      //           //                   lWeight: FontWeight.w400,
      //           //                   fontSize: 18,
      //           //                   color: Colors.black)),
      //           //         GestureDetector(
      //           //               onTap: (){
      //           //                    downvote(context,"Post",widget.id,dataObj);  
                                  
      //           //               },
      //           //             child: const Icon(
      //           //               Icons.arrow_drop_down_outlined,
      //           //               size: 35,
      //           //               color: Colors.black,
      //           //             ),
      //           //           ),
      //           //         ],
      //           //       ),
      //           //     ),
      //           //     InkWell(
      //           //         onTap: () {
      //           //                     // Navigator.push(
      //           //                     //       context,
      //           //                     //       PageTransition(
      //           //                     //             type: PageTransitionType.bottomToTop,
      //           //                     //             duration: Durations.long1,
      //           //                     //             child:TribeShare(data: dataObj,),
      //           //                     //             isIos: true,
      //           //                     //       ));


      //           //     showModalBottomSheet(context: context,
      //           //     backgroundColor: Colorcodes.appBarColor,
      //           //      builder: (context) {
      //           //               return TribeShare(data: dataObj,dataObj:dataObj);
      //           //          },);



      //           //         },
      //           //         child: imageurl('assets/images2/share.svg'))
      //           //   ],
      //           // ),
      //           vote(context,dataObj,dataObj),
      //         ],
      //       ),
      //     ),