

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
// import 'package:flutter_application_code_stakeplot/user_chat/openShowModal.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';


// RxString tagName="".obs;
// RxBool loadAgain=false.obs;

// class TagShowmodal extends StatefulWidget
// {
// var data;
// int index;
// bool isGroupTransaction=false;
// bool isTag=false;
// TagShowmodal({ Key? key ,required this.data,required  this.index,this.isGroupTransaction=false,this.isTag=false }) : super(key: key);

//   @override
//   State<TagShowmodal> createState() => _TagShowmodalState();
// }

// class _TagShowmodalState extends State<TagShowmodal>with SingleTickerProviderStateMixin {

//    late AnimationController _controller;
//   late Animation<Offset> _animation;
//   double opacity = 1.0;

//  TextEditingController nameController=TextEditingController();
//  TextEditingController searchController=TextEditingController();

//   RxBool customSelections=false.obs;
//   RxString UrlPathImage="".obs;

//   @override
//   void initState() {
//     super.initState();
//        UrlPathImage.value =  getIconPath(widget.data['category'].toLowerCase());
//       _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 200),
//     );
    
//     _animation = Tween<Offset>(
//       begin: Offset(0, 3),  // Start from below
//       end: Offset(0, 0),    // Move to normal position
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOut,
//     ));

//     // Start animation
//     _controller.forward();

//     // Delay opacity animation
//     // Future.delayed(Duration(milliseconds: 1000), () {
//     //   setState(() {
//     //     opacity = 1.0;
//     //   });
//     // });
//   }

//   String getIconPath(String category)
//   {

//     if(imageMapForHistory.containsKey(category))return Categories.link + imageMapForHistory[category]!;
//     return Categories.link + Categories.groceries;

//   }

//   @override
//   Widget build(BuildContext context)
//   {
//     return Container(
//       // duration: Duration(milliseconds: 300),
//       // curve: Curves.easeInOut,
//       // padding: EdgeInsets.all(16),
//       padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height/1.3,
//       decoration: BoxDecoration(
//         color: Colorcodes.white,
//         borderRadius:const BorderRadius.only(
//           topLeft:Radius.circular(20), 
//           topRight:Radius.circular(20), 
//         )
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//             children: [
//                     topHeader(context),
//                     const SizedBox(height: 5,),
//                     TextFeildWidget(textEditingController: searchController, heading: "tagSearch", keyBoard: TextInputType.text, lableText: "Search Cat",icon: CupertinoIcons.doc_text_search,),
//                     const SizedBox(height: 5,),
//                     Obx(()=> loadAgain.value?  selectedItem(context):selectedItem(context)),
//                     Obx(()=>   LoadTag.value? getCustomCategoryList(context):getCustomCategoryList(context)),
//                     Obx(()=>  LoadTag.value? getListOfCat(context):getListOfCat(context)),
//             ], 
//         ),
//       ),

//     );
//   }

// List<Map<String, dynamic>> getthelist()
//  {
//   final lowerSearch = searchController.text.toLowerCase();
//   return  customCategoryList.where((e) {
//     final name = e['name']?.toString().toLowerCase() ?? '';
//     return name.contains(lowerSearch);
//   }).toList().cast<Map<String, dynamic>>();

// }

//  Widget getCustomCategoryList(context){
//   List custom = getthelist();

//     return custom.isEmpty? SizedBox.shrink():Container(
//       width: MediaQuery.of(context).size.width/1.1,
//       height: 70,
//       alignment: Alignment.center ,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: custom.map((e){
//                 return !(e['name'].toString().contains(searchController.text.toLowerCase()))? SizedBox.shrink():InkWell(
//                   onTap: () {
//                     widget.data['category'] = e['name'];
//                     widget.data['subcategory'] = "";
//                     tagName.value = e['name'];
//                     UrlPathImage.value = e['imageUrl'];
//                     loadAgain.value = !loadAgain.value;
//                     customSelections.value = true;
//                   },
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(5),
//                         child: AvatarProfileImage(
//                           url:  (e['imageUrl']),
//                           height: 30,
//                           width: 30,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       textStyle(context: context,text: e['name'], fontsize: 14, fontWeight: FontWeight.bold, c: widget.data['category'] == e['name'] ? AppColors.bg2 : AppColors.primaryColor),
//                     ],
//                   ),
//                 );
//               }).toList(),
//       ),
//     );
//   }


