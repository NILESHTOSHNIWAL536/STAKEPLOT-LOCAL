import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/opt_email.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'dart:math' as math;

import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

class CreateNewPasswordScreen extends StatefulWidget {
    String name;
  String email;
   CreateNewPasswordScreen({super.key,required this.email, required this.name});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController conformController = TextEditingController();
  
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      
                      // Title
                      _buildHeaderText(),
                      
                      const SizedBox(height: 60),
                      
                      // New Password Field
                      _buildNewPasswordField(),
                      
                      const SizedBox(height: 20),
                      
                      // Confirm Password Field
                      _buildConfirmPasswordField(),
                      
                      const SizedBox(height: 40),
                      
                      // Reset Password Button
                      _buildResetPasswordButton(),
                      
                      // Spacer to push waves to bottom
                    ],
                  ),
                ),
                
                // Bottom Wave Design
                _buildBottomWaves(),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '12:00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Icon(Icons.wifi, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Icon(Icons.battery_full, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return textStyle(context: context,text: 'Create New Password',fontWeight: FontWeight.w500,fontsize: 25,c: Colorcodes.white);
  }

  Widget _buildNewPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextField(
        controller: passwordController,
        obscureText: !_isNewPasswordVisible,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'New password',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextField(
        controller: conformController,
        obscureText: !_isConfirmPasswordVisible,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Confirm Password',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _handleResetPassword();
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
          'Reset Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWaves() {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width, 200),
        painter: DetailedWavePainter(),
      ),
    );
  }

  void _handleResetPassword() {
    // Validate passwords
    String password = passwordController.text;
                      String conform = conformController.text;
                  
                      if (password.length < 8) {
                        snackBarCalledfail(
                            context,
                           SignupData().shortPassword,
                            Colors.red);
                        return;
                      }
                       if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~])').hasMatch(password)) {
                        snackBarCalledfail(
                            context,
                           SignupData().weakPassword,
                            Colors.red);
                        return;
                      }
                      if (conform.isEmpty) {
                        snackBarCalledfail(
                            context,
                          SignupData().emptyConfirmPassword,
                            Colors.red);
                        return;
                      }
                  
                      if (password != conform) {
                        snackBarCalledfail(
                            context,
                          SignupData().passwordMismatch,
                            Colors.red);
                        return;
                      }
                  
                      changePassword(
                        context,
                        widget.email,
                        passwordController.text,
                        conformController.text,
                      );
  }

  bool _isPasswordStrong(String password) {
    // Check for at least one uppercase letter, one lowercase letter, one digit, and one special character
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Success!'),
            ],
          ),
          content: const Text(
            'Your password has been reset successfully. You can now sign in with your new password.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to login screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B95),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Go to Sign In'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DetailedWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Create multiple detailed wave lines
    for (int i = 0; i < 12; i++) {
      final path = Path();
      final yOffset = i * 12.0;
      final amplitude = 15.0 + (i * 2.0); // Increasing amplitude
      final frequency = 0.8 + (i * 0.1); // Varying frequency
      
      path.moveTo(0, size.height - 100 + yOffset);
      
      for (double x = 0; x <= size.width; x += 2) {
        final y = size.height - 100 + yOffset + 
                 (amplitude * math.sin((x / size.width) * frequency * 2 * math.pi));
        path.lineTo(x, y);
      }
      
      // Adjust opacity for depth effect
      final wavePaint = Paint()
        ..color = Colors.white.withOpacity(0.08 + (i * 0.01))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + (i * 0.1);
      
      canvas.drawPath(path, wavePaint);
    }

    // Add some additional curved lines for more detail
    for (int j = 0; j < 8; j++) {
      final path = Path();
      final yBase = size.height - 60 + (j * 8.0);
      final amplitude = 20.0 + (j * 3.0);
      
      path.moveTo(0, yBase);
      
      // Create more complex wave pattern
      for (double x = 0; x <= size.width; x += 3) {
        final wave1 = amplitude * math.sin((x / size.width) * 3 * math.pi);
        final wave2 = (amplitude * 0.5) * math.sin((x / size.width) * 5 * math.pi);
        final y = yBase + wave1 + wave2;
        path.lineTo(x, y);
      }
      
      final detailPaint = Paint()
        ..color = Colors.white.withOpacity(0.06 + (j * 0.008))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      
      canvas.drawPath(path, detailPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}