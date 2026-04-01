import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/collections/trip/screens/trip_dashboard_screen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

import '../../../../Constants/colors.dart';
import '../../../../Constants/core/app_padding_sizes.dart';
import '../../../../Constants/font_manager.dart';
import '../create_collection_data.dart';
import 'create_collection_flow.dart';

class StepOptionalDescription extends StatefulWidget {
  final VoidCallback onNext;

  const StepOptionalDescription({super.key, required this.onNext});

  @override
  State<StepOptionalDescription> createState() =>
      _StepOptionalDescriptionState();
}

class _StepOptionalDescriptionState extends State<StepOptionalDescription> {
  bool _isSubmitting = false;

  /// Build the friends list from collectionDraft roles map
  List<Map<String, dynamic>> _buildFriendsList() {
    final List<Map<String, dynamic>> friends = [];
    collectionDraft.roles.forEach((friendId, role) {
      friends.add({
        "friendId": friendId,
        "role": role.toString().toUpperCase(),
      });
    });
    return friends;
  }

  Future<void> _submit(BuildContext context) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final String? newCollectionId =
          await collectionsController.createCollectionWithMembers(
        name: collectionDraft.name ?? "Untitled",
        type: collectionDraft.type ?? "PERSONAL",
        description: collectionDraft.description?.trim() ?? "",
        expiryAt: collectionDraft.duration,
        friends: _buildFriendsList(),
        context: context,
      );

      if (newCollectionId != null && context.mounted) {
        // Load the new collection's data into the controller
        await collectionsController
            .refreshCollectionData(newCollectionId);

        if (context.mounted) {
          // Navigate to the dashboard, removing all create-flow screens
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const TripDashboardScreen(),
            ),
            (route) => route.isFirst,
          );
        }
      } else if (context.mounted) {
        Get.snackbar(
          "Error",
          "Failed to create collection. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("_submit error: $e");
      if (context.mounted) {
        Get.snackbar(
          "Error",
          "Something went wrong. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                onTap: _isSubmitting
                    ? null
                    : () async {
                        collectionDraft.description = null;
                        await _submit(context);
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
          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(
                  text: "Proceed",
                  onTap: () => _submit(context),
                ),

          SizedBox(height: AppSizes.h12),
        ],
      ),
    );
  }
}