//  Widget topHeader(context){
//     return Padding(
//       padding:  EdgeInsets.symmetric(vertical: Colorcodes.paddingCard/2,horizontal: 8),
//       child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//               InkWell(
//                 onTap: (){
//                     Navigator.pop(context);
//                 },
//                 child: Icon(
//                   CupertinoIcons.clear,
//                    size: 25,
//                 ),
//               ),
//              textStyle(context: context,text:"Tag transaction",fontsize: 18,fontWeight: FontWeight.bold),
//              Row(
//                children: [
              
//               InkWell(
//                   onTap: (){
//                        openShowModalCate(context, nameController,  transactionsHistory[widget.index]['narration']??"");
//                   },
//                   child: Icon(
//                     CupertinoIcons.add,
//                      size: 30,
//                      color: AppColors.bg1,
//                   ),
//                 ),



//                  InkWell(
//                   onTap: (){
//                       //  Change Tag
                 
//                     if(widget.isTag)
//                     {
//                         if(widget.data['category']==null && widget.data['subcategory']==null){
//                             snackBarCalledSignup(context, "Please select a category and subcategory",Colorcodes.red);
//                             return;
//                         }                         
//                         redioButton.forEach((key, id) {
//                         // final index = redioButtonIndex[id];
//                              final index = transactionsHistory.indexWhere((t) => t['_id'] == id);
                 
//                        if (index != null) {
//                           updateTheTagOfTarnsactions(
//                             widget.data['category'],
//                             widget.data['subcategory'],
//                             id,
//                             context,
//                             index,
//                           );
//                           transactionsHistory[index]['category'] = widget.data['category'];
//                           transactionsHistory[index]['subcategory'] = widget.data['subcategory'];
//                           transactionsHistory[index]['needsReview'] = false;
//                         }
//                       });
//                        // getAllTransaction(context);
//                         redioButton.clear();
//                         redioButtonIndex.clear();
//                         tagName.value="";  
//                         showCheckBox.value=false;
//                         transactionsHistory.refresh();
//                         Navigator.pop(context);
//                         Navigator.pop(context);
                 
                       
//                     }
//                     else if(!widget.isGroupTransaction)
//                       {
//                           updateTheTagOfTarnsactions(widget.data['category'], widget.data['subcategory'], widget.data['_id'], context,widget.index);
//                           transactionsHistory[widget.index]['category']=widget.data['category'];
//                           transactionsHistory[widget.index]['subcategory']=widget.data['subcategory'];
//                           transactionsHistory[widget.index]['needsReview']=false;
//                           transactionsHistory.refresh();
//                       }else{
                        
//                           if(widget.data['category']==null && widget.data['subcategory']==Null){
//                               snackBarCalledSignup(context, "Please select a category and subcategory",Colorcodes.red);
//                               return;
//                           }
//                           updateTheTagOfTarnsactionsGroup(widget.data['category'], widget.data['subcategory'], widget.data['_id'], context,widget.index);
                        
//                       }
                 
                 
//                   },
//                    child: Icon(
//                       CupertinoIcons.checkmark_alt,
//                        size: 30,
//                        color: AppColors.green,
//                     ),
//                  ),
//                ],
//              ),
//           ],
//       ),
//     );
//  }


// List<MapEntry<String, List<String>>> getMatchingCategories(
//     Map<String, List<String>> categories, String searchString) {
//   final lowerSearch = searchString.toLowerCase();

//   return categories.entries
//       .map((entry) {
//         final categoryName = entry.key.toLowerCase();

//         // If the category name matches, return all subcategories
//         if (categoryName.contains(lowerSearch)) {
//           return MapEntry(entry.key, entry.value);
//         }

//         // Otherwise, filter subcategories
//         final matchedSubcategories = entry.value
//             .where((sub) => sub.toLowerCase().contains(lowerSearch))
//             .toList();

