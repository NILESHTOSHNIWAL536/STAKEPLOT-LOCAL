import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Constants/app_styles.dart';
import '../../../../Constants/colors.dart';
import '../../../../Constants/core/app_padding_sizes.dart';
import '../../../../Constants/font_manager.dart';
import '../../../../Constants/core/container_border.dart';
import '../../../../backed_connections/apis_connect.dart';
import '../../../../image_service/avatarProfile.dart';
import '../../../FriendsUi.dart';
import 'collection_people_selector.dart';
import '../collection_step_indicator.dart';
import '../create_collection_data.dart';
import 'step_add_people.dart';

import 'step_assign_roles.dart';
import 'step_collection_name.dart';
import 'step_collection_type.dart';
import 'step_optional_description.dart';
import 'step_select_duration.dart';

/// ---------------- CREATE FLOW ----------------
class CreateCollectionFlow extends StatefulWidget {
  const CreateCollectionFlow({super.key});

  @override
  State<CreateCollectionFlow> createState() => _CreateCollectionFlowState();
}

class _CreateCollectionFlowState extends State<CreateCollectionFlow> {
  final PageController _controller = PageController();
  int step = 0;

  /// SINGLE SOURCE OF TRUTH
  final RxList<Map<String, dynamic>> selectedMembers =
      <Map<String, dynamic>>[].obs;
 

  void next() {
    // if (step >= 5) return;

    bool isPersonalSkip = collectionDraft.type == "personal" && step == 1;

    setState(() {
      step = isPersonalSkip ? step + 4 : step + 1;
    });

    if (isPersonalSkip) {
      _controller.animateToPage(
        4,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void back() {
    if (step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => step--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbg,
      body: SafeArea(
        child: Column(
          children: [
            CollectionHeader(onBack: back),
            Container(
                color: AppColors.border,
                child: CollectionStepIndicator(currentStep: step)),
            Container(
              height: MediaQuery.of(context).size.height - 150,
              color: AppColors.border,
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StepCollectionName(onNext: next),
                  StepCollectionType(onNext: next),
                  StepAddPeople(
                    members: selectedMembers,
                    userIds: collectionsController.selectedUserIds,
                    onNext: (members) {
                      collectionDraft.members = members;
                      next();
                    },
                  ),
                  StepAssignRoles(
                    members: selectedMembers,
                    onNext: next,
                  ),
                  StepSelectDuration(onNext: next),
                  StepOptionalDescription(onNext: next),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const PrimaryButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: FontManager().getTextStyle(
            context,
            fontSize: 16,
            lWeight: FontWeight.w500,
            color: AppColors.backgroundColor,
          ),
        ),
      ),
    );
  }
}

class CollectionHeader extends StatelessWidget {
  final VoidCallback onBack;

  const CollectionHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.newbg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            InkWell(
                onTap: onBack,
                child: CustomStyledContainer(
                  padding: const EdgeInsets.all(AppSizes.p12),
                  radius: 30,
                  // width: 42,
                  // height: 40,
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: AppColors.accentColor,
                  ),
                )),
            SizedBox(width: AppSizes.w52),
            Text(
              "Create Collection",
              style: FontManager().getTextStyle(
                context,
                fontSize: 18,
                lWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget wrapperCollection(BuildContext context, Widget child) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 220,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              SizedBox(height: AppSizes.h20),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget titleCollection(BuildContext context, String text) {
  return Text(
    text,
    style: FontManager().getTextStyle(
      context,
      fontSize: 16,
      lWeight: FontWeight.w500,
    ),
  );
}

Widget inputCollection(String hint, BuildContext context) {
  return TextField(
    style: FontManager().getTextStyle(
      context,
      fontSize: 16,
      lWeight: FontWeight.w500,
      color: AppColors.accentColor,
    ),
    onChanged: (v) {
      collectionDraft.name = v.trim();
    },
    decoration: InputDecoration(
      hintText: "Enter collection name",
      hintStyle: FontManager().getTextStyle(
        context,
        fontSize: 16,
        color: AppColors.border,
        lWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.backgroundColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

Widget cardCollection(
  BuildContext context,
  String title, {
  bool isSelected = false,
}) {
  return Container(
    height: MediaQuery.of(context).size.height / 5.6,
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(10),

      /// ✅ BORDER ADDED
      border: Border.all(
        color: isSelected ? AppColors.primaryColor : Colors.transparent,
        width: 2,
      ),
    ),
    child: AvatarProfileImageZero(
      url: title,
      width: 1.3,
      height: 4,
    ),
  );
}

Widget chipCollection(String text, BuildContext context,
    {bool isSelected = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
    child: Container(
      height: MediaQuery.of(context).size.height / 18,
      width: MediaQuery.of(context).size.width / 1.2,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : AppColors.border,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: FontManager().getTextStyle(
            context,
            fontSize: 14,
            color:
                isSelected ? AppColors.backgroundColor : AppColors.accentColor,
          ),
        ),
      ),
    ),
  );
}
