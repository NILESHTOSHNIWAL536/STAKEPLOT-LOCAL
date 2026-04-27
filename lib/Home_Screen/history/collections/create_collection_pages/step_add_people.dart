import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../backed_connections/apis_connect.dart';
import 'collection_people_selector.dart';
import 'create_collection_flow.dart';

class StepAddPeople extends StatefulWidget {
  final RxList<Map<String, dynamic>> members;
  final RxSet<String> userIds;
  final Function(List<Map<String, dynamic>>) onNext;

  const StepAddPeople({
    super.key,
    required this.members,
    required this.userIds,
    required this.onNext,
  });

  @override
  State<StepAddPeople> createState() => _StepAddPeopleState();
}

class _StepAddPeopleState extends State<StepAddPeople> {
  @override
  void initState() {
    super.initState();
    // Ensure the current user is included in the members list
    userController.fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return wrapperCollection(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CollectionPeopleSelector(
              members: widget.members,
              userIds: widget.userIds,
              userId: userController.userId.value,
              userName: userController.userName.value,
              userAvatar: userController.avatar.value,
            ),
          ),
          const Spacer(),
          Obx(
            () => PrimaryButton(
              text: "Proceed",
              onTap: widget.members.isNotEmpty
                  ? () {
                      widget.onNext(
                          List<Map<String, dynamic>>.from(widget.members));
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
