
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/BudgetOverView.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
// import 'package:get/get.dart';

// class BudgetSearch extends StatefulWidget {
//   String amount;
//   String name;
//   String period;
//   BudgetSearch(
//       {Key? key,
//       required this.amount,
//       required this.name,
//       required this.period})
//       : super(key: key);

//   @override
//   _BudgetSearchState createState() => _BudgetSearchState();
// }

// class _BudgetSearchState extends State<BudgetSearch> {
//   TextEditingController nameController = TextEditingController(text: "");
//   String selectedValue = categoriesSeleted[0] ?? "";
//   RxList<String> filteredCategories = <String>[].obs; 
//   void initState() {
//     super.initState();

//     // Add listener to the TextEditingController
//     nameController.addListener(() {
//       filterCategories(); // Call filtering method on text change
//     });

//     // Initially populate the filtered categories
//     filteredCategories.assignAll(Categories.categoriesList);
//   }
//   void filterCategories() {
//     String query = nameController.text.toLowerCase();
//     filteredCategories.value = Categories.categoriesList.where((category) {
//       String categoryName = category.substring(0, category.length - 4).toLowerCase();
//       return categoryName.contains(query);
//     }).toList();
//   }
//    void dispose() {
//     nameController.dispose(); // Dispose the controller
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundColor,
//         body: getBudgetUiScreen(height, width),
//       ),
//     );
//   }

//   Widget getBudgetUiScreen(height, width) {
//     return Container(
//       width: width,
//       height: height / 1.1,
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(color: AppColors.backgroundColor),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: Colorcodes.paddingSize),
//             textStyle(
//                 context: context,
//                 text: "Budget Categories",
//                 fontsize: 20,
//                 fontWeight: FontWeight.bold),
//             SizedBox(height: Colorcodes.paddingSize / 2),
//             searchList(width, height),
//             SizedBox(height: Colorcodes.paddingSize),
//             Obx(() => getCategories.value ? getListOfCat() : getListOfCat()),
//             SizedBox(height: Colorcodes.paddingSize),
//             InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BudgetOverView(
//                           amount: widget.amount,
//                           name: widget.name,
//                           period: widget.period),
//                     ),
//                   );
//                 },
//                 child: getButton(context, "Continue")),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget getListOfCat() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       child: Wrap(
//         spacing: 8.0, // Adjust spacing between items
//         runSpacing: 8.0, // Adjust spacing between lines
//         children: categoriesSeleted.map((name) {
//           return getUipartOfCatero(context, name.toString());
//         }).toList(),
//       ),
//     );
//   }

//   Widget getUipartOfCatero(BuildContext context, String name) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: AppColors.mt,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           textStyle(
//               context: context,
//               text: toUpperCase(name.toString()),
//               fontsize: 16),
//           const SizedBox(width: 10),
//           InkWell(
//             onTap: () {
//               categoriesSeleted.remove(name);
//               getCategories.value = !getCategories.value;
//             },
//             child: Icon(
//               Icons.close,
//               color: AppColors.primaryColor,
//               size: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget searchList(double width, double height) {
//     return Container(
//       width: width / 1.1,
//       child: Column(
//         children: [
//           TextFeildWidgetCustom(
//             textEditingController: nameController,
//             heading: "",
//             keyBoard: TextInputType.emailAddress,
//             lableText: "Search for category",
//             icon: ProfileIcons.friends,
//             flag: false,
//           ),
//           Container(
//             width: width,
//             height: height / 3,
//             decoration: BoxDecoration(
//                 color: AppColors.mt,
//                 borderRadius: BorderRadius.circular(16)),
//             child: SingleChildScrollView(
//               child: Container(
//                 child: Obx(() => getSearchBox()),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget getSearchBox() {
//     // Filter the categories based on the search query
//     return filteredCategories.isNotEmpty
//         ? Column(
//             children: filteredCategories.map((categorie) {
//               return listViewOfcategorie(categorie);
//             }).toList(),
//           )
//         : Center(
//             child: Text("No categories found", style: TextStyle(color: Colors.grey)),
//           );
//   }

//   Widget listViewOfcategorie(String categorie) {
//     String s = categorie.substring(0, categorie.length - 4);
//     if (categoriesSeleted.contains(s)) return SizedBox.shrink();
//     return InkWell(
//       onTap: () {
//         categoriesSeleted.add(s);
//         getCategories.value = !getCategories.value;
//         getCategories.refresh();
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 3),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start, // Align items horizontally
//   crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             AvatarProfileImage(
//                 url: Categories.link + categorie, width: 24, height: 24),
//             const SizedBox(width: 10),
//             textStyle(context: context, text: s)
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/BudgetOverView.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:get/get.dart';

