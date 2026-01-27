import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:get/get.dart';

import '../Constants/core/app_padding_sizes.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({Key? key}) : super(key: key);

  @override
  State<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    clearInterest();
    
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background SVG Image
            Center(
              child: AvatarProfileImage(
                url: FinSpaceIcons.bgMarks,
                height: 2, // 50% of screen height
                width: 1, // 50% of screen width
              ),
            ),
            // Main Content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  HeaderWidget(),
                  // Title Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                      vertical: AppSizes.p16,
                    ),
                    child: TitleWidget(),
                  ),
                  // Categories List
                  GetListOfInterest(),
                  // Done Button
                  Obx(
                    () => !isListEnabled.value
                        ? SizedBox.shrink()
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 70,
                            alignment: Alignment.topCenter, // Change alignment
                            child: Padding(
                              padding: EdgeInsets.all(AppSizes.p12),
                              child: DoneButtonWidget(
                                onPressed: () {
                                  final combinedList = [
                                    ...selectedSubCategories,
                                    ...selectedCategories
                                  ];
                                  var body = {
                                    "interestedTags": combinedList,
                                  };
                                  addMyIntreastAndName(context, body);
                                },
                              ),
                            )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GetListOfInterest extends StatefulWidget {
  double height = 0.63;
  final bool limitTagbool;
  final bool enableAnimations;
  GetListOfInterest({
    Key? key,
    this.height = 0.63,
    this.limitTagbool = false,
    this.enableAnimations = true,
  }) : super(key: key);

  @override
  State<GetListOfInterest> createState() => _GetListOfInterestState();
}

class _GetListOfInterestState extends State<GetListOfInterest>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    selectedCategories.clear();
    selectedSubCategories.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      height: screenSize.height *
          widget.height, // 60% of screen height for categories
      child: CategoriesListWidget(
        onCategoryToggle: _toggleCategory,
        onSubCategoryToggle: _toggleSubCategory,
        limitTagbool: widget.limitTagbool,
        enableAnimations: widget.enableAnimations,
      ),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      final totalSelected =
          selectedCategories.length + selectedSubCategories.length;
      if (widget.limitTagbool &&
          totalSelected >= CommunityScreenStrings().limitTag &&
          !selectedCategories.contains(category)) {
        // Show a snackbar or dialog to inform the user

        snackBarCalledfail(context, SnackbarData().limitTagSnackbar);
        return;
      }
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        selectedSubCategories
            .removeWhere((sub) => categories[category]?.contains(sub) ?? false);
      } else {
        selectedCategories.add(category);
      }
    });
    _animationController.forward().then((_) {
      _animationController.reset();
    });
    isListEnabled.value =
        selectedCategories.isNotEmpty || selectedSubCategories.isNotEmpty;
  }

  void _toggleSubCategory(String subCategory) {
    setState(() {
      final totalSelected =
          selectedCategories.length + selectedSubCategories.length;
      if (widget.limitTagbool &&
          totalSelected >= CommunityScreenStrings().limitTag &&
          !selectedSubCategories.contains(subCategory)) {
        // Show a snackbar or dialog to inform the user
        snackBarCalledfail(context, SnackbarData().limitTagSnackbar);
        return;
      }
      if (selectedSubCategories.contains(subCategory)) {
        selectedSubCategories.remove(subCategory);
      } else {
        selectedSubCategories.add(subCategory);
      }
    });
    isListEnabled.value =
        selectedCategories.isNotEmpty || selectedSubCategories.isNotEmpty;
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: AppSizes.p16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome to',
                  style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.black54)),
              Text('Finspace',
                  style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.finSpaceColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Select Your Interest',
          style: FontManager2().getTextStyle(context,
              lWeight: FontWeight.w500, fontSize: 20, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Choose some categories you like. You can change them anytime',
          style: FontManager2().getTextStyle(context,
              lWeight: FontWeight.w500,
              fontSize: 14,
              lineHeight: 1.4,
              color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class CategoriesListWidget extends StatefulWidget {
  final Function(String) onCategoryToggle;
  final Function(String) onSubCategoryToggle;
  final bool limitTagbool;
  final bool enableAnimations;

  const CategoriesListWidget({
    Key? key,
    required this.onCategoryToggle,
    required this.onSubCategoryToggle,
    required this.limitTagbool,
    this.enableAnimations = true,
  }) : super(key: key);

  @override
  _CategoriesListWidgetState createState() => _CategoriesListWidgetState();
}

class _CategoriesListWidgetState extends State<CategoriesListWidget>
    with TickerProviderStateMixin {
  final Map<String, List<String>> categoriesInterest =
      FinspaceStrings().categories;
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers and animations for categories only
    if (widget.enableAnimations) {
      _controllers = categoriesInterest.keys.map((_) {
        return AnimationController(
          duration: const Duration(milliseconds: 1400),
          vsync: this,
        )..forward();
      }).toList();

      _animations =
          categoriesInterest.keys.toList().asMap().entries.map((entry) {
        final index = entry.key;
        Offset beginOffset;
        final totalCategories = categoriesInterest.keys.length;
        final estimatedRows = (totalCategories / 2).ceil();
        final rowIndex = (index / 2).floor();

        if (totalCategories % 2 == 1 && index == totalCategories - 1) {
          beginOffset = Offset(0, rowIndex % 2 == 0 ? -2 : 2);
        } else if (estimatedRows >= 3 &&
            rowIndex > 0 &&
            rowIndex < estimatedRows - 1) {
          beginOffset = Offset(0, index % 2 == 0 ? -2 : 2);
        } else {
          beginOffset = index % 2 == 0 ? Offset(-2, 0) : Offset(2, 0);
        }

        return Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeOutCubic,
        ));
      }).toList();
    }
    else{
      _controllers = [];
      _animations = [];
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
        child: Wrap(
          spacing: screenSize.width * 0.015,
          runSpacing: screenSize.height * 0.005,
          alignment: WrapAlignment.start,
          children:
              categoriesInterest.keys.toList().asMap().entries.expand((entry) {
            final index = entry.key;
            final category = entry.value;
            final subCategories = categoriesInterest[category] ?? [];
            final isSelected = selectedCategories.contains(category);
            final hasSubCategories = subCategories.isNotEmpty;

            // List of chips: category chip followed by subcategories (if selected)
            final chipList = <Widget>[
               widget.enableAnimations
                  ? 
              SlideTransition(
                position: _animations[index],
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  child: CategoryChip(
                    label: category,
                    isSelected: isSelected,
                    onTap: () => widget.onCategoryToggle(category),
                    isSubCategory: false,
                    isEnabled: !widget.limitTagbool ||
                        selectedCategories.length +
                                selectedSubCategories.length <
                            CommunityScreenStrings().limitTag ||
                        isSelected,
                  ),
                ),
              ):
              AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      child: CategoryChip(
                        label: category,
                        isSelected: isSelected,
                        onTap: () => widget.onCategoryToggle(category),
                        isSubCategory: false,
                        isEnabled: !widget.limitTagbool ||
                            selectedCategories.length +
                                    selectedSubCategories.length <
                                CommunityScreenStrings().limitTag ||
                            isSelected,
                      ),
                    ),
            ];

            // Add subcategory chips if the category is selected and has subcategories
            if (isSelected && hasSubCategories) {
              chipList.addAll(subCategories.map((subCategory) {
                final isSubSelected =
                    selectedSubCategories.contains(subCategory);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  child: CategoryChip(
                    label: subCategory,
                    isSelected: isSubSelected,
                    onTap: () => widget.onSubCategoryToggle(subCategory),
                    isSubCategory: true,
                    isEnabled: !widget.limitTagbool ||
                        selectedCategories.length +
                                selectedSubCategories.length <
                            CommunityScreenStrings().limitTag ||
                        isSubSelected,
                  ),
                );
              }));
            }

            return chipList;
          }).toList(),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSubCategory;
  final bool isEnabled;
  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSubCategory = false,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: IntrinsicWidth(
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: AppSizes.p10), // Further reduced padding
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.finSpaceColor
                    : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A4E69)
                      : const Color(0xFF8A8A8A),
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: FontManager2().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: isSubCategory ? 12 : 14,
                  color: isSelected
                      ? AppColors.backgroundColor
                      : (isEnabled ? AppColors.bg1 : Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ));
  }
}

class DoneButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const DoneButtonWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 4,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A4E69),
          foregroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text('Done',
            style: FontManager2().getTextStyle(context,
                lWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.backgroundColor)),
      ),
    );
  }
}
