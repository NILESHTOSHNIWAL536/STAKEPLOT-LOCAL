import 'package:flutter/material.dart';

import '../../../../Constants/core/app_padding_sizes.dart';
import '../create_collection_data.dart';
import 'create_collection_flow.dart';

class StepCollectionName extends StatelessWidget {
  final VoidCallback onNext;
  const StepCollectionName({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return wrapperCollection(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleCollection(context, "Collection Name"),
           SizedBox(height: AppSizes.h8),
          inputCollection("Enter collection name", context),
          const Spacer(),
          PrimaryButton(
  text: "Proceed",
  onTap: (collectionDraft.name?.isNotEmpty == true) ? onNext : null,
),

        ],
      ),
    );
  }
}

