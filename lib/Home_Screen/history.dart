  import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/hiddenTransaction.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';

Widget historyTransactions(Map<String, dynamic> transaction, String? date, int index,context,[bool hideReview=false]) {
    String logo = transaction['bankLogo']?.toString() ?? "";
    final category = transaction['category']?.toString() ?? 'Uncategorized';
    final subcategory = transaction['subcategory']?.toString() ?? 'General';
    final double amount =double.parse(doubleToFixed((transaction['amount'] ?? 0.0).toString()));
    final isManual = transaction['manualTransaction'] ?? false;
    final formattedDate = date != null
        ? formatWhatsAppDate(convertStringToDateTime(date))
        : 'Date';
    final type = transaction['type']?.toString() ?? '0';
    final narration = transaction['narration'] ?? 'Unnamed Group';
    final id = transaction['_id'] ?? 'Unnamed Group';
    bool isReview = transaction['needsReview'] ?? true;

   if(hideReview && isReview)return SizedBox.shrink();

    List<String> parts = narration.split('/');
    if (parts.isEmpty || parts.length == 1) parts = narration.split('-');
    if (parts.isEmpty || parts.length == 1) parts = narration.split('&');
    if (parts.isEmpty || parts.length == 1) parts = narration.split(' ');

    String nameOfUser = parts.length >= 4
        ? parts[3]
        : parts.length >= 3
            ? parts[2]
            : parts.length >= 2
                ? parts[1]
                : parts[0];

    final amtColor = type == 'CREDIT' ? Colors.green.shade700 : const Color.fromARGB(255, 207, 118, 113);
    final formatAmount = type == 'CREDIT' ? "+₹${formatMoneyIndian(amount.toString())}" : "-₹${formatMoneyIndian(amount.toString())}";
      
    // Responsive scaling with MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 360; // Base width: 360px
    final padding = 16.0 * scaleFactor;
    final margin = 12.0 * scaleFactor;
    final iconSize = 14.0 * scaleFactor; // Smaller icons for simplicity
    final avatarSize = 40.0 * scaleFactor;
    final fontSizeLarge = 14.0 * scaleFactor;
    final fontSizeMedium = 12.0 * scaleFactor;
    final fontSizeSmall = 10.0 * scaleFactor;
    final badgeSize = 20.0 * scaleFactor;

    return GestureDetector(
      onTap: () {
        if (!isManual) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return TransactionDetailsPage(transaction: transaction);
            },
          );
        }
      },
      child: Column(
        children: [

          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: margin, horizontal: margin),
            // padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scaleFactor),
              border:!isReview? null:Border.all(
                color: Colorcodes.red,
                width:  0.5,
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.backgroundColor.withOpacity(0.03),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8 * scaleFactor,
                  offset: Offset(0, 3 * scaleFactor),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              (isManual || isReview) ? reviewTagTransactions(isReview,scaleFactor, isManual, margin, badgeSize, fontSizeSmall,context,index,id):SizedBox(height: padding,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Row(
                    children: [
                      // Icon Container
                      getIconAvtar(avatarSize, category, scaleFactor),
                      // Container(
                      //   width: avatarSize,
                      //   height: avatarSize,
                      //   decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         AppColors.button.withOpacity(0.8),
                      //         Colors.white.withOpacity(0.6),
                      //       ],
                      //       begin: Alignment.topLeft,
                      //       end: Alignment.bottomRight,
                      //     ),
                      //     borderRadius: BorderRadius.circular(12 * scaleFactor),
                      //   ),
                      //   child: Center(
                      //     child: AvatarProfileImage(
                      //       url: Categories.link +
                      //           (imageMapForHistory[category.toLowerCase()] ??
                      //               'default_image.png'),
                      //       height: avatarSize * 0.5,
                      //       width: avatarSize * 0.5,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(width: padding),
                      // Narration and Amount
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Tooltip(
                                  message: narration,
                                  child: Container(
                                    // height: 30,
                                    // color: Colorcodes.appBarColor,
                                    width: MediaQuery.sizeOf(context).width / 3,
                                    child: textStyle(
                                        context: context,
                                        text: nameOfUser,
                                        c: AppColors.accentColor,
                                        fontsize: fontSizeMedium,
                                        fontWeight: FontWeight.w600,
                                        lineHeight: 1.5),
                                  ),
                                ),
                                textStyle(
                                  context: context,
                                  text: formattedDate,
                                  c: AppColors.primaryColor.withOpacity(0.7),
                                  fontsize: fontSizeSmall,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                            textStyle(
                              context: context,
                              text: formatAmount,
                              c: amtColor,
                              fontsize: fontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Row: Category and Actions
                getIconsForHideUpdateSplit(iconSize, padding, category, amount, logo, context, index, subcategory, transaction,isReview,id),
               (isManual || isReview)?SizedBox(height: 0,):SizedBox(height: padding/2,),
              ],
            ),
          ),
          // Manual Badge
          
            
        ],
      ),
    );
  }


   Widget reviewTagTransactions(bool isReview,double scaleFactor,bool isManual,double margin,double badgeSize,double fontSizeSmall,context,int index,String narration_id) {
    return Row(
      mainAxisAlignment: isManual? MainAxisAlignment.spaceBetween:MainAxisAlignment.end,
      children: [
        if (isManual)
            Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4 * scaleFactor,
                    offset: Offset(2 * scaleFactor, 2 * scaleFactor),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeSmall * 0.8,
                  ),
                ),
              ),
            ),

      if (isReview)  
       Container(         
         padding: EdgeInsets.symmetric(horizontal: 14,vertical: 6),
         decoration: BoxDecoration(
           color: Colorcodes.red,
            borderRadius: BorderRadius.only(
             topRight: Radius.circular(16 * scaleFactor),
           )),
          child: textStyle(text:"Review",context: context,fontsize: 11,fontWeight: FontWeight.bold,c: Colors.white),  
      ),
      ],
    );
  }




  Widget getIconsForHideUpdateSplit(iconSize,padding,category,amount,logo,context,index,subcategory,transaction,bool isReview,String id)
  {
    // Responsive scaling with MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 360; // Base width: 360px
    final fontSizeMedium = 12.0 * scaleFactor;
    final fontSizeSmall = 10.0 * scaleFactor;
    final badgeSize = 20.0 * scaleFactor;
    
    return  Padding(
                  padding:  EdgeInsets.symmetric(horizontal: padding, vertical: padding/2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category
                      Container(
                        width: MediaQuery.sizeOf(context).width / 3,
                        child: textStyle(
                          context: context,
                          text: category,
                          c: AppColors.accentColor,
                          fontsize: fontSizeMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Action Icons
                isReview?  getTagButton(transaction, index, category,context,id):   Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Hide Transaction
                     logo==""? SizedBox.shrink():
                          Image.network(
                            logo,
                            width: 30,
                            height: 30,
                            fit: BoxFit.fitWidth,
                          ),
                         SizedBox(width: 8 * scaleFactor),
                          Tooltip(
                            message: 'Hide',
                            child: GestureDetector(
                              onTap: () {
                                hideTransaction(
                                    index, true, context, transaction['_id']);
                              },
                              child: Container(
                                padding: EdgeInsets.all(6 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(8 * scaleFactor),
                                ),
                                child: Icon(
                                  Icons.visibility_off_rounded,
                                  color: AppColors.primaryColor,
                                  size: iconSize,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * scaleFactor),
                          // Friends Modal
                          Tooltip(
                            message: 'Split with Friends',
                            child: GestureDetector(
                              onTap: () async {
                                await showCustomFriendsModal(
                                  context,
                                  amount,
                                  false,
                                  category,
                                  subcategory,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(6 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(8 * scaleFactor),
                                ),
                                child: Icon(
                                  Icons.group_add_rounded,
                                  color: AppColors.primaryColor,
                                  size: iconSize,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * scaleFactor),
                          // Tag Action
                          Tooltip(
                            message: 'Tag',
                            child: GestureDetector(
                              onTap: () {
                                tagName.value = category;
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return TagShowmodal(
                                      data: transaction,
                                      index: index,
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(6 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(8 * scaleFactor),
                                ),
                                child: Icon(
                                  Icons.tag_rounded,
                                  color: AppColors.primaryColor,
                                  size: iconSize,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * scaleFactor),
                          // Details Action
                        ],
                      ),
                    ],
                  ),
                );
  }


  Widget getTagButton(transaction, index, category,context,narration_id) {
    return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    InkWell(
                      onTap: ()async{
                          // _showTransactionModal(context, transaction, index);
                         await addTagToTransactions(context,narration_id,false,index);
                      },
                      child: Icon(Icons.close_rounded,
                        color: Colorcodes.red,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 10), 
                    InkWell(
                      onTap: ()
                      {
                        addTagToTransactions(context,narration_id,true,index);
                      },
                      child: Icon(Icons.check,
                        color: Colorcodes.green,
                        size: 30,
                      ),
                    ),
                ],
              );
    
    //  InkWell(
    //   onTap: (){
    //       callTagModal(context, transaction, index, category);
    //   },
    //   child: Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //     child: Container(
    //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    //       decoration: BoxDecoration(
    //         border: Border.all(
    //           color: Colorcodes.red,
    //           width: 0.5, 
    //         ),
    //         borderRadius: BorderRadius.circular(8),
    //       ),
    //       child: Row(
    //         children: [
    //           Icon(
    //             Icons.check_circle,
    //             color: Colorcodes.red,
    //             size: 16,
    //           ),
    //            const SizedBox(width: 2),
    //             textStyle(
    //               context: context,
    //               text: "Tag",
    //               fontsize: 16,
    //               fontWeight: FontWeight.w500,
    //               c : Colorcodes.red,
    //             ),
    //              const SizedBox(width: 2),
    //             //  InkWell(
    //             //       onTap: ()
    //             //       {
    //             //         transaction['needsReview'] = false;
    //             //         addTagToTransactions(transaction['_id'],true,index);
    //             //       },
    //             //       child: Icon(Icons.check,
    //             //         color: Colorcodes.budgetDarkGreen,
    //             //         size: 30,
    //             //       ),
    //             //     ),
    //       ],)
    //     ),
    //   ),
    // );

  }


    void callTagModal(BuildContext context, Map<String, dynamic> transaction,index,category) {
                               tagName.value = category;
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return TagShowmodal(
                                      data: transaction,
                                      index: index,
                                    );
                                  },
            );
  }