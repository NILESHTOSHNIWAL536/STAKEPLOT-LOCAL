enum PostType {
  exploria,
  poll,
  write,
  image,
  unknown;

  static PostType fromString(String value) {
    switch (value.toLowerCase()) {
      case "exploria":
        return PostType.exploria;
      case "poll":
        return PostType.poll;
      case "write":
        return PostType.write;
      case "image":
        return PostType.image;
      default:
        return PostType.unknown;
    }
  }

  String get name {
    switch (this) {
      case PostType.exploria:
        return "exploria";
      case PostType.poll:
        return "poll";
      case PostType.write:
        return "write";
      case PostType.image:
        return "image";
      case PostType.unknown:
        return "unknown";
    }
  }
}


class PollOptionModel {
  final String option;
  final List<String> votes;

  PollOptionModel({
    required this.option,
    required this.votes,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      option: json['option'] ?? '',
      votes: List<String>.from(json['votes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option': option,
      'votes': votes,
    };
  }
}

class PollModel {
  final String question;
  final List<PollOptionModel> options;

  PollModel({
    required this.question,
    required this.options,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      question: json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => PollOptionModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

class AuthorModel {
  final String id;
  final String name;
  final String maskedName;
  final String avatarType;
  final String avatarBackGround;

  AuthorModel({
    required this.id,
    required this.name,
    required this.maskedName,
    required this.avatarType,
    required this.avatarBackGround,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      maskedName: json['maskedName'] ?? '',
      avatarType: json['avatarType'] ?? '',
      avatarBackGround: json['avatarBackGround'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'maskedName': maskedName,
      'avatarType': avatarType,
      'avatarBackGround': avatarBackGround,
    };
  }
}

class PostModel {
  final String id;
  final AuthorModel author;
  final String title;
  final dynamic description;
  final String image;
  final PostType postType;
  final bool isItenary;
  final bool isPoll;
  final bool isSquareImage;
  final PollModel? pollData;
  final String chartType;
  final int comments;
  final int upvotes;
  final int downvotes;
  final String path;
  final int reportCount;
  final int hideCount;
  final List<String> tag;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.image,
    required this.postType,
    required this.isItenary,
    required this.isPoll,
    required this.isSquareImage,
    required this.pollData,
    required this.chartType,
    required this.comments,
    required this.upvotes,
    required this.downvotes,
    required this.path,
    required this.reportCount,
    required this.hideCount,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final postTypeStr = json['postType'] ?? '';
    final postType = PostType.fromString(postTypeStr);

    return PostModel(
      id: json['_id'] ?? '',
      author: AuthorModel.fromJson(json['author'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'],
      image: json['image'] ?? 'none',
      postType: postType,
      isItenary: json['isItenary'] ?? false,
      isPoll: json['isPoll'] ?? false,
      isSquareImage: json['isSquareImage'] ?? false,
      pollData: json['pollData'] != null ? PollModel.fromJson(json['pollData']) : null,
      chartType: json['chartType'] ?? 'none',
      comments: json['comments'] ?? 0,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      path: json['path'] ?? '',
      reportCount: json['reportCount'] ?? 0,
      hideCount: json['hideCount'] ?? 0,
      tag: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author,
      'title': title,
      'description': description,
      'image': image,
      'postType': postType.name,
      'isItenary': isItenary,
      'isPoll': isPoll,
      'isSquareImage': isSquareImage,
      'pollData': pollData?.toJson(),
      'chartType': chartType,
      'comments': comments,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'path': path,
      'reportCount': reportCount,
      'hideCount': hideCount,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }


static List<PostModel> listFromJson(List<dynamic> jsonList) {
  return jsonList.map((e) => PostModel.fromJson(e)).toList();
}

// static List<PostModel> filterPollPosts(List<PostModel> allPosts) {
//   return allPosts.where((post) => post.postType == PostType.poll).toList();
// }
}