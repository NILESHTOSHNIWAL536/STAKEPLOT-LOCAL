import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/repository/autopay_repository.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';

enum AutoPayStep { selectDate, confirm }

class CreateAutoPayFromTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const CreateAutoPayFromTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<CreateAutoPayFromTransactionScreen> createState() =>
      _CreateAutoPayFromTransactionScreenState();
}

class _CreateAutoPayFromTransactionScreenState
    extends State<CreateAutoPayFromTransactionScreen> {
  AutoPayStep currentStep = AutoPayStep.selectDate;

  int? selectedDay;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbg,
      appBar: AppBar(
        backgroundColor: AppColors.newbg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accentColor),
          onPressed: () {
            if (currentStep == AutoPayStep.selectDate) {
              Navigator.pop(context);
            } else {
              setState(() {
                currentStep = AutoPayStep.selectDate;
              });
            }
          },
        ),
        title: Text(
          currentStep == AutoPayStep.confirm
              ? "Confirm Autopay"
              : "Select Due Date",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 18,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p26),
        child: _buildCurrentStep(),
      ),
    );
  }

  /// ---------------- STEP SWITCH ----------------
  Widget _buildCurrentStep() {
    switch (currentStep) {
      case AutoPayStep.selectDate:
        return _selectDateUI();
      case AutoPayStep.confirm:
        return _confirmUI();
    }
  }

  /// ---------------- TRANSACTION CARD ----------------
  Widget _transactionCard({bool showDetails = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.transactionCardShadow,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.transaction.narration,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.accentColor,
                ),
              ),
              Text(
                "₹${widget.transaction.amount}",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 16,
                  color: AppColors.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.h8),
          if (showDetails && selectedDay != null)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "Due Date:",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.greyCard,
                ),
              ),
              Text(
                "${selectedDay}th of every month",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.accentColor,
                ),
              ),
            ])
        ],
      ),
    );
  }

  /// ---------------- STEP 1 : SELECT DATE ----------------
  Widget _selectDateUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _transactionCard(),
        SizedBox(height: AppSizes.h20),
        Text("Select day of the month for payment",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w400,
              fontSize: 12,
              color: AppColors.accentColor,
            )),
        SizedBox(height: AppSizes.h12),
        GridView.builder(
          shrinkWrap: true,
          itemCount: 31,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final day = index + 1;
            final isSelected = selectedDay == day;

            return GestureDetector(
              onTap: () => setState(() => selectedDay = day),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.greyCard,
                  ),
                ),
                child: Text("$day",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: isSelected
                          ? AppColors.backgroundColor
                          : AppColors.accentColor,
                    )),
              ),
            );
          },
        ),
        const Spacer(),
        _actionButton(
          text: "Continue",
          enabled: selectedDay != null,
          onTap: () {
            setState(() {
              currentStep = AutoPayStep.confirm;
            });
          },
        ),
      ],
    );
  }

  Widget _confirmUI() {
    return Column(
      children: [
        _transactionCard(showDetails: true),
        SizedBox(height: AppSizes.h30),
        _actionButton(
          text: "Confirm Autopay",
          enabled: !isSaving,
          onTap: () async {
            setState(() => isSaving = true);
            final success = await createAutoPayFromTransaction(
              widget.transaction.id,
              dueDay: selectedDay,
            );
            if (!mounted) return;
            setState(() => isSaving = false);
            snackBarCalled(
              context,
              success
                  ? "Autopay added for next month"
                  : "Failed to add autopay",
            );
            if (success) Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  /// ---------------- COMMON BUTTON ----------------
  Widget _actionButton({
    required String text,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? AppColors.primaryColor : Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: enabled ? onTap : null,
        child: isSaving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 14,
                  color: enabled ? AppColors.backgroundColor : AppColors.grey,
                )),
      ),
    );
  }
}
