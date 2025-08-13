import 'package:hive/hive.dart';

part 'post_hive_storage.g.dart'; // Run `flutter packages pub run build_runner build` after creating

// ---------------- ENUM ----------------
@HiveType(typeId: 11)
enum PostTypes {
  @HiveField(0)
  exploria,
  @HiveField(1)
  poll,
  @HiveField(2)
  write,
  @HiveField(3)
  image,
  @HiveField(4)
  unknown,
}

// ---------------- MODELS ----------------
@HiveType(typeId: 12)
class PollOptionModels extends HiveObject {
  @HiveField(0)
  String option;

  @HiveField(1)
  List<String> votes;

  PollOptionModels({
    required this.option,
    required this.votes,
  });
}

@HiveType(typeId: 13)
class PollModels extends HiveObject {
  @HiveField(0)
  String question;

  @HiveField(1)
  List<PollOptionModels> options;

  PollModels({
    required this.question,
    required this.options,
  });
}

@HiveType(typeId: 14)
class AuthorModels extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String maskedName;

  @HiveField(3)
  String avatarType;

  @HiveField(4)
  String avatarBackGround;

  AuthorModels({
    required this.id,
    required this.name,
    required this.maskedName,
    required this.avatarType,
    required this.avatarBackGround,
  });
}

@HiveType(typeId: 15)
class BudgetModels extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  int amount;

  BudgetModels({
    required this.id,
    required this.category,
    required this.amount,
  });
}

@HiveType(typeId: 16)
class PostModels extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  AuthorModels author;

  @HiveField(2)
  String title;

  @HiveField(3)
  String place;

  @HiveField(4)
  dynamic description;

  @HiveField(5)
  String image;

  @HiveField(6)
  PostTypes postType;

  @HiveField(7)
  bool isItenary;

  @HiveField(8)
  bool isPoll;

  @HiveField(9)
  bool isSquareImage;

  @HiveField(10)
  PollModels? pollData;

  @HiveField(11)
  String chartType;

  @HiveField(12)
  int comments;

  @HiveField(13)
  int upvotes;

  @HiveField(14)
  int downvotes;

  @HiveField(15)
  String path;

  @HiveField(16)
  int reportCount;

  @HiveField(17)
  int hideCount;

  @HiveField(18)
  List<String> tag;

  @HiveField(19)
  DateTime createdAt;

  @HiveField(20)
  DateTime updatedAt;

  @HiveField(21)
  String location;

  @HiveField(22)
  List<BudgetModels> budget;

  @HiveField(23)
  int rating;

  @HiveField(24)
  List<String> tripHighlights;

  @HiveField(25)
  List<String> images;

  PostModels({
    required this.id,
    required this.author,
    required this.title,
    required this.place,
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
    required this.location,
    required this.budget,
    required this.rating,
    required this.tripHighlights,
    required this.images,
  });
}

