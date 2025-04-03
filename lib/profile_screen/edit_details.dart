import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
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
                  _buildNonEditableField(Icons.calendar_today, "dob", dob.value),
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
              return _buildAccountDetails(e['bankName'], e['maskedAccNumber'], e);
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
                
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MobileNumber(
                        flag: true,
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
            contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
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