//         if (matchedSubcategories.isNotEmpty) {
//           return MapEntry(entry.key, matchedSubcategories);
//         }

//         return null;
//       })
//       .whereType<MapEntry<String, List<String>>>()
//       .toList();
// }




// //  Widget getListOfCat(context){
// Widget getListOfCat(BuildContext context)
// {
//     List<MapEntry<String, List<String>>> categoryList = getMatchingCategories(categories, searchController.text);

//   return SizedBox(
//     height: MediaQuery.of(context).size.height * 0.6, // Adjust height as needed
//     child: ListView.builder(
//       itemCount: categoryList.length,
//       shrinkWrap: true,
//       padding: EdgeInsets.symmetric(vertical: 5),
//       itemBuilder: (context, index) {
//         var e = categoryList[index];
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//           margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//           // decoration: BoxDecoration(
//           //   borderRadius: BorderRadius.circular(15),
//           //   border: Border.all(
//           //     width: 1,
//           //     color: AppColors.primaryColor,
//           //   ),
//           // ),
//           child: Column(
//             children: [
//               mainCategory(context, e.key, e.value),
//               const SizedBox(height: 10),
//               subCategory(context, e.key, e.value),
//               Divider()
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }

//  Widget mainCategory(context,String s,List subCategories){
    
//      return Row(
//          children: [
//          Obx(()=>   Radio<String>(
//               value: s,
//               groupValue: tagName.value,
//               activeColor: AppColors.primaryColor,
//               onChanged: (value) {
//                   UrlPathImage.value = getIconPath(widget.data['category'].toLowerCase());
//                   customSelections.value = false;
//                   tagName.value = value!;
//                   widget.data['category']=value;
//                   widget.data['subcategory']="";
//                   loadAgain.value=!loadAgain.value;  
//               },
//             )),
//              AvatarProfileImage(
//                      url:  getIconPath(s.toLowerCase()),
//                     height: 30,
//                     width: 30,
//              ),
//              const SizedBox(width: 5,),
//              textStyle(context: context,text:s,fontsize: 13,fontWeight: FontWeight.bold),
          
//          ],
         
//      );
//  }

//   Widget selectedItem(context){
//       return  SlideTransition(
//       position: _animation,
//         child: AnimatedOpacity(
//           duration: Duration(milliseconds: 500),
//           opacity: opacity,
//                     child: Container(
//               child: historyTransactions(widget.data,!widget.isGroupTransaction? widget.data['transactionTimestamp']:widget.data['createdAt'], context),
//                     ),
//                   ),
//       );
//   }

//  Widget subCategory(context,String main,List subCategories){
    
//      return Container( 
//           width: MediaQuery.of(context).size.width,
//           height: 60,
//         child: Center(
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//               children: subCategories.map((e){
//                      return getSubList(context, e,main);
//               }).toList(),
              
//           ),
//         ),
//      );
//  }

//  Widget getSubList(context,s,main){
//       // bool f=data['subcategory']==s;
//       return InkWell(
//         onTap: (){
//              widget.data['category']=main;
//              widget.data['subcategory']=s;
//             tagName.value = main!;
//             customSelections.value = false;
//                UrlPathImage.value = getIconPath(widget.data['category'].toLowerCase());
//              loadAgain.value=!loadAgain.value;

//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 5),
//           child: Column(
//              children: [
//             //     Chip(
//             // avatar: ProfileImage(
//             //   url: BudgetSubCategories.listofSubCategories[s].toString(),
//             // ),
//             // label: textStyle(context: context,text:s,fontsize: widget.data['subcategory']==s?13:11,fontWeight: FontWeight.bold,c: widget.data['subcategory']==s?AppColors.bg2:AppColors.primaryColor),
//             // backgroundColor: AppColors.button,
//             // shape: RoundedRectangleBorder(
//             //   borderRadius: BorderRadius.circular(12),
//             // ),
//             // ),
//                     SizedBox(
//                       height: MediaQuery.sizeOf(context).height/30,
//                       width: MediaQuery.sizeOf(context).width/10,
                      
