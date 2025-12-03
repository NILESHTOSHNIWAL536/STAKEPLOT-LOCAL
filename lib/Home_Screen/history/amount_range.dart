import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/helper.dart';
import '../../components/shared_utils.dart';

class AmountRangeField extends StatelessWidget {
  const AmountRangeField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colorcodes.white,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
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
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  hintText: 'Enter min amount',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
            // Spacer or line between fields
            Container(
              width: 24,
              height: 2,
              color: Colors.grey[300],
            ),
            // Second TextField
            Expanded(
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
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  hintText: 'Enter max amount',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
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