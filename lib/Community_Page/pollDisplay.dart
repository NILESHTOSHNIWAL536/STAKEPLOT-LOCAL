import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/user_chat/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:get/get.dart';

import '../Constants/core/app_padding_sizes.dart';

Widget getQuestionsAndOptions(
  PollModel? e,
  BuildContext context,
  bool flag,
  PostId,
) {
  final colors = context.appColors;
  String id = userController.userId.value;
  List<PollOptionModel> options = e!.options;

  int index = -1;
  String selectedOption = "";
  for (int i = 0; i < options.length; i++) {
    List votesArray = options[i].votes;
    bool vote = votesArray.contains(id);
    if (vote) {
      index = i;
      selectedOption = options[i].option;
      break;
    }
  }
  RxBool myvote = (index != -1).obs;
  RxString selected = selectedOption.obs;
  RxInt totalVotes =
      options.fold<int>(0, (sum, element) => sum + element.votes.length).obs;

  RxList<PollOptionModel> optionsList = <PollOptionModel>[].obs;
  optionsList.addAll(options);

  return Obx(() => Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: optionsList.map((op) {
                final int optionVotes = op.votes.length;
                final double percent =
                    totalVotes.value == 0 ? 0 : optionVotes / totalVotes.value;
                final String percentLabel =
                    "${(percent * 100).round().clamp(0, 100)}%";
                final bool isSelected = op.option == selected.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: myvote.value
                        ? null
                        : () {
                            if (ControllerManagement
                                .userController.maskedName.value
                                .trim()
                                .isEmpty) {
                              MaskedNameDialogBox.showMaskedNameDialog(context);
                              return;
                            }

                            final optionIndex = options.indexOf(op);
                            selected.value = op.option;
                            if (!op.votes.contains(id)) {
                              op.votes.add(id);
                              totalVotes.value++;
                            }
                            votePollInPost(context, PostId, optionIndex);
                            myvote.value = true;
                            optionsList.refresh();
                          },
                    child: Stack(
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 58),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.border,
                              width: isSelected ? 1.4 : 1,
                            ),
                          ),
                        ),
                        if (myvote.value)
                          Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percent.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary.withOpacity(0.16)
                                      : colors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        Container(
                          constraints: const BoxConstraints(minHeight: 58),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: AppSizes.p10),
                          child: Row(
                            children: [
                              // Icon(
                              //   isSelected
                              //       ? Icons.favorite
                              //       : Icons.favorite_border_rounded,
                              //   size: 20,
                              //   color: isSelected
                              //       ? colors.error
                              //       : colors.primary,
                              // ),
                              // const SizedBox(width: AppSizes.w10),
                              Expanded(
                                child: Text(
                                  op.option,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              if (myvote.value) ...[
                                const SizedBox(width: AppSizes.w10),
                                Text(
                                  percentLabel,
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.h8),
            Text(
              "${totalVotes.value} votes",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 12,
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      ));
}
