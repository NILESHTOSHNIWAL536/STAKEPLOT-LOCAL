// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../Constants/colors.dart';
// import '../../../../Constants/core/app_padding_sizes.dart';
// import '../../../../Constants/font_manager.dart';
// import '../../../../backed_connections/apis_connect.dart';

// class CollectionPeopleSelector extends StatelessWidget {
//   final RxList<Map<String, dynamic>> members;
//   final RxSet<String> userIds;

//   final String userId;
//   final String userName;
//   final String userAvatar;

//   CollectionPeopleSelector({
//     super.key,
//     required this.members,
//     required this.userIds,
//     required this.userId,
//     required this.userName,
//     required this.userAvatar,
//   });

//   final RxString search = ''.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final filteredUsers = userController.friendsList.where((f) {
//         final name = f['name'].toString().toLowerCase();
//         return name.contains(search.value.toLowerCase()) &&
//             !userIds.contains(f['_id']);
//       }).toList();

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// ---------------- ADD PEOPLE ----------------
//           Text(
//             "Add people",
//             style: FontManager().getTextStyle(
//               context,
//               fontSize: 14,
//               lWeight: FontWeight.w600,
//             ),
//           ),
//            SizedBox(height: AppSizes.h10),

//           /// SEARCH BAR
//           _searchBar(context),

//           /// SEARCH RESULT CARD
//           if (search.value.isNotEmpty && filteredUsers.isNotEmpty) ...[
//             SizedBox(height: AppSizes.h10),
//             _whiteCard(
//               Column(
//                 children: filteredUsers.map((user) {
//                   return _userRow(
//                     context,
//                     name: user['name'],
//                     onTap: () {
//                       userIds.add(user['_id']);
//                       members.add({
//                         "id": user['_id'],
//                         "name": user['name'],
//                         "avatar": user['avatar'],
//                         "avatarBackGround":
//                             user['avatarBackGround'] ??
//                                 defaultBackGround.value,
//                       });
//                       search.value = '';
//                     },
//                     icon: Icons.add,
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],

//           /// ---------------- ADDED PEOPLE ----------------
//           if (members.isNotEmpty) ...[
//             SizedBox(height: AppSizes.h20),
//             Text(
//               "Added people",
//               style: FontManager().getTextStyle(
//                 context,
//                 fontSize: 14,
//                 lWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: AppSizes.h10),
//             _whiteCard(
//               Column(
//                 children: members.map((member) {
//                   return _userRow(
//                     context,
//                     name: member['name'],
//                     onTap: () {
//                       userIds.remove(member['id']);
//                       members.removeWhere(
//                           (e) => e['id'] == member['id']);
//                     },
//                     icon: Icons.close,
//                     isRemove: true,
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ],
//       );
//     });
//   }

//   /// ================= SEARCH BAR =================
//   Widget _searchBar(BuildContext context) {
//     return Container(
//       height: 48,
//       padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.search, color: Colors.grey),
//           SizedBox(width: AppSizes.w8),
//           Expanded(
//             child: TextField(
//               onChanged: (v) => search.value = v,
//               decoration: const InputDecoration(
//                 hintText: "Search",
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           if (search.value.isNotEmpty)
//             GestureDetector(
//               onTap: () => search.value = '',
//               child: const Icon(Icons.close, size: 18),
//             ),
//         ],
//       ),
//     );
//   }

//   /// ================= WHITE CARD =================
//   Widget _whiteCard(Widget child) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: AppSizes.p6),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundColor,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: child,
//     );
//   }

//   /// ================= USER ROW =================
//   Widget _userRow(
//     BuildContext context, {
//     required String name,
//     required VoidCallback onTap,
//     required IconData icon,
//     bool isRemove = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p6),
//       child: Row(
//         children: [
//           /// AVATAR
//           CircleAvatar(
//             radius: 18,
//             backgroundColor: AppColors.bg3,
//             child: Text(
//               name[0].toUpperCase(),
//               style: FontManager().getTextStyle(
//                 context,
//                 fontSize: 14,
//                 color: AppColors.backgroundColor,
//                 lWeight: FontWeight.w600,
//               ),
//             ),
//           ),

