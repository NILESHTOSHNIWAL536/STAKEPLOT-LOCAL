import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
    'name': TextEditingController(text: userName.value),
    'Email': TextEditingController(text: email.value),
    'dob': TextEditingController(text: dob.value),
    'Number': TextEditingController(text: number.value),
  };

  @override
  void initState() {
    super.initState();
    changeAvater.value = avatar.value;
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed from the tree
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void resetCupertinoPin(BuildContext context) {
    print("Reset PIN dialog opened");
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.backgroundColor,
          title: Row(
            children: [
              Icon(Icons.lock_reset, color: AppColors.primaryColor),
              SizedBox(width: 8),
              textStyleOnly2(
                context: context,
                text: "Reset PIN",
                fontsize: 18,
                color: AppColors.bg2,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textStyleOnly2(
                context: context,
                text: "Are you sure you want to reset your PIN?",
                fontsize: 14,
                color: AppColors.bg3,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: 8),
              textStyleOnly2(
                context: context,
                text: "You'll need to set a new PIN after reset.",
                fontsize: 12,
                color: AppColors.bg3.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("Reset PIN dialog cancelled");
                Navigator.of(dialogContext).pop();
              },
              child: textStyleOnly2(
                context: context,
                text: "Cancel",
                fontsize: 14,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
             onPressed: () async {
                print("Reset PIN button pressed");
                try {
                  final response = await updateDataApiCall3(
                    '$url/user/updateCupertino', // Use your base URL
                    data: {
                      'pin': '0',
                    },
                  );

                  print("Response status code: ${response.statusCode}");
                  print("Response body: ${response.body}");
                  if (response.statusCode == 200) {
                    print("PIN reset successful");
                    cupertinoPin.value = "0"; // Reset the global PIN
                    Navigator.of(dialogContext).pop();
                  } else {
                    print("Failed to reset PIN: ${response.statusCode} - ${response.body}");
                  }
                } catch (e) {
                  print("Error occurred while resetting PIN: $e");
                }
              },
              child: textStyleOnly2(
                context: context,
                text: "Reset",
                fontsize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: textStyleOnly2(
          context: context,
          text: "Edit Profile",
          fontsize: 18,
          color: AppColors.accentColor,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Column(
              children: [
                Obx(() => AvatarProfileImage(
                      url: changeAvater.value,
                      width: 10,
                      height: 10,
                    )),
                GestureDetector(
                  onTap: () {
                    var data = {
                      'name': userName.value,
                      'email': email.value,
                    };
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return Avatar(
                          data: data,
                          isEdit: true,
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: textStyleOnly2(
                      context: context,
                      text: "Change Profile Picture",
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
                    text: "Personal details",
                    fontsize: 16,
                    color: AppColors.bg3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              bankAccountLinkedList.isEmpty? SizedBox.shrink(): InkWell(
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
                        text: "Reset PIN",
                        fontsize: 14,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
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
                  _buildNonEditableField(Icons.email, "Email", email.value),
                  Divider(),
                  _buildNonEditableField(Icons.person, "name", userName.value),
                  Divider(),
                  _buildNonEditableField(Icons.phone, "Number", number.value),
                  Divider(),
                  _buildNonEditableField(
                      Icons.calendar_today, "dob", dob.value),
                  // Divider(),
                  // _buildEditableField(Icons.location_on, "Address",
                  //     "6-10-128/3/A/5/A, Budwel, Telangana"),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: textStyle(
                  text: 'Account Details',
                  context: context,
                  fontWeight: FontWeight.bold,
                  fontsize: 14),
            ),
            // Account Details
            const SizedBox(height: 20),
            getListOfBankConnected(),
            const SizedBox(height: 20),

            InkWell(
                onTap: () {
                  editUserDetails(context, _controllers);
                },
                child: getButton(context, "Save Changes"))
          ],
        ),
      ),
    );
  }

  Widget getListOfBankConnected() {
    return Container(
      child: Column(
        children: [
          Column(
            children: bankAccountLinkedList.map((e) {
              return _buildAccountDetails(
                  e['bankName'], e['maskedAccNumber'], e);
            }).toList(),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
                onTap: () {
                  number.value = Phone.value;
                  isFromEditDeatils.value=true;
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
                    text: '+ Add Bank',
                    context: context,
                    fontWeight: FontWeight.bold,
                    fontsize: 16)),
          ),
          const SizedBox(
            height: 10,
          ),
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
          controller: controller, // Use the controller to manage the text
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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

  Widget _buildAccountDetails(String bankName, String accountNumber, var data) {
    return Card(
      //shape: ,
      elevation: 2,
      color: AppColors.mt,
      child: ListTile(
        //  leading: AvatarProfileImage(url:  bankImagemap[bankName] ?? avatarUser.value, width: 10, height: 10),
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
      ),
    );
  }
}
