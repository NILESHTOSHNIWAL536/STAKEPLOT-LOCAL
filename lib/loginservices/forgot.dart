import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loginservices/wave.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the email as shown in the image
    _emailController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
           height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            
                Color(0xFF6568A7),
                Color(0xFF272841),
                
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      
                      // Title and Description
                      _buildHeaderText(),
                      
                      const SizedBox(height: 60),
                      
                      // Email Field
                      _buildEmailField(),
                      
                      const SizedBox(height: 40),
                      
                      // Get Code Button
                      _buildGetCodeButton(),
                      
                     
                    ],
                  ),
                ),
                
                // Bottom Wave Design
                 Padding(
                   padding: const EdgeInsets.symmetric(vertical: 20),
                   child: buildBottomWaves(context),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 
  Widget _buildHeaderText() {
    return Column(
      children: [

        textStyle(context: context,text: 'Forgot Password',fontWeight: FontWeight.w500,fontsize: 32,c: Colorcodes.white),
        const SizedBox(height: 16),
        textStyle(context: context,text: 'Please enter your Email Address to\nrecieve a verification code.'
        ,fontWeight: FontWeight.w300,fontsize: 15,c: Colorcodes.white,lineHeight: 1.2),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextFormField(
       
        controller: _emailController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
           hintText: 'Email',
          hintStyle: TextStyle(color: AppColors.whiteOpacity07),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGetCodeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _handleGetCode();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Get Code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

 

  void _handleGetCode() {
     if (
                            _emailController.text == "") {
                          snackBarCalledfail(context,SnackbarData().enterValidemail);
                          return;
                        }

        getforgotPassword(context,"", _emailController.text);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6B5B95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
