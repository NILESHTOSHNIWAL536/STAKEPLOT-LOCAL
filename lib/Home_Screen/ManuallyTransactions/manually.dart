
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

import '../../image_service/avatarProfile.dart';


class Manualtransaction extends StatefulWidget {
  const Manualtransaction({super.key});

  @override
  State<Manualtransaction> createState() => _ManualtransactionState();
}

class _ManualtransactionState extends State<Manualtransaction> {
  @override
  void initState() {
    super.initState();
    getCustomCategory(context);
  }

  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width / 0.8,
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AvatarProfileImage(
                url: HomePageIcons.manualTransaction,
                height: 24,
                width: 24,
              ),
              SizedBox(width: MediaQuery.of(context).size.width / 52),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(HomepageStringsDart().manualTransaction,
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w600,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: AppColors.accentColor)),
                    const SizedBox(height: 8),
                    Container(
                        decoration: BoxDecoration(
                                  color: AppColors.button,
                                 // borderRadius: BorderRadius.circular(16)
                                  ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              isDebit = false;
                              showCustomModal(context,isDebit);
                           },
                            child: Container(
                              height: Colorcodes.paddingSize * 1.5,
                              width: Colorcodes.paddingSize * 3,
                              
                              child: Center(
                                child: Text(HomepageStringsDart().cashIn,
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: AppColors.primaryColor)),
                              ),
                            ),
                          ),
                         Container(
                            width: 0.5, // Width of the divider
                            height: Colorcodes.paddingSize * 1.2, // Match the height of the buttons
                            color: AppColors.accentColor, // Color of the divider
                          ),
                          InkWell(
                            onTap: () {
                              isDebit = true;
                              showCustomModal(context,isDebit);
                            },
                            child: Container(
                              height: Colorcodes.paddingSize * 1.5,
                              width: Colorcodes.paddingSize * 3,
                             
                              child: Center(
                                child: Text(HomepageStringsDart().cashOut,
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: AppColors.primaryColor)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          AvatarProfileImage(
            url: LikeComment.manualTransaction,
            height: 10,
            width: 14,
          )
        ],
      ),
    );
  }
}

void showCustomModal(BuildContext context, bool isDebit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.mt,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (BuildContext context) {
      return SafeArea(
          child: ModalContent(isDebit)); // Use the modal widget here
    },
  );
}

