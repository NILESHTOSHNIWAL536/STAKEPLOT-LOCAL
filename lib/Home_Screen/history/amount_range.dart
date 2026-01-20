import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/helper.dart';
import '../../components/shared_utils.dart';
import '../../repository/transactions_repository.dart';

class AmountRangeField extends StatelessWidget {
  const AmountRangeField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      width: MediaQuery.of(context).size.width,
      color: AppColors.newbg,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: MediaQuery.sizeOf(context).height / 24,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              
              width: MediaQuery.sizeOf(context).width/2.4,
              child: TextField(
                controller: minController,
                inputFormatters: allowDecimalInput(),
                textInputAction: TextInputAction.done,
                onSubmitted: (c) {
                  if (checkRangeofAmount(context)) {
                    onChanedAutoTransactionStatus(context);
                  }
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  hintText: 'Enter min amount',
                  filled: true,
                  fillColor: AppColors.newbg,
                  
                 
                 enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 0.8,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 1.2,
    ),
  ),

  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 0.8,
    ),
  ),
                  hintStyle: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
            // Spacer or line between fields
            Container(
              width: 24,
              height: 4,
              color: AppColors.filterBorders,
            ),
            // Second TextField
            SizedBox(
              
              width: MediaQuery.sizeOf(context).width/2.4,
              child: TextField(
                controller: maxController,
                inputFormatters: allowDecimalInput(),
                onSubmitted: (c) {
                  if (checkRangeofAmount(context)) {
                    onChanedAutoTransactionStatus(context);
                  }
                },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  hintText: 'Enter max amount',
                  filled: true,
                  fillColor: AppColors.newbg,
                  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 0.8,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 1.2,
    ),
  ),

  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 0.8,
    ),
  ),
                  hintStyle: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}