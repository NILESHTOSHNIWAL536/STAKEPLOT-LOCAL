// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';

// TextEditingController messageController = TextEditingController();
// DateTime? selectedDueDate;

// class LendDetailsModal extends StatefulWidget {
//   final double amount;
//   final Map<String, dynamic> member;
//   final String category;
//   final String subCategory;
//   final VoidCallback onConfirm;

//   const LendDetailsModal({
//     Key? key,
//     required this.amount,
//     required this.member,
//     required this.category,
//     required this.subCategory,
//     required this.onConfirm,
//   }) : super(key: key);

//   @override
//   _LendDetailsModalState createState() => _LendDetailsModalState();
// }

// class _LendDetailsModalState extends State<LendDetailsModal> {
//   Future<void> _selectDueDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(Duration(days: 7)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != selectedDueDate) {
//       setState(() {
//         selectedDueDate = picked;
//       });
//     }
//   }



//   void _validateAndConfirm() {
//     if (messageController.text.trim().isEmpty) {
//       // _showSnackBar('Please enter a message.');
//       snackBarCalledfail(context, "Please enter a message.");
//       return;
//     }
//     if (selectedDueDate == null) {
//       // _showSnackBar('Please select a due date.');
//       snackBarCalledfail(context, "Please select a due date.");
//       return;
//     }
//     Navigator.pop(context, {
//       'message': messageController.text.trim(),
//       'dueDate': selectedDueDate!.toIso8601String(),
//     });
//     widget.onConfirm();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16.0,
//             right: 16.0,
//             top: 16.0,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Lend Details',
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: AppColors.accentColor,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Message Field
//               TextField(
//                 controller: messageController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter a message *',
//                   fillColor: AppColors.button,
//                   filled: true,
//                   hintStyle: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.normal,
//                     fontSize: 16,
//                     color: AppColors.accentColor,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AppColors.accentColor),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AppColors.accentColor),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AppColors.accentColor),
//                   ),
//                 ),
//                 maxLines: 3,
//                 textInputAction:
//                     TextInputAction.done, // Optional: Adds "Done" to keyboard
//                 onSubmitted: (_) =>
//                     _validateAndConfirm(), // Optional: Confirm on keyboard submit
//               ),
//               const SizedBox(height: 16),
//               // Due Date Field
//               GestureDetector(
//                 onTap: () => _selectDueDate(context),
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                   decoration: BoxDecoration(
//                     color: AppColors.button,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.accentColor),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         selectedDueDate == null
//                             ? 'Select Due Date *'
//                             : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.normal,
//                           fontSize: 16,
//                           color: selectedDueDate == null
//                               ? AppColors.accentColor.withOpacity(0.6)
//                               : AppColors.accentColor,
//                         ),
//                       ),
//                       Icon(Icons.calendar_today, color: AppColors.accentColor),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Confirm Button
//               Center(
//                 child: InkWell(
//                   onTap: _validateAndConfirm,
//                   child: getButton(context, 'Confirm'),
//                 ),
//               ),
//               const SizedBox(height: 16), // Extra padding at the bottom
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:intl/intl.dart'; // For formatting date

TextEditingController messageController = TextEditingController();
DateTime? selectedDueDate;

class LendDetailsModal extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> member;
  final String category;
  final String subCategory;
  final VoidCallback onConfirm;

  const LendDetailsModal({
    Key? key,
    required this.amount,
    required this.member,
    required this.category,
    required this.subCategory,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _LendDetailsModalState createState() => _LendDetailsModalState();
}

class _LendDetailsModalState extends State<LendDetailsModal> {
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accentColor, // Header background
              onPrimary: Colors.white, // Header text
              surface: Colors.white, // Background
              onSurface: AppColors.bg1, // Text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentColor, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  void _validateAndConfirm() {
    if (messageController.text.trim().isEmpty) {
      snackBarCalledfail(context, "Please enter a message.");
      return;
    }
    if (selectedDueDate == null) {
      snackBarCalledfail(context, "Please select a due date.");
      return;
    }
    Navigator.pop(context, {
      'message': messageController.text.trim(),
      'dueDate': selectedDueDate!.toIso8601String(),
    });
    widget.onConfirm();
  }

 

  @override
  Widget build(BuildContext context) {
    return Container(
      // Match NewFriendsUi height
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0, // Adjust for keyboard
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lend Details',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.bg1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.bg1),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Summary Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.button.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.bg3,
                            ),
                          ),
                          Text(
                            '\₹${widget.amount.toStringAsFixed(2)}',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.bg1,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'To',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.bg3,
                            ),
                          ),
                          Text(
                            widget.member['name'],
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.bg1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Message Field
                Text(
                  'Message *',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.bg1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Lunch at Cafe',
                    fillColor: AppColors.button.withOpacity(0.5),
                    filled: true,
                    hintStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.normal,
                      fontSize: 14,
                      color: AppColors.bg3,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _validateAndConfirm(),
                ),
                const SizedBox(height: 16),
                // Due Date Field
                Text(
                  'Due Date *',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.bg1,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDueDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.button.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDueDate == null
                              ? 'Select a due date'
                              : DateFormat('dd/MM/yyyy')
                                  .format(selectedDueDate!),
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.normal,
                            fontSize: 14,
                            color: selectedDueDate == null
                                ? AppColors.bg3
                                : AppColors.bg1,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.accentColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Confirm Button
                Center(
                  child: InkWell(
                    onTap: _validateAndConfirm,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}