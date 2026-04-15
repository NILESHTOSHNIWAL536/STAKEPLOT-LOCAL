import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/model/bank_model.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/delete_account.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/resetPin.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/revoke_access.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:flutter_application_code_stakeplot/services/icon_picker_modal.dart';
import 'package:flutter_application_code_stakeplot/signInOut/emailUpdateOtp.dart';
import 'package:get/get.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Utils/credit_card.dart';
import '../backed_connections/bankServices/share_data.dart';
import '../image_service/avatarProfile.dart';
import '../loginservices/login.dart';
import '../repository/bankinfo.dart';
import '../repository/delete_banks_users.dart';
import '../show_modal/theme_modal.dart';

late BuildContext showSnackBarContext;

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  final UserController userController = ControllerManagement.userController;

  final Map<String, TextEditingController> _controllers = {
    ProfileScreenStrings().nameLabel: TextEditingController(),
    ProfileScreenStrings().emailLabel: TextEditingController(),
    ProfileScreenStrings().numberLabel: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    // Initialize controllers with reactive values
    _controllers[ProfileScreenStrings().nameLabel]!.text =
        userController.userName.value;
    _controllers[ProfileScreenStrings().emailLabel]!.text =
        userController.email.value;
    _controllers[ProfileScreenStrings().numberLabel]!.text = number.value;

    // checkBiometricsStatus();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // void checkBiometricsStatus() async {
  //   final LocalAuthentication auth = LocalAuthentication();
  //   bool canCheckBiometrics = await auth.canCheckBiometrics;
  //   bool isDeviceSupported = await auth.isDeviceSupported();
  //   List<BiometricType> availableBiometrics =
  //       await auth.getAvailableBiometrics();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // AppColors.backgroundColor,
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
        iconTheme: const IconThemeData(color: AppColors.accentColor),
        actions: [
          InkWell(
            onTap: () {
              showThemeSelectorModal(context);
            },
            child: Icon(
              Icons.color_lens_outlined,
              size: 30,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: AppColors.redColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeleteAccountScreen()),
              );
            },
          ),
          !CreditCardScreenStrings().showRevokeScreen.value
              ? SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.remember_me_outlined,
                      color: AppColors.redColor, size: 25),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RevokeAccessScreen()),
                    );
                  },
                ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Column(
              children: [
                Obx(() => InkWell(
                      onTap: () {
                        shareStakeplot();
                      },
                      child: AvatarProfile(
                        name: userController.userName.value,
                        width: 5,
                        height: 10,
                        background: userController.avatarBackGround.value,
                        flag: true,
                      ),
                    )),
              ],
            ),
            SizedBox(height: AppSizes.h20),
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
                            userController.cupertinoPin.value == "0" ||
                            userController.cupertinoPin.value == "00"))
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          resetCupertinoPin(context);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.lock_reset,
                                color: AppColors.primaryColor, size: 20),
                            SizedBox(width: AppSizes.w4),
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
            SizedBox(height: AppSizes.h20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.mt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Obx(() => _buildNonEditableField(
                        Icons.email,
                        ProfileScreenStrings().emailLabel,
                        userController.email.value,
                      )),
                  const Divider(),

                  _buildNonEditableField(
                      Icons.person,
                      ProfileScreenStrings().nameLabel,
                      userController.userName.value),
                  (userController.phone.value == "0" ||
                          userController.phone.value == '')
                      ? const SizedBox.shrink()
                      : const Divider(),
                  (userController.phone.value == "0" ||
                          userController.phone.value == '')
                      ? const SizedBox.shrink()
                      : _buildNonEditableField(
                          Icons.phone,
                          ProfileScreenStrings().numberLabel,
                          userController.phone.value),
                  // const Divider(),
                  // _buildNonEditableField(
                  //   Icons.calendar_today,
                  //   ProfileScreenStrings().dobLabel,
                  //   userController.dob.value.isNotEmpty
                  //       ? DateFormat('yyyy-MM-dd')
                  //           .format(DateTime.parse(userController.dob.value))
                  //       : 'Not provided',
                  // ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.h20),
            const Divider(),
            SizedBox(height: AppSizes.h10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: textStyle(
                    text: ProfileScreenStrings().accountDetailsLabel,
                    context: context,
                    fontWeight: FontWeight.bold,
                    fontsize: 14,
                  ),
                ),
                InkWell(
                  onTap: () {
                    number.value = userController.phone.value;
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
                    fontsize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.h20),
            ElevatedButton(
              child: Text("Change App Icon"),
              onPressed: () => IconPickerModal.show(context),
            ),
            getListOfBankConnected(),
            SizedBox(height: AppSizes.h20),
          ],
        ),
      ),
    );
  }

  Widget getListOfBankConnected() {
    return Container(
      child: Obx(
        () => Column(
          children: bankAccountLinkedList.map((e) {
            return _buildAccountDetails(
              e.bankName,
              e.maskedAccNumber,
              e, // pass the whole model instead of Map
              e.bankLogo,
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget getListOfBankConnected() {

  //   return Container(
  //     child: Obx(() => Column(
  //           children: bankAccountLinkedList.map((e) {

  //             return _buildAccountDetails(
  //               e['bankName'],
  //               e['maskedAccNumber'],
  //               e,
  //               e['bankLogo'],
  //             );
  //           }).toList(),
  //         )),
  //   );
  // }

  Widget _buildNonEditableField(IconData icon, String label, String value) {
    final isEmailField = label == ProfileScreenStrings().emailLabel;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      width: MediaQuery.of(context).size.width / 1.1,
      child: TextFormField(
        controller: _controllers[label]!
          ..text = value, // Update controller text
        enabled: isEmailField, // Only email field is editable via dialog
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(AppSizes.p6),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryColor),
            ),
          ),
          suffixIcon: isEmailField
              ? IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                  onPressed: () {
                    showSnackBarContext = context;
                    _showEmailEditDialog(context, userController.email.value);
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: value,
        ),
      ),
    );
  }

  void _showEmailEditDialog(BuildContext contextBuild, String currentEmail) {
    final TextEditingController newEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: textStyleOnly2(
            context: context,
            text: "Update Email",
            fontsize: 18,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 1.8,
                  ),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor,
                hintText: "Enter new email address",
                hintStyle: FontManager().getTextStyle(
                  context,
                  fontSize: 12,
                  lWeight: FontWeight.w500,
                  color: AppColors.grey,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter an email";
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return "Please enter a valid email";
                }
                if (value == userController.email.value) {
                  return "New email must be different";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w500,
                  color: AppColors.bg1,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _confirmAndSendOtp(contextBuild, newEmailController.text);
                }
              },
              child: Text(
                "Send OTP",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmAndSendOtp(BuildContext contextShow, String newEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: Text(
            "Confirm Email Update",
            style: FontManager().getTextStyle(
              context,
              fontSize: 18,
              lWeight: FontWeight.w500,
              color: AppColors.accentColor,
            ),
          ),
          content: Text(
            "An OTP will be sent to $newEmail. Proceed?",
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              lWeight: FontWeight.w500,
              color: AppColors.bg1,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w500,
                  color: AppColors.bg1,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _sendOtpForEmailUpdate(contextShow, newEmail);
              },
              child: Text(
                "Confirm",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendOtpForEmailUpdate(
      BuildContext context, String newEmail) async {
    try {
      // Show loading indicator
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (context) => const Center(child: CircularProgressIndicator()),
      // );

      // Call OTP API
      sendOtp(context, userController.userName.value, newEmail);

      // Navigate to OTP screen
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      snackBarCalledfail(
          context, "Failed to send OTP. Please try again.", AppColors.redColor);
    }
  }

  void sendOtp(BuildContext context, String name, String email) async {
    var response = await postDataApiCallwithOutSharedPref(otpRoutes.sendOtp, {
      'email': email,
      'name': name,
    });
    if (getFlagOfResponse(response)) {
      snackBarCalled(
        context,
        SnackbarData().sentOtpToEmail,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => emailUpdation(
            data: {
              'email': email,
              'name': userController.userName.value,
              'password': '',
              'response': null,
              'isForcedLogin': false,
            },
          ),
        ),
      );
    } else {
      var body = jsonDecode(response.body);
      snackBarCalledfail(
          showSnackBarContext, body['error'] ?? "error", AppColors.redColor);
    }
  }

  Widget _buildAccountDetails(
    String bankName,
    String accountNumber,
    BankAccountModel data,
    String logo,
  ) {
    return InkWell(
      onTap: () {
        // shareBankData(bankAccountLinkedList[index]);
        shareBankDataFromModel(data);
      },
      child: Card(
        elevation: 2,
        color: AppColors.mt,
        child: ListTile(
          leading: Image.network(
            logo,
            width: 30,
            height: 30,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.account_balance,
              size: 30,
              color: AppColors.primaryColor,
            ),
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
            icon: const Icon(Icons.delete, color: AppColors.debitColor),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                        'Are you sure you want to delete this account?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteBankAccount(
                            bankid: data.bankId,
                            AccountId: data.accountId,
                            context: context,
                          );
                          // deleteBankAccount(
                          //   bankid: data['bankId'],
                          //   AccountId: data['accountId'],
                          //   context: context,
                          // );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
