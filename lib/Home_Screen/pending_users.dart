import 'package:flutter/material.dart';

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
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dues to receive',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  child: const Text(
                    'more',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
                  title: Text(users[index]["name"] ?? "Unknown User"),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Remind now",
                      style: TextStyle(color: Colors.green, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
        title: const Text('Dues to receive'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(users[index]["profilePic"] ??
                  "https://via.placeholder.com/150"),
            ),
            title: Text(users[index]["name"] ?? "Unknown User"),
            trailing: TextButton(
              onPressed: () {},
              child: const Text(
                "Remind now",
                style: TextStyle(color: Colors.green, fontSize: 15),
              ),
            ),
          );
        },
      ),
    );
  }
}



//
