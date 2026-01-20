// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';

// import '../../components/shared_utils.dart';

// class TransactionDetailsPage extends StatelessWidget {
//   final TransactionModel transaction;

//   const TransactionDetailsPage({Key? key, required this.transaction})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final formattedDate = transaction.transactionTimestamp != null
//         ? formatWhatsAppDate4(convertStringToDateTime(
//             transaction.transactionTimestamp.toString()))
//         : 'N/A'; 

//     return Scaffold(
//       backgroundColor: Colors.grey[100], // Light background
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: AppColors.backgroundColor,
//         title: Text(
//           'Transaction Details',
//           style: FontManager().getTextStyle(context,
//               lWeight: FontWeight.bold,
//               fontSize: 18,
//               color: AppColors.accentColor),
//         ),
       
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Amount Section
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       '₹${formatMoneyIndian(transaction.amount.toString())}',
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.bold,
//                           fontSize: 36,
//                           color: transaction.type == 'DEBIT'
//                               ? const Color.fromARGB(255, 207, 118, 113)
//                               : Colors.green),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       transaction.type,
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.w500,
//                           fontSize: 16,
//                           color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 30),

//               // Details Card
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.backgroundColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 5,
//                       blurRadius: 10,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildDetailRow(
//                       context: context,
//                       label: 'Transaction ID',
//                       value: transaction.txnId.toString(),
//                     ),
//                     const Divider(height: 24),
//                     _buildDetailRow(
//                       context: context,
//                       label: 'Date & Time',
//                       value: formattedDate,
//                     ),
//                     const Divider(height: 24),
//                     _buildDetailRow(
//                       context: context,
//                       label: 'Narration',
//                       value: transaction.narration,
//                     ),
//                     // Only show Category row if tagged
//                     if (_isCategoryTagged(
//                         transaction.category, transaction.subcategory)) ...[
//                       const Divider(height: 24),
//                       _buildDetailRow(
//                         context: context,
//                         label: 'Category',
//                         value: _formatCategory(
//                             transaction.category, transaction.subcategory),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method to build detail rows
//   Widget _buildDetailRow({
//     required BuildContext context,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: FontManager().getTextStyle(context,
//               lWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: FontManager().getTextStyle(context,
//               lWeight: FontWeight.w500, fontSize: 14, color: AppColors.bg1),
//         ),
//       ],
//     );
//   }

//   // Helper method to format category and subcategory
//   String _formatCategory(dynamic category, dynamic subcategory) {
//     final cat = category?.toString().trim() ?? 'Uncategorized';
//     final subcat = subcategory?.toString().trim() ?? null;

//     if (subcat == null || subcat.isEmpty || subcat == 'Uncategorized') {
//       return cat;
//     }
//     return '$cat - $subcat';
//   }

//   // Helper method to check if category is tagged
//   bool _isCategoryTagged(dynamic category, dynamic subcategory) {
//     final cat = category?.toString().trim() ?? 'Uncategorized';
//     final subcat = subcategory?.toString().trim() ?? 'Uncategorized';
//     return !(cat == 'Uncategorized' && (subcat == 'Uncategorized' || subcat.isEmpty));
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:get/get.dart';
import '../../Constants/app_styles.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/core/app_shadows.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/shared_utils.dart';
import '../../image_service/avatarProfile.dart';


final RxBool excludeCashFlow = false.obs;

class TransactionDetailsPage extends StatelessWidget {
  final TransactionModel transaction;
  final int index;

