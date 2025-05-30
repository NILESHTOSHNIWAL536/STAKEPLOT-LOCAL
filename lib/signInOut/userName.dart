import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const UserDetailsPage({Key? key, required this.data}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  RxBool flag = false.obs;
  TextEditingController usernameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  RxString usernameError = ''.obs;

  @override
  void initState() {
    super.initState();
    // Autofill fields with Google Sign-In data
    usernameController.text = widget.data['data']['name'] ?? 'Google User';
    dobController.text = widget.data['data']['dob'] ?? '1970-01-01';
    // Add listener for real-time username validation
    usernameController.addListener(validateUsername);
  }

  @override
  void dispose() {
    usernameController.removeListener(validateUsername);
    usernameController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void validateUsername() {
    String username = usernameController.text;
    if (username.isEmpty) {
      usernameError.value = 'Username cannot be empty';
    } else if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
      usernameError.value = 'Username must start with a letter';
    } else if (username.length < 3) {
      usernameError.value = 'Username must be at least 3 characters';
    } else {
      usernameError.value = '';
    }
  }

  void submitDetails() async {
    String username = usernameController.text;
    String dob = dobController.text;

    // Validate inputs
    if (username.isEmpty) {
      snackBarCalledfail(context, SignupData().emptyUsername, Colors.red);
      return;
    }
    if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
      snackBarCalledfail(context, SignupData().invalidUsername, Colors.red);
      return;
    }
    if (username.length < 3) {
      snackBarCalledfail(context, SignupData().shortUsername, Colors.red);
      return;
    }
    if (dob.isEmpty) {
      snackBarCalledfail(context, SignupData().emptyDob, Colors.red);
      return;
    }

    // Prepare updated data for storeData
    final updatedData = {
      'name': username,
      'email': widget.data['data']['email'] ?? "heyooo@gmail.com",
      'dob': dob,
    };

    print("updates data: $updatedData");

    flag.value = true;
    await storeData2(context, updatedData, 'assets/avatar/FRAME-2.svg');
    flag.value = false;
  }

  Future<void> storeData2(
      context, Map<String, dynamic> data, String avatarUrl) async {
    print("came till here");
    String name = data['name'];
    String email = data['email'];
    String dob = data['dob'];
    String colorString =
        avatarBackGroundList[getRandomValue(avatarBackGroundList)];
    print("Body got printed-----------------------$colorString");
    print("Sending request to register user with data: $data");
    final response = await http.post(
      Uri.parse('${url}/user/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'dob': dob,
        'avatarType': avatarUrl,
        'avatarBackGround': colorString,
        'isGoogleUser': true,
      }),
    );
    print("Received response: ${response.body}");

    try {
      var data2 = jsonDecode(response.body);
      bool boolvar = data2['success'];

      acceptReset.value = false;
      if (!boolvar) {
        snackBarCalledSignup(
            context, data2['error']['explanation'], Colors.red);
        return;
      }
      final body = jsonDecode(response.body);

      String accessToken = body['data'];
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      _pref.setString("accessToken", "Bearer " + accessToken);
      clearStack(context);
      Navigator.pushReplacementNamed(context, '/ShareAccountLogin');
    } catch (e) {
      snackBarCalledSignup(context, SignupData().errorInvalidOtp, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorcodes.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Colorcodes.paddingTopDesign / 1.4),
                  child: Text(
                    'Complete Your Profile',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: Colorcodes.paddingSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFeildWidget(
                        textEditingController: usernameController,
                        heading: SignupData().usernameLabel,
                        keyBoard: TextInputType.name,
                        lableText: SignupData().usernameSubLabel,
                        icon: Icons.person_2_outlined,
                      ),
                      Obx(() => usernameError.value.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(left: 20, top: 5),
                              child: Text(
                                usernameError.value,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                          : SizedBox.shrink()),
                      TextFeildCalender(
                        textEditingController: dobController,
                        heading: SignupData().dobLabel,
                        keyBoard: TextInputType.datetime,
                        lableText: SignupData().dobSubLabel,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius:
                          BorderRadius.circular(Colorcodes.borderRadius30),
                    ),
                    child: InkWell(
                      onTap: submitDetails,
                      child: Obx(() => Center(
                            child: flag.value
                                ? Spinner(
                                    size: 20,
                                    color: Colorcodes.white,
                                  )
                                : Text(
                                    'Submit',
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colorcodes.white,
                                    ),
                                  ),
                          )),
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
}
