
import 'dart:ui';

import 'package:flutter/material.dart';

import '../create_collection_data.dart';
import 'create_collection_flow.dart';

class StepSelectDuration extends StatefulWidget {
  final VoidCallback onNext;
  const StepSelectDuration({super.key, required this.onNext});

  @override
  State<StepSelectDuration> createState() => _StepSelectDurationState();
}

class _StepSelectDurationState extends State<StepSelectDuration> {
  String? selectedDuration = collectionDraft.duration;

  void select(String value) {
    setState(() {
      selectedDuration = value;
      collectionDraft.duration = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return wrapperCollection(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleCollection(context, "Select Duration"),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => select("Until I change"),
                  child: chipCollection(
                    "Until I change",
                    context,
                    isSelected: selectedDuration == "Until I change",
                  ),
                ),
                GestureDetector(
                  onTap: () => select("3 Months"),
                  child: chipCollection(
                    "3 Months",
                    context,
                    isSelected: selectedDuration == "3 Months",
                  ),
                ),
                GestureDetector(
                  onTap: () => select("6 Months"),
                  child: chipCollection(
                    "6 Months",
                    context,
                    isSelected: selectedDuration == "6 Months",
                  ),
                ),
                GestureDetector(
                  onTap: () => select("1 Year"),
                  child: chipCollection(
                    "1 Year",
                    context,
                    isSelected: selectedDuration == "1 Year",
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          /// ✅ PROCEED ENABLE ONLY AFTER SELECT
          PrimaryButton(
            text: "Proceed",
            onTap: selectedDuration != null ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}

