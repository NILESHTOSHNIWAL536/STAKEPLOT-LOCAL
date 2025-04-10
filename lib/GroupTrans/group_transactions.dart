

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';

class GroupTransactions extends StatefulWidget 
{
const GroupTransactions({ Key? key }) : super(key: key);

  @override
  State<GroupTransactions> createState() => _GroupTransactionsState();
}

class _GroupTransactionsState extends State<GroupTransactions> {

 @override
  void initState() {
    super.initState();
    getGroupTransactions();
  }

  @override
  Widget build(BuildContext context){
    return Container(
         child: Obx(()=>!setGroupTransactions.value?  Spinner(size: 30,):getGroupItemList()),
     );
  }


  Widget getGroupItemList(){

    return groupTransactionList.isEmpty? Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: textStyle(context: context,text: "No grouped similar transactions Found",c:AppColors.primaryColor,fontsize: 12,fontWeight: FontWeight.bold ),
    ):Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemCount: groupTransactionList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var transaction = groupTransactionList[index];
          return InkWell(
            onTap: () {
              removedGrpItemsList.clear();
              lengthOfTransactions.value=false;
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                     width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical:  MediaQuery.of(context).size.width * 0.04),
                          decoration: BoxDecoration(
                            color: AppColors.bg1,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            if(lengthOfTransactions.value){
                                return;
                            }
                             showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                ),
                                builder: (context) {
                                  return TagShowmodal(
                                    data: transaction,
                                    index: index,
                                  );
                                },
                              );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            
                              Container( 
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primaryColor, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                 child:Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                const Icon(
                                      Icons.search,
                                      color: AppColors.primaryColor,
                                      size: 22,
                              ),
                                SizedBox(width: 2,),
                                textStyle(context: context, text: "Tag", fontsize: 18, c: AppColors.primaryColor, iswrap: true),

                                 ]),
                              ),
                            ],
                          ),
                        ),
                      
                  Obx(()=>  lengthOfTransactions.value ? textStyle(context: context,text: "Nothing to catergorise..😎") :   Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                var transactionDetails = transaction['transactions'][index];  
                                return  Obx(()=> reloadremovedTransactions.value  ? unTagItem(transactionDetails,transaction['transactions'].length):unTagItem(transactionDetails,transaction['transactions'].length));
                              },
                              itemCount: transaction['transactions'].length,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                            ),
                          ),
                        )),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor
                , width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(transaction['narrationPattern']),
                subtitle: Text(transaction['count'].toString()),
                trailing: Text(transaction['totalAmount'].toString()),
              ),
            ),
          );
        },
      ),
    );
  }



Widget unTagItem(transactionDetails,int len)
{
   return  removedGrpItemsList.contains(transactionDetails['_id'])? SizedBox.shrink():Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 4,horizontal: 3),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.primaryColor
                                      , width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      title: textStyle(text:transactionDetails['narration'], c: AppColors.primaryColor, fontsize: 12,context: context,iswrap: true),
                                      subtitle: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                              const SizedBox(height: 2,),
                                             textStyle(text:transactionDetails['txnId'], c: AppColors.bg1, fontsize: 11,context: context),
                                             const SizedBox(height: 2,),
                                             textStyle(text:transactionDetails['amount'], c: AppColors.bg1, fontsize: 11,context: context),
                                         ],
                                      ),
                                      trailing: InkWell(
                                        onTap: ()
                                        {
                                          reloadremovedTransactions.value= !reloadremovedTransactions.value;
                                          removedGrpItemsList.add(transactionDetails['_id']);
                                          lengthOfTransactions.value = removedGrpItemsList.length == len;
                                        },
                                        child: Icon(Icons.delete_outline_rounded, size: 25, color: Colorcodes.red)),

                                    ),
              ),
         );
}


}