  const TransactionDetailsPage({Key? key, required this.transaction, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = transaction.transactionTimestamp != null
        ? formatWhatsAppDate4(
            convertStringToDateTime(transaction.transactionTimestamp.toString()))
        : 'N/A';

    final bool isDebit = transaction.type == 'DEBIT';

    return Scaffold(
      backgroundColor: AppColors.border,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            SizedBox(
              height: MediaQuery.of(context).size.height/1.2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ((transaction.isBalanceOut ?? false) && transaction.balanceOut != "₹-1")?
                    Row(
                      children: [
                        _amountSection(context, isDebit),
                         SizedBox(width: AppSizes.w16),
                         const VerticalDashDivider(),
                       SizedBox(width: AppSizes.w16),
                        _balanceOutSection(context, isDebit),
                      ],
                    ):
                    _amountSection(context, isDebit),
                    SizedBox(height: AppSizes.h16),
                    // _locationChips(context),
                     SizedBox(height: AppSizes.h16),
                    _receivedCard(context, formattedDate),
                    SizedBox(height: AppSizes.h20),
                    _moreDetails(context),
                    SizedBox(height: AppSizes.h16),
                    _excludeCashFlow(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.newbg,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child:globalbackArrow(),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Center(
              child: Text(
                "Overview",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.1,
            height: MediaQuery.of(context).size.width * 0.1,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [AppShadows.tabs]
            ),
            child:  AvatarProfileImage(url: HomePageIcons.splitIcon, width: 50, height: 50),
          ),
        ],
      ),
    );
  }

  // ---------------- AMOUNT ----------------
  Widget _amountSection(BuildContext context, bool isDebit) {
    return Column(
      children: [
        Text(
          isDebit
              ? "- ₹${formatMoneyIndian(transaction.amount.toString())}"
              : "+ ₹${formatMoneyIndian(transaction.amount.toString())}",
          style: FontManager().getTextStyle(
            context,
            fontSize: 32,
            lWeight: FontWeight.bold,
            color: isDebit
                ? AppColors.redColor
                : AppColors.primaryColor,
          ),
        ),
         SizedBox(height: AppSizes.h12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.greyCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isDebit ? "Spent" : "Earning",
            style: FontManager().getTextStyle(
              context,
              fontSize: 13,
              lWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
  Widget _balanceOutSection(BuildContext context, bool isDebit) {
    return Column(
      children: [
          
               
          ((transaction.isBalanceOut ?? false) && transaction.balanceOut != "₹-1")?
          Text(
          isDebit
              ? "- ₹${formatMoneyIndian(transaction.balanceOut.toString())}"
              : "+ ₹${formatMoneyIndian(transaction.balanceOut.toString())}",
          style: FontManager().getTextStyle(
            context,
            fontSize: 24,
            lWeight: FontWeight.bold,
            color: isDebit
                ? AppColors.debitColor
                : AppColors.primaryColor,
          ),
        ) : const SizedBox.shrink(),
         SizedBox(height: AppSizes.h16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.greyCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
             "Balanced Out",
            style: FontManager().getTextStyle(
              context,
              fontSize: 13,
              lWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- LOCATION CHIPS ----------------
  Widget _locationChips(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip(context, "Goa", selected: true),
        _chip(context, "Vizag"),
        _chip(context, "Araku"),
      ],
    );
  }

  Widget _chip(BuildContext context, String text,
      {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryColor : AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bg5),
      ),
      child: Text(
        text,
        style: FontManager().getTextStyle(
          context,
          fontSize: 12,
          lWeight: FontWeight.w500,
          color:
              selected ? AppColors.backgroundColor : AppColors.primaryColor,
        ),
      ),
    );
  }

  // ---------------- RECEIVED CARD ----------------
  Widget _receivedCard(BuildContext context, String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow2(context, "Received In",
              transaction.bankName ?? 'N/A'),
          SizedBox(height: AppSizes.h12),
          _infoRow2(context, "On Date ", formattedDate),
        ],
      ),
    );
  }

  // ---------------- MORE DETAILS ----------------
  Widget _moreDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "More Details",
          style: FontManager().getTextStyle(
            context,
            fontSize: 16,
            lWeight: FontWeight.w600,
            color: AppColors.bg1,
          ),
        ),
         SizedBox(height: AppSizes.h10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _infoRow(context, "Transaction ID",
                  transaction.txnId.toString(),
                  copy: true),
                 SizedBox(height: AppSizes.h12),
              
              _infoRow(context, "Narration",
                  transaction.narration),
             SizedBox(height: AppSizes.h12),
              
              _infoRow(context, "Mode", "UPI",
                  trailingIcon: Icons.flash_on),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- EXCLUDE ----------------
  Widget _excludeCashFlow(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.show_chart, color: AppColors.primaryColor),
        SizedBox(width: AppSizes.w12),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: Text(
            "Exclude from Cash Flow",
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              lWeight: FontWeight.w500,
              color: AppColors.accentColor,
            ),
          ),
        ),

        /// ✅ FIXED SWITCH
      Obx(() {
  final bool isExcluded = transactionsHistory[index].isExcluded ?? false;

  return Switch(
    value: isExcluded,
    onChanged: (v) {
      excludeCashFlowTransaction(
        index,
        v,
        context,
        transaction.id!,
      );
      Navigator.pop(context);
    },
    activeColor: AppColors.primaryColor,
    inactiveThumbColor: AppColors.grey,

    inactiveTrackColor: AppColors.grey.withOpacity(0.4),
  );
})

      ],
    ),
  );
}

  // ---------------- COMMON ROW ----------------
  Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    bool copy = false,
    IconData? trailingIcon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.76,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: AppSizes.h4),
              Text(
                value,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w500,
                  color: AppColors.accentColor,
                ),
              ),
            ],
          ),
        ),
        if (copy)
          const Icon(Icons.copy, size: 16),
        if (trailingIcon != null)
          Icon(trailingIcon, size: 16),
      ],
    );
  }

  Widget _infoRow2(
    BuildContext context,
    String label,
    String value, {
    bool copy = false,
    IconData? trailingIcon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
              Text(
                label,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: AppSizes.h4),
              Text(
                value,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w500,
                  color: AppColors.accentColor,
                ),
              ),
            ],
          );
        
       
  }


}

