// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import '../backed_connections/apis_connect.dart';
import 'user-controller.dart';

// class InviteSelectUsersScreen extends StatefulWidget {
//   final String collectionId;

//   const InviteSelectUsersScreen({super.key, required this.collectionId});

//   @override
//   State<InviteSelectUsersScreen> createState() =>
//       _InviteSelectUsersScreenState();
// }

// class _InviteSelectUsersScreenState extends State<InviteSelectUsersScreen> {
// final userController = Get.find<UserController>();

// final RxList<Map<String, dynamic>> selectedUsers =
//     <Map<String, dynamic>>[].obs;

// List<Map<String, dynamic>> availableFriends = [];

// @override
// void initState() {
//   super.initState();

//   final allFriends =
//       List<Map<String, dynamic>>.from(userController.friendsList);

//   final members =
//       collectionsController.collectionDetails.value?.members ?? [];

//   final existingIds = members.map((e) => e.userId).toSet();

//   availableFriends =
//       allFriends.where((f) => !existingIds.contains(f["_id"])).toList();
// }

//   bool isSelected(String id) {
//     return selectedUsers.any((e) => e["id"] == id);
//   }

//   void toggleUser(Map<String, dynamic> friend) {
//     final id = friend["_id"];

//     if (isSelected(id)) {
//       selectedUsers.removeWhere((e) => e["id"] == id);
//     } else {
//       selectedUsers.add({
//         "id": id,
//         "name": friend["name"],
//         "role": "VIEW",
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),

//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text("Select Friends"),
//       ),

//       body: ListView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: availableFriends.length,
//         itemBuilder: (context, index) {
//           final friend = availableFriends[index];
//           final selected = isSelected(friend["_id"]);

//           return GestureDetector(
//             onTap: () => toggleUser(friend),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               margin: const EdgeInsets.only(bottom: 10),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: selected ? Colors.blue.shade50 : Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color: selected ? Colors.blue : Colors.grey.shade200,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   /// AVATAR
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.indigo.shade200,
//                     child: Text(
//                       friend["name"][0].toUpperCase(),
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   /// NAME
//                   Expanded(
//                     child: Text(
//                       friend["name"],
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                   /// TOGGLE ICON
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: selected ? Colors.blue : Colors.transparent,
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(
//                         color: selected ? Colors.blue : Colors.grey,
//                       ),
//                     ),
//                     child: selected
//                         ? const Icon(Icons.check, size: 16, color: Colors.white)
//                         : null,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),

//       /// 🔥 STICKY BUTTON
//       bottomNavigationBar: Obx(
//         () => Container(
//           padding: const EdgeInsets.all(16),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//           ),
//           child: ElevatedButton(
//             onPressed: selectedUsers.isEmpty
//                 ? null
//                 : () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => InviteAssignRoleScreen(
//                           users: selectedUsers,
//                           collectionId: widget.collectionId,
//                         ),
//                       ),
//                     );
//                   },
//             style: ElevatedButton.styleFrom(
//               minimumSize: const Size(double.infinity, 50),
//               backgroundColor: Colors.blue,
//             ),
//             child: Text(
//               selectedUsers.isEmpty
//                   ? "Select Users"
//                   : "Next (${selectedUsers.length})",
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class InviteAssignRoleScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> users;
//   final String collectionId;

//   const InviteAssignRoleScreen({
//     super.key,
//     required this.users,
//     required this.collectionId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text("Assign Roles"),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: users.length,
//         itemBuilder: (_, index) {
//           final u = users[index];

//           return Container(
//             margin: const EdgeInsets.only(bottom: 10),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(14),
//               color: Colors.white,
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 18,
//                   child: Text(u["name"][0]),
//                 ),

//                 const SizedBox(width: 10),

//                 Expanded(
//                   child: Text(
//                     u["name"],
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ),

