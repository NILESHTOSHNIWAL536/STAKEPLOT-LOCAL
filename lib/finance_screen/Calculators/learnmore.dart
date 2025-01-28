import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final List<String> howToUseContent; // Content for "How to use the calculator?"
  final List<String> howItWorksContent; // Content for "How it works?"

  const CustomExpansionTile({
    super.key,
    required this.howToUseContent,
    required this.howItWorksContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: const Text("How to use the calculator?"), // Fixed title
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: howToUseContent.map((text) => Text(text)).toList(),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text("How it works?"), // Fixed title
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: howItWorksContent.map((text) => Text(text)).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
