import 'dart:convert';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart";
import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Tribe/model_delete_edit.dart";
import "package:flutter_application_code_stakeplot/Tribe/tribe_home.dart";
import "package:flutter_application_code_stakeplot/Utils/snackBar.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/model/comment.dart";
import "package:flutter_application_code_stakeplot/model/post_model.dart";
import "package:flutter_application_code_stakeplot/routes.dart";
import "package:flutter_svg/svg.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:http/http.dart' as http;
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";

RxBool toggle = false.obs;
RxList<Comments> commentList = <Comments>[].obs;
RxList<int> indexArray = <int>[].obs;

class TribeUnique extends StatefulWidget {
  final String id;
  PostModel dataObj;
  RxBool popBox;
  TribeUnique(
      {Key? key, required this.id, required this.dataObj, required this.popBox})
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
  List historyListData = [];
  List commentListData = [];
  List postList = [];

  late Comments commentObj;

  bool onReply = false;
  String replyid = "";
  String name = "";
  String userId = "";
  late PostModel dataObj;

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

  void addComment(
    context,
    String data,
    String postId,
  ) async {
    if (data == "") {
      FocusScope.of(context).requestFocus(_replyFocusNode);
      snackBarCalledfail(
          context, SnackbarData().emptyCommentNotAllowed, Colors.red);
      return;
    }

    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");

    Comments obj = Comments();
    Author auth = Author();
    PostDetails post = PostDetails();

    // auth.id = authorId;
    auth.name = userController.maskedName.value;
    auth.avatar = userController.avatar.value;
    auth.avatarBackGround = userController.avatarBackGround.value;

    obj.replies = [];
    obj.author = auth;
    obj.commentText = data;
    obj.upvotes = 0;
    obj.downvotes = 0;
    obj.postDetails = post;

    // commentList.insert(0,obj);
    // indexArray.add(i);
    // i++;

    final response = await http.post(
      Uri.parse('${url}/comment/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        'post': postId,
        // 'user': authorId,
        'comment': data,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);

      var id = body['data']['_id'];
      obj.sId = id;

      commentList.insert(0, obj);
      indexArray.add(i);
      i++;

      postController.postCount[id] = 0;
      snackBarCalled(
          context, SnackbarData().commentAddedSuccessfully, Colors.black);
    } else {
      snackBarCalledfail(
          context, SnackbarData().unableToAddComment, Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    dataObj = widget.dataObj;
    postController.uniquePostDeatils = widget.dataObj;
    getpost(widget.id);
    getTransactionComments();
    getInfo();
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
        userController.avatar.value = obj['avatarType'];
      });
    } else {}
  }

  void getTransactionComments() async {
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
      historyListData = obj;

      commentList.clear();

      historyListData.forEach((e) {
        // Comments obj=Comments();
        //  historyListData.forEach((element) {
        postController.postCount[e["_id"]] = e['upvotes'];
        //  });

        Comments obj = Comments.fromJson(e);
        indexArray.add(i);
        i++;

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
    if (!widget.popBox.value) {
      // post screen withoutv comments
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                size: 30,
              )),
          title: Text(
            "FinSpace",
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.finSpaceColor),
          ),
        ),
        // bottomNavigationBar: BottomNavigations(data: sizeRoom ? 3 : 2),
        extendBody: true,

        body: SafeArea(
          child: Container(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  Obx(() => PostCard(
                        data: postController.reloadUniquePost.value
                            ? postController.uniquePostDeatils
                            : postController.uniquePostDeatils,
                        flag: true,
                        index: -1,
                        isTribeOne: true,
                      )),
                  uploadData(postController.uniquePostDeatils)
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return SafeArea(
        child: Container(
          child: AnimatedPadding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            duration: const Duration(milliseconds: 100),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(() => widget.popBox.value
                      ? uploadData(postController.uniquePostDeatils)
                      : SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 30,
    );
  }

  Widget uploadData(PostModel dataObj) {
    return Padding(
      padding: widget.popBox.value
          ? const EdgeInsets.only(bottom: 15, top: 10)
          : const EdgeInsets.only(bottom: 0, top: 0),
      child: Container(
        child: Column(
          children: [
            widget.popBox.value
                ? Text(
                    "Comments",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black),
                  )
                : SizedBox.shrink(),
            widget.popBox.value
                ? Divider(
                    color: AppColors.buttonBorder,
                    thickness: 0.8,
                  )
                : SizedBox.shrink(),
            commentedData(dataObj),
          ],
        ),
      ),
    );
  }

  Widget commentedData(PostModel dataObj) {
    return Container(
        width: MediaQuery.sizeOf(context).width / 1,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(

            // color: const Color.fromRGBO(249, 246, 238, 1),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            //  commentText:

            Obx(
              () => Container(
                width: MediaQuery.sizeOf(context).width / 1,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(

                    //  color: Colorcodes.budgetLightGreen,
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.popBox.value
                        ? replyid == "" // adding comment
                            ? InputDate("Add a comment", TextInputType.name,
                                calController1, widget.id)
                            : SizedBox.shrink()
                        : SizedBox.shrink(),
                    // Column(
                    //   children: commentList
                    //       .map((index) =>
                    //           dataComments(commentList[index], index,dataObj))
                    //       .toList(),
                    // ),
                    Column(
                      children: commentList.asMap().entries.map((entry) {
                        int index = entry.key;
                        var comment = entry.value;

                        return dataComments(comment, index, dataObj);
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget dataComments(Comments data, int index, PostModel dataObj) {
    List<Replies> list = data.replies ?? [];

    String idData = data.sId == null ? "" : data.sId.toString();
    double width = MediaQuery.of(context).size.width;

    return Obx(() => Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarProfileImagePng(
                    url: data.author!.avatar.toString(),
                    width: 10,
                    height: 23,
                    // background: data.author!.avatarBackGround.toString(),
                  ),
                  const SizedBox(width: 0),
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
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                (data.author!.name ?? "name"),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.bg1),
                              ),

                              //  trimlowercase(dataObj.author.maskedName) == trimlowercase(userController.maskedName) || (trimlowercase(data.author!.name)) == trimlowercase(userController.maskedName)?
                              //   Row(
                              //        children: [
                              //         InkWell(
                              //           onTap: (){
                              //               showDeleteDialogComment(context,data.commentText.toString(),'comment',data.sId.toString(),dataObj.id,index,0);
                              //           },
                              //           child: Icon(Icons.delete,size: 20,color: Colorcodes.red)),
                              //         (trimlowercase(data.author!.name)) == trimlowercase(userController.maskedName)  ?  Padding(
                              //           padding: const EdgeInsets.only(left: 5),
                              //           child: IconButton(
                              //             icon: Icon(Icons.edit),
                              //             onPressed: () {
                              //               showEditBottomSheet(
                              //                 context: context,
                              //                 initialText:data.commentText.toString() ,
                              //                 id: data.sId.toString(),
                              //                 postId: dataObj.id,
                              //                 type: 'comment'

                              //               );
                              //             },
                              //          ),
                              //         )
                              //         :
                              //         SizedBox.shrink(),

                              //        ],
                              //     ):SizedBox.shrink(),

                              trimlowercase(dataObj.author.maskedName) ==
                                          trimlowercase(
                                              userController.maskedName) ||
                                      trimlowercase(data.author!.name) ==
                                          trimlowercase(
                                              userController.maskedName)
                                  ? Align(
                                      alignment: Alignment.topRight,
                                      
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_horiz_rounded,
                                            size: 20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        position: PopupMenuPosition.under,
                                        offset: Offset(-20, -10),
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            showDeleteDialogComment(
                                              context,
                                              data.commentText.toString(),
                                              'comment',
                                              data.sId.toString(),
                                              dataObj.id,
                                              index,
                                              0,
                                            );
                                          } else if (value == 'edit') {
                                            showEditBottomSheet(
                                              context: context,
                                              initialText:
                                                  data.commentText.toString(),
                                              id: data.sId.toString(),
                                              postId: dataObj.id,
                                              type: 'comment',
                                            );
                                          }
                                        },
                                        color: Colorcodes.white,
                                        itemBuilder: (BuildContext context) {
                                          List<PopupMenuEntry<String>> items =
                                              [];
                                          if (trimlowercase(
                                                  data.author!.name) ==
                                              trimlowercase(
                                                  userController.maskedName)) {
                                            items.add(
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit',
                                                    style: getStyle()),
                                              ),
                                            );
                                          }
                                          if (trimlowercase(dataObj
                                                      .author.maskedName) ==
                                                  trimlowercase(userController
                                                      .maskedName) ||
                                              trimlowercase(
                                                      data.author!.name) ==
                                                  trimlowercase(userController
                                                      .maskedName)) {
                                            items.add(
                                              PopupMenuItem(

                                                value: 'delete',
                                                child: Text('Delete',
                                                    style: getStyle()),
                                              ),
                                            );
                                          }
                                          return items;
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                        SizedBox(
                          child: Text(
                            (data.commentText!),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.commentColor),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Container(
                                  height:
                                      MediaQuery.sizeOf(context).height / 36,
                                  width: MediaQuery.sizeOf(context).width / 7,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (userController.maskedName.value
                                              .trim()
                                              .isEmpty) {
                                            MaskedNameDialogBox
                                                .showMaskedNameDialog(context);
                                          } else {
                                            upvote2(
                                                context,
                                                "Comment",
                                                data.sId!,
                                                data,
                                                historyListData,
                                                data,
                                                index);
                                            String l1 = "liked" + idData;
                                            bool liked = postController
                                                .likedList
                                                .contains(l1);
                                            String l2 = "disliked" + idData;
                                            bool disliked = postController
                                                .likedList
                                                .contains(l2);
                                            if (liked) {
                                              postController.likedList
                                                  .remove(l1);
                                              postController.postCount[idData] =
                                                  postController
                                                          .postCount[idData]! -
                                                      1;
                                              if (postController
                                                      .postCount[idData]! <
                                                  0) {
                                                postController
                                                    .postCount[idData] = 0;
                                              }
                                            } else {
                                              postController.likedList.add(l1);
                                              postController.postCount[idData] =
                                                  postController
                                                          .postCount[idData]! +
                                                      1;
                                            }
                                            postController.likedList.remove(l2);
                                            reRender.value = !reRender.value;
                                          }
                                        },
                                        child: likeIcon(
                                            context,
                                            postController.likedList.contains(
                                                "liked" + data.sId.toString())),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: Text(
                                          data.sId == null
                                              ? '0'
                                              : (reRender.value
                                                  ? postController.postCount[
                                                              data.sId]! <
                                                          0
                                                      ? postController
                                                          .postCount[dataObj.id]
                                                          .toString()
                                                      : (postController
                                                          .postCount[data.sId]
                                                          .toString())
                                                  : (postController
                                                      .postCount[data.sId]
                                                      .toString())),
                                          style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(_replyNode);
                                  // _scrollToTextField();
                                  autofocus.value = true;
                                  setState(() {
                                    commentObj = data;
                                    str = "reply to " + data.commentText!;
                                    replyid = data.sId!;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: Container(
                                    height:
                                        MediaQuery.sizeOf(context).height / 36,
                                    width: MediaQuery.sizeOf(context).width / 7,
                                    child: Center(
                                      child: Text(
                                        'Reply',
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: AppColors.commentColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Column(
                        //   children:
                        //       list.map((obj) => replyDatas(obj, data,dataObj,index)).toList(),
                        // ),
                        Column(
                          children: list.asMap().entries.map((entry) {
                            int indexReply = entry.key;
                            var obj = entry.value;
                            return replyDatas(
                                obj, data, dataObj, index, indexReply);
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (replyid == idData)
              Padding(
                padding: const EdgeInsets.only(left: 40.0, top: 4.0),
                child: InputComment(
                  str,
                  TextInputType.name,
                  replyController,
                  replyid,
                ),
              ),
            index + 1 == indexArray.length
                ? SizedBox.shrink()
                : Divider(
                    color: AppColors.buttonBorder,
                    thickness: index + 1 == indexArray.length ? 0 : .8,
                    endIndent: 5,
                    indent: 5,
                  ),
          ],
        ));
  }

  getStyle() {
    return FontManager().getTextStyle(context,
        lWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryColor);
  }

  Widget InputDate(lableText, keyBoard, TextEditingController Textcontroller,
      String postId) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        child: Center(
          child: TextField(
            focusNode: _replyFocusNode,
            keyboardType: keyBoard,
            autofocus: true,
            maxLines: null,
            controller: Textcontroller,
            onSubmitted: (value) {
              if (userController.maskedName.value.trim().isEmpty) {
                MaskedNameDialogBox.showMaskedNameDialog(context);
              } else {
                addComment(context, value, postId);
                postController.postCommentCount
                    .putIfAbsent(postId, () => widget.dataObj.comments);
                postController.postCommentCount
                    .update(postId, (value) => value + 1);
                Textcontroller.clear();
              }
            },
            decoration: InputDecoration(
              filled: true,
              suffixIcon: suffixcomment(Textcontroller, postId),
              hintText: lableText,
              hintStyle: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.buttonBorder),
              enabledBorder: const OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(40),
                  ),
              focusedBorder: const OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(color: AppColors.buttonBorder)),
              fillColor: AppColors.backgroundColor,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget InputComment(
    lableText,
    keyBoard,
    TextEditingController Textcontroller,
    String commentId,
  ) {
    if (commentId == "") return SizedBox.shrink();
    return Obx(() => Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarProfileImagePng(
                  url: userController
                      .avatar.value, // Use the user's name from state
                  width: 10,
                  height: 23,
                ),
                Container(
                  // height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width / 1.6,
                  child: Center(
                    child: TextField(
                      focusNode: _replyNode,
                      autofocus: autofocus.value,
                      keyboardType: keyBoard,
                      maxLines: null,
                      controller: Textcontroller,
                      readOnly: commentId == "",
                      onSubmitted: (value) {
                        reply(value, commentId, Textcontroller);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        hintText: lableText,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        suffixIcon: suffix(
                            Textcontroller.text, commentId, Textcontroller),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.buttonBorder)),
                        fillColor: AppColors.backgroundColor,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
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
        child: Icon(
          Icons.mode_comment_outlined, // Or Icons.favorite if already liked
          size: 20,
          color: AppColors.primaryColor, // Optional
        ),
      ),
    );
  }

  Widget suffixcomment(TextEditingController Textcontroller, postId) {
    return GestureDetector(
      onTap: () {
        if (userController.maskedName.value.trim().isEmpty) {
          MaskedNameDialogBox.showMaskedNameDialog(context);
        } else {
          String value = Textcontroller.text;

          addComment(
            context,
            value,
            postId,
          );
          postController.postCommentCount
              .putIfAbsent(postId, () => widget.dataObj.comments ?? 0);
          postController.postCommentCount.update(postId, (value) => value + 1);
          Textcontroller.clear();
        }
      },
      child: Container(
        height: 10,
        width: 10,
        child: Icon(
          Icons.mode_comment_outlined, // Or Icons.favorite if already liked
          size: 20,
          color: AppColors.primaryColor, // Optional
        ),
      ),
    );
  }

  void _scrollToTextField() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
  }

  Widget replyDatas(Replies replayObj, Comments data, PostModel dataObj,
      int index, int replyIndex) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarProfileImagePng(
              url: replayObj.author!.avatar.toString(),
              width: 10,
              height: 23,
            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text((replayObj.author!.name.toString()),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.bg1)),
                      ),
                      //  trimlowercase(dataObj.author.maskedName) == trimlowercase(userController.maskedName)   ||  trimlowercase(replayObj.author!.name)==trimlowercase(userController.maskedName)?
                      //           Row(
                      //                children: [
                      //                       InkWell(
                      //                         onTap: (){
                      //                           showDeleteDialogComment(context,replayObj.replyText!,'reply',replayObj.sId.toString(),data.sId.toString(),index,replyIndex);
                      //                         },
                      //                         child: Icon(Icons.delete,size: 20,color: Colorcodes.red)),
                      //                       trimlowercase(replayObj.author!.name)==trimlowercase(userController.maskedName)? Padding(
                      //                         padding: const EdgeInsets.only(left: 5),
                      //                         child:IconButton(
                      //                     icon: Icon(Icons.edit),
                      //                     onPressed: () {
                      //                       showEditBottomSheet(
                      //                         context: context,
                      //                         initialText:replayObj.replyText.toString() ,
                      //                         id: replayObj.sId.toString(),
                      //                         postId: data.sId.toString(),
                      //                         type: 'reply'
                      //                       );
                      //                     },
                      //                  ),
                      //                       ):SizedBox.shrink(),
                      //                ],
                      //             ):SizedBox.shrink(),

                      trimlowercase(dataObj.author.maskedName) ==
                                  trimlowercase(userController.maskedName) ||
                              trimlowercase(replayObj.author!.name) ==
                                  trimlowercase(userController.maskedName)
                          ? Align(
                              alignment: Alignment.topRight,
                              heightFactor: 1.1,
                              widthFactor: 1.1,
                            
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_horiz_rounded, size: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                position: PopupMenuPosition.under,
                                offset: Offset(-20, -10),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    showDeleteDialogComment(
                                      context,
                                      replayObj.replyText ?? '',
                                      'reply',
                                      replayObj.sId.toString(),
                                      data.sId.toString(),
                                      index,
                                      replyIndex,
                                    );
                                  } else if (value == 'edit') {
                                    showEditBottomSheet(
                                      context: context,
                                      initialText: replayObj.replyText ?? '',
                                      id: replayObj.sId.toString(),
                                      postId: data.sId.toString(),
                                      type: 'reply',
                                    );
                                  }
                                },
                                 color: Colorcodes.white,
                                itemBuilder: (BuildContext context) {
                                  List<PopupMenuEntry<String>> items = [];

                                  // Show "Edit" only if the logged-in user is the reply author
                                  if (trimlowercase(replayObj.author!.name) ==
                                      trimlowercase(
                                          userController.maskedName)) {
                                    items.add(
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit', style: getStyle()),
                                      ),
                                    );
                                  }

                                  // Show "Delete" if the user is either the post owner or the reply author
                                  if (trimlowercase(
                                              dataObj.author.maskedName) ==
                                          trimlowercase(
                                              userController.maskedName) ||
                                      trimlowercase(replayObj.author!.name) ==
                                          trimlowercase(
                                              userController.maskedName)) {
                                    items.add(
                                      PopupMenuItem(
                                        value: 'delete',
                                        child:
                                            Text('Delete', style: getStyle()),
                                      ),
                                    );
                                  }

                                  return items;
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  Text((replayObj.replyText!),
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.commentColor,
                      )),
                ],
              ),
            )
          ]),
    );
  }

  String trimlowercase(str) {
    return str.toString().trim().toLowerCase();
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
          boolVar.value = !boolVar.value;
          commentList[index].upvotes = commentList[index].upvotes! + 1;
          postListIds.add(objectId);
        } else {
          boolVar.value = !boolVar.value;
          commentList[index].upvotes = commentList[index].upvotes! - 1;
          postListIds.remove(objectId);
        }
      });

      commentList.add(dataObj);
      commentList.removeLast();
    } else {}
  }

  void reply(value, commentId, Textcontroller) async {
    if (userController.maskedName.value.trim().isEmpty) {
      MaskedNameDialogBox.showMaskedNameDialog(context);
    } else {
      if (value == "") {
        FocusScope.of(context).requestFocus(_replyNode);
        snackBarCalledfail(
            context, SnackbarData().emptyReplyNotAllowed, Colors.red);
        return;
      }

      if (commentId == "") return;
      var responce = await addReply(context, value, commentId, widget.id);
      var body = jsonDecode(responce.body);
      replyid = '';
      Replies rep = Replies();
      rep.sId = body['data']['_id'];
      rep.commentId = body['data']['comment'];
      rep.replyText = value;
      Author author = Author();
      author.name = userController.maskedName.value;
      author.id = name;
      author.avatar = userController.avatar.value;
      author.name = userController.maskedName.value;
      author.avatar = userController.avatar.value;
      author.avatarBackGround = userController.avatarBackGround.value;
      //  author.avatar=avatar;
      rep.author = author;
      commentObj.replies!.insert(0, rep);
      Textcontroller.clear();
      autofocus.value = false;
      setState(() {});
    }
  }
}
