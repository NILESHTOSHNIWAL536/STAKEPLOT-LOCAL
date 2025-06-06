import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:get/get.dart';

class UpdateInterestScreen extends StatefulWidget {
  const UpdateInterestScreen({Key? key}) : super(key: key);

  @override
  State<UpdateInterestScreen> createState() => _UpdateInterestScreenState();
}

class _UpdateInterestScreenState extends State<UpdateInterestScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Populate selectedCategories and selectedSubCategories from interestedTags
    final categoriesMap = FinspaceStrings().categories;
    selectedCategories.clear();
    selectedSubCategories.clear();
    for (String tag in interestedTags) {
      // Check if tag is a main category
      if (categoriesMap.containsKey(tag)) {
        selectedCategories.add(tag);
      } else {
        // Check if tag is a subcategory
        bool isSubCategory = categoriesMap.values.any((subList) => subList.contains(tag));
        if (isSubCategory) {
          selectedSubCategories.add(tag);
        }
      }
    }
    isListEnabled.value = selectedCategories.isNotEmpty || selectedSubCategories.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
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
                  // Header (reused from InterestSelectionScreen)
                  HeaderWidget(),
                  // Title Section (modified for update context)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                      vertical: 16,
                    ),
                    child: UpdateTitleWidget(),
                  ),
                  // Categories List (filtered to exclude selected interests)
                  GetListOfInterest(height: 0.5),
                  // Previously Selected Interests (now with deselection)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                      vertical: 8,
                    ),
                    child: PreviouslySelectedInterestsWidget(
                      onCategoryToggle: _toggleCategory,
                      onSubCategoryToggle: _toggleSubCategory,
                    ),
                  ),
                  // Update Button
                  Obx(
                    () => 
                     AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 70,
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: isListEnabled.value? UpdateButtonWidget(
                                onPressed: () {
                                  final combinedList = [
                                    ...selectedSubCategories,
                                    ...selectedCategories
                                  ];
                                  // Update interestedTags
                                 
                                  var body = {
                                    "interestedTags": combinedList,
                                  };
                                  // Call API to update interests
                                  addMyIntreastAndName(context, body,false,true);
                                 
                                },
                              ):null,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        selectedSubCategories
            .removeWhere((sub) => FinspaceStrings().categories[category]?.contains(sub) ?? false);
      } else {
        selectedCategories.add(category);
      }
      isListEnabled.value = selectedCategories.isNotEmpty || selectedSubCategories.isNotEmpty;
    });
  }

  void _toggleSubCategory(String subCategory) {
    setState(() {
      if (selectedSubCategories.contains(subCategory)) {
        selectedSubCategories.remove(subCategory);
      } else {
        selectedSubCategories.add(subCategory);
      }
      isListEnabled.value = selectedCategories.isNotEmpty || selectedSubCategories.isNotEmpty;
    });
  }
}


class GetListOfInterest extends StatefulWidget {
  final double height;
  GetListOfInterest({Key? key, this.height = 0.63}) : super(key: key);

  @override
  State<GetListOfInterest> createState() => _GetListOfInterestState();
}

class _GetListOfInterestState extends State<GetListOfInterest> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      height: screenSize.height * widget.height,
      child: FilteredCategoriesListWidget(
        onCategoryToggle: (category) {
          setState(() {
            selectedCategories.add(category);
            isListEnabled.value = selectedCategories.isNotEmpty || selectedSubCategories.isNotEmpty;
          });
          _animationController.forward().then((_) => _animationController.reset());
        },
        onSubCategoryToggle: (subCategory) {
          setState(() {
            selectedSubCategories.add(subCategory);
            isListEnabled.value = selectedCategories.isNotEmpty || selectedSubCategories.isNotEmpty;
          });
        },
      ),
    );
  }
}

// FilteredCategoriesListWidget to exclude selected interests
class FilteredCategoriesListWidget extends StatelessWidget {
  final Function(String) onCategoryToggle;
  final Function(String) onSubCategoryToggle;

  FilteredCategoriesListWidget({
    Key? key,
    required this.onCategoryToggle,
    required this.onSubCategoryToggle,
  }) : super(key: key);

  final Map<String, List<String>> categoriesInterest = FinspaceStrings().categories;

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
          children: categoriesInterest.keys.where((category) {
            // Only show categories that are not selected
            return !selectedCategories.contains(category);
          }).map((category) {
            final subCategories = categoriesInterest[category] ?? [];
            final hasSubCategories = subCategories.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Category Chip
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  child: CategoryChip(
                    label: category,
                    isSelected: false,
                    onTap: () => onCategoryToggle(category),
                    isSubCategory: false,
                  ),
                ),
                // Subcategories (filtered to exclude selected ones)
                if (hasSubCategories)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: screenSize.width * 0.015,
                      runSpacing: screenSize.height * 0.005,
                      children: subCategories.where((subCategory) {
                        return !selectedSubCategories.contains(subCategory);
                      }).map((subCategory) {
                        return CategoryChip(
                          label: subCategory,
                          isSelected: false,
                          onTap: () => onSubCategoryToggle(subCategory),
                          isSubCategory: true,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Modified Title Widget for Update Screen
class UpdateTitleWidget extends StatelessWidget {
  const UpdateTitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Update Your Interests',
          style: FontManager2().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Tap to add new interests or deselect current ones below.',
          style: FontManager2().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 14,
            lineHeight: 1.4,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Modified to allow deselection
class PreviouslySelectedInterestsWidget extends StatelessWidget {
  final Function(String) onCategoryToggle;
  final Function(String) onSubCategoryToggle;

  const PreviouslySelectedInterestsWidget({
    Key? key,
    required this.onCategoryToggle,
    required this.onSubCategoryToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Interests',
            style: FontManager2().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: screenSize.width * 0.015,
            runSpacing: screenSize.height * 0.005,
            children: [
              ...selectedCategories.map((category) => CategoryChip(
                    label: category,
                    isSelected: true,
                    onTap: () => onCategoryToggle(category),
                    isSubCategory: false,
                  )),
              ...selectedSubCategories.map((subCategory) => CategoryChip(
                    label: subCategory,
                    isSelected: true,
                    onTap: () => onSubCategoryToggle(subCategory),
                    isSubCategory: true,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// Update Button Widget
class UpdateButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const UpdateButtonWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 2.8,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A4E69),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Update',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}