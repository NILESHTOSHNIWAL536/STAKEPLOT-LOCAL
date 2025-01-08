import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import './colors.dart';

class UserListScreen extends StatelessWidget {
  final List<Map<String, String>> users = [
    {"name": "John Doe", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Jane Smith", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Alice Johnson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Bob Brown", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Charlie Wilson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Emma Watson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "John Doe", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Jane Smith", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Alice Johnson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Bob Brown", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Charlie Wilson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Emma Watson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "John Doe", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Jane Smith", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Alice Johnson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Bob Brown", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Charlie Wilson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Emma Watson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Alice Johnson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Bob Brown", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Charlie Wilson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "Emma Watson", "profilePic": "https://via.placeholder.com/150"},
    {"name": "John Doe", "profilePic": "https://via.placeholder.com/150"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dues to receive',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.accentColor),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the "Show All Users" page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowAllUsersScreen(users: users),
                    ),
                  );
                },
                child: Text('more',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.primaryColor)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(users[index]["profilePic"] ??
                      "https://via.placeholder.com/150"),
                ),
                title: Text(users[index]["name"] ?? "Unknown User",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 16,
                        color: AppColors.accentColor)),
                trailing: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Remind now",
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.primaryColor),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Screen showing all users
class ShowAllUsersScreen extends StatelessWidget {
  final List<Map<String, String>> users;

  const ShowAllUsersScreen({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dues to receive',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.accentColor)),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(users[index]["profilePic"] ??
                  "https://via.placeholder.com/150"),
            ),
            title: Text(users[index]["name"] ?? "Unknown User",
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColors.accentColor)),
            trailing: TextButton(
              onPressed: () {},
              child: Text(
                "Remind now",
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 14,
                    color: AppColors.primaryColor),
              ),
            ),
          );
        },
      ),
    );
  }
}

//