//                       child: AvatarProfileImage(
//                               url:  BudgetSubCategories.listofSubCategories[s].toString(),
//                               height: 40,
//                               width: 40,
//                       ),
//                     ),
//                     const SizedBox(height: 5,),
//                    Obx(()=> loadAgain.value?
//                      textStyle(context: context,text:s,fontsize: widget.data['subcategory']==s?13:11,fontWeight: FontWeight.bold,c: widget.data['subcategory']==s?AppColors.bg2:AppColors.primaryColor):
//                      textStyle(context: context,text:s,fontsize: widget.data['subcategory']==s?13:11,fontWeight: FontWeight.bold,c: widget.data['subcategory']==s?AppColors.bg2:AppColors.primaryColor)),
//                     const SizedBox(height: 5,),
//              ],
//           ),
//         ),
//       );
//  }

//   Widget historyTransactions(Map<String, dynamic> transaction, String? date,context) {
//   final category = transaction['category']?.toString() ?? 'Uncategorized';
//   final subcategory = transaction['subcategory']?.toString() ?? 'General';
//   final amount =  transaction[ !widget.isGroupTransaction? 'amount' : 'totalAmount']?.toString() ?? '0';
//   final formattedDate = date != null ? formatDate(date) : 'Unknown Date';
  
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       margin: const EdgeInsets.symmetric(vertical: 5),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colorcodes.greyLight, width: 0.6),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             flex: 3,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     margin: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       // color: Colorcodes.black,
//                       border: Border.all(
//                         color: AppColors.primaryColor,
//                         width: .4
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child:Obx(()=> AvatarProfileImage(
//                       url:  UrlPathImage.value ,//: Categories.link +(imageMapForHistory[category.toLowerCase()] ?? 'default_image.png'),
//                       height: 16,
//                       width: 20,
//                     )),
//                   ),
//                 ),
//                 const SizedBox(width: 5),
//                 Expanded(
//                   flex: 2,
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: " $category",
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.w600,
//                             fontSize: 14,
//                             lineHeight: 2.14,
//                             color: AppColors.accentColor,
//                           ),
//                         ),
//                         TextSpan(
//                           text: " ($subcategory)",
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.w400,
//                             fontSize: 12,
//                             lineHeight: 1.14,
//                             color: AppColors.accentColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Column(
//               children: [
//                 textStyle(
//                   text: '₹${formatMoneyIndian(amount.toString())}',
//                   context: context,
//                   fontWeight: FontWeight.bold,
//                   fontsize: 15,
//                 ),
//                 const SizedBox(height: 6),
//                 textStyle(
//                   text: formattedDate,
//                   context: context,
//                   fontWeight: FontWeight.w300,
//                   fontsize: 11,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

 
// }




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/user_chat/openShowModal.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


RxString tagName="".obs;
RxBool loadAgain=false.obs;

class TagShowmodal extends StatefulWidget
{
var data;
int index;
String id;
bool isGroupTransaction=false;
bool isTag=false;
TagShowmodal({ Key? key,this.id="" ,required this.data,required  this.index,this.isGroupTransaction=false,this.isTag=false }) : super(key: key);

  @override
  State<TagShowmodal> createState() => _TagShowmodalState();
}

class _TagShowmodalState extends State<TagShowmodal>with SingleTickerProviderStateMixin {

   late AnimationController _controller;
  late Animation<Offset> _animation;
  double opacity = 1.0;

 TextEditingController nameController=TextEditingController();
 TextEditingController searchController=TextEditingController();

  RxBool customSelections=false.obs;
  RxString UrlPathImage="".obs;

  @override
  void initState() {
    super.initState();
      
       UrlPathImage.value =  getIconPath(widget.data['category'].toLowerCase());
      _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    
    _animation = Tween<Offset>(
      begin: Offset(0, 3),  // Start from below
      end: Offset(0, 0),    // Move to normal position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation
    _controller.forward();
    custom = getthelist();

    // Delay opacity animation
    // Future.delayed(Duration(milliseconds: 1000), () {
    //   setState(() {
    //     opacity = 1.0;
    //   });
    // });
  }

  String getIconPath(String category)
  {

    if(imageMapForHistory.containsKey(category))return Categories.link + imageMapForHistory[category]!;
    return Categories.link + Categories.groceries;

  }

  @override
  Widget build(BuildContext context)
  {
    return Container(

      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height/1.1,
      decoration: BoxDecoration(
        color: Colorcodes.white,
        borderRadius:const BorderRadius.only(
          topLeft:Radius.circular(20), 
          topRight:Radius.circular(20), 
        )
      ),
      child: SingleChildScrollView(
        child: Column(
            children: [
                    topHeader(context),
                    const SizedBox(height: 5,),
                    TextFeildWidget(textEditingController: searchController, heading: "tagSearch", keyBoard: TextInputType.text, lableText: "Search Category",icon: CupertinoIcons.doc_text_search,),
                    const SizedBox(height: 5,),
                    Obx(()=> loadAgain.value?  selectedItem(context):selectedItem(context)),
                   // Obx(()=>   LoadTag.value? getCustomCategoryList(context):getCustomCategoryList(context)),
                    Obx(()=>  LoadTag.value? getListOfCat(context):getListOfCat(context)),
            ], 
        ),
      ),

    );
  }

void callBack(e){
                      widget.data['category'] = e['name'];
                      widget.data['subcategory'] = "Other";
                      tagName.value = e['name'];
                      UrlPathImage.value = e['imageUrl'];
                      loadAgain.value = !loadAgain.value;
                      customSelections.value = true;
}


Widget getCustomCategoryList(BuildContext context) {
  

  if (custom.isEmpty) return SizedBox.shrink();

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textStyle(
          context: context,
          text: "Custom",
          fontsize: 16,
          fontWeight: FontWeight.bold,
          c: AppColors.primaryColor,
        ),
        const SizedBox(height: 5),
        Container(
          height: 50,
          width:MediaQuery.of(context).size.width/1.1,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: custom.map((e) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Radio<String>(
                    value: e['name'],
                    groupValue: tagName.value,
                    activeColor: AppColors.primaryColor,
                    onChanged: (value) {
                      widget.data['category'] = e['name'];
                      widget.data['subcategory'] = "Other";
                      tagName.value = e['name'];
                      UrlPathImage.value = e['imageUrl'];
                      loadAgain.value = !loadAgain.value;
                      customSelections.value = true;
                    },
                  ),
                  AvatarProfileImage(
                    url: e['imageUrl'],
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: textStyle(
                      context: context,
                      text: e['name'],
                      fontsize: 13,
                      fontWeight: FontWeight.bold,
                      c: widget.data['category'] == e['name']
                          ? AppColors.bg2
                          : AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              );
            }).toList(),
          ),
        ),
        Divider(),
      ],
    ),
  );
}


 Widget topHeader(context){
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: Colorcodes.paddingCard/2,horizontal: 8),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              InkWell(
                onTap: (){
                    Navigator.pop(context);
                },
                child: Icon(
                  CupertinoIcons.clear,
                   size: 25,
                ),
              ),
             textStyle(context: context,text:"Tag transaction",fontsize: 18,fontWeight: FontWeight.bold),
             Row(
               children: [
              
              InkWell(
                  onTap: (){
                       openShowModalCate(context, nameController,  transactionsHistory[widget.index]['narration']??"",callBack);
                  },
                  child: Icon(
                    CupertinoIcons.add,
                     size: 30,
                     color: AppColors.bg1,
                  ),
                ),



                 InkWell(
                  onTap: (){
                      //  Change Tag
                 
                    if(widget.isTag)
                    {
                        if(widget.data['category']==null && widget.data['subcategory']==null){
                            snackBarCalledSignup(context,SnackbarData().selectCategoryAndSubcategory,Colorcodes.red);
                            return;
                        }                         
                        redioButton.forEach((key, id) {
                        // final index = redioButtonIndex[id];
                             final index = transactionsHistory.indexWhere((t) => t['_id'] == id);
                 
                       if (index != null) {
                          updateTheTagOfTarnsactions(
                            widget.data['category'],
                            widget.data['subcategory'],
                            id,
                            context,
                            index,
                          );
                          transactionsHistory[index]['category'] = widget.data['category'];
                          transactionsHistory[index]['subcategory'] = widget.data['subcategory'];
                          transactionsHistory[index]['needsReview'] = false;
                        }
                      });
                       // getAllTransaction(context);
                        redioButton.clear();
                        redioButtonIndex.clear();
                        tagName.value="";  
                        showCheckBox.value=false;
                        transactionsHistory.refresh();
                        Navigator.pop(context);
                        Navigator.pop(context);
                 
                       
                    }
                    else if(!widget.isGroupTransaction)
                      {
                          updateTheTagOfTarnsactions(widget.data['category'], widget.data['subcategory'], widget.data['_id'], context,widget.index);
                          transactionsHistory[widget.index]['category']=widget.data['category'];
                          transactionsHistory[widget.index]['subcategory']=widget.data['subcategory'];
                          transactionsHistory[widget.index]['needsReview']=false;
                          transactionsHistory.refresh();
                      }else{
                        
                          if(widget.data['category']==null && widget.data['subcategory']==Null){
                              snackBarCalledSignup(context, SnackbarData().selectCategoryAndSubcategory,Colorcodes.red);
                              return;
                          }
                          updateTheTagOfTarnsactionsGroup(widget.data['category'], widget.data['subcategory'], widget.id, context,widget.index);
                        
                      }

                        getCategoryData();
                 
                 
                  },
                   child: Icon(
                      CupertinoIcons.checkmark_alt,
                       size: 30,
                       color: AppColors.green,
                    ),
                 ),
               ],
             ),
          ],
      ),
    );
 }


