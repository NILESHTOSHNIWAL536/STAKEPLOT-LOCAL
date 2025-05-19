

// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/loader.dart';
// import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
// import 'package:get/get.dart';

// class GroupTransactions extends StatefulWidget 
// {
// const GroupTransactions({ Key? key }) : super(key: key);

//   @override
//   State<GroupTransactions> createState() => _GroupTransactionsState();
// }

// class _GroupTransactionsState extends State<GroupTransactions> {

//  @override
//   void initState() {
//     super.initState();
//     getGroupTransactions();
//   }

//   @override
//   Widget build(BuildContext context){
//     return Container(
//          child: Obx(()=>!setGroupTransactions.value?  Spinner(size: 30,):getGroupItemList()),
//      );
//   }


//   Widget getGroupItemList(){

//     return groupTransactionList.isEmpty? textStyle(context: context,text: "No grouped similar transactions Found",c:AppColors.primaryColor,fontsize: 12,fontWeight: FontWeight.bold ):Container(
//       width: MediaQuery.of(context).size.width,
//       child: ListView.builder(
//         itemCount: groupTransactionList.length,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemBuilder: (context, index) {
//           var transaction = groupTransactionList[index];
//           return InkWell(
//             onTap: () {
//               removedGrpItemsList.clear();
//               lengthOfTransactions.value=false;
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) {
//                   return Container(
//                      width: MediaQuery.of(context).size.width,
//                     child: Column(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 4,
//                           margin: EdgeInsets.symmetric(vertical:  MediaQuery.of(context).size.width * 0.04),
//                           decoration: BoxDecoration(
//                             color: AppColors.bg1,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: (){
//                             if(lengthOfTransactions.value){
//                                 return;
//                             }
//                              showModalBottomSheet(
//                                 context: context,
//                                 isScrollControlled: true,
//                                 shape: const RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//                                 ),
//                                 builder: (context) {
//                                   return TagShowmodal(
//                                     data: transaction,
//                                     index: index,
//                                   );
//                                 },
//                               );
//                           },
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
                            
//                               Container( 
//                                 alignment: Alignment.centerRight,
//                                 margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
//                                 padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: AppColors.primaryColor, width: 1),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                  child:Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                 const Icon(
//                                       Icons.search,
//                                       color: AppColors.primaryColor,
//                                       size: 22,
//                               ),
//                                 SizedBox(width: 2,),
//                                 textStyle(context: context, text: "Tag", fontsize: 18, c: AppColors.primaryColor, iswrap: true),

//                                  ]),
//                               ),
//                             ],
//                           ),
//                         ),
                      
//                   Obx(()=>  lengthOfTransactions.value ? textStyle(context: context,text: "Nothing to catergorise..😎") :   Expanded(
//                           child: SizedBox(
//                             width: MediaQuery.of(context).size.width,
//                             child: ListView.builder(
//                               itemBuilder: (context, index) {
//                                 var transactionDetails = transaction['transactions'][index];  
//                                 return  Obx(()=> reloadremovedTransactions.value  ? unTagItem(transactionDetails,transaction['transactions'].length):unTagItem(transactionDetails,transaction['transactions'].length));
//                               },
//                               itemCount: transaction['transactions'].length,
//                               shrinkWrap: true,
//                               physics: const BouncingScrollPhysics(),
//                             ),
//                           ),
//                         )),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(vertical: 4),
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.primaryColor
//                 , width: 1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListTile(
//                 title: Text(transaction['narrationPattern']),
//                 subtitle: Text(transaction['count'].toString()),
//                 trailing: Text(transaction['totalAmount'].toString()),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }



// Widget unTagItem(transactionDetails,int len)
// {
//    return  removedGrpItemsList.contains(transactionDetails['_id'])? SizedBox.shrink():Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 5),
//                                   child: Container(
//                                     margin: EdgeInsets.symmetric(vertical: 4,horizontal: 3),
//                                     decoration: BoxDecoration(
//                                       border: Border.all(color: AppColors.primaryColor
//                                       , width: 1),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: ListTile(
//                                       title: textStyle(text:transactionDetails['narration'], c: AppColors.primaryColor, fontsize: 12,context: context,iswrap: true),
//                                       subtitle: Column(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                          children: [
//                                               const SizedBox(height: 2,),
//                                              textStyle(text:transactionDetails['txnId'], c: AppColors.bg1, fontsize: 11,context: context),
//                                              const SizedBox(height: 2,),
//                                              textStyle(text:transactionDetails['amount'], c: AppColors.bg1, fontsize: 11,context: context),
//                                          ],
//                                       ),
//                                       trailing: InkWell(
//                                         onTap: ()
//                                         {
//                                           reloadremovedTransactions.value= !reloadremovedTransactions.value;
//                                           removedGrpItemsList.add(transactionDetails['_id']);
//                                           lengthOfTransactions.value = removedGrpItemsList.length == len;
//                                         },
//                                         child: Icon(Icons.delete_outline_rounded, size: 25, color: Colorcodes.red)),

//                                     ),
//               ),
//          );
// }


// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';

class GroupTransactions extends StatefulWidget {

  const GroupTransactions({Key? key}) : super(key: key);

  @override
  State<GroupTransactions> createState() => _GroupTransactionsState();
}

class _GroupTransactionsState extends State<GroupTransactions>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    getGroupTransactions();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => !setGroupTransactions.value
          ?  Center(child: Spinner(size: 30))
          : _buildGroupList(context),
    );
  }

  // Main group list
  Widget _buildGroupList(BuildContext context) {
    if (groupTransactionList.isEmpty) return _buildEmptyState(context);

    return FadeTransition(
      opacity: _animationController!.drive(CurveTween(curve: Curves.easeIn)),
      child: ListView.builder(
        itemCount: groupTransactionList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemBuilder: (context, index) {
          var transaction = groupTransactionList[index];
          return _buildGroupCard(context, transaction, index);
        },
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_off_rounded,
            size: 70,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 20),
          textStyle(
            context: context,
            text: "No Groups Yet!",
            c: AppColors.accentColor,
            fontsize: 20,
            fontWeight: FontWeight.bold,
          ),
          
        ],
      ),
    );
  }

  // Group card
  Widget _buildGroupCard(BuildContext context, Map<String, dynamic> transaction, int index) {
    final narration = transaction['narrationPattern'] ?? 'Unnamed Group';
    final count = transaction['count']?.toString() ?? '0';
    final totalAmount = transaction['totalAmount']?.toString() ?? '0';

    return GestureDetector(
      onTap: () => _showTransactionModal(context, transaction, index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundColor.withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items with equal spacing
          children: [
            // Icon container
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Text details
                Container(
                 
                  width: MediaQuery.sizeOf(context).width/2.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     // ... existing code ...
                      Tooltip(
                        message: narration, // Full text to show on hover
                        child: textStyle(
                          context: context,
                          text: narration,
                          c: AppColors.accentColor,
                          fontsize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
// ... existing code ...
                      const SizedBox(height: 6),
                      textStyle(
                        context: context,
                        text: '$count transactions',
                        c: AppColors.primaryColor.withOpacity(0.8),
                        fontsize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          //  const SizedBox(width: 16),
            // Amount
            textStyle(
              context: context,
              text: '₹${formatMoneyIndian(totalAmount)}',
              c: Colors.green.shade700,
              fontsize: 14,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  // Improved modal
  void _showTransactionModal(
      BuildContext context, Map<String, dynamic> transaction, int index) {
    removedGrpItemsList.clear();
    lengthOfTransactions.value = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.7,
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal handle and header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Spacer for alignment
                  textStyle(
                    context: context,
                    text: "Group Transactions",
                    c: AppColors.accentColor,
                    fontsize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(modalContext),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Tag button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: lengthOfTransactions.value
                      ? null
                      : () {
                           transaction['transactions'][0]['totalAmount']=transaction['totalAmount']??0;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => TagShowmodal(
                              data: transaction['transactions'][0] , //widget.data[0]["transactions"]
                              index: index,
                              isGroupTransaction: true,
                              id: transaction['_id'],
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.tag_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        textStyle(
                          context: context,
                          text: "Tag Group",
                          c: Colors.white,
                          fontsize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Transaction list
              Obx(
                () => lengthOfTransactions.value
                    ? SizedBox(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.green,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            textStyle(
                              context: context,
                              text: "All Cleared!",
                              c: AppColors.accentColor,
                              fontsize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(modalContext).size.height * 0.51,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: transaction['transactions'].length,
                          itemBuilder: (context, idx) {
                            var details = transaction['transactions'][idx];
                            return _buildUnTagItem(context, details, transaction);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Un-tag item
  Widget _buildUnTagItem(
      BuildContext context, dynamic transactionDetails, Map<String, dynamic> transaction) {
    return Obx(
      () => removedGrpItemsList.contains(transactionDetails['_id'])
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.backgroundColor.withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ... existing code ...
                      Tooltip(
                        message: transactionDetails['narration'] ?? 'Unnamed', // Full text to show on hover
                        child: textStyle(
                          context: context,
                          text: transactionDetails['narration'] ?? 'Unnamed',
                          c: AppColors.accentColor,
                          fontsize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
// ... existing code ...
                      
                          const SizedBox(height: 6),
                          textStyle(
                            context: context,
                            text: transactionDetails['txnId'] ?? 'No ID',
                            c: AppColors.accentColor.withOpacity(0.7),
                            fontsize: 12,
                          ),
                         
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              textStyle(
                                context: context,
                                text: '₹${formatMoneyIndian(transactionDetails['amount'].toString())}',
                                c: Colors.green.shade700,
                                fontsize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                                const SizedBox(width: 10),
                               textStyle(
                                context: context,
                                text:formatWhatsAppDate(convertStringToDateTime(transactionDetails['transactionTimestamp'])),
                                c: AppColors.accentColor.withOpacity(0.7),
                                fontsize: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Delete button
                    GestureDetector(
                      onTap: () {
                        reloadremovedTransactions.value =
                            !reloadremovedTransactions.value;
                        removedGrpItemsList.add(transactionDetails['_id']);
                        lengthOfTransactions.value =
                            removedGrpItemsList.length ==
                                transaction['transactions'].length;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colorcodes.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_rounded,
                          color: Colorcodes.red,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