class BudgetSearch extends StatefulWidget {
  String amount;
  String name;
  String period;
  BudgetSearch(
      {Key? key,
      required this.amount,
      required this.name,
      required this.period})
      : super(key: key);

  @override
  _BudgetSearchState createState() => _BudgetSearchState();
}

class _BudgetSearchState extends State<BudgetSearch> {
  TextEditingController nameController = TextEditingController(text: "");
  String selectedValue = categoriesSeleted[0] ?? "";
  RxList<String> filteredCategories = <String>[].obs;
  bool isSearchListVisible = false; // Track if the search list should be visible
  
  void initState() {
    super.initState();

    // Add listener to the TextEditingController
    nameController.addListener(() {
      filterCategories(); // Call filtering method on text change
    });

    // Initially populate the filtered categories
    filteredCategories.assignAll(Categories.categoriesList);
  }

  void filterCategories() {
    String query = nameController.text.toLowerCase();
    filteredCategories.value = Categories.categoriesList.where((category) {
      String categoryName = category.substring(0, category.length - 4).toLowerCase();
      return categoryName.contains(query);
    }).toList();
  }

  void toggleSearchListVisibility() {
    setState(() {
      isSearchListVisible = !isSearchListVisible; // Toggle search list visibility
    });
  }

  @override
  void dispose() {
    nameController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: getBudgetUiScreen(height, width),
      ),
    );
  }

  Widget getBudgetUiScreen(height, width) {
    return Container(
      width: width,
      height: height / 1.1,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: AppColors.backgroundColor),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Colorcodes.paddingSize),
            textStyle(
                context: context,
                text: "Budget Categories",
                fontsize: 20,
                fontWeight: FontWeight.bold),
            SizedBox(height: Colorcodes.paddingSize / 2),
            searchList(width, height),
            SizedBox(height: Colorcodes.paddingSize),
            getListOfCat(),
            SizedBox(height: Colorcodes.paddingSize),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetOverView(
                          amount: widget.amount,
                          name: widget.name,
                          period: widget.period),
                    ),
                  );
                },
                child: getButton(context, "Continue")),
          ],
        ),
      ),
    );
  }

  Widget getListOfCat() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        spacing: 8.0, // Adjust spacing between items
        runSpacing: 8.0, // Adjust spacing between lines
        children: categoriesSeleted.map((name) {
          return getUipartOfCatero(context, name.toString());
        }).toList(),
      ),
    );
  }

  Widget getUipartOfCatero(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.mt,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          textStyle(
              context: context,
              text: toUpperCase(name.toString()),
              fontsize: 16),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              categoriesSeleted.remove(name);
              getCategories.value = !getCategories.value;
            },
            child: Icon(
              Icons.close,
              color: AppColors.primaryColor,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget searchList(double width, double height) {
    return GestureDetector(
      onTap: toggleSearchListVisibility, // Toggle visibility of search list
      child: Container(
        width: width / 1.1,
        child: Column(
          children: [
            TextFeildWidgetCustom(
              textEditingController: nameController,
              heading: "",
              keyBoard: TextInputType.emailAddress,
              lableText: "Search for category",
              icon: ProfileIcons.friends,
              flag: false,
            ),
            if (!isSearchListVisible) // Only show the list if it is expanded
              Container(
                width: width,
                height: height / 3,
                decoration: BoxDecoration(
                    color: AppColors.mt,
                    borderRadius: BorderRadius.circular(16)),
                child: SingleChildScrollView(
                  child: Obx(() => getSearchBox()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget getSearchBox() {
    // Filter the categories based on the search query
    return filteredCategories.isNotEmpty
        ? Column(
            children: filteredCategories.map((categorie) {
              return listViewOfcategorie(categorie);
            }).toList(),
          )
        : Center(
            child: Text("No categories found", style: TextStyle(color: Colors.grey)),
          );
  }

  Widget listViewOfcategorie(String categorie) {
    String s = categorie.substring(0, categorie.length - 4);
    if (categoriesSeleted.contains(s)) return SizedBox.shrink();
    return InkWell(
      onTap: () {
        categoriesSeleted.add(s);
        getCategories.value = !getCategories.value;
        getCategories.refresh();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align items horizontally
  crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvatarProfileImage(
                url: Categories.link + categorie, width: 24, height: 24),
            const SizedBox(width: 10),
            textStyle(context: context, text: s)
          ],
        ),
      ),
    );
  }
}
