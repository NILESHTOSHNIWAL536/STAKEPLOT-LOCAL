import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';


class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({Key? key}) : super(key: key);

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen>
    with TickerProviderStateMixin {
  
  Set<String> selectedCategories = {};
  Set<String> selectedSubCategories = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, List<String>> categories = FinspaceStrings().categories;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        // Remove all subcategories of this category
        selectedSubCategories.removeWhere((sub) => 
            categories[category]?.contains(sub) ?? false);
      } else {
        selectedCategories.add(category);
      }
    });
    _animationController.forward().then((_) {
      _animationController.reset();
    });
  }

  void _toggleSubCategory(String subCategory) {
    setState(() {
      if (selectedSubCategories.contains(subCategory)) {
        selectedSubCategories.remove(subCategory);
      } else {
        selectedSubCategories.add(subCategory);
      }
    });
  }

  bool get _hasSelections => 
      selectedCategories.isNotEmpty || selectedSubCategories.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
            Expanded(
              child: CategoriesListWidget(
                categories: categories,
                selectedCategories: selectedCategories,
                selectedSubCategories: selectedSubCategories,
                onCategoryToggle: _toggleCategory,
                onSubCategoryToggle: _toggleSubCategory,
                fadeAnimation: _fadeAnimation,
              ),
            ),
            
            // Done Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _hasSelections ? 80 : 0,
              child: _hasSelections
                  ? Padding(
                      padding: EdgeInsets.all(16),
                      child: DoneButtonWidget(
                        onPressed: () {
                          // Handle done action
                          print('Selected Categories: $selectedCategories');
                          print('Selected SubCategories: $selectedSubCategories');
                          final combinedList = [...selectedSubCategories, ...selectedCategories];

                          addMyIntreastAndName(
                            "Niles_3gt473",
                            combinedList,
                            context
                          );
                        },
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
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
                'Welcome back to',
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
  final Map<String, List<String>> categories;
  final Set<String> selectedCategories;
  final Set<String> selectedSubCategories;
  final Function(String) onCategoryToggle;
  final Function(String) onSubCategoryToggle;
  final Animation<double> fadeAnimation;

  const CategoriesListWidget({
    Key? key,
    required this.categories,
    required this.selectedCategories,
    required this.selectedSubCategories,
    required this.onCategoryToggle,
    required this.onSubCategoryToggle,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final subCategories = categories[category] ?? [];
        final isSelected = selectedCategories.contains(category);
        final hasSubCategories = subCategories.isNotEmpty;
        
        return Column(
          children: [
            // Main Category Chip
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(vertical: 4),
              child: CategoryChip(
                label: category,
                isSelected: isSelected,
                onTap: () => onCategoryToggle(category),
              ),
            ),
            
            // Subcategories (if main category is selected)
            if (isSelected && hasSubCategories)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(left: 20, bottom: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subCategories.map((subCategory) {
                    final isSubSelected = selectedSubCategories.contains(subCategory);
                    return CategoryChip(
                      label: subCategory,
                      isSelected: isSubSelected,
                      onTap: () => onSubCategoryToggle(subCategory),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF4A4E69) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Color(0xFF4A4E69) : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class SubCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SubCategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade700 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w400,
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
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A4E69),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
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