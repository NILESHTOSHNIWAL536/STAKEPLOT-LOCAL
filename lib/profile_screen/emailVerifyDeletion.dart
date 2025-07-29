import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/delete_account.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String name;
  final String selectedReason;

  const VerifyOtpScreen({
    Key? key,
    required this.email,
    required this.name,
    required this.selectedReason,
  }) : super(key: key);

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCooldown = 30;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // Start cooldown timer for resend button
  void _startCooldownTimer() {
    setState(() {
      _canResend = false;
      _resendCooldown = 30;
    });
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  // Send OTP using provided API
  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await getOTPDeleteCall(context, widget.name, widget.email);
      setState(() {
        _isOtpSent = true;
      });
      _startCooldownTimer();
    } catch (e) {
      // Error is already handled by getOTP via snackBarCalled
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Verify OTP using provided API
  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? otpInt = otp.toString();
      if (otpInt == null) {
        snackBarCalledfail(context, 'Invalid OTP format', Colors.red);
        return;
      }
      await verifyDeleteOTP(context, widget.email, otpInt);
      setState(() {
        _isOtpVerified = true;
      });
    } catch (e) {
      // Error is already handled by verifyDeleteOTP via snackBarCalled
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Email',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
              SizedBox(height: 40),
              // Warning Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Important: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'To proceed with account deletion, verify your identity by entering the OTP sent to your email.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
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
              SizedBox(height: 40),
              // Email Display
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Get OTP Button
              if (!_isOtpSent)
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDC2626),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            'Get OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              // OTP Input and Resend Button
              if (_isOtpSent)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        onChanged: (value) async {
                          if (value.length == 6) {
                            await _verifyOtp(value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter 6-digit OTP',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          counterText: '',
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Resend OTP Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _canResend && !_isLoading ? _sendOtp : null,
                        child: Text(
                          _canResend
                              ? 'Resend OTP'
                              : 'Resend OTP (${_resendCooldown}s)',
                          style: TextStyle(
                            color: _canResend && !_isLoading
                                ? Color(0xFFDC2626)
                                : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Spacer(),
              // Delete Account Button
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 32),
                child: ElevatedButton(
                  onPressed: _isOtpVerified && !_isLoading
                      ? () => showDeleteConfirmationDialog(
                            context,
                            widget.selectedReason,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOtpVerified && !_isLoading
                        ? Color(0xFFDC2626)
                        : Colors.grey[300],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          'Delete Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isOtpVerified && !_isLoading
                                ? Colors.white
                                : Colors.grey[600],
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