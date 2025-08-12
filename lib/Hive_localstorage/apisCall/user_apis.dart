
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:hive/hive.dart';
import '../../controllers/user-controller.dart';
import '../user-data/user_model.dart';



class  UserLocalStorage {
  

static Future<void> cacheUserDataLocally() async {
  final box = Hive.box<UserModel>('userBox');

  final user = UserModel(
    userId:  userController.userId.value,
    userName:  userController.userName.value,
    isGoogleUser: isGoogleUser.value,
    interestedTags:  userController.interestedTags.toList(),
    maskedName:  userController.maskedName.value,
    canMaskMessage:  userController.canMaskMessage.value,
    email:  userController.email.value,
    dob:  userController.dob.value,
    phone:  userController.phone.value,
    currency:  userController.currency.value,
    coins:  userController.coins.value,
    coupons:  userController.coupons.value,
    score:  userController.score.value,
    aboutMe:  userController.aboutMe.value,
    avatar:  userController.avatar.value,
    avatarBackGround:  userController.avatarBackGround.value,
    likedPosts:  userController.likedPosts.toList(),
    likedComments:  userController.likedComments.toList(),
    likedProducts:  userController.likedProducts.toList(),
    expense:  userController.expense.value,
    firstTimeLogin:  userController.firstTimeLogin.value,
    isBankAccountLinked:  userController.isBankAccountLinked.value,
    fetchInProgress:  userController.fetchInProgress.value,
    cupertinoPin:  userController.cupertinoPin.value,
    cupertinoAttemptCount:  userController.cupertinoAttemptCount.value,
    selectedBank:  userController.selectedBank.value,
    firstFetchedDate:  userController.firstFetchedDate.value,
    friendsList:  userController.friendsList.toList(),
  );

  await box.put('localUser', user);
}


static Future<void> loadUserFromHive() async 
{
  final box = Hive.box<UserModel>('userBox');
  final user = box.get('localUser');

  if (user != null) {
    userController.userId.value = user.userId;
    userController.userName.value = user.userName;
    userController.isGoogleUser.value = user.isGoogleUser;
    userController.maskedName.value = user.maskedName;
    userController.canMaskMessage.value = user.canMaskMessage;
    userController.email.value = user.email;
    userController.dob.value = user.dob;
    userController.phone.value = user.phone;
    userController.currency.value = user.currency;
    userController.coins.value = user.coins;
    userController.coupons.value = user.coupons;
    userController.score.value = user.score;
    userController.aboutMe.value = user.aboutMe;
    userController.avatar.value = user.avatar;
    userController.avatarBackGround.value = user.avatarBackGround;

    userController.likedPosts.clear();
    userController.interestedTags.clear();
    userController.likedComments.clear();
    userController.likedProducts.clear();
    userController.friendsList.clear();

    userController.likedPosts.addAll(user.likedPosts);
    userController.interestedTags.addAll(user.interestedTags);
    userController.likedComments.addAll(user.likedComments);
    userController.likedProducts.addAll(user.likedProducts);
    userController.friendsList.addAll(user.friendsList);

    userController.expense.value = user.expense;
    userController.firstTimeLogin.value = user.firstTimeLogin;
    userController.isBankAccountLinked.value = user.isBankAccountLinked;
    userController.fetchInProgress.value = user.fetchInProgress;
    userController.cupertinoPin.value = user.cupertinoPin;
    userController.cupertinoAttemptCount.value = user.cupertinoAttemptCount;
    userController.selectedBank.value = user.selectedBank;
    userController.firstFetchedDate.value = user.firstFetchedDate;
    addFriendtoList();
  }
}

}