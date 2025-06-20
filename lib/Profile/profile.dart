// import "dart:convert";
// // import "dart:ffi";

// import "package:flutter/cupertino.dart";
// import "package:flutter/material.dart";
// import "package:flutter/widgets.dart";
// import "package:flutter_application_code_stakeplot/Profile/Saved.dart";
// import "package:flutter_application_code_stakeplot/Tribe/tribe_home.dart";
// import "package:flutter_application_code_stakeplot/Tribe/tribe_one.dart";
// import "package:flutter_application_code_stakeplot/avatarProfile.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart";
// import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
// import "package:flutter_application_code_stakeplot/headersList/textfeild.dart";
// import "package:flutter_application_code_stakeplot/profile.dart";
// import "package:flutter_application_code_stakeplot/readmore.dart";
// import "package:get/get.dart";
// import "package:get/get_rx/get_rx.dart";
// import "package:page_transition/page_transition.dart";
// import "package:readmore/readmore.dart";
// import "package:shared_preferences/shared_preferences.dart";

// import "dart:convert";
// import "package:flutter/material.dart";
// import "package:flutter_application_code_stakeplot/Community_Page/postCard.dart";
// import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart";
// import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
// import "package:flutter_application_code_stakeplot/colorcodes.dart";
// import "package:flutter_application_code_stakeplot/headersList/userProfileHeader.dart";
// import "package:get/get.dart";
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import "package:syncfusion_flutter_charts/charts.dart";
// // List<Color> color=[Color.fromARGB(255, 112, 185, 246),Color.fromARGB(255, 237, 131, 131),Color.fromAc

// class Profile extends StatefulWidget {
//   Profile({Key? key}) : super(key: key);

//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class SalesData {
//   final String month;
//   final double sales;

//   SalesData(this.month, this.sales);
// }

// class _ProfileState extends State<Profile> {
//   var data;

//   bool findData = true;

//   TextEditingController emailController = TextEditingController();
//   TextEditingController userController = TextEditingController();
//   TextEditingController emailIdController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController currencyController = TextEditingController();

//   //  var data={
//   //      'name':"Loading....",
//   //      'email':"Loading....",
//   //      "phone":"Loading....",
//   //      "currency":"Loading....",
//   //  };

//   @override
//   void initState() {
//     super.initState();
//     getUserInfomations();
//     // getDis();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         extendBody: true,
//         backgroundColor: Colorcodes.budgetDarkGreen,
//         bottomNavigationBar: BottomNavigations(data: 4),

//         // appBar: AppBar(
//         //   automaticallyImplyLeading: false,
//         //   // toolbarHeight: 90,
//         //   backgroundColor: Colorcodes.budgetDarkGreen,
//         //   title:   UserProfileHeader(name: userName.value),
//         // ),

//         body: Obx(
//           () => Column(
//             children: [
//               UserProfileHeader(
//                 name: userName.value,
//                 flag: false,
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: Colorcodes.paddingTopDesign),
//                   child: Container(
//                     height: MediaQuery.of(context).size.height,
//                     width: MediaQuery.of(context).size.width,
//                     padding: EdgeInsets.only(top: Colorcodes.paddingTopScroll),
//                     decoration: BoxDecoration(
//                         color: Colorcodes.white,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(Colorcodes.borderCut),
//                           topRight: Radius.circular(Colorcodes.borderCut),
//                         )),
//                     child: ListView(
//                       // mainAxisAlignment: MainAxisAlignment.start,
//                       // crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10.0, vertical: 0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               getIncome(),
//                               getTop(),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20.0, vertical: 10),
//                                 child: Text(("Details"),
//                                     style: FontManager().getTextStyle(context,
//                                         lWeight: FontWeight.w500,
//                                         fontSize: 20,
//                                         color: Colors.black)),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 0),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 10),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                     // color: Colorcodes.lightTheamColor,
//                                   ),
//                                   child: Obx(() => Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           TextFeildWidget2(
//                                               heading: "User Name",
//                                               lableText: userName.value),
//                                           TextFeildWidget2(
//                                               heading: "Email",
//                                               lableText: email.value),
//                                           TextFeildWidget2(
//                                               heading: "Phone Number",
//                                               lableText: Phone.value),
//                                           TextFeildWidget2(
//                                               heading: "Currency",
//                                               lableText: currency.value),
//                                           // TextFeildWidget2(heading: "Score", lableText: score.value),

