import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Home_Screen/history/collections/collection_setting.dart';
import '../Home_Screen/history/collections/create_collection_pages/collection_people_selector.dart';
import '../backed_connections/apis_connect.dart';

class InviteMembersScreen extends StatefulWidget {
  final String collectionId;

  const InviteMembersScreen({super.key, required this.collectionId});

  @override
  State<InviteMembersScreen> createState() =>
      _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  final RxList<Map<String, dynamic>> members =
      <Map<String, dynamic>>[].obs;

  final RxSet<String> userIds = <String>{}.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invite Members")),

      body: Column(
        children: [

          /// PEOPLE SELECTOR
          Expanded(
            child: CollectionPeopleSelector(
              members: members,
              userIds: userIds,
              userId: userController.userId.value,
              userName: userController.userName.value,
              userAvatar: userController.avatar.value,
            ),
          ),

          /// BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => ElevatedButton(
                onPressed: members.isEmpty
                    ? null
                    : () async {
                        final friends = buildInviteList(members);

                        await collectionsController.addMembers(
                          collectionId: widget.collectionId,
                          friends: friends,
                        );

                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Send Invite"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}