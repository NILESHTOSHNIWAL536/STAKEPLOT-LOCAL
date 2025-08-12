import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0) String userId;
  @HiveField(1) String userName;
  @HiveField(2) bool isGoogleUser;
  @HiveField(3) List<String> interestedTags;
  @HiveField(4) String maskedName;
  @HiveField(5) bool canMaskMessage;
  @HiveField(6) String email;
  @HiveField(7) String dob;
  @HiveField(8) String phone;
  @HiveField(9) String currency;
  @HiveField(10) int coins;
  @HiveField(11) int coupons;
  @HiveField(12) int score;
  @HiveField(13) String aboutMe;
  @HiveField(14) String avatar;
  @HiveField(15) String avatarBackGround;
  @HiveField(16) List<String> likedPosts;
  @HiveField(17) List<String> likedComments;
  @HiveField(18) List<String> likedProducts;
  @HiveField(19) int expense;
  @HiveField(20) bool firstTimeLogin;
  @HiveField(21) bool isBankAccountLinked;
  @HiveField(22) bool fetchInProgress;
  @HiveField(23) String cupertinoPin;
  @HiveField(24) bool cupertinoAttemptCount;
  @HiveField(25) String selectedBank;
  @HiveField(26) String firstFetchedDate;
  @HiveField(27) List friendsList;

  UserModel({
    required this.userId,
    required this.userName,
    required this.isGoogleUser,
    required this.interestedTags,
    required this.maskedName,
    required this.canMaskMessage,
    required this.email,
    required this.dob,
    required this.phone,
    required this.currency,
    required this.coins,
    required this.coupons,
    required this.score,
    required this.aboutMe,
    required this.avatar,
    required this.avatarBackGround,
    required this.likedPosts,
    required this.likedComments,
    required this.likedProducts,
    required this.expense,
    required this.firstTimeLogin,
    required this.isBankAccountLinked,
    required this.fetchInProgress,
    required this.cupertinoPin,
    required this.cupertinoAttemptCount,
    required this.selectedBank,
    required this.firstFetchedDate,
    required this.friendsList,
  });
}