//                                           // dataInputByUser("Username:", userController,userName.value),
//                                           // dataInputByUser("Email :", emailIdController,email.value),
//                                           // dataInputByUser("phone Number :", phoneController,Phone.value),
//                                           // dataInputByUser("currency :", currencyController,currency.value),
//                                         ],
//                                       )),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         myDis(),
//                         logoutWidget(context),
//                         help(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget help() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         children: [
//           Center(
//             child: Text(("Help & Support"),
//                 style: FontManager().getTextStyle(context,
//                     lWeight: FontWeight.w300,
//                     fontSize: 15,
//                     color: Colors.black)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget imageurl(url) {
//     return SvgPicture.asset(
//       url,
//       height: 30,
//     );
//   }

//   Widget textStyle(String str, color, double size) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5),
//       child: Text(
//         str,
//         style: FontManager().getTextStyle(context,
//             fontSize: size, color: color, lWeight: FontWeight.bold),
//       ),
//     );
//   }
//   // Widget textStyleDesign(String str,color,double size){
//   //     return Card(
//   //       elevation: 3,
//   //       shape: RoundedRectangleBorder(
//   //               borderRadius: BorderRadius.circular(Colorcodes.borderRadius-10),
//   //             ),

//   //       child: Container(
//   //         decoration: BoxDecoration(
//   //         borderRadius: BorderRadius.circular(Colorcodes.borderRadius-10),
//   //                  gradient: LinearGradient(
//   //                                         begin: Alignment.centerLeft,
//   //                                         end: Alignment.centerRight,
//   //                                         colors: [
//   //                                           Colorcodes.cardShade3,
//   //                                           Colorcodes.dropdown,
//   //                                           // Colorcodes.cardShade2,
//   //                                         ],
//   //                    ),
//   //         ),
//   //         padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 15),
//   //         child: Text(str,style: FontManager().getTextStyle(context,
//   //                fontSize: size,
//   //                color:Colorcodes.white ,
//   //                lWeight: FontWeight.bold
//   //         ),),
//   //       ),
//   //     );
//   // }

//   Widget aboutUs() {
//     return Card(
//       elevation: Colorcodes.elevation,
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 0),
//         child: Container(
//           width: MediaQuery.of(context).size.width / 1.1,
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Colorcodes.white,
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4.0),
//                 child: Text(("About"),
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.bold,
//                         fontSize: 22,
//                         color: Colors.black)),
//               ),
//               Obx(() => aboutMe.value
//                   ? InputDate("Tell about yourself", TextInputType.emailAddress,
//                       emailController)
//                   : Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Obx(
//                         () => Text(
//                             (aboutUS.value.isEmpty
//                                 ? "Loading...."
//                                 : aboutUS.value),
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.w400,
//                                 fontSize: 20,
//                                 color: Colors.black)),
//                       ))),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget profileAmount() {
//     return UserProfileHeader(name: userName.value);
//   }

