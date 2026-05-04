import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart'; // Assuming FontManager2 is here
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

import '../Constants/core/app_padding_sizes.dart';
import '../Home_Screen/history/dotted_Border.dart';
import '../backed_connections/apis_connect.dart';

void showTagListOfInterestModal({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
  final screenSize = MediaQuery.of(context).size;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows dynamic height
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          height: screenSize.height * 0.7, // 60% of screen height
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05, // Responsive padding
            vertical: AppSizes.p16,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: AppSizes.p8),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Semantics(
                label: 'Add Interest',
                child: Text(
                  'Add Interest',
                  style: FontManager2().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: screenSize.width < 360 ? 18 : 20,
                    color: AppColors.finSpaceColor,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02), // Responsive spacing
              // List of interests

              Container(
                height: MediaQuery.sizeOf(context).height / 2,

                child: GetListOfInterest(
                  height: 0,
                  limitTagbool: true,
                  enableAnimations: false,
                ), // Let it take available space
              ),

              SizedBox(height: screenSize.height * 0.02),
              // Continue button

              Obx(
                () => InkWell(
                    onTap: () {
                      if (!isListEnabled.value) return;
                      onConfirm(); // Call the passed function
                      Navigator.pop(context); // Close the modal
                    },
                    child: isListEnabled.value
                        ? getButton(context, "Continue")
                        : getButton(
                            context,
                            "Add",
                            AppColors.grey,
                            AppColors.bg1,
                          )),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class InterestSelectionPage extends StatelessWidget {
  final String question;
  final List<Map<String, dynamic>> options;
  final Function(String, List<Map<String, dynamic>>) onConfirm;

  const InterestSelectionPage({
    Key? key,
    required this.question,
    required this.options,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PollStepHeader(
            title: "Create Poll",
            step: 2,
          ),

          /// Interest list
          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizes.h16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    "Select a Category",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w700,
                      fontSize: 24,
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.h10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    "Choose the topic that best fits your poll",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.h16),

                Container(
                  height: MediaQuery.sizeOf(context).height / 1.6,
                  child: GetListOfInterest(
                    height: 0,
                    limitTagbool: true,
                    enableAnimations: false,
                  ),
                ),

                SizedBox(height: AppSizes.h16),

                /// Continue button
                Obx(
                  () => InkWell(
                    onTap: () async {
                      if (!isListEnabled.value) return;
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PollPreviewPage(
                            question: question,
                            options: options,
                            selectedCategories: selectedCategories.toList(),
                          ),
                        ),
                      );

                      if (result != null) {
                        onConfirm(result["question"], result["options"]);
                      }

                      // onConfirm();
                      // Navigator.pop(context);
                    },
                    child: isListEnabled.value
                        ? getButton(context, "Continue")
                        : getButton(
                            context,
                            "Add",
                            AppColors.grey,
                            AppColors.bg1,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PollStepHeader extends StatelessWidget {
  final String title;
  final int step; // 1 or 2
  final int totalSteps;

  const PollStepHeader({
    Key? key,
    required this.title,
    required this.step,
    this.totalSteps = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = step / totalSteps;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 60, 12, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4B4D73),
            Color(0xFF8E91D9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.backgroundColor),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 20,
                  lineHeight: 28 / fontSize,
                  color: AppColors.backgroundColor,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),

          SizedBox(height: AppSizes.h12),

          /// Progress bar + step text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width / 1.56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          AppColors.backgroundColor.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.w12),
                Text(
                  "Step $step of $totalSteps",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    lWeight: FontWeight.w400,
                    color: AppColors.backgroundColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PollPreviewPage extends StatefulWidget {
  final String question;
  final List<Map<String, dynamic>> options;
  final List<String> selectedCategories;

  const PollPreviewPage({
    Key? key,
    required this.question,
    required this.options,
    required this.selectedCategories,
  }) : super(key: key);

  @override
  State<PollPreviewPage> createState() => _PollPreviewPageState();
}

class _PollPreviewPageState extends State<PollPreviewPage> {
  late TextEditingController questionCtrl;
  late List<TextEditingController> optionCtrls;

  @override
  void initState() {
    super.initState();

    questionCtrl = TextEditingController(text: widget.question);

    optionCtrls = widget.options
        .map((e) => TextEditingController(text: e["option"]))
        .toList();
  }

  /// ➕ ADD OPTION
  void addOption() {
    if (optionCtrls.length >= 4) {
      snackBarCalledfail(context, "Maximum 4 options allowed");
      return;
    }
    setState(() {
      optionCtrls.add(TextEditingController());
    });
  }

  /// ❌ REMOVE OPTION
  void removeOption(int index) {
    if (optionCtrls.length <= 2) {
      snackBarCalledfail(context, "At least 2 options are required");
      return;
    }
    setState(() {
      optionCtrls.removeAt(index);
    });
  }

  /// ✅ RETURN FINAL DATA
  void postPoll() {
    if (questionCtrl.text.trim().isEmpty) {
      snackBarCalledfail(context, "Question cannot be empty");
      return;
    }

    if (optionCtrls.any((c) => c.text.trim().isEmpty)) {
      snackBarCalledfail(context, "Options cannot be empty");
      return;
    }

    Navigator.pop(context, {
      "question": questionCtrl.text.trim(),
      "options": optionCtrls.map((c) => {"option": c.text.trim()}).toList(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.border,
      body: Column(
        children: [
          PollStepHeader(
            title: "Create Poll",
            step: 3,
            totalSteps: 3,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30, vertical: AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// QUESTION (EDITABLE)
                  /// CATEGORIES (READ ONLY)
                  Text(
                    "Selected Categories",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: AppSizes.h8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.selectedCategories.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: AppSizes.p4), // 👈 tight spacing
                          child: Chip(
                            label: Text(
                              tag,
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            backgroundColor: AppColors.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                color: AppColors.backgroundColor,
                                width: 1,
                              ),
                            ),
                            visualDensity:
                                VisualDensity.compact, // 👈 reduces height
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: AppSizes.h20),
                  Text(
                    "Your Question",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: AppSizes.h8),

                  _previewCard(
                    context,
                    TextField(
                      controller: questionCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizes.h20),

                  /// OPTIONS HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Answer Options",
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h8),

                  /// OPTIONS LIST (EDIT + REMOVE)
                  ...optionCtrls.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ctrl = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// OPTION CONTAINER
                          Container(
                            width: MediaQuery.sizeOf(context).width / 1.3,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.p12,
                                vertical: AppSizes.p10),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.border,
                                  child: Text(
                                    "${index + 1}",
                                    style: FontManager()
                                        .getTextStyle(context, fontSize: 12),
                                  ),
                                ),
                                SizedBox(width: AppSizes.w12),
                                Expanded(
                                  child: TextField(
                                    controller: ctrl,
                                    decoration: const InputDecoration(
                                      hintText: "",
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// DELETE ICON (OUTSIDE CONTAINER)
                          if (optionCtrls.length > 2)
                            InkWell(
                              onTap: () => removeOption(index),
                              borderRadius: BorderRadius.circular(20),
                              child: Icon(
                                Icons.close,
                                size: 26,
                                color: AppColors.redColor,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: AppSizes.h20),
                  if (optionCtrls.length < 4)
                    GestureDetector(
                      onTap: addOption,
                      child: DottedBorderBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            Text(
                              "Add Option",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.normal,
                                fontSize: 14,
                                color: AppColors.bg1,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// POST BUTTON
          Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: InkWell(
              onTap: postPoll,
              child: getButton(context, "Post Poll"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewCard(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
