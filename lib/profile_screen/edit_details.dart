import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/resetPin.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/userstats.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  final Map<String, TextEditingController> _controllers = {
    ProfileScreenStrings().nameLabel:
        TextEditingController(text: userName.value),
    ProfileScreenStrings().emailLabel: TextEditingController(text: email.value),
    ProfileScreenStrings().dobLabel: TextEditingController(text: dob.value),
    ProfileScreenStrings().numberLabel:
        TextEditingController(text: number.value),
  };

  @override
  void initState() {
    super.initState();
    changeAvater.value = avatar.value;
    checkBiometricsStatus();
    getUserInfomations();
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed from the tree
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void checkBiometricsStatus() async {
    final LocalAuthentication auth = LocalAuthentication();

    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: textStyleOnly2(
          context: context,
          text: ProfileScreenStrings().editProfileTitle,
          fontsize: 18,
          color: AppColors.accentColor,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Show dialog box for confirmation
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Account'),
                    content: Text(
                        'Are you sure you want to delete your account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          
                          deleteUserAccount(context);
                           // Close the dialog
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Column(
              children: [
                Obx(() => AvatarProfile(
                      name: userName.value,
                      width: 5,
                      height: 10,
                      background: userAvatarBackGround.value,
                      flag: true,
                    )),
                // Obx(() => AvatarProfileImage(
                //       url: avaterUrlPath(userName.value),
                //       width: 14,
                //       height: 9,
                //     )),
                GestureDetector(
                  onTap: () {
                    // var data = {
                    //   'name': userName.value,
                    //   'email': email.value,
                    // };
                    // showModalBottomSheet(
                    //   isScrollControlled: true,
                    //   context: context,
                    //   builder: (context) {
                    //     return Avatar(
                    //       data: data,
                    //       isEdit: true,
                    //     );
                    //   },
                    // );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserStatsScreen()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 0.0),
                    child: textStyleOnly2(
                      context: context,
                      text: "",
                      fontsize: 14,
                      color: AppColors.bg3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: textStyleOnly2(
                    context: context,
                    text: ProfileScreenStrings().personalDetailsLabel,
                    fontsize: 16,
                    color: AppColors.bg3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Obx(() => (bankAccountLinkedList.isEmpty ||
                        (hideBackAccountPassword.value ||
                            cupertinoPin.value == "0"))
                    ? SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          resetCupertinoPin(context);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.lock_reset,
                                color: AppColors.primaryColor, size: 20),
                            SizedBox(width: 4),
                            textStyleOnly2(
                              context: context,
                              text: ProfileScreenStrings().resetPinLabel,
                              fontsize: 14,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      )),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.mt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildNonEditableField(Icons.email,
                      ProfileScreenStrings().emailLabel, email.value),
                  Divider(),
                  _buildNonEditableField(Icons.person,
                      ProfileScreenStrings().nameLabel, userName.value),
                  Divider(),
                  _buildNonEditableField(Icons.phone,
                      ProfileScreenStrings().numberLabel, number.value),
                  Divider(),
                  _buildNonEditableField(Icons.calendar_today,
                      ProfileScreenStrings().dobLabel, dob.value),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: textStyle(
                      text: ProfileScreenStrings().accountDetailsLabel,
                      context: context,
                      fontWeight: FontWeight.bold,
                      fontsize: 14),
                ),
                InkWell(
                    onTap: () {
                      number.value = Phone.value;
                      isFromEditDeatils.value = true;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MobileNumber(
                            flag: true,
                            formEditDetails: true,
                          ),
                        ),
                      );
                    },
                    child: textStyle(
                        text: ProfileScreenStrings().addBankLabel,
                        context: context,
                        fontWeight: FontWeight.bold,
                        fontsize: 14)),
              ],
            ),
            // Account Details
            const SizedBox(height: 20),
            getListOfBankConnected(),
            const SizedBox(height: 20),

    
          ],
        ),
      ),
    );
  }

  Widget getListOfBankConnected() {
    return Container(
      child: Column(
        children: [
        Obx(()=>  Column(
            children: bankAccountLinkedList.map((e) {
            
              return _buildAccountDetails(e['bankName'], e['maskedAccNumber'], e,e['bankLogo']);
            }).toList(),
          )),
         
        ],
      ),
    );
  }

  Widget _buildEditableField(IconData icon, String label, String value) {
    final controller =
        _controllers[label] ?? TextEditingController(text: value);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      width: MediaQuery.of(context).size.width / 1.1,
      child: Center(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //prefixIcon: Icon(icon, color: Colors.blueGrey),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryColor)),
            ),
            hintText: value,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: const Icon(Icons.edit, color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildNonEditableField(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      width: MediaQuery.of(context).size.width / 1.1,
      child: Center(
        child: TextFormField(
          enabled: false,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            // prefixIcon: Icon(icon, color: Colors.blueGrey),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryColor)),
            ),
            border: InputBorder.none, // No border
            enabledBorder: InputBorder.none, // No border when not focused
            focusedBorder: InputBorder.none,
            hintText: value,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetails(
      String bankName, String accountNumber, var data, String logo) {
    return Card(
      //shape: ,
      elevation: 2,
      color: AppColors.mt,
      child: ListTile(
        leading: Image.network(
          logo,
          width: 30,
          height: 30,
          fit: BoxFit.fitWidth,
        ),
        title: textStyleOnly2(
          context: context,
          text: bankName,
          fontsize: 14,
          color: AppColors.bg2,
          fontWeight: FontWeight.w600,
        ),
        subtitle: textStyleOnly2(
          context: context,
          text: accountNumber,
          fontsize: 14,
          color: AppColors.bg3,
          fontWeight: FontWeight.w400,
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: AppColors.debitColor),
          onPressed: () {
            // Show dialog box for confirmation
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete Account'),
                  content: Text('Are you sure you want to delete this account?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add your delete logic here
                        deleteBankAccount(bankid: data['bankId'],AccountId: data['accountId'],context: context);
                         // Close the dialog
                      },
                      child: Text('Delete'),
                    ),
                  ],
                );
              },
            );
          }
        )
      )
        );
  
      
      }
        
}