import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/emailVerifyDeletion.dart';

import '../Constants/core/app_padding_sizes.dart';
import '../components/shared_utils.dart';
import '../repository/delete_banks_users.dart';

class DeleteAccountScreen extends StatefulWidget {
  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String? selectedReason;
  final List<String> reasons = [
    'No longer need the service',
    'I found an alternative',
    'I have privacy concerns',
    'I had a poor experience',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delete Account',
          style: FontManager().getTextStyle(
            context,
            fontSize: 18,
            lWeight: FontWeight.w600,
            color: AppColors.accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizes.h40),
              Center(
                child: Text(
                  "We're sorry to see you go!",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 18,
                    lWeight: FontWeight.w600,
                    color: AppColors.accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSizes.h24),
              Center(
                child: Text(
                  "Please help us improve by letting us know why you're deleting your account",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 16,
                    lWeight: FontWeight.w400,
                    color: AppColors.accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSizes.h40),
              Center(
                child: Container(
                  height: 120,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: AppSizes.p20,
                        left: 40,
                        child: Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppSizes.p30,
                        right: AppSizes.p40,
                        child: Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.currency_yen,
                          color: AppColors.backgroundColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h40),
              Text(
                'Reason for Deletion (Required)',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w600,
                  color: AppColors.accentColor,
                ),
              ),
              SizedBox(height: AppSizes.h16),
              Expanded(
                child: ListView.builder(
                  itemCount: reasons.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: AppSizes.p16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedReason = reasons[index];
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: selectedReason == reasons[index]
                                    ? Colors.indigo[400]
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selectedReason == reasons[index]
                                      ? Colors.indigo[400]!
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: selectedReason == reasons[index]
                                  ? Icon(
                                      Icons.check,
                                      size: 14,
                                      color: AppColors.backgroundColor,
                                    )
                                  : null,
                            ),
                            SizedBox(width: AppSizes.w12),
                            Expanded(
                              child: Text(
                                reasons[index],
                                style: FontManager().getTextStyle(
                                  context,
                                  fontSize: 16,
                                  lWeight: FontWeight.w500,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: selectedReason != null
                      ? () async {
                          if (userController.email.value != null &&
                              userController.userName.value != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerifyOtpScreen(
                                  name: userController.userName.value,
                                  email: userController.email.value,
                                  selectedReason: selectedReason!,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error: Unable to fetch user email'),
                                backgroundColor: AppColors.redColor,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedReason != null
                        ? Color(0xFFDC2626)
                        : Colors.grey[300],
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isGoogleUser.value ? 'Delete' : 'Continue',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 18,
                      lWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmDeleteScreen extends StatefulWidget {
  final String selectedReason;

  const ConfirmDeleteScreen({Key? key, required this.selectedReason})
      : super(key: key);

  @override
  _ConfirmDeleteScreenState createState() => _ConfirmDeleteScreenState();
}

class _ConfirmDeleteScreenState extends State<ConfirmDeleteScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delete Account',
          style: FontManager().getTextStyle(
            context,
            fontSize: 18,
            lWeight: FontWeight.w600,
            color: AppColors.accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizes.h40),
              Container(
                padding: EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSizes.p4),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning,
                        color: AppColors.backgroundColor,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: AppSizes.w12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Important: ',
                              style: FontManager().getTextStyle(
                                context,
                                fontSize: 16,
                                lWeight: FontWeight.w600,
                                color: AppColors.accentColor,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Deleting your account is permanent and cannot be undone. All your data will be erased.',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.accentColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.h40),
              Text(
                'Re-enter Password',
                style: FontManager().getTextStyle(context,
                    fontSize: 16,
                    lWeight: FontWeight.w600,
                    color: AppColors.accentColor),
              ),
              SizedBox(height: AppSizes.h12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'enter password',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: AppSizes.p16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
              Spacer(),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 32),
                child: ElevatedButton(
                  onPressed: _passwordController.text.isNotEmpty
                      ? () => showDeleteConfirmationDialog(
                          context, widget.selectedReason)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _passwordController.text.isNotEmpty
                        ? Color(0xFFDC2626)
                        : Colors.grey[300],
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    'Delete Account',
                    style: FontManager().getTextStyle(context,
                        fontSize: 16,
                        lWeight: FontWeight.w600,
                        color: _passwordController.text.isNotEmpty
                            ? AppColors.backgroundColor
                            : Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

void showDeleteConfirmationDialog(context2, selectedReason) {
  showDialog(
    context: context2,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Confirm Account Deletion',
          style: FontManager()
              .getTextStyle(context, fontSize: 18, lWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected reason: ${selectedReason}',
              style: FontManager().getTextStyle(context,
                  fontSize: 14,
                  color: Colors.grey[600],
                  lFontStyle: FontStyle.italic),
            ),
            SizedBox(height: AppSizes.h12),
            Text(
              'This action is permanent and cannot be undone. All your data will be permanently deleted.',
              style: FontManager().getTextStyle(context,
                  fontSize: 16, color: Colors.grey[700], lineHeight: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: FontManager().getTextStyle(context,
                  color: Colors.grey[600],
                  fontSize: 16,
                  lWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteUserAccount(context2, selectedReason);
              // if(accountDeleted)performAccountDeletion(context2);
            },
            child: Text(
              'Delete Account',
              style: FontManager().getTextStyle(context,
                  color: Color(0xFFDC2626),
                  fontSize: 16,
                  lWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
}

void performAccountDeletion(context2) {
  showDialog(
    context: context2,
    barrierDismissible: false,
    builder: (context) => Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(AppSizes.p20),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Spinner(
              size: 40,
              color: Color(0xFFDC2626),
            ),
            SizedBox(height: AppSizes.h16),
            textStyle(
              context: context,
              text: 'Deleting account...',
              fontsize: 16,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    ),
  );

  Future.delayed(Duration(seconds: 2), () {
    Navigator.pop(context2);
    Navigator.pop(context2);
    Navigator.pop(context2);

    ScaffoldMessenger.of(context2).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.backgroundColor),
            SizedBox(width: AppSizes.w8),
            Text('Account deleted successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  });
}
