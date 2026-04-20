import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:get/get.dart';
import '../../../Constants/app_styles.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/core/container_border.dart';
import '../../../Constants/font_manager.dart';
import '../../../backed_connections/apis_connect.dart';
import '../../../controllers/limit-reachedBottomSheet.dart';
import '../../../image_service/avatarProfile.dart';
import '../../../model/collections_model.dart';
import 'create_collection_data.dart';
import 'create_collection_pages/create_collection_flow.dart';
import 'invitations_list.dart';

Widget buildCollectionsBody(BuildContext context) {
  return Obx(() {
    final hasInvitations = collectionsController.invitationsList.isNotEmpty;

    final invitationCount = collectionsController.invitationsList.length;

    return DefaultTabController(
      length: hasInvitations ? 2 : 1,
      child: Column(
        children: [
          /// 🔥 CUSTOM TAB DESIGN
          if (hasInvitations)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    /// COLLECTIONS TAB
                    Tab(
                      child: Text(
                        "Collections",
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 13,
                          lWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    /// INVITATIONS TAB WITH BADGE
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Invitations",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 13,
                              lWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 6),

                          /// 🔴 BADGE
                          if (invitationCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                invitationCount.toString(),
                                style: FontManager().getTextStyle(
                                  context,
                                  fontSize: 10,
                                  color: Colors.white,
                                  lWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// 🔥 CONTENT
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                /// COLLECTIONS TAB
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CollectionsBody(context),
                ),

                /// INVITATIONS TAB
                if (hasInvitations)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: InvitationsList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

Widget CollectionsBody(BuildContext context) {
  /// Call once — controller skips if data already loaded

  return Obx(() {
    if (collectionsController.isLoading.value &&
        collectionsController.collectionsList.isEmpty) {
      return const _LoadingShimmer();
    }

    if (collectionsController.collectionsList.isEmpty) {
      return _buildEmptyCollectionsUI(context);
    }

    final allCollections = collectionsController.collectionsList
        .where((e) => e.status.toLowerCase() != "closed")
        .toList(growable: false);

    final closedCollections = collectionsController.collectionsList
        .where((e) => e.status.toLowerCase() == "closed")
        .toList(growable: false);

    return Container(
      height: MediaQuery.of(context).size.height / 2,
      // color: AppColors.redColor,
            child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CollectionLimitInfo(),
                  const SizedBox(height: 12),
                  CreateCollectionButton(context),
                ],
              ),
            ),
          ),
          if (allCollections.isNotEmpty) ...[
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionTitle(title: "All Collections"),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              sliver: _CollectionSliverList(
                collections: allCollections,
              ),
            ),
          ],
          if (closedCollections.isNotEmpty) ...[
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionTitle(title: "Closed Collections"),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: _CollectionSliverList(
                collections: closedCollections,
              ),
            ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  });
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

class _CollectionLimitInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final remaining = collectionsController.remainingCollectionLimit.value;
      final total = collectionsController.collectionTotalLimit.value;
      final used = collectionsController.usedCollectionCount.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                remaining > 0
                    ? 'You can create $remaining more collection${remaining == 1 ? '' : 's'}'
                    : 'You have reached your collection limit',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 13,
                  lWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$used / $total',
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                lWeight: FontWeight.w600,
                color: remaining > 0 ? AppColors.accentColor : AppColors.redColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// ------------------------------
/// SLIVER LIST (TIMELINE)
/// ------------------------------
class _CollectionSliverList extends StatelessWidget {
  final List<CollectionModel> collections;

  const _CollectionSliverList({required this.collections});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final item = collections[index];
        final isLast = index == collections.length - 1;
        return _TimelineItem(
          key: ValueKey(item.id),
          item: item,
          isLast: isLast,
          isFirst: index == 0,
          isSingle: collections.length == 1,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final CollectionModel item;
  final bool isLast;
  final bool isFirst;
  final bool isSingle;
  const _TimelineItem({
    super.key,
    required this.item,
    required this.isLast,
    required this.isFirst,
    required this.isSingle,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 TIMELINE
          SizedBox(
            width: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// 🔼 TOP LINE
                if (!isFirst || isSingle)
                  Positioned(
                    top: 0,
                    bottom: 9,
                    child: Container(
                      width: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),

                /// 🔽 BOTTOM LINE
                if (!isLast || isSingle)
                  Positioned(
                    top: 9,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),

                /// 🔵 CIRCLE
                Positioned(
                  top: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// 📦 CARD
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await collectionsController.getCollectionById(item.id, context);
              },
              child: _CollectionCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// COLLECTION CARD
/// ------------------------------
class _CollectionCard extends StatelessWidget {
  final CollectionModel item;

  const _CollectionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.status.toLowerCase() == "closed"
            ? AppColors.grey
            : AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + DATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 15,
                    lWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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

          const SizedBox(height: 5),

          /// DESCRIPTION
          Text(
            item.description,
            style: FontManager().getTextStyle(
              context,
              fontSize: 12,
              color: AppColors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          /// MEMBERS + AMOUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (item.type.toLowerCase() == "shared") ...[
                    SizedBox(
                      height: 28,
                      width: item.members.length * 20.0, // ✅ FIX
                      child: Stack(
                        clipBehavior: Clip.none, // ✅ allow overflow if needed
                        children: List.generate(item.members.length, (index) {
                          final member = item.members[index];

                          return Positioned(
                            left: index * 22,
                            child: _MemberCircle(
                              label: member.substring(0, 1).toUpperCase(),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                  SizedBox(
                    width: 30,
                  ),
                  // ...item.members.map((member) => _MemberCircle(
                  //     label: member.substring(0, 2).toUpperCase())),
                  if (item.totalAmount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        " Contributed : ₹${item.totalAmount.toStringAsFixed(0)}",
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 11,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.type,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 11,
                    color: AppColors.primaryColor,
                    lWeight: FontWeight.w500,
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

/// ------------------------------
/// MEMBER CHIP (const-safe)
/// ------------------------------
// class _MemberCircle extends StatelessWidget {
//   final String label;
//   const _MemberCircle({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 4),
//       width: 28,
//       height: 28,
//       decoration: const BoxDecoration(
//         color: AppColors.primaryColor,
//         shape: BoxShape.circle,
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
class _MemberCircle extends StatelessWidget {
  final String label;
  const _MemberCircle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white, // 🔥 important for overlap look
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ------------------------------
/// CREATE COLLECTION BUTTON
/// ------------------------------
class CreateCollectionButton extends StatelessWidget {
  final BuildContext parentContext;
  const CreateCollectionButton(this.parentContext);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          if (collectionsController.hasReachedCollectionLimit) {
            LimitReachedBottomSheet.show(context);
            return;
          }
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
}

class CreateCollectionButtonInRow extends StatelessWidget {
  final BuildContext parentContext;
  const CreateCollectionButtonInRow(this.parentContext);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (collectionsController.hasReachedCollectionLimit) {
          LimitReachedBottomSheet.show(context);
          return;
        }
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
      child: CustomStyledContainer(
        radius: 5.0, // <-- Passing a custom radius
        width: 100,
        height: 36,

        child: Center(
          child: Text(
            "Create",
            style: FontManager().getTextStyle(
              context,
              fontSize: 16,
              lWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------
/// SHIMMER LOADING
/// ------------------------------
class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: List.generate(
              4,
              (i) => _ShimmerCard(shimmerValue: _anim.value),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double shimmerValue;
  const _ShimmerCard({required this.shimmerValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(shimmerValue - 1, 0),
          end: Alignment(shimmerValue + 1, 0),
          colors: const [
            Color(0xFFEEEEEE),
            Color(0xFFE0E0E0),
            Color(0xFFEEEEEE),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

/// ------------------------------
/// EMPTY STATE
/// ------------------------------
Widget _buildEmptyCollectionsUI(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppSizes.h20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE6E7F0).withOpacity(0.7),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE6E7F0).withOpacity(0.9),
                ),
              ),
              AvatarProfileImage(
                  url: HomePageIcons.noCollection, width: 20, height: 20),
            ],
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
          CreateCollectionButton(context),
        ],
      ),
    ),
  );
}

// Backward-compat alias for CreateCollections usage across the app
// ignore: non_constant_identifier_names
Widget CreateCollections(BuildContext context) =>
    CreateCollectionButton(context);
