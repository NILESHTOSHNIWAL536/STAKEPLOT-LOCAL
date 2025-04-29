import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';

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
      initialDate: DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.normal,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.accentColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _validateAndConfirm() {
    if (messageController.text.trim().isEmpty) {
      // _showSnackBar('Please enter a message.');
      snackBarCalledfail(context, "Please enter a message.");
      return;
    }
    if (selectedDueDate == null) {
      // _showSnackBar('Please select a due date.');
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lend Details',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(height: 16),
              // Message Field
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Enter a message *',
                  fillColor: AppColors.button,
                  filled: true,
                  hintStyle: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accentColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accentColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accentColor),
                  ),
                ),
                maxLines: 3,
                textInputAction:
                    TextInputAction.done, // Optional: Adds "Done" to keyboard
                onSubmitted: (_) =>
                    _validateAndConfirm(), // Optional: Confirm on keyboard submit
              ),
              const SizedBox(height: 16),
              // Due Date Field
              GestureDetector(
                onTap: () => _selectDueDate(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDueDate == null
                            ? 'Select Due Date *'
                            : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: selectedDueDate == null
                              ? AppColors.accentColor.withOpacity(0.6)
                              : AppColors.accentColor,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: AppColors.accentColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Confirm Button
              Center(
                child: InkWell(
                  onTap: _validateAndConfirm,
                  child: getButton(context, 'Confirm'),
                ),
              ),
              const SizedBox(height: 16), // Extra padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
