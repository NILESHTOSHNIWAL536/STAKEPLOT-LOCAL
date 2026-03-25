import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/routes/route_collections.dart';
import 'package:get/get.dart';

import '../../../Constants/app_styles.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';
import '../../../image_service/avatarProfile.dart';
import 'collections_empty_page.dart';
import 'create_collection_data.dart';
import 'create_collection_pages/create_collection_flow.dart';

RxList collectionsList = [].obs;

void getCollections() async {
  try {
    var response = await getDataApiCall(CollectionsRoute.getCollections);

    if (getFlagOfResponse(response)) {
      var data = json.decode(response.body);
      collectionsList.clear();
      collectionsList.addAll(data['data']);
    }
  } catch (e) {
    print(e);
  }
}

Widget buildCollectionsBody(BuildContext context) {
  // TEMP flag – replace with API data later

  getCollections();

  return Obx(() => collectionsList.isNotEmpty
      ? _buildCollectionsList(context)
      : _buildEmptyCollectionsUI(context));
}

Widget _buildCollectionsList(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p8),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CreateCollections(context),
        ),
        Column(
          children: List.generate(collectionsList.length, (index) {
            final item = collectionsList[index];
            final isLast = index == collectionsList.length;

            return _timelineItem(
              context,
              isLast: isLast,
              child: _collectionCard(
                context: context,
                title: item["name"] as String,
                date: item["expiryAt"] as String,
                description: item["description"] as String,
                members: item["members"] as List<String>?,
                amount: item["amount"] ?? "1000" as String?,
              ),
            );
          }),
        ),
      ],
    ),
  );
}

Widget _timelineItem(
  BuildContext context, {
  required Widget child,
  bool isLast = false,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 32,
        child: Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 120,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),

      /// 👇 TAP HANDLER ADDED
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CollectionDetailsPage(
                title: "Kerala Trip", // later pass dynamically
                hasTransactions: true,
              ),
            ),
          );
        },
        child: child,
      ),
    ],
  );
}

Widget _collectionCard({
  required BuildContext context,
  required String title,
  required String date,
  required String description,
  List<String>? members,
  String? amount,
}) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.16,
    width: MediaQuery.of(context).size.width * 0.8,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(AppSizes.p14),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE + DATE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: FontManager().getTextStyle(
                context,
                fontSize: 15,
                lWeight: FontWeight.w600,
                color: AppColors.accentColor,
              ),
            ),
            Text(
              date,
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                color: AppColors.accentColor,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSizes.h6),

        /// DESCRIPTION
        Text(
          description,
          style: FontManager().getTextStyle(
            context,
            fontSize: 12,
            color: AppColors.accentColor,
          ),
        ),

        /// MEMBERS + AMOUNT
        if (members != null) ...[
          SizedBox(height: AppSizes.h10),
          Row(
            children: [
              ...members.map(
                (e) => Container(
                  margin: const EdgeInsets.only(right: AppSizes.p6),
                  padding: const EdgeInsets.all(AppSizes.p6),
                  decoration: const BoxDecoration(
                    color: AppColors.button,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    e,
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 12,
                      color: AppColors.backgroundColor,
                    ),
                  ),
                ),
              ),
              if (amount != null)
                Container(
                  margin: const EdgeInsets.only(left: AppSizes.p8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: AppSizes.p4),
                  decoration: BoxDecoration(
                    color: AppColors.bg5,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Contributed: $amount",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 11,
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _buildEmptyCollectionsUI(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppSizes.h20),

          /// Icon
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // OUTER CIRCLE
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE6E7F0).withOpacity(0.7),
                  ),
                ),

                // MIDDLE CIRCLE
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE6E7F0).withOpacity(0.9),
                  ),
                ),

                // CENTER CIRCLE
                AvatarProfileImage(
                    url: HomePageIcons.noCollection, width: 20, height: 20),
              ],
            ),
          ),

          SizedBox(height: AppSizes.h24),

          Text(
            "No collections yet!",
            style: FontManager().getTextStyle(
              context,
              fontSize: 22,
              lWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: AppSizes.h10),

          Text(
            "Start organizing your finances by creating your first collection — it can be just for you or shared with someone.",
            textAlign: TextAlign.center,
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              lWeight: FontWeight.w400,
              color: AppColors.grey,
            ),
          ),

          SizedBox(height: AppSizes.h30),

          CreateCollections(context)

          /// Create Button
        ],
      ),
    ),
  );
}

Widget CreateCollections(context) {
  return SizedBox(
    width: double.infinity,
    height: MediaQuery.of(context).size.height * 0.06,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: () {
        collectionDraft.name = null;
        collectionDraft.type = null;
        collectionDraft.members = [];
        collectionDraft.roles = {};
        collectionDraft.duration = null;
        collectionDraft.description = null;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateCollectionFlow(),
          ),
        );
      },
      child: Text(
        "+ Create Collection",
        style: FontManager().getTextStyle(
          context,
          fontSize: 16,
          lWeight: FontWeight.w500,
          color: AppColors.backgroundColor,
        ),
      ),
    ),
  );
}
