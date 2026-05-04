import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import '../backed_connections/apis_connect.dart';
import 'user-controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _AppColors {
  static const bg = Color(0xFFF5F6FA);
  static const surface = Colors.white;
  static const primary = AppColors.appIcon;
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
        style: FontManager().getTextStyle(context,
            fontSize: 12,
            lWeight: FontWeight.w600,
            color: _AppColors.textSecondary,
            letterSpacing: 0.5),
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
                style: FontManager().getTextStyle(context,
                    fontSize: 15,
                    lWeight: FontWeight.w600,
                    color:
                        count == 0 ? _AppColors.textSecondary : Colors.white),
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
                  style: FontManager().getTextStyle(context,
                      fontSize: 16,
                      lWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : avatarColor),
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
                    style: FontManager().getTextStyle(context,
                        fontSize: 14,
                        lWeight: FontWeight.w600,
                        color: _AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    friend["username"] ?? "",
                    style: FontManager().getTextStyle(context,
                        fontSize: 12, color: _AppColors.textSecondary),
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
                style: FontManager().getTextStyle(context,
                    color: Colors.white,
                    fontSize: 13,
                    lWeight: FontWeight.w700),
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
                style: FontManager().getTextStyle(context,
                    fontSize: 14,
                    lWeight: FontWeight.w700,
                    color: _AppColors.textPrimary),
              ),
              Text(
                "Choose View or Contribute for each",
                style: FontManager().getTextStyle(context,
                    fontSize: 12, color: _AppColors.textSecondary),
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
        style: FontManager().getTextStyle(context,
            fontSize: 11,
            lWeight: FontWeight.w700,
            color: _AppColors.textSecondary,
            letterSpacing: 0.8),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Send Invite",
                      style: FontManager().getTextStyle(context,
                          fontSize: 15,
                          lWeight: FontWeight.w600,
                          color: Colors.white),
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
                style: FontManager().getTextStyle(context,
                    fontSize: 16, lWeight: FontWeight.w700, color: avatarColor),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              name,
              style: FontManager().getTextStyle(context,
                  fontSize: 14,
                  lWeight: FontWeight.w600,
                  color: _AppColors.textPrimary),
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
          _toggleChip(context, "View", Icons.visibility_rounded),
          _toggleChip(context, "Contribute", Icons.edit_rounded),
        ],
      ),
    );
  }

  Widget _toggleChip(BuildContext context, String role, IconData icon) {
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
              style: FontManager().getTextStyle(context,
                  fontSize: 12,
                  lWeight: FontWeight.w600,
                  color: isActive ? Colors.white : _AppColors.textSecondary),
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
      style: FontManager().getTextStyle(context,
          fontSize: 17,
          lWeight: FontWeight.w700,
          color: _AppColors.textPrimary,
          letterSpacing: -0.3),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: _AppColors.border),
    ),
  );
}
