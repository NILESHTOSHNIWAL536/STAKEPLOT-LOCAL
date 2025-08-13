import 'package:flutter_application_code_stakeplot/Hive_localstorage/post_data.dart/post_hive_storage.dart';
import 'package:get/get.dart';
import '../../backed_connections/apis_connect.dart';
import '../../model/post_model.dart'; 
import '../hive_storage.dart';
part 'post_helper.dart';

class PostLocalStorage {
  /// Save all posts to Hive
  static Future<void> savePostsToHive({required RxList<PostModel> postList,required bool isPostTranding,bool isSavedPost=false})  async {
   final box =isPostTranding? isSavedPost? await HiveStorage.savedPost:await HiveStorage.postBoxTranding: await HiveStorage.postBoxFeed;  
   await box.clear();

    try {
      postList.forEach((element) {
        AuthorModel auth=element.author;
        box.add(PostModels(
          id: element.id,
          author: AuthorModels(id:auth.id, name: auth.name, maskedName: auth.maskedName, avatarType: auth.avatarType, avatarBackGround: auth.avatarBackGround),
          title: element.title,
          place: element.place,
          description: element.description,
          image: element.image,
          isItenary: element.isItenary,
          isPoll: element.isPoll,
          isSquareImage: element.isSquareImage,
          chartType: element.chartType,
          comments: element.comments,
          upvotes: element.upvotes,
          downvotes: element.downvotes,
          path: element.path,
          reportCount: element.reportCount,
          hideCount: element.hideCount,
          tag: element.tag,
          createdAt: element.createdAt,
          updatedAt: element.updatedAt,
          location: element.location,
          rating: element.rating,
          tripHighlights: element.tripHighlights,
          images: element.images,
          pollData: element.postType==PostType.poll?PollMapper.toHive(element.pollData!):null,
          postType: PostTypeMapper.toHive(element.postType),
          budget:  BudgetMapper.toHiveList(element.budget),
        ));
      });
    } catch (e) {
      print("Error saving posts to Hive: $e");
    }
  }




  /// Load posts from Hive into RxList
  static Future<void> loadPostsFromHive({required bool isPostTranding,bool isSavedPost=false}) async {
    final box =isPostTranding? isSavedPost? await HiveStorage.savedPost:await HiveStorage.postBoxTranding: await HiveStorage.postBoxFeed;
    RxList<PostModel> postList=<PostModel>[].obs;
    
    try {
      box.values.forEach((element) {
        AuthorModels auth=element.author;
        postList.add(PostModel(
          id: element.id,
          author:  AuthorModel(id:auth.id, name: auth.name, maskedName: auth.maskedName, avatarType: auth.avatarType, avatarBackGround: auth.avatarBackGround),
          title: element.title,
          place: element.place,
          description: element.description,
          image: element.image,
          isItenary: element.isItenary,
          isPoll: element.isPoll,
          isSquareImage: element.isSquareImage,
          chartType: element.chartType,
          comments: element.comments,
          upvotes: element.upvotes,
          downvotes: element.downvotes,
          path: element.path,
          reportCount: element.reportCount,
          hideCount: element.hideCount,
          tag: element.tag,
          createdAt: element.createdAt,
          updatedAt: element.updatedAt,
          location: element.location,
          rating: element.rating,
          tripHighlights: element.tripHighlights,
          images: element.images,
          budget: BudgetMapper.fromHiveList(element.budget),
          postType: PostTypeMapper.toApp(element.postType),
          pollData: element.postType==PostTypes.poll?PollMapper.fromHive(element.pollData!):null,
        ));
      });

     if(isPostTranding){
         if(isSavedPost){
                userController.savedList.clear();
                userController.savedList.addAll(postList);
         }else{ 
          postController.trandingPostList.clear();
          postController.trandingPostList.addAll(postList);
        }
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
      print("Error loading posts from Hive: $e");
    }
  }
}
