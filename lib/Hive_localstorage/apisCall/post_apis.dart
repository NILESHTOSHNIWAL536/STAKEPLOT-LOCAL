import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/init_hive.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/post_data.dart/post_hive_storage.dart';
import 'package:get/get.dart';
import '../../backed_connections/apis_connect.dart';
import '../../model/post_model.dart'; 
import '../hive_storage.dart';
part 'post_helper.dart';

class PostLocalStorage {
  /// Save all posts to Hive
  static Future<void> savePostsToHive({required RxList<PostModel> postList,required bool isPostTranding,bool isSavedPost=false,bool isUserPost=false})  async {

    String boxName = isUserPost? HiveStorage.userPostName:isSavedPost
        ? HiveStorage.savedPostName
        : (isPostTranding
            ? HiveStorage.postBoxTrandingName
            : HiveStorage.postBoxFeedName);

    // ✅ Ensure the box is open
     HiveHelper.openBoxIfNot<PollModels>(boxName);

   final box =isUserPost? HiveStorage.userPost: isPostTranding? isSavedPost? await HiveStorage.savedPost:await HiveStorage.postBoxTranding: await HiveStorage.postBoxFeed;  
   await box.clear();
    try {
      postList.forEach((element) {
        box.add(PostObj.StorePost(element));
      });
    } catch (e) {
    }
  }



  /// Load posts from Hive into RxList
  static Future<void> loadPostsFromHive({required bool isPostTranding,bool isSavedPost=false,bool isUserPost=false}) async {
    String boxName = isUserPost? HiveStorage.userPostName:
           isSavedPost
        ? HiveStorage.savedPostName
        : (isPostTranding
            ? HiveStorage.postBoxTrandingName
            : HiveStorage.postBoxFeedName);

    // ✅ Ensure the box is open
    HiveHelper.openBoxIfNot<PollModels>(boxName);

    final box = isUserPost?await HiveStorage.userPost:   isPostTranding? isSavedPost? await HiveStorage.savedPost:await HiveStorage.postBoxTranding: await HiveStorage.postBoxFeed;
    RxList<PostModel> postList=<PostModel>[].obs;

    try {
      box.values.forEach((element) {
        postList.add(PostObj.getPost(element));
      });

     if(isPostTranding){
         if(isSavedPost){
                userController.savedList.clear();
                userController.savedList.addAll(postList);
         }else{ 
          postController.trandingPostList.clear();
          postController.trandingPostList.addAll(postList);
        }
     }else if(isUserPost){
        userController.myPostList.clear();
        userController.myPostList.addAll(postList);
     }else{
        postController.feedPostList.clear();
        postController.feedPostList.addAll(postList);
     }

     postList.forEach((element) {
      String id=element.id;
      postController.postData[id] = true;
      postController.postCount[id] = element.upvotes;
      postController.postCommentCount[id] = element.comments;
    });

    } catch (e) {
    }
  }
}
