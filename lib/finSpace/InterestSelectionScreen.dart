import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
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
    selectedSubCategories.clear();
    isListEnabled.value = false;
    selectedCategories.clear();
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
                                addMyIntreastAndName(
                                  combinedList,
                                  context
                                );
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

  const GetListOfInterest({Key? key}) : super(key: key);

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
                    height: screenSize.height * 0.63, // 60% of screen height for categories
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'Finspace',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Choose some categories you like. You can change them anytime',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class CategoriesListWidget extends StatelessWidget {
  final Function(String) onCategoryToggle;
  final Function(String) onSubCategoryToggle;

   CategoriesListWidget({
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
          spacing:
              screenSize.width * 0.015, // Further reduced horizontal spacing
          runSpacing:
              screenSize.height * 0.005, // Further reduced vertical spacing
          alignment: WrapAlignment.start, // Align to start for brick-like effect
          children: categoriesInterest.keys.map((category) {
            final subCategories = categoriesInterest[category] ?? [];
            final isSelected = selectedCategories.contains(category);
            final hasSubCategories = subCategories.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Category Chip
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                      vertical: 1), // Minimal vertical margin
                  child: CategoryChip(
                    label: category,
                    isSelected: isSelected,
                    onTap: () => onCategoryToggle(category),
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4A4E69)
                    : const Color(0xFF8A8A8A),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.backgroundColor : AppColors.bg1,
                fontSize: isSubCategory ? 12 : 14,
                fontWeight: isSubCategory ? FontWeight.w400 : FontWeight.w400,
              ),
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
      width: double.infinity,
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
