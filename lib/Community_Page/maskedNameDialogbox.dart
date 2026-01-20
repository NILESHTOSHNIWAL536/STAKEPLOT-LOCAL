import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/finSpace/marks.dart';

import '../Constants/core/app_padding_sizes.dart';

class MaskedNameDialogBox {
  static  showMaskedNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: AppColors.transparentColor,
          child: _buildDialogContent(context),
        );
      },
    );
  }

  static Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Create a Masked Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.accentColorOpacity,
            ),
          ),
           SizedBox(height: AppSizes.h12),
          // Description
          const Text(
            'Use a masked name to post, like, comment, and more while keeping your identity private.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
           SizedBox(height: AppSizes.h20),
          // Close button
          Row(
            children: [
               TextButton(
                onPressed: () async{  
                  await getMaskedNumber(context);
                   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MaskNameScreen(isupdate: true,)),
                        
                      );},
                child: const Text(
                  'Create ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}