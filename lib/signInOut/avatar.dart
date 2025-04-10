import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/signInOut/confirm.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

RxString changeAvater = avatar.value.obs;

class Avatar extends StatefulWidget {
  var data;
  bool isEdit;
  Avatar({Key? key, required this.data, this.isEdit = false}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Avatar> {
  int index = 0;
  final PageController _pageController = PageController(viewportFraction: 0.7);
  int _currentPage = 0;

  // List<String> images = [
  //   "assets/avatar/menp1.svg",
  //   "assets/avatar/menp2.svg",
  //   "assets/avatar/menp3.svg",
  //   "assets/avatar/menp4.svg",
  //   "assets/avatar/womenp1.svg",
  //   "assets/avatar/womenp2.svg",
  //   "assets/avatar/womenp3.svg",
  //   "assets/avatar/womenp4.svg",
  // ];
   List<String> images = [
    "assets/onboarding/Avatar1.png",
    "assets/onboarding/Avatar2.png",
   "assets/onboarding/Avatar3.png",
    "assets/onboarding/Avatar4.png",
   "assets/onboarding/Avatar6.png",
   
   
  ];

  int activePage = 3;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  Widget slider() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 4, // Adjust height as needed
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        onPageChanged: (position) {
          setState(() {
            activePage = position;
          });
        },
        itemBuilder: (context, index) {
          double scale = (_currentPage == index) ? 1.0 : 0.8;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            transform: Matrix4.identity()..scale(scale),
            child: Container(
              height: 20,
              width: 100,
              child: SvgPicture.asset(
                images[index].replaceAll('.svg', '.png'),
                fit: BoxFit.cover,
                width: 20,
                height: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colorcodes.white,
        body: Container(
          height: MediaQuery.of(context).size.height * 2,
          //  padding:const EdgeInsets.only(bottom: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                        ("Choose Avatar!"), // email already exists..! or other errors
                        style: FontManager().getTextStyle(context,
                            fontSize: 18,
                            letterSpacing: 1.2,
                            lWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                ),

                Container(
                  height: MediaQuery.of(context).size.height / 4,
                  // width: 200,
                  child: SvgPicture.asset(
                    images[activePage],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: Text(
                        (!widget.data['name'].toString().isEmpty
                            ? widget.data['name']
                            : "Nilesh Toshniwal"), // email already exists..! or other errors
                        style: FontManager().getTextStyle(context,
                            fontSize: 18,
                            letterSpacing: 1.2,
                            lWeight: FontWeight.w400,
                            color: Colors.black)),
                  ),
                ),

                // avatarSlider(),
                // avatarSlider2(),
                slider(),

                const SizedBox(
                  height: 20,
                ),

                InkWell(
                  onTap: () {
                  
                    if (widget.isEdit) {
                      changeAvater.value = images[activePage];
                      avatar.value = changeAvater.value;
                      Navigator.pop(context);
                      return;
                    }
                   
                    getOTP(context, widget.data['name'], widget.data['email']);
        
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => conform(
                          data: widget.data,
                          url:  "assets/avatar/menp1.svg",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colorcodes.budgetLightGreen, width: .5)),
                    child: Center(
                      child: Text(("Continue"),
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colorcodes.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openShowModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return conform(data: widget.data, url: images[activePage]);
        });
  }

// Widget avatarSlider2(){
//     return   Container(
//                 width: MediaQuery.of(context).size.width,
//                  height: MediaQuery.of(context).size.height/3,
//                 // color: Colors.red,
//                 // height: MediaQuery.of(context).size.height/2,
//                 padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20),
//                 child: CarouselSlider.builder(
//                 itemCount: images.length,

//                 itemBuilder: (context, index, realIndex) {
//                     return  Container(
//                                    height: MediaQuery.of(context).size.height/4,

//                                    color: Colorcodes.appBarColor,
//                                    margin: EdgeInsets.symmetric(horizontal: 2),

//                                   child: SvgPicture.asset(
//                                  images[index],
//                                  width: MediaQuery.of(context).size.width,
//                          ),
//                                 );
//                 },
//               options: CarouselOptions(
//                  aspectRatio: 1.3,
//                  height: 400,
//                 //  autoPlay: true,

//                  onPageChanged: (position,reason){
//                 setState(() {
//                       activePage=position;
//                 });
//                 },

//               )

//     ));
}

Widget avatarSlider() {
  return Text("");
//   return
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                  height: MediaQuery.of(context).size.height/3,
//                 // color: Colors.red,
//                 // height: MediaQuery.of(context).size.height/2,
//                 padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20),
//                 child: CarouselSlider(

//               options: CarouselOptions(
//                 // aspectRatio: 1.6,
//                  aspectRatio: 2,
//                  enlargeCenterPage:true,
//                 viewportFraction: 0.3,
//                  height: MediaQuery.of(context).size.height/3.5,
//                 // enlargeCenterPage: true,
//                 // autoPlay: true,
//                 initialPage: 3,
//                 onPageChanged: (position,reason){
//                 setState(() {
//                       activePage=position;
//                 });
//                 },
//                 enableInfiniteScroll: false,

//               ),
//               items: images.map<Widget>((i) {
//                 return Builder(
//           builder: (BuildContext context) {
//             return SvgPicture.asset(
//                                i,
//                               //  width: 10,
//                               //  height: 10,
//                        );
//           },
//                 );
//               }).toList(),
//             )

//               );

// }
}

void storeData(context, data, String opt, Avatarurl) async {
  String name = data['name'];
  String email = data['email'];
  String password = data['userpassword'];
  String conform = data['confirmPassword'];
  String dob = data['dob'];


  final response = await http.post(
    Uri.parse('${url}/user/register'),
    // Uri.parse('https://stakeplot-bk4z.onrender.com/api/v1/user/register'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'name': name,
      'email': email,
      'userpassword': password,
      'confirmPassword': conform,
      'dob': dob,
      'avatarType': Avatarurl,
      'otp': opt
    }),
  );

  try {
    var data2 = jsonDecode(response.body);
    print(data2);
    bool boolvar = data2['success'];

    acceptReset.value = false;
    if (!boolvar) {
      snackBarCalledSignup(context, data2['error']['explanation'], Colors.red);
      return;
    }
    final body = json.decode(response.body);

    String accessToken = body['data'];
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString("accessToken", "Bearer " + accessToken);
    print(accessToken);
    clearStack(context);
    Navigator.pushReplacementNamed(context, '/ShareAccountLogin');
  } catch (e) {
    snackBarCalledSignup(context, "Invalid OTP!", Colors.red);
  }
}
