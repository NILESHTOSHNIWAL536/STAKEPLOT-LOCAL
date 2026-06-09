import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';

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
import '../components/shared_utils.dart';
import '../image_service/avatarProfile.dart';
import '../loginservices/login.dart';
import '../repository/bankinfo.dart';
import '../repository/delete_banks_users.dart';
import '../show_modal/theme_modal.dart';

late BuildContext showSnackBarContext;

class EditDetails extends StatefulWidget
{
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
   }

  @override
  void dispose() {
    // Dispose all controllers
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: textStyleOnly2(
          context: context,
          text: ProfileScreenStrings().editProfileTitle,
          fontsize: 18,
          color: colors.onBackground,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: colors.appBarBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: [
          InkWell(
            onTap: () {
              showThemeSelectorModal(context);
            },
            child: Icon(
              Icons.color_lens_outlined,
              size: 30,
              color: colors.onBackground,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: colors.error),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeleteAccountScreen()),
              );
            },
          ),
          CreditCardScreenStrings().showRevokeScreen.value
              ? SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.remember_me_outlined,
                      color: colors.error, size: 25),
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
                    color: colors.labelText,
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
                            Icon(Icons.lock_reset,
                                color: colors.primary, size: 20),
                            SizedBox(width: AppSizes.w4),
                            textStyleOnly2(
                              context: context,
                              text: ProfileScreenStrings().resetPinLabel,
                              fontsize: 14,
                              color: colors.primary,
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
                color: colors.surface,
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
                ],
              ),
            ),

            SizedBox(height: AppSizes.h20),
            _buildAppearanceCard(),
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

  Widget _buildAppearanceCard() {
    final colors = context.appColors;
    final controller = ControllerManagement.themeController;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Obx(() {
        final current = controller.themeMode.value;
        return Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                current == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : current == ThemeMode.light
                        ? Icons.light_mode_rounded
                        : Icons.brightness_auto_rounded,
                color: colors.primary,
              ),
            ),
            SizedBox(width: AppSizes.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textStyleOnly2(
                    context: context,
                    text: "Appearance",
                    fontsize: 14,
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: AppSizes.h4),
                  textStyleOnly2(
                    context: context,
                    text: "Choose the app theme",
                    fontsize: 12,
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _themeSegment(
                    icon: Icons.brightness_auto_rounded,
                    selected: current == ThemeMode.system,
                    onTap: () => controller.changeTheme(ThemeMode.system),
                  ),
                  _themeSegment(
                    icon: Icons.light_mode_rounded,
                    selected: current == ThemeMode.light,
                    onTap: () => controller.changeTheme(ThemeMode.light),
                  ),
                  _themeSegment(
                    icon: Icons.dark_mode_rounded,
                    selected: current == ThemeMode.dark,
                    onTap: () => controller.changeTheme(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _themeSegment({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? Colors.white : colors.secondaryText,
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

    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      width: MediaQuery.of(context).size.width / 1.1,
      child: TextFormField(
        controller: _controllers[label]!..text = value,
        enabled: isEmailField,
        style: TextStyle(color: colors.onBackground),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(AppSizes.p6),
            child: Container(
              decoration: BoxDecoration(
                color: colors.iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors.primary),
            ),
          ),
          suffixIcon: isEmailField
              ? IconButton(
                  icon: Icon(Icons.edit, color: colors.primary),
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
          hintStyle: TextStyle(color: colors.hintText),
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
        final colors = context.appColors;
        return AlertDialog(
          backgroundColor: colors.dialogBackground,
          title: textStyleOnly2(
            context: context,
            text: "Update Email",
            fontsize: 18,
            color: colors.primary,
            fontWeight: FontWeight.w600,
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: newEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: colors.onBackground),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.primary, width: 1.8),
                ),
                filled: true,
                fillColor: colors.inputBackground,
                hintText: "Enter new email address",
                hintStyle: FontManager().getTextStyle(
                  context,
                  fontSize: 12,
                  lWeight: FontWeight.w500,
                  color: colors.hintText,
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
                  color: colors.secondaryText,
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
                  color: colors.primary,
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
        final colors = context.appColors;
        return AlertDialog(
          backgroundColor: colors.dialogBackground,
          title: Text(
            "Confirm Email Update",
            style: FontManager().getTextStyle(
              context,
              fontSize: 18,
              lWeight: FontWeight.w500,
              color: colors.onBackground,
            ),
          ),
          content: Text(
            "An OTP will be sent to $newEmail. Proceed?",
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              lWeight: FontWeight.w500,
              color: colors.secondaryText,
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
                  color: colors.secondaryText,
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
                  color: colors.primary,
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
    final colors = context.appColors;
    return InkWell(
      onTap: () {
        shareBankDataFromModel(data);
      },
      child: Card(
        elevation: 0,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
        child: ListTile(
          leading: Image.network(
            logo,
            width: 30,
            height: 30,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.account_balance,
              size: 30,
              color: colors.primary,
            ),
          ),
          title: textStyleOnly2(
            context: context,
            text: bankName,
            fontsize: 14,
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
          subtitle: textStyleOnly2(
            context: context,
            text: accountNumber,
            fontsize: 14,
            color: colors.secondaryText,
            fontWeight: FontWeight.w400,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: colors.debit),
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
