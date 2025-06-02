
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';

Widget showModel(BuildContext context, String id, [bool flag = false,int indexElement=-1]) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    height: MediaQuery.of(context).size.height * 0.55,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Report Content",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
            ],
          ),
        ),
        // Report Options
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: reportOptions.length,
            separatorBuilder: (context2, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context2, index) {
              final option = reportOptions[index];
              return InkWell(
                onTap: () {
                  // Handle report submission with id and flag
                  Navigator.pop(context);
                  // Add your reporting logic here using id and flag
                  reportPost(context, id, option['title'], "report",indexElement);
                 
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['title']!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: option['isDescription'] == true
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: option['isDescription'] == true
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                      ),
                      if (option['subtitle']!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            option['subtitle']!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Cancel Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}