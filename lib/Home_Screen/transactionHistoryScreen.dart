import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:get/get.dart';

final TextEditingController searchController = TextEditingController();
FocusNode focusNodeSearchFeild = FocusNode();


class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final RxList<Map<String, dynamic>> filteredTransactions = RxList<Map<String, dynamic>>([]);
    final ScrollController scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    // Initialize filtered transactions with all transactions
    scrollController.addListener(_onScroll);

  }

void _onScroll() {
    scrollController.addListener(() async{
  
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50)
          {
               getAllTransactionHistory(context, false, false);
          }
    });
  
  }


  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        clearData();
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
       appBar: AppBar(
       // Flat design for a modern look
        title: Text(
      'History',
      style: FontManager().getTextStyle(
        context,
        lWeight: FontWeight.w600, // Slightly bolder for emphasis
        fontSize: 18, // Slightly larger for better readability
        color: AppColors.accentColor,
      ),
        ),
         // Center the title for symmetry
        leading: IconButton(
      icon: Icon(
        Icons.arrow_back_ios, // More refined back icon
        color: AppColors.accentColor,
        size: 24, // Slightly smaller for balance
      ),
      onPressed: (){
        clearData();
        Navigator.pop(context);
      },
      splashRadius: 20, // Smaller splash radius for a subtle effect
        ),
        actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16.0), // Proper spacing
        child: InkWell(
          onTap: ()
          {
              int len=bankAccountLinkedList.length;
            if(len==0){
                 snackBarCalled(context, "No Bank Account Linked Please link your bank account to download the statement.");
            }
            else if(len==1)
            {
               accountIdPdf.value=bankAccountLinkedList[0]['accountId'];
               showModalForPdfDownload(context);
            }
            else
            {
               accountIdPdf.value=bankAccountLinkedList[0]['accountId'];
               showModalForPdfDownloadBankUiCheckBox(context);
            }
          },
          splashColor: AppColors.accentColor.withOpacity(0.2), // Subtle splash effect
          borderRadius: BorderRadius.circular(12), // Rounded ripple effect
          child: Container(
            padding: const EdgeInsets.all(8.0), 
                     decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1), // Added filled color grey
              borderRadius: BorderRadius.circular(16), // Added rounded borders
            ), // Comfortable tap area// Comfortable tap area
          
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.download_for_offline, // Modern, appealing download icon
                  size: 15, // Slightly smaller to balance with text
                  color: AppColors.accentColor,
                ),
                const SizedBox(width: 2), // Spacing between icon and text
                Text(
                  'My Statement',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600, // Semi-bold for readability
                    fontSize: 10, // Compact to fit AppBar
                    color: AppColors.accentColor,
                  ),
                ),
              ])
          ),
        ),
      ),
        ],
       
      ),
      
       body: Column(
          children: [
            Container(
             // height: MediaQuery.of(context).size.height/1.1,
              width: MediaQuery.of(context).size.width/.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.only(left: 12,right:4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                    //  height: MediaQuery.of(context).size.height /5,
                     decoration: BoxDecoration(
                    color: AppColors.bg5,
                    borderRadius: BorderRadius.circular(30),
                    
                  ),
                      child: Column(
                        children: [


                         const SizedBox(height: 4,),
                          Row(
                            children: [
                               getTextFeild(),
                              InkWell(onTap: ()
                              { 
                                 showModalBottomSheet(context: context, builder: (_)=>
                                 Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration:const BoxDecoration(
                                    color: AppColors.bg5,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: filterTransaction(context)
                                  ));
                              }, 
                             child:  Icon(Icons.filter_alt_outlined, 
                             size:  MediaQuery.of(context).size.width/10,
                             color: AppColors.accentColor),) 
                            ],
                          ),
                      
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: getTab(context),
                            ),

                      
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Transaction History
                 Container(
                   height: MediaQuery.sizeOf(context).height/1.38,
                   child: SingleChildScrollView(
                     controller: scrollController,
                     child: transactionsHistoryList(),
                   ),
                 )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 void clearData({bool f=false})
 {
          searchController.clear();
          redioButton.clear();
          redioButtonIndex.clear();
          allOrGroupTransactionsName.value = StringConstant.allTransactions;
          showCheckBox.value=false;
          accountIdPdf.value="-";

       if(f)
       {
          currentPage = 1;
          isLoadingMore.value = false;
          getAllTransaction(context);
       }
 }

  Widget  transactionsHistoryList() {
    return  Obx(() => loadChatdataOnChnage.value
                        ? TransactionHistory(
                            isYearView: isYearView.value,
                            isflag: true,
                            showIcon: false,
                            expandedPage: true,

                          )
                        : TransactionHistory(
                            isYearView: isYearView.value,
                            isflag: true,
                             showIcon: false,
                              expandedPage: true,
                          ));
  }
  
 Widget getTextFeild()
 {
    return Container(
                            width: MediaQuery.of(context).size.width /1.17,
                            height: MediaQuery.of(context).size.width /9,
                            child: TextField(
                              controller: searchController,
                              focusNode: focusNodeSearchFeild,
                              onChanged: (value) {
                                   onChanedAutoTransactionStatus(context);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search transactions',
                                hintStyle:FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColors.likesharecommentCount,
                            ),
                                prefixIcon: const Icon(Icons.search, color: AppColors.accentColor),
                                 suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.accentColor),
                                    onPressed: () {
                                        clearData(f: true);
                                      // Unfocus the search field
                                    },
                                  )
                                : null,
                                filled: true,
                                fillColor: AppColors.bg5,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30), // Changed to 30 for more circular appearance
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder( // Added for the enabled state
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: AppColors.accentColor,), // Border color when enabled
                                ),
                                focusedBorder: OutlineInputBorder( // Added for the focused state
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: AppColors.primaryColor), // Border color when focused
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), 
                              ),
                              style: const TextStyle(color: AppColors.accentColor),
                            ),
                          );
  }

}