//   Widget getIncome() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 7.0),
//       child: Container(
//         // height: 50,
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Obx(() => Column(
//                   children: [
//                     textStyle("Income", Colorcodes.black, 18),
//                     textStyle(doubleToFixed(income.value.toString()),
//                         Colorcodes.blue, 18),
//                   ],
//                 )),
//             Obx(() => Column(
//                   children: [
//                     textStyle("Expense", Colorcodes.black, 18),
//                     textStyle(
//                         doubleToFixed(expenses.value), Colorcodes.red, 18),
//                   ],
//                 )),
//             Obx(() => Column(
//                   children: [
//                     textStyle("Score", Colorcodes.black, 18),
//                     textStyleDesign(doubleToFixed(score.value),
//                         Colorcodes.dropdown, 18, context),
//                   ],
//                 )),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget dataInputByUser(str, controller, value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 3.0),
//               child: Text((str),
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.w400,
//                       fontSize: 13,
//                       color: Colors.black)),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Container(
//               color: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               child: Text(
//                 value,
//                 style: FontManager().getTextStyle(context,
//                     lWeight: FontWeight.w400,
//                     fontSize: 13,
//                     color: Colors.black),
//               ),
//             ),
//           )
//           // Expanded(
//           //     flex: 2,
//           //     child: InputDate("", TextInputType.emailAddress, controller)),
//         ],
//       ),
//     );
//   }

//   Widget InputDate(lableText, keyBoard, Textcontroller) {
//     return Center(
//       child: TextField(
//         keyboardType: keyBoard,
//         controller: Textcontroller,
//         onSubmitted: (value) {
//           aboutuser(context, value);
//           aboutUS.value = value as String;
//           aboutMe.value = false;
//           // Navigator.pushReplacement(
//           //       context,
//           //       MaterialPageRoute(
//           //         builder: (context) => Profile(),
//           //       ),
//           //   );
//         },
//         decoration: InputDecoration(
//           filled: true,
//           hintText: lableText,
//           enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(0),
//               borderSide: BorderSide(color: Color.fromRGBO(249, 246, 238, 1))),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(0),
//               borderSide: BorderSide(color: Color.fromRGBO(249, 246, 238, 1))),
//           fillColor: Colors.white,
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }

//   Widget getTop() {
//     return Column(
//       children: [
//         //  profileAmount(),
//         Container(
//           width: MediaQuery.of(context).size.width,
//           height: 100,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             children: [
//               // servicesList("Add Account", (){
//               //          Navigator.push(
//               //               context,
//               //               PageTransition(
//               //                 type: PageTransitionType.fade,

//               //                 duration: Durations.long1,
//               //                 child: AddAccount(),
//               //                 isIos: true,
//               //               ),
//               //     );
//               //    }, svgIconPath.account),

//               servicesList("Friends List", () {
//                 Navigator.pushNamed(context, '/Friends');
//               }, svgIconPath.friends),

//               servicesList("Saved", () {
//                 Navigator.push(
//                   context,
//                   PageTransition(
//                     type: PageTransitionType.fade,
//                     duration: Durations.long1,
//                     child: Saved(
//                       data: savedList,
//                     ),
//                     isIos: true,
//                   ),
//                 );
//                 // Navigator.pushNamed(context, '/Saved');
//               }, svgIconPath.savedList),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget servicesList(name, onTap, urlPath) {
//     double width = MediaQuery.of(context).size.width;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: width > 500 ? width / 3.5 : width / 2,
//         margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Colorcodes.services,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Align(alignment: Alignment.topRight, child: imageurl(urlPath)),
//             Text(name,
//                 style: FontManager().getTextStyle(context,
//                     lWeight: FontWeight.bold,
//                     fontSize: 20,
//                     color: Colorcodes.white)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget myDis() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
//           child: Text("My Discussion ",
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.w500, fontSize: 20, color: Colors.black)),
//         ),
//         //  Column(children:getTrendingData.map((dataObj) => uploadData(dataObj)).toList()),
//         feedWidgets(),
//       ],
//     );
//   }

//   Widget feedWidgets() {
//     return Column(
//       children: [
//         Container(
//         child: Wrap(
//           children: myPostList.asMap().entries.map((entry) {
//             int index = entry.key;
//             var item = entry.value;
//             return PostCard(data: item, index: index);
//           }).toList(),
//         ),
//       ),
//         SizedBox(
//           height: 100,
//         ),
//       ],
//     );
//   }