//                 /// ROLE SELECTOR (BETTER THAN DROPDOWN)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: DropdownButton(
//                     value: u["role"],
//                     underline: const SizedBox(),
//                     items: ["VIEW", "CONTRIBUTE"]
//                         .map((e) => DropdownMenuItem(
//                               value: e,
//                               child: Text(e),
//                             ))
//                         .toList(),
//                     onChanged: (val) {
//                       u["role"] = val;
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: () async {
//             final friends = users.map((u) {
//               return {
//                 "friendId": u["id"],
//                 "role": u["role"],
//               };
//             }).toList();

//             await collectionsController.addMembers(
//               collectionId: collectionId,
//               friends: friends,
//             );

//             Navigator.pop(context);
//             Navigator.pop(context);
//           },
//           style: ElevatedButton.styleFrom(
//             minimumSize: const Size(double.infinity, 50),
//           ),
//           child: const Text("Send Invite"),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _AppColors {
  static const bg = Color(0xFFF5F6FA);
  static const surface = Colors.white;
  static const primary = Color(0xFF3D6FFF);
  static const primaryLight = Color(0xFFEEF2FF);
  static const accent = Color(0xFF22C55E);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const chip = Color(0xFFF3F4F6);
  static const avatarBg = Color(0xFFDDE4FF);
  static const avatarText = Color(0xFF3D6FFF);
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 1 — SELECT FRIENDS
// ─────────────────────────────────────────────────────────────────────────────
class InviteSelectUsersScreen extends StatefulWidget {
  final String collectionId;

  const InviteSelectUsersScreen({super.key, required this.collectionId});

  @override
  State<InviteSelectUsersScreen> createState() =>
      _InviteSelectUsersScreenState();
}

class _InviteSelectUsersScreenState extends State<InviteSelectUsersScreen> {
  // Replace with your actual controller references
  // final userController = Get.find<UserController>();
  // final collectionsController = Get.find<CollectionsController>()

  bool _isSelected(String id) => selectedUsers.any((e) => e["id"] == id);

  void _toggleUser(Map<String, dynamic> friend) {
    final id = friend["_id"];
    if (_isSelected(id)) {
      selectedUsers.removeWhere((e) => e["id"] == id);
    } else {
      selectedUsers.add({
        "id": id,
        "name": friend["name"],
        "role": "View",
      });
    }
  }

  // ── Avatar initials color palette ─────────────────────────────────────────
  static const List<Color> _avatarColors = [
    Color(0xFF3D6FFF),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  final userController = Get.find<UserController>();

  final RxList<Map<String, dynamic>> selectedUsers =
      <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> availableFriends = [];

  @override
  void initState() {
    super.initState();

    final allFriends =
        List<Map<String, dynamic>>.from(userController.friendsList);

    final members =
        collectionsController.collectionDetails.value?.members ?? [];

    final existingIds = members.map((e) => e.userId).toSet();

    availableFriends =
        allFriends.where((f) => !existingIds.contains(f["_id"])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: _buildAppBar(context, "Invite Friends"),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSectionLabel("Friends (${availableFriends.length})"),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: availableFriends.length,
              itemBuilder: (context, index) {
                final friend = availableFriends[index];
                return Obx(() => _FriendTile(
                      friend: friend,
                      isSelected: _isSelected(friend["_id"]),
                      avatarColor: _avatarColor(index),
                      onTap: () => _toggleUser(friend),
                    ));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => _buildBottomBar(context)),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: _AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: TextField(
        style: const TextStyle(
          fontSize: 14,
          color: _AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: "Search friends…",
          hintStyle:
              const TextStyle(color: _AppColors.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: _AppColors.textSecondary, size: 20),
          filled: true,
          fillColor: _AppColors.chip,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final count = selectedUsers.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: _AppColors.surface,
        border: Border(top: BorderSide(color: _AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0) ...[
            _SelectedAvatarRow(selectedUsers: selectedUsers),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: count == 0
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InviteAssignRoleScreen(
                            users: selectedUsers,
                            collectionId: widget.collectionId,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.primary,
                disabledBackgroundColor: _AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                count == 0
                    ? "Select Friends to Continue"
                    : "Next → $count Selected",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: count == 0 ? _AppColors.textSecondary : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FRIEND TILE
// ─────────────────────────────────────────────────────────────────────────────
class _FriendTile extends StatelessWidget {
  final Map<String, dynamic> friend;
  final bool isSelected;
  final Color avatarColor;
  final VoidCallback onTap;

  const _FriendTile({
    required this.friend,
    required this.isSelected,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : _AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _AppColors.primary : _AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _AppColors.primary.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? _AppColors.primary
                    : avatarColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  friend["name"][0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : avatarColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend["name"],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    friend["username"] ?? "",
                    style: const TextStyle(
                      fontSize: 12,
                      color: _AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Check box
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? _AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? _AppColors.primary : _AppColors.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELECTED AVATAR ROW (bottom strip)
// ─────────────────────────────────────────────────────────────────────────────
class _SelectedAvatarRow extends StatelessWidget {
  final RxList<Map<String, dynamic>> selectedUsers;
  const _SelectedAvatarRow({required this.selectedUsers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedUsers.length,
        itemBuilder: (_, i) {
          final u = selectedUsers[i];
          return Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: _AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                u["name"][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 2 — ASSIGN ROLES
// ─────────────────────────────────────────────────────────────────────────────
class InviteAssignRoleScreen extends StatefulWidget {
  final RxList<Map<String, dynamic>> users;
  final String collectionId;

  const InviteAssignRoleScreen({
    super.key,
    required this.users,
    required this.collectionId,
  });

  @override
  State<InviteAssignRoleScreen> createState() => _InviteAssignRoleScreenState();
}

class _InviteAssignRoleScreenState extends State<InviteAssignRoleScreen> {
  final Map<String, String> _roles = {};
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    for (final u in widget.users) {
      _roles[u["id"]] = u["role"] ?? "View";
    }
  }

  void _setRole(String id, String role) {
    setState(() {
      _roles[id] = role;
      // Update in the reactive list too
      final idx = widget.users.indexWhere((u) => u["id"] == id);
      if (idx != -1) widget.users[idx]["role"] = role;
    });
  }

  Future<void> _sendInvite(BuildContext context) async {
    setState(() => _sending = true);
    try {
      final friends = widget.users.map((u) {
        return {
          "friendId": u["id"],
          "role": _roles[u["id"]].toString().toUpperCase()
        };
      }).toList();

      await collectionsController.addMembers(
        collectionId: widget.collectionId,
        friends: friends,
      );

      await Future.delayed(
          const Duration(seconds: 1)); // remove this mock delay
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Avatar initials color palette ─────────────────────────────────────────
  static const List<Color> _avatarColors = [
    Color(0xFF3D6FFF),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: _buildAppBar(context, "Assign Roles"),
      body: Column(
        children: [
          _buildHeaderCard(),
          _buildSectionLabel2("Set permission for each friend"),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: widget.users.length,
              itemBuilder: (context, index) {
                final u = widget.users[index];
                final id = u["id"] as String;
                final name = u["name"] as String;
                final role = _roles[id] ?? "View";
                return _RoleTile(
                  name: name,
                  selectedRole: role,
                  avatarColor: _avatarColor(index),
                  onRoleChanged: (r) => _setRole(id, r),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      color: _AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.group_rounded,
                color: _AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.users.length} friend${widget.users.length == 1 ? '' : 's'} selected",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.textPrimary,
                ),
              ),
              const Text(
                "Choose View or Contribute for each",
                style: TextStyle(
                  fontSize: 12,
                  color: _AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel2(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: _AppColors.surface,
        border: Border(top: BorderSide(color: _AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _sending ? null : () => _sendInvite(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: _sending
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Send Invite",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE TILE
// ─────────────────────────────────────────────────────────────────────────────
class _RoleTile extends StatelessWidget {
  final String name;
  final String selectedRole;
  final Color avatarColor;
  final ValueChanged<String> onRoleChanged;

  const _RoleTile({
    required this.name,
    required this.selectedRole,
    required this.avatarColor,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: avatarColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _AppColors.textPrimary,
              ),
            ),
          ),

          // Toggle
          _RoleToggle(
            selected: selectedRole,
            onChanged: onRoleChanged,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE TOGGLE WIDGET  (View / Contribute)
// ─────────────────────────────────────────────────────────────────────────────
class _RoleToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _RoleToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: _AppColors.chip,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleChip("View", Icons.visibility_rounded),
          _toggleChip("Contribute", Icons.edit_rounded),
        ],
      ),
    );
  }

  Widget _toggleChip(String role, IconData icon) {
    final isActive = selected == role;
    return GestureDetector(
      onTap: () => onChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isActive ? Colors.white : _AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              role,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : _AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED APP BAR
// ─────────────────────────────────────────────────────────────────────────────
PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: _AppColors.surface,
    centerTitle: false,
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _AppColors.chip,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 16, color: _AppColors.textPrimary),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: _AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: _AppColors.border),
    ),
  );
}
