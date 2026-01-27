import 'package:flutter/material.dart';

import '../../../../Constants/app_styles.dart';
import '../../../../Constants/core/app_padding_sizes.dart';
import '../create_collection_data.dart';
import 'create_collection_flow.dart';

class StepCollectionType extends StatefulWidget {
  final VoidCallback onNext;
  const StepCollectionType({super.key, required this.onNext});

  @override
  State<StepCollectionType> createState() => _StepCollectionTypeState();
}

class _StepCollectionTypeState extends State<StepCollectionType> {
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return wrapperCollection(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleCollection(context, "Select Collection Type"),
          SizedBox(height: AppSizes.h16),
          GestureDetector(
            
             onTap: () {
              selectedType = "personal";
               setState(() {
                 collectionDraft.type = "personal";
              });
  
  },child: cardCollection(context, HomePageIcons.personal, isSelected: selectedType == "personal",)),

          SizedBox(height: AppSizes.h16),
          GestureDetector(
             onTap: () {
              selectedType = "shared";
              setState(() {
                 collectionDraft.type = "shared";
              });
   
  },
            child: cardCollection(context, HomePageIcons.shared, isSelected: selectedType == "shared",),),
          const Spacer(),
          PrimaryButton(text: "Proceed", onTap: collectionDraft.type == "shared" ? widget.onNext : null
),
        ],
      ),
    );
  }
}

