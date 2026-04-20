import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_padding_sizes.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/repository/referral_repository.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  final TextEditingController _referralController = TextEditingController();

  bool _isLoading = false;
  bool _isValidated = false;
  bool _didAutoValidate = false;
  String _statusMessage = '';
  String? _validatedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistReferralCodeFromArguments();
    });
    _loadReferralCode();
    _referralController.addListener(_resetValidationState);
  }

  @override
  void dispose() {
    _referralController.removeListener(_resetValidationState);
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _persistReferralCodeFromArguments() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['refCode'] != null) {
      await ReferralRepository.saveIncomingReferralCode(
        args['refCode'].toString(),
      );
      if (!mounted) return;
      await _loadReferralCode();
    }
  }

  Future<void> _loadReferralCode() async {
    final validatedCode = await ReferralRepository.getValidatedReferralCode();
    final incomingCode = await ReferralRepository.getIncomingReferralCode();
    final codeToUse = validatedCode ?? incomingCode;

    if (codeToUse == null || codeToUse.isEmpty || !mounted) return;

    setState(() {
      _referralController.text = codeToUse;
      _isValidated = validatedCode != null;
      _validatedCode = validatedCode;
      _statusMessage =
          validatedCode != null ? 'Referral code already validated.' : '';
    });

    if (validatedCode == null && !_didAutoValidate) {
      _didAutoValidate = true;
      await _validateCode(showSuccessMessage: false);
    }
  }

  void _resetValidationState() {
    final normalizedText = ReferralRepository.normalizeCode(_referralController.text);
    if (_validatedCode != null && normalizedText == _validatedCode) {
      return;
    }

    if (_isValidated || _statusMessage.isNotEmpty) {
      setState(() {
        _isValidated = false;
        _validatedCode = null;
        _statusMessage = '';
      });
    }
  }

  Future<void> _validateCode({bool showSuccessMessage = true}) async {
    final code = ReferralRepository.normalizeCode(_referralController.text);

    if (code.isEmpty) {
      snackBarCalledfail(context, 'Enter a referral code to validate');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ReferralRepository.validateReferralCode(code);
      final bool isValid = response['isValid'] == true;
      final String message =
          (response['reason'] ?? 'Referral validation completed').toString();

      if (!mounted) return;

      if (!isValid) {
        await ReferralRepository.clearValidatedReferralCode();
        if (!mounted) return;
        setState(() {
          _isValidated = false;
          _validatedCode = null;
          _statusMessage = message;
        });
        snackBarCalledfail(context, message);
        return;
      }

      await ReferralRepository.saveIncomingReferralCode(code);
      await ReferralRepository.saveValidatedReferralCode(code);
      if (!mounted) return;

      setState(() {
        _referralController.text = code;
        _isValidated = true;
        _validatedCode = code;
        _statusMessage = message;
      });

      if (showSuccessMessage) {
        snackBarCalled(context, message);
      }
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _isValidated = false;
        _validatedCode = null;
        _statusMessage = message;
      });
      snackBarCalledfail(context, message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continue() async {
    final code = ReferralRepository.normalizeCode(_referralController.text);

    if (code.isNotEmpty && !_isValidated) {
      snackBarCalledfail(context, 'Validate the referral code first or skip for now');
      return;
    }

    Navigator.pushReplacementNamed(context, '/user_onboarding');
  }

  Future<void> _skip() async {
    await ReferralRepository.clearAllReferralCodes();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/user_onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCode = _referralController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.newbg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p20,
            vertical: AppSizes.p24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add referral code',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 24,
                  lWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: AppSizes.h12),
              Text(
                'If you opened the app from AppsFlyer, your referral code is filled automatically. You can also enter it manually and validate it now.',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w400,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(height: AppSizes.h32),
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.greyCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referral code',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 14,
                        lWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.h12),
                    TextField(
                      controller: _referralController,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter referral code',
                        filled: true,
                        fillColor: AppColors.newbg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (_statusMessage.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.h12),
                      Text(
                        _statusMessage,
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 13,
                          lWeight: FontWeight.w500,
                          color: _isValidated ? Colors.green.shade700 : AppColors.redColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.h24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _validateCode(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Validate code',
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 16,
                            lWeight: FontWeight.w600,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _continue,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color:
                          hasCode && !_isValidated ? AppColors.grey : AppColors.primaryColor,
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 16,
                      lWeight: FontWeight.w600,
                      color: hasCode && !_isValidated ? AppColors.grey : AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.h12),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _skip,
                  child: Text(
                    'Skip for now',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 14,
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
