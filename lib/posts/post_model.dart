class PostModel {
  final String id;
  final Author author;
  final String title;
  final Description description;
  final String? image;
  final String postType;
  final bool isItenary;
  final bool isPoll;
  final PollData? pollData;
  final String chartType;
  final int comments;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    this.image,
    required this.postType,
    required this.isItenary,
    required this.isPoll,
    this.pollData,
    required this.chartType,
    required this.comments,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id']['\$oid'],
      author: Author.fromJson(json['author']),
      title: json['title'],
      description: Description.fromJson(json['description']),
      image: json['image'] != 'none' ? json['image'] : null,
      postType: json['postType'],
      isItenary: json['isItenary'],
      isPoll: json['isPoll'],
      pollData: json['pollData'] != null ? PollData.fromJson(json['pollData']) : null,
      chartType: json['chartType'],
      comments: json['comments'],
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
      createdAt: DateTime.parse(json['createdAt']['\$date']),
    );
  }
}

class Author {
  final String id;
  final String name;
  final String avatar;
  final String avatarBackGround;

  Author({
    required this.id,
    required this.name,
    required this.avatar,
    required this.avatarBackGround,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id']['\$oid'],
      name: json['name'],
      avatar: json['avatar'],
      avatarBackGround: json['avatarBackGround'],
    );
  }
}

class Description {
  final dynamic message;

  Description({required this.message});

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(message: json['message']);
  }
}

class PollData {
  final String question;
  final List<PollOption> options;
  final Author author;
  final String pollType;

  PollData({
    required this.question,
    required this.options,
    required this.author,
    required this.pollType,
  });

  factory PollData.fromJson(Map<String, dynamic> json) {
    return PollData(
      question: json['question'],
      options: (json['options'] as List)
          .map((option) => PollOption.fromJson(option))
          .toList(),
      author: Author.fromJson(json['author']),
      pollType: json['pollType'],
    );
  }
}

class PollOption {
  final String option;
  final List<String> votes;
  final String id;

  PollOption({
    required this.option,
    required this.votes,
    required this.id,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      option: json['option'],
      votes: (json['votes'] as List).map((vote) => vote['\$oid'].toString()).toList(),
      id: json['_id']['\$oid'],
    );
  }
}

class ExploreData {
  final List<String> pictures;
  final Place place;
  final List<Budget> budget;
  final int rating;
  final String tripHighlight;
  final String description;

  ExploreData({
    required this.pictures,
    required this.place,
    required this.budget,
    required this.rating,
    required this.tripHighlight,
    required this.description,
  });

  factory ExploreData.fromJson(Map<String, dynamic> json) {
    return ExploreData(
      pictures: List<String>.from(json['pictures']),
      place: Place.fromJson(json['place']),
      budget: (json['budget'] as List).map((b) => Budget.fromJson(b)).toList(),
      rating: json['rating'],
      tripHighlight: json['tripHighlight'],
      description: json['description'],
    );
  }
}

class Place {
  final String name;
  final String location;

  Place({required this.name, required this.location});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      location: json['location'],
    );
  }
}

class Budget {
  final String category;
  final int amount;

  Budget({required this.category, required this.amount});

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['category'],
      amount: json['amount'],
    );
  }
}