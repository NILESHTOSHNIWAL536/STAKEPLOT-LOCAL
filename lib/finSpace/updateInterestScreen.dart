import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
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
    for (String tag in userController.interestedTags) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  HeaderWidget(),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                      vertical: 16,
                    ),
                    child: UpdateTitleWidget(),
                  ),
                  // Categories List (filtered to exclude selected interests)
                   GetListOfInterest(),
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
                  Align(
                     alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Obx(
                        () => 
                         AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: MediaQuery.sizeOf(context).height/14,
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
                    ),
                  ),
                   SizedBox(height: 16),
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
  const GetListOfInterest({Key? key}) : super(key: key);

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
    return Column(
      mainAxisSize: MainAxisSize.min, // Take only the space needed
      children: [
        FilteredCategoriesListWidget(
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
      ],
    );
  }
}

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
if (categoriesInterest.keys.every((category) => selectedCategories.contains(category))) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'All interests selected',
            style: FontManager2().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
     return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
        child: Wrap(
          spacing: screenSize.width * 0.015, // Horizontal spacing between chips
          runSpacing: screenSize.height * 0.005, // Vertical spacing between rows
          alignment: WrapAlignment.start, // Align chips to the start
          children: categoriesInterest.keys.where((category) {
            // Only show categories that are not selected
            return !selectedCategories.contains(category);
          }).expand((category) {
            final subCategories = categoriesInterest[category] ?? [];
            // Create a list starting with the category chip, followed by its subcategories
            return [
              // Category Chip
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
              // Subcategory Chips
              ...subCategories.where((subCategory) {
                return !selectedSubCategories.contains(subCategory);
              }).map((subCategory) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  child: CategoryChip(
                    label: subCategory,
                    isSelected: false,
                    onTap: () => onSubCategoryToggle(subCategory),
                    isSubCategory: true,
                  ),
                );
              }),
            ];
          }).toList(),
        ),
      ),
    );
    // return SingleChildScrollView(
    //   child: Padding(
    //     padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
    //     child: Wrap(
    //       spacing: screenSize.width * 0.015,
    //       runSpacing: screenSize.height * 0.005,
    //       alignment: WrapAlignment.start,
    //       children: categoriesInterest.keys.where((category) {
    //         // Only show categories that are not selected
    //         return !selectedCategories.contains(category);
    //       }).map((category) {
    //         final subCategories = categoriesInterest[category] ?? [];
    //         final hasSubCategories = subCategories.isNotEmpty;

    //         return Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             // Main Category Chip
    //             AnimatedContainer(
    //               duration: const Duration(milliseconds: 200),
    //               margin: const EdgeInsets.symmetric(vertical: 1),
    //               child: CategoryChip(
    //                 label: category,
    //                 isSelected: false,
    //                 onTap: () => onCategoryToggle(category),
    //                 isSubCategory: false,
    //               ),
    //             ),
    //             // Subcategories (filtered to exclude selected ones)
    //             if (hasSubCategories)
    //               AnimatedContainer(
    //                 duration: const Duration(milliseconds: 300),
    //                 margin: const EdgeInsets.only(bottom: 2),
    //                 child: Wrap(
    //                   alignment: WrapAlignment.start,
    //                   spacing: screenSize.width * 0.015,
    //                   runSpacing: screenSize.height * 0.005,
    //                   children: subCategories.where((subCategory) {
    //                     return !selectedSubCategories.contains(subCategory);
    //                   }).map((subCategory) {
    //                     return CategoryChip(
    //                       label: subCategory,
    //                       isSelected: false,
    //                       onTap: () => onSubCategoryToggle(subCategory),
    //                       isSubCategory: true,
    //                     );
    //                   }).toList(),
    //                 ),
    //               ),
    //           ],
    //         );
    //       }).toList(),
    //     ),
    //   ),
    // );
  
  }
}


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
            color: AppColors.accentColor,
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
              color: AppColors.bg1,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
           alignment: WrapAlignment.start, // Ensure chips start from the left
                  spacing: screenSize.width * 0.015, // Consistent with FilteredCategoriesListWidget
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
          backgroundColor: AppColors.finSpaceColor,
          foregroundColor: AppColors.backgroundColor,
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