List<MapEntry<String, List<String>>> getMatchingCategories(
    Map<String, List<String>> categories, String searchString) {
  final lowerSearch = searchString.toLowerCase();

  return categories.entries
      .map((entry) {
        final categoryName = entry.key.toLowerCase();

        // If the category name matches, return all subcategories
        if (categoryName.contains(lowerSearch)) {
          return MapEntry(entry.key, entry.value);
        }

        // Otherwise, filter subcategories
        final matchedSubcategories = entry.value
            .where((sub) => sub.toLowerCase().contains(lowerSearch))
            .toList();

        if (matchedSubcategories.isNotEmpty) {
          return MapEntry(entry.key, matchedSubcategories);
        }

        return null;
      })
      .whereType<MapEntry<String, List<String>>>()
      .toList();
}




//  Widget getListOfCat(context){
Widget getListOfCat(BuildContext context) {
  List<MapEntry<String, List<String>>> categoryList = getMatchingCategories(categories, searchController.text);

  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.64,
    child: ListView.builder(
      itemCount: categoryList.length + 1, // +1 for custom categories
      shrinkWrap: true,
   //   padding: EdgeInsets.symmetric(vertical: 5),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Obx(() => LoadTag.value ? getCustomCategoryList(context) : getCustomCategoryList(context));
        }
        var e = categoryList[index - 1]; // Adjust index for regular categories
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
         
          child: Column(
            children: [
              mainCategory(context, e.key, e.value),
             // const SizedBox(height: 10),
              subCategory(context, e.key, e.value),
              Divider(),
            ],
          ),
        );
      },
    ),
  );
}
 Widget mainCategory(context,String s,List subCategories){
    
     return Row(
         children: [
         Obx(()=>   Radio<String>(
              value: s,
              groupValue: tagName.value,
              activeColor: AppColors.primaryColor,
              onChanged: (value) {
                  UrlPathImage.value = getIconPath(widget.data['category'].toLowerCase());
                  customSelections.value = false;
                  tagName.value = value!;
                  widget.data['category']=value;
                  widget.data['subcategory']="Other";
                  loadAgain.value=!loadAgain.value;  
              },
            )),
             AvatarProfileImage(
                     url:  getIconPath(s.toLowerCase()),
                    height: 30,
                    width: 30,
             ),
             const SizedBox(width: 5,),
             textStyle(context: context,text:s,fontsize: 13,fontWeight: FontWeight.bold),
          
         ],
         
     );
 }

  Widget selectedItem(context){
      return  SlideTransition(
      position: _animation,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: opacity,
                    child: Container(
                      child: historyTransactions(widget.data, widget.data['transactionTimestamp'], context),
                    ),
             ),
      );
  }

 Widget subCategory(context,String main,List subCategories){
    
     return Container( 
          width: MediaQuery.of(context).size.width,
          height: 60,
        child: Center(
          child: ListView(
            scrollDirection: Axis.horizontal,
              children: subCategories.map((e){
                     return getSubList(context, e,main);
              }).toList(),
              
          ),
        ),
     );
 }

 Widget getSubList(context,s,main){
      // bool f=data['subcategory']==s;
      // bool flag=(widget.data['subcategory']==s &&  widget.data['category']==main);

      return InkWell(
        onTap: (){
             widget.data['category']=main;
             widget.data['subcategory']=s;
            tagName.value = main!;
            customSelections.value = false;
               UrlPathImage.value = getIconPath(widget.data['category'].toLowerCase());
             loadAgain.value=!loadAgain.value;

        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
             children: [
            //     Chip(
            // avatar: ProfileImage(
            //   url: BudgetSubCategories.listofSubCategories[s].toString(),
            // ),
            // label: textStyle(context: context,text:s,fontsize: widget.data['subcategory']==s?13:11,fontWeight: FontWeight.bold,c: widget.data['subcategory']==s?AppColors.bg2:AppColors.primaryColor),
            // backgroundColor: AppColors.button,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(12),
            // ),
            // ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height/30,
                      width: MediaQuery.sizeOf(context).width/10,
                      
                      child: AvatarProfileImage(
                              url:  BudgetSubCategories.listofSubCategories[s].toString(),
                              height: 40,
                              width: 40,
                      ),
                    ),
                    const SizedBox(height: 5,),
                   Obx(()=> loadAgain.value?
                     textStyle(context: context,text:s,fontsize: (widget.data['subcategory']==s &&  widget.data['category']==main)?13:11,fontWeight: FontWeight.bold,c: (widget.data['subcategory']==s &&  widget.data['category']==main)?AppColors.bg2:AppColors.primaryColor):
                     textStyle(context: context,text:s,fontsize: (widget.data['subcategory']==s &&  widget.data['category']==main)?13:11,fontWeight: FontWeight.bold,c: (widget.data['subcategory']==s &&  widget.data['category']==main)?AppColors.bg2:AppColors.primaryColor)),
                    const SizedBox(height: 5,),
             ],
          ),
        ),
      );
 }

  Widget historyTransactions(Map<String, dynamic> transaction, String? date,context) {
  final category = transaction['category']?.toString() ?? 'Uncategorized';
  final subcategory = transaction['subcategory']?.toString() ?? 'General';
  final amount =  transaction[ !widget.isGroupTransaction? 'amount' : 'totalAmount']?.toString() ?? '0';
  final formattedDate = date != null ? formatDate(date) : 'Unknown Date';
  
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colorcodes.greyLight, width: 0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // color: Colorcodes.black,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: .4
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:Obx(()=> AvatarProfileImage(
                      url:  UrlPathImage.value ,//: Categories.link +(imageMapForHistory[category.toLowerCase()] ?? 'default_image.png'),
                      height: 16,
                      width: 20,
                    )),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 2,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: " $category",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w600,
                            fontSize: 14,
                            lineHeight: 2.14,
                            color: AppColors.accentColor,
                          ),
                        ),
                        TextSpan(
                          text: " ($subcategory)",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w400,
                            fontSize: 12,
                            lineHeight: 1.14,
                            color: AppColors.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                textStyle(
                  text: '₹${formatMoneyIndian(amount.toString())}',
                  context: context,
                  fontWeight: FontWeight.bold,
                  fontsize: 15,
                ),
                const SizedBox(height: 6),
                textStyle(
                  text: formattedDate,
                  context: context,
                  fontWeight: FontWeight.w300,
                  fontsize: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 
}


