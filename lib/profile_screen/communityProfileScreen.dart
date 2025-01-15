import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CommunityProfileScreen extends StatefulWidget {
  const CommunityProfileScreen({super.key});

  @override
  State<CommunityProfileScreen> createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityProfileScreen> {
  File? _profileImage;
  File? _coverImage;

  final dummyData = {
    "name": "Rohit Sharma",
    "username": "@rohit45_",
    "followers": 400,
    "following": 1100,
    "posts": "Posts Content",
    "polls": "Polls Content",
    "exploria": "Exploria Content"
  };

  Future<void> _pickImage(ImageSource source, String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (type == "profile") {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Cover and Profile Picture
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Positioned button to edit cover image
                Positioned(
                  top: 20,
                  right: 16,
                  child: TextButton.icon(
                    onPressed: () {
                      _pickImage(ImageSource.gallery, "cover");
                    },
                    label: const Text(
                      'Edit cover',
                      style: TextStyle(color: Colors.blue),
                    ),
                    icon: const Icon(Icons.edit),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage(
                                  'assets/cover_placeholder.jpg'), // Optional placeholder
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery, "profile"),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/profile_placeholder.jpg')
                              as ImageProvider,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            // User Details
            Column(
              children: [
                Text(
                  dummyData['name'].toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dummyData['username'].toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            dummyData['followers'].toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Followers',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          Text(
                            dummyData['following'].toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Following',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs Section with TabController
                DefaultTabController(
                  length: 3, // Number of tabs
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(text: 'Posts'),
                          Tab(text: 'Polls'),
                          Tab(text: 'Exploria'),
                        ],
                      ),
                      SizedBox(
                        height: 300, // Adjust as needed for TabBarView
                        child: TabBarView(
                          children: [
                            Center(child: Text(dummyData['posts'].toString())),
                            Center(child: Text(dummyData['polls'].toString())),
                            Center(
                                child: Text(dummyData['exploria'].toString())),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
