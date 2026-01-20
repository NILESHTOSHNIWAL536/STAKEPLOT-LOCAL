import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Constants/colors.dart';
import '../../../../Constants/core/app_padding_sizes.dart';
import '../../../../Constants/font_manager.dart';
import '../create_collection_data.dart';


class StepAssignRoles extends StatefulWidget {
  final RxList<Map<String, dynamic>> members;
  final VoidCallback onNext;

  const StepAssignRoles({
    super.key,
    required this.members,
    required this.onNext,
  });

  @override
  State<StepAssignRoles> createState() => _StepAssignRolesState();
}

class _StepAssignRolesState extends State<StepAssignRoles> {
  /// userId -> role
  final Map<String, String> roles = {};

  @override
  void initState() {
    super.initState();
    // default role = View
    for (var m in widget.members) {
      roles[m['id']] = "View";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SizedBox(height: AppSizes.h20),

          Text(
            "Assign roles",
            style: FontManager().getTextStyle(
              context,
              fontSize: 16,
              lWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppSizes.h16),

          Expanded(
            child: ListView.builder(
              itemCount: widget.members.length,
              itemBuilder: (context, index) {
                final member = widget.members[index];
                final id = member['id'];
                final name = member['name'];

                return _roleRow(context, id, name);
              },
            ),
          ),

          SizedBox(height: AppSizes.h12),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: collectionDraft.roles.length == widget.members.length
    ? widget.onNext
    : null,

              child: Text(
                "Proceed",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  lWeight: FontWeight.w500,
                  color: AppColors.backgroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // ROLE ROW
  Widget _roleRow(BuildContext context, String id, String name) {
    final selectedRole = roles[id];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar commented as requested
          CircleAvatar(
            backgroundColor: AppColors.bg3,
            child: Text(name[0].toUpperCase(), style: FontManager().getTextStyle(
              context,
              fontSize: 16,
              lWeight: FontWeight.w500,
              color: AppColors.backgroundColor,
            ))
          ),

          SizedBox(width: AppSizes.w12),

          Expanded(
            child: Text(
              name,
              style: FontManager().getTextStyle(
                context,
                fontSize: 14,
                lWeight: FontWeight.w500,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roleChip(id, "View"),
                
                _roleChip(id, "Contribute"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // ROLE CHIP
  Widget _roleChip(String id, String role) {
    final isSelected = roles[id] == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          roles[id] = role;
           collectionDraft.roles[id] = role;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        height: MediaQuery.of(context).size.height * 0.04,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryColor : AppColors.border,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            role,
            style: FontManager().getTextStyle(
              context,
              fontSize: 12,
              lWeight: FontWeight.w500,
              color: isSelected
                  ? AppColors.backgroundColor
                  : AppColors.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

