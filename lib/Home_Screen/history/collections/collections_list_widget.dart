import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:get/get.dart';
import '../../../Constants/app_styles.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';
import '../../../backed_connections/apis_connect.dart';
import '../../../image_service/avatarProfile.dart';
import '../../../model/collections_model.dart';
import 'create_collection_data.dart';
import 'create_collection_pages/create_collection_flow.dart';

/// ------------------------------
/// MAIN
/// ------------------------------
Widget buildCollectionsBody(BuildContext context) {
  collectionsController.getCollections();

  return Obx(() {
    if (collectionsController.collectionsList.isEmpty) {
      return _buildEmptyCollectionsUI(context);
    }

    final allCollections = collectionsController.collectionsList
        .where((e) => e.status.toLowerCase() != "closed")
        .toList();

    final closedCollections = collectionsController.collectionsList
        .where((e) => e.status.toLowerCase() == "closed")
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreateCollections(context),

          const SizedBox(height: 16),

          /// 🔵 ALL COLLECTIONS
          if (allCollections.isNotEmpty) ...[
            _sectionTitle("All Collections"),
            _timelineList(context, allCollections),
          ],

          const SizedBox(height: 20),

          /// ⚫ CLOSED COLLECTIONS
          if (closedCollections.isNotEmpty) ...[
            _sectionTitle("Closed Collections"),
            _timelineList(context, closedCollections),
          ],
        ],
      ),
    );
  });
}

/// ------------------------------
/// SECTION TITLE
/// ------------------------------
Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryColor,
      ),
    ),
  );
}

/// ------------------------------
/// TIMELINE LIST
/// ------------------------------
Widget _timelineList(BuildContext context, List<CollectionModel> list) {
  return Column(
    children: List.generate(list.length, (index) {
      final item = list[index];

      return _timelineItem(
        context,
        item,
        isLast: index == list.length - 1,
        child: _collectionCard(context, item),
      );
    }),
  );
}

/// ------------------------------
/// TIMELINE ITEM
/// ------------------------------
Widget _timelineItem(
  BuildContext context,
  CollectionModel collections, {
  required Widget child,
  bool isLast = false,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppColors.primaryColor,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
          if (!isLast)
            Container(
              width: 2,
              height: 90,
              color: AppColors.primaryColor.withOpacity(0.5),
            ),
        ],
      ),

      const SizedBox(width: 12),

      /// TAP
      Expanded(
        child: GestureDetector(
          onTap: () async {
            await collectionsController.getCollectionById(
                collections.id, context);
          },
          child: child,
        ),
      ),
    ],
  );
}

/// ------------------------------
/// COLLECTION CARD (RESPONSIVE)
/// ------------------------------
Widget _collectionCard(BuildContext context, CollectionModel item) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE + DATE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name,
              style: FontManager().getTextStyle(
                context,
                fontSize: 15,
                lWeight: FontWeight.w600,
                color: AppColors.accentColor,
              ),
            ),
            Text(
              item.expiryAt != null ? formatWhatsAppDate(item.expiryAt!) : "",
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                color: AppColors.accentColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// DESCRIPTION
        Text(
          item.description,
          style: FontManager().getTextStyle(
            context,
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),

        const SizedBox(height: 10),

        /// MEMBERS + AMOUNT (dummy for now)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _memberCircle("A"),
                _memberCircle("B"),
                _memberCircle("C"),
                _memberCircle("+2"),
                const SizedBox(width: 8),
                if (item.totalAmount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "₹${item.totalAmount}",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 11,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              item.type,
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                color: AppColors.accentColor,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// ------------------------------
/// MEMBER CHIP
/// ------------------------------
Widget _memberCircle(String text) {
  return Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.all(8),
    decoration: const BoxDecoration(
      color: AppColors.primaryColor,
      shape: BoxShape.circle,
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
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