//   Widget uploadData(dataObj) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//                 color: const Color.fromRGBO(249, 246, 238, 1),
//                 borderRadius: BorderRadius.circular(20)),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.person_pin_sharp,
//                             size: 35,
//                             color: Colors.black,
//                           ),
//                           // ProfileImage(),
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Text((dataObj["author"]['name']),
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w400,
//                                   fontSize: 18,
//                                   color: Colors.black)),
//                         ],
//                       ),
//                     ),
//                     // Icon(
//                     //   Icons.more_vert_outlined,
//                     //   size: 25,
//                     //   color: Colors.black,
//                     // ),
//                     popUpBox(dataObj['_id']),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Text((dataObj['title']),
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.w400,
//                           fontSize: 16,
//                           color: Colors.black)),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 10.0),
//                   child: Text((dataObj['description']['message']),
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.w400,
//                           fontSize: 16,
//                           color: Colors.black)),
//                 ),
//                 dataObj['image'] != null
//                     ? Container(
//                         width: MediaQuery.of(context).size.width / 1.1,
//                         height: MediaQuery.of(context).size.height / 3,
//                         child: Image.network(
//                           dataObj['image']['filePath'],
//                           fit: BoxFit.contain,
//                           filterQuality: FilterQuality.high,
//                         ),
//                         // child: Image.asset("assets/images/news.jpg", fit: BoxFit.fill),
//                       )
//                     : SizedBox.shrink(),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       child: Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               upvote(context, "Post", dataObj["_id"]);
//                             },
//                             child: const Icon(
//                               Icons.arrow_drop_up_outlined,
//                               size: 35,
//                               color: Colors.black,
//                             ),
//                           ),
//                           Text((dataObj["upvotes"].toString()),
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w400,
//                                   fontSize: 18,
//                                   color: Colors.black)),
//                           GestureDetector(
//                             onTap: () {
//                               downvote(context, "Post", dataObj["_id"]);
//                             },
//                             child: const Icon(
//                               Icons.arrow_drop_down_outlined,
//                               size: 35,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(
//                               height: 20,
//                               child: ProfileImage(
//                                 url: "assets/images/comment.svg",
//                               )),
//                           const SizedBox(
//                             width: 2,
//                           ),
//                           Text(dataObj["comments"].toString(),
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w400,
//                                   fontSize: 18,
//                                   color: Colors.black)),
//                           const SizedBox(width: 15),
//                           imageurl('assets/images2/share.svg'),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // void clearGetX() {
//   //           income=0.obs;
//   //           messages.clear();
//   //           messagesTemp.clear();
//   //           roomBills.clear();
//   //           questionRoom.clear();
//   //           productList.clear();
//   //           userPostList.clear();
//   //           savedList.clear();
//   //           myPostList.clear();
//   //           friendsList.clear();
//   //           chatList.clear();
//   //           chatListOriginal.clear();
//   //           friendsListDetails.clear();
//   //           chatOfUserList.clear();
//   //           chatOfUserListData.clear();
//   //           aboutMe=false.obs;
//   //           sizeRoom=false;
//   //           fontSize=20;
//   //           budgetLength=0.obs;
//   //           billLength=0.obs;
//   //           debtLength=0.obs;
//   //           paymentLength=0.obs;
//   //           keyss=originalKeys;
//   //           room=[];
//   //           account=[];
//   //           notificationList.clear();
//   //           hasGetNewNotifications.value=false;
//   //             userName="Loading...".obs;
//   //           currentId="Loading...".obs;
//   //           Phone="Loading...".obs;
//   //           currency="Loading...".obs;
//   //           score="Loading...".obs;
//   //           email="Loading...".obs;
//   //           userId="";
//   //        targetString="".obs;
//   //        listOfCater =<Plot> [].obs;
//   // }
// }

// Widget popUpBox(id) {
//   return PopupMenuButton(
//     initialValue: 2,
//     color: Colorcodes.appBarColor,
//     child: const Center(
//         child: Icon(
//       Icons.more_vert_outlined,
//       size: 25,
//       color: Colors.black,
//     )),
//     itemBuilder: (context) {
//       return [
//         PopupMenuItem(
//           value: 0,
//           child: Text("hide", style: FontManager().getTextStyle(context)),
//         ),
//         PopupMenuItem(
//           value: 1,
//           child: Text("Report", style: FontManager().getTextStyle(context)),
//         ),
//       ];
//     },
//   );
// }
