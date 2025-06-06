import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:get/get.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({Key? key}) : super(key: key);

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
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
                  // Header
                  HeaderWidget(),
                  // Title Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                      vertical: 16,
                    ),
                    child: TitleWidget(),
                  ),
                  // Categories List
                  GetListOfInterest(),
                  // Done Button
                Obx(()=> !isListEnabled.value? SizedBox.shrink(): AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height:   70,
                    alignment:  Alignment.topCenter, // Change alignment
                    child:   Padding(
                            padding: EdgeInsets.all(12),
                            child: DoneButtonWidget(
                              onPressed: () {
                               final combinedList = [...selectedSubCategories, ...selectedCategories];
                                var body = {
                                  "interestedTags": combinedList,
                                };
                                addMyIntreastAndName(context,body);
                            },

                            ),
                          )
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
}


class GetListOfInterest extends StatefulWidget  {
  double height=0.63;
  GetListOfInterest({Key? key,this.height=0.63}) : super(key: key);

  @override
  State<GetListOfInterest> createState() => _GetListOfInterestState();
}

class _GetListOfInterestState extends State<GetListOfInterest>  with TickerProviderStateMixin  {
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
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return  Container(
                    height: screenSize.height * widget.height, // 60% of screen height for categories
                    child: CategoriesListWidget(
                      onCategoryToggle: _toggleCategory,
                      onSubCategoryToggle: _toggleSubCategory,
                    ),
          );
  }

   void _toggleCategory(String category) {
    setState(() {
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
     isListEnabled.value = selectedCategories.isNotEmpty ||
        selectedSubCategories.isNotEmpty;
  }

  void _toggleSubCategory(String subCategory) {
    setState(() {
      if (selectedSubCategories.contains(subCategory)) {
        selectedSubCategories.remove(subCategory);
      } else {
        selectedSubCategories.add(subCategory);
      }
    });
    isListEnabled.value = selectedCategories.isNotEmpty ||
        selectedSubCategories.isNotEmpty;
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
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to',
                style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.black54)
              ),
              Text(
                'Finspace',
                style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.finSpaceColor)
              ),
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
                      lWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.black87),
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

  const CategoriesListWidget({
    Key? key,
    required this.onCategoryToggle,
    required this.onSubCategoryToggle,
  }) : super(key: key);

  @override
  _CategoriesListWidgetState createState() => _CategoriesListWidgetState();
}

class _CategoriesListWidgetState extends State<CategoriesListWidget>
    with TickerProviderStateMixin {
  final Map<String, List<String>> categoriesInterest = FinspaceStrings().categories;
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
 
 @override
  void initState() {
    super.initState();
    _controllers = categoriesInterest.keys.map((_) {
      return AnimationController(
        duration: const Duration(milliseconds: 1400), // Increased duration
        vsync: this,
      )..forward(); // Start animation immediately
    }).toList();

    _animations = categoriesInterest.keys.toList().asMap().entries.map((entry) {
      final index = entry.key;
      Offset beginOffset;
      // Estimate rows (assuming 2 categories per row)
      final totalCategories = categoriesInterest.keys.length;
      final estimatedRows = (totalCategories / 2).ceil();
      final rowIndex = (index / 2).floor(); // Which row this category is in

      if (totalCategories % 2 == 1 && index == totalCategories - 1) {
        // Single category in the last row
        beginOffset = Offset(0, rowIndex % 2 == 0 ? -2 : 2); // Top or bottom, increased distance
      } else if (estimatedRows >= 3 && rowIndex > 0 && rowIndex < estimatedRows - 1) {
        // Middle rows: alternate top/bottom per category
        beginOffset = Offset(0, index % 2 == 0 ? -2 : 2); // Top for even index, bottom for odd
      } else {
        // First and last rows: left/right
        beginOffset = index % 2 == 0 ? Offset(-2, 0) : Offset(2, 0); // Increased distance
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
          children: categoriesInterest.keys.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final subCategories = categoriesInterest[category] ?? [];
            final isSelected = selectedCategories.contains(category);
            final hasSubCategories = subCategories.isNotEmpty;

            return SlideTransition(
              position: _animations[index],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Category Chip
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    child: CategoryChip(
                      label: category,
                      isSelected: isSelected,
                      onTap: () => widget.onCategoryToggle(category),
                      isSubCategory: false,
                    ),
                  ),
                  // Subcategories (if main category is selected)
                  if (isSelected && hasSubCategories)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 2),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: screenSize.width * 0.015,
                        runSpacing: screenSize.height * 0.005,
                        children: subCategories.map((subCategory) {
                          final isSubSelected = selectedSubCategories.contains(subCategory);
                          return CategoryChip(
                            label: subCategory,
                            isSelected: isSubSelected,
                            onTap: () => widget.onSubCategoryToggle(subCategory),
                            isSubCategory: true,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
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

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSubCategory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: IntrinsicWidth(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6), // Further reduced padding
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.finSpaceColor
                  : AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4A4E69)
                    : const Color(0xFF8A8A8A),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize:  isSubCategory ? 12 : 14,
                      color: isSelected ? AppColors.backgroundColor : AppColors.bg1),
              
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
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
       width: MediaQuery.sizeOf(context).width/4,
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
          'Done',
           style:FontManager2().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color:  AppColors.backgroundColor)
        ),
      ),
    );
  }
}
