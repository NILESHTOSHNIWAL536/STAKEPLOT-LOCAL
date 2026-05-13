import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/post_interest.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/user_chat/room_poll_chart.dart';
import 'package:get/get.dart';

import '../Constants/core/app_padding_sizes.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({Key? key}) : super(key: key);

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final CommunityScreenStrings strings = CommunityScreenStrings();

  bool get _isFormValid =>
      _questionController.text.trim().isNotEmpty &&
      _optionControllers.every((controller) => controller.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_refreshForm);
    for (final controller in _optionControllers) {
      controller.addListener(_refreshForm);
    }
  }

  @override
  void dispose() {
    _questionController
      ..removeListener(_refreshForm)
      ..dispose();
    for (final controller in _optionControllers) {
      controller
        ..removeListener(_refreshForm)
        ..dispose();
    }
    super.dispose();
  }

  void _refreshForm() {
    if (mounted) setState(() {});
  }

  void _addOptionController() {
    if (_optionControllers.length >= 6) return;
    setState(() {
      _optionControllers.add(TextEditingController()..addListener(_refreshForm));
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    final controller = _optionControllers.removeAt(index);
    controller
      ..removeListener(_refreshForm)
      ..dispose();
    setState(() {});
  }

  void _createPoll(String finalQuestion, List<Map<String, dynamic>> finalOptions) {
    if (postController.posting.value) return;
    postController.posting.value = true;

    createPollOfCommunityPost(
      context,
      finalQuestion,
      finalOptions,
      {},
      [],
      "casual",
    );
  }

  void _continueToInterests() {
    final filledOptions =
        _optionControllers.where((e) => e.text.trim().isNotEmpty).length;

    if (filledOptions < 2) {
      snackBarCalledfail(context, "Atleast two options must be there");
      return;
    }

    if (!_isFormValid) {
      snackBarCalledfail(context, "Please fill in all fields before continuing");
      return;
    }

    final pollOptions = _optionControllers
        .map((controller) => {"option": controller.text.trim()})
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InterestSelectionPage(
          question: _questionController.text.trim(),
          options: pollOptions,
          onConfirm: (String question, List<Map<String, dynamic>> options) {
            Navigator.pop(context);
            _createPoll(question, options);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            PollStepHeader(
              title: strings.createPoll,
              step: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p20,
                  vertical: AppSizes.p20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _questionField(context),
                    const SizedBox(height: AppSizes.h30),
                    Text(
                      "Answer Options * (2-6 options)",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 15,
                        lWeight: FontWeight.w700,
                        color: colors.onBackground,
                      ),
                    ),
                    const SizedBox(height: AppSizes.h10),
                    ...List.generate(
                      _optionControllers.length,
                      (index) => _optionField(context, index),
                    ),
                    const SizedBox(height: AppSizes.h12),
                    if (_optionControllers.length < 6) _addOptionButton(context),
                  ],
                ),
              ),
            ),
            _bottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _questionField(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Question *",
          style: FontManager().getTextStyle(
            context,
            fontSize: 15,
            lWeight: FontWeight.w700,
            color: colors.onBackground,
          ),
        ),
        const SizedBox(height: AppSizes.h8),
        TextField(
          controller: _questionController,
          maxLength: 200,
          maxLines: 3,
          style: FontManager().getTextStyle(
            context,
            color: colors.onSurface,
            fontSize: 14,
          ),
          buildCounter: (
            BuildContext context, {
            required int currentLength,
            required bool isFocused,
            required int? maxLength,
          }) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "$currentLength / $maxLength characters",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 12,
                  lWeight: FontWeight.w400,
                  color: colors.secondaryText,
                ),
              ),
            );
          },
          decoration: _inputDecoration(
            context,
            hintText: strings.askQuestion,
          ),
        ),
      ],
    );
  }

  Widget _optionField(BuildContext context, int index) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.iconBackground,
            child: Text(
              "${index + 1}",
              style: FontManager().getTextStyle(
                context,
                fontSize: 15,
                color: colors.primary,
                lWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.w12),
          Expanded(
            child: TextField(
              controller: _optionControllers[index],
              maxLength: 80,
              style: FontManager().getTextStyle(
                context,
                color: colors.onSurface,
                fontSize: 14,
              ),
              decoration: _inputDecoration(
                context,
                hintText: "Option ${index + 1}",
                suffixIcon: _optionControllers.length > 2
                    ? IconButton(
                        onPressed: () => _removeOption(index),
                        icon: Icon(Icons.close, color: colors.error),
                      )
                    : null,
              ).copyWith(counterText: ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addOptionButton(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: _addOptionController,
      child: DottedBorderBox(
        color: colors.primary,
        dashWidth: 1.0,
        dashHeight: 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: colors.primary, size: 26),
            const SizedBox(width: AppSizes.w10),
            Flexible(
              child: Text(
                strings.addOption,
                overflow: TextOverflow.ellipsis,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 16,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButton(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSizes.p20,
        AppSizes.p8,
        AppSizes.p20,
        AppSizes.p16,
      ),
      child: GestureDetector(
        onTap: _continueToInterests,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: AppSizes.p16,
          ),
          decoration: BoxDecoration(
            color: _isFormValid ? colors.primary : colors.surface,
            border: Border.all(
              color: _isFormValid ? colors.primary : colors.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Obx(
              () => postController.posting.value
                  ? Spinner(size: 30, color: AppColors.backgroundColor)
                  : Text(
                      strings.continueButton,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 16,
                        color: _isFormValid
                            ? AppColors.backgroundColor
                            : colors.onSurface,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hintText,
    Widget? suffixIcon,
  }) {
    final colors = context.appColors;

    return InputDecoration(
      hintText: hintText,
      hintStyle: FontManager().getTextStyle(
        context,
        color: colors.hintText,
        fontSize: 14,
      ),
      filled: true,
      fillColor: colors.inputBackground,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }
}