//           SizedBox(width: AppSizes.w12),

//           /// NAME
//           Expanded(
//             child: Text(
//               name,
//               style: FontManager().getTextStyle(
//                 context,
//                 fontSize: 14,
//                 lWeight: FontWeight.w500,
//               ),
//             ),
//           ),

//           /// ACTION ICON
//           GestureDetector(
//             onTap: onTap,
//             child: Container(
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//               child: Icon(
//                 icon,
//                 size: 18,
//                 color: AppColors.primaryColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Constants/colors.dart';
import '../../../../Constants/core/app_padding_sizes.dart';
import '../../../../Constants/font_manager.dart';
import '../../../../backed_connections/apis_connect.dart';

class CollectionPeopleSelector extends StatelessWidget {
  final RxList<Map<String, dynamic>> members;
  final RxSet<String> userIds;

  final String userId;
  final String userName;
  final String userAvatar;

  CollectionPeopleSelector({
    super.key,
    required this.members,
    required this.userIds,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });

  final RxString search = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allUsers = userController.friendsList;

      final query = search.value.toLowerCase();

      /// 🔍 FILTER USERS
      final filtered = allUsers.where((f) {
        final name = f['name'].toString().toLowerCase();
        return name.contains(query);
      }).toList();

      /// ✅ SELECTED USERS (TOP)
      final selectedUsers =
          filtered.where((f) => userIds.contains(f['_id'])).toList();

      /// 👇 REMAINING USERS
      final remainingUsers =
          filtered.where((f) => !userIds.contains(f['_id'])).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            "Add people",
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              lWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppSizes.h10),

          /// SEARCH BAR
          _searchBar(context),

          SizedBox(height: AppSizes.h10),

          /// USER LIST CARD
          _whiteCard(
            Column(
              children: [
                /// 🔥 SELECTED USERS
                if (selectedUsers.isNotEmpty) ...[
                  ...selectedUsers.map((user) {
                    return _userRow(
                      context,
                      name: user['name'],
                      isSelected: true,
                      onTap: () {
                        userIds.remove(user['_id']);
                        members.removeWhere((e) => e['id'] == user['_id']);
                      },
                    );
                  }),
                  const Divider(height: 20),
                ],

                /// 🔥 REMAINING USERS
                ...remainingUsers.map((user) {
                  return _userRow(
                    context,
                    name: user['name'],
                    isSelected: false,
                    onTap: () {
                      userIds.add(user['_id']);

                      members.add({
                        "id": user['_id'],
                        "name": user['name'],
                        "avatar": user['avatar'],
                        "avatarBackGround":
                            user['avatarBackGround'] ?? defaultBackGround.value,
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// ================= SEARCH BAR =================
  Widget _searchBar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          SizedBox(width: AppSizes.w8),
          Expanded(
            child: TextField(
              onChanged: (v) => search.value = v,
              decoration: const InputDecoration(
                hintText: "Search people...",
                border: InputBorder.none,
              ),
            ),
          ),
          if (search.value.isNotEmpty)
            GestureDetector(
              onTap: () => search.value = '',
              child: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }

  /// ================= CARD =================
  Widget _whiteCard(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p6),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  /// ================= USER ROW =================
  Widget _userRow(
    BuildContext context, {
    required String name,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p12, vertical: AppSizes.p6),
      child: Row(
        children: [
          /// AVATAR
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.bg3,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '',
              style: FontManager().getTextStyle(
                context,
                fontSize: 14,
                color: AppColors.backgroundColor,
                lWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(width: AppSizes.w12),

          /// NAME
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

          /// ACTION BUTTON
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.green : AppColors.primaryColor,
                ),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.add,
                size: 18,
                color: isSelected ? Colors.green : AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
