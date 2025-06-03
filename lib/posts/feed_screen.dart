import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/posts/post_card.dart';
import 'package:flutter_application_code_stakeplot/posts/post_model.dart';


class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<PostModel> posts = [];

  @override
  void initState() {
    super.initState();

    _loadSampleData();
  }

  void _loadSampleData() {
    // Sample JSON data converted to PostModel objects
    final sampleJsonData = [
      {
  // "_id": {"\$oid": "67f80fa55adb9f409df11d0b"},
  // "author": {
  //   "id": {"\$oid": "67efec4d91509235e7c77f55"},
  //   "name": "Harish Podishetty",
  //   "avatar": "assets/avatar/menp1.svg",
  //   "avatarBackGround": "#68B2A0"
  // },
   "_id": {"\$oid": "67f00eff91509235e7c7b3ae"},
        "author": {
          "id": {"\$oid": "67f0089491509235e7c79fdb"},
          "name": "Akash Kakularam",
          "avatar": "assets/avatar/menp1.svg",
          "avatarBackGround": "#FFB07A"
        },
  "title": "wyye",
  "description": {
    "message": {
      "pictures": [
        "https://res.cloudinary.com/deus5rcgl/image/upload/v1744310177/public/trxt62tuhulfaezleumd.png",
        "https://res.cloudinary.com/deus5rcgl/image/upload/v1744310180/public/sct5vrwbbubjjnw38afr.png"
      ],
      "place": {
        "name": "eyuueu",
        "location": "eyu7e"
      },
      "budget": [
        {
          "category": "eyye",
          "amount": 36
        }
      ],
      "rating": 4,
      "tripHighlight": "wyye",
      "description": "Ey66e",
      "comments": 0,
      "shares": 0,
      "upvotes": 0
    }
  },
  "image": "https://res.cloudinary.com/deus5rcgl/image/upload/v1744310177/public/trxt62tuhulfaezleumd.png",
  "postType": "explore",
  "isItenary": false,
  "isPoll": false,
  "chartType": "none",
  "comments": 0,
  "upvotes": 1,
  "downvotes": 0,
  "path": " ",
  "reportCount": 0,
  "hideCount": 1,
  "createdAt": {"\$date": "2025-06-02T18:36:21.012Z"},
},
      {
        "_id": {"\$oid": "67f00eff91509235e7c7b3ae"},
        "author": {
          "id": {"\$oid": "67f0089491509235e7c79fdb"},
          "name": "Akash Kakularam",
          "avatar": "assets/avatar/menp1.svg",
          "avatarBackGround": "#FFB07A"
        },
        "title": "Go Karting",
        "description": {
          "message": "It's an amazing experience, had lot of fun with my friends \n\n1. Spending-1500rs\n2. Food-2350rs\n\na costly trip, but worth it 💙😜"
        },
        "image": "https://res.cloudinary.com/deus5rcgl/image/upload/v1743785726/public/aoxqf9dwn83o69pcqqmp.png",
        "postType": "feed",
        "isItenary": false,
        "isPoll": false,
        "chartType": "none",
        "comments": 1,
        "upvotes": 2,
        "downvotes": 0,
        "createdAt": {"\$date": "2025-04-04T16:55:27.233Z"}
      },
      {
        "_id": {"\$oid": "67f0105e91509235e7c7b7ba"},
        "author": {
          "id": {"\$oid": "67f0089491509235e7c79fdb"},
          "name": "Akash Kakularam",
          "avatar": "assets/avatar/menp1.svg",
          "avatarBackGround": "#FFB07A"
        },
        "title": "Poll is Added in the Post",
        "description": {"message": "description"},
        "image": "none",
        "postType": "feed",
        "isItenary": false,
        "isPoll": true,
        "pollData": {
          "question": "I'm planning for Goa this month, is that a great plan ?",
          "options": [
            {
              "option": "yes, absolutely ",
              "votes": [{"\$oid": "67efd21391509235e7c77379"}],
              "_id": {"\$oid": "67f0105e91509235e7c7b7bc"}
            },
            {
              "option": "No, I don't recommend ",
              "votes": [{"\$oid": "67f0089491509235e7c79fdb"}],
              "_id": {"\$oid": "67f0105e91509235e7c7b7bd"}
            },
            {
              "option": "May be, It can be a good plan. Not sure",
              "votes": [],
              "_id": {"\$oid": "67f0105e91509235e7c7b7be"}
            }
          ],
          "author": {
            "name": "Akash Kakularam",
            "id": {"\$oid": "67f0089491509235e7c79fdb"},
            "avatar": "assets/avatar/menp1.svg",
            "avatarBackGround": "#FFB07A"
          },
          "pollType": "casual",
          "_id": {"\$oid": "67f0105e91509235e7c7b7bb"},
          "createdAt": {"\$date": "2025-04-04T17:01:18.304Z"}
        },
        "chartType": "none",
        "comments": 0,
        "upvotes": 2,
        "downvotes": 0,
        "createdAt": {"\$date": "2025-04-04T17:01:18.305Z"}
      }
    ];



    setState(() {
      posts = sampleJsonData.map((json) => PostModel.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: BottomNavigations(data: 2,),
      appBar: AppBar(
        title: const Text('Social Feed'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh
          await Future.delayed(const Duration(seconds: 1));
          _loadSampleData();
        },
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(
              post: posts[index],
              onLike: () => _handleLike(posts[index]),
              onComment: () => _handleComment(posts[index]),
              onShare: () => _handleShare(posts[index]),
              onBookmark: () => _handleBookmark(posts[index]),
              onPollVote: (optionId) => _handlePollVote(posts[index], optionId),
            );
          },
        ),
      ),
    );
  }

  void _handleLike(PostModel post) {
    print('Liked post: ${post.title}');
  }

  void _handleComment(PostModel post) {
    print('Comment on post: ${post.title}');
  }

  void _handleShare(PostModel post) {
    print('Share post: ${post.title}');
  }

  void _handleBookmark(PostModel post) {
    print('Bookmark post: ${post.title}');
  }

  void _handlePollVote(PostModel post, String optionId) {
    print('Voted on poll: ${post.title}, option: $optionId');
  }
}