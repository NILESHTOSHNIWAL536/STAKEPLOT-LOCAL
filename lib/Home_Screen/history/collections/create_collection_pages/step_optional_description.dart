import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';

import '../../../../Constants/colors.dart';
import '../../../../Constants/core/app_padding_sizes.dart';
import '../../../../Constants/font_manager.dart';
import '../../../../routes/route_collections.dart';
import '../../transactionHistoryScreen.dart';
import '../create_collection_data.dart';
import 'create_collection_flow.dart';

class StepOptionalDescription extends StatelessWidget {
  final VoidCallback onNext;

  const StepOptionalDescription({super.key, required this.onNext});

  /// ---------------- API CALL ----------------
  Future<void> _createCollectionApi(BuildContext context) async {
    try {
      final Map<String, dynamic> body = {
        "name": collectionDraft.name,
        "type": collectionDraft.type.toString().toUpperCase(),
        "expiryAt": "2026-12-31T23:59:59.000Z",
        // "expiryAt": collectionDraft.duration,
        "description": "",
      };

      final List<Map<String, dynamic>> friends = [];

      collectionDraft.roles.forEach((friendId, role) {
        friends.add({
          "friendId": friendId,
          "role": role.toString().toUpperCase(), // IMPORTANT
        });
      });

      /// OPTIONAL DESCRIPTION
      if (collectionDraft.description != null &&
          collectionDraft.description!.trim().isNotEmpty) {
        body["description"] = collectionDraft.description;
      }

      var response =
          await postDataApiCall(CollectionsRoute.createCollection, body);

      if (getFlagOfResponse(response)) {
        var res_data = json.decode(response.body);
        print(res_data["data"]["_id"]);
        var res = await postDataApiCall(
            CollectionsRoute.addMember(res_data["data"]["_id"]), {
          "friends": friends,
        });
        if (getFlagOfResponse(res)) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionHistoryScreen(),
              ));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return wrapperCollection(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Description",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w600,
                ),
              ),

              /// -------- SKIP --------
              InkWell(
                onTap: () async {
                  collectionDraft.description = null; // ensure skip
                  await _createCollectionApi(context);
                  onNext();
                },
                child: Text(
                  "Skip",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 14,
                    lWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSizes.h12),

          /// DESCRIPTION INPUT
          Container(
            height: 140,
            padding: const EdgeInsets.all(AppSizes.p12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              maxLines: null,
              expands: true,
              onChanged: (v) {
                collectionDraft.description = v;
              },
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: "enter description",
                hintStyle: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.accentColor,
                ),
                border: InputBorder.none,
              ),
              style: FontManager().getTextStyle(
                context,
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          ),

          const Spacer(),

          /// -------- PROCEED --------
          PrimaryButton(
            text: "Proceed",
            onTap: () async {
              await _createCollectionApi(context);
              onNext();
            },
          ),
        ],
      ),
    );
  }
}
