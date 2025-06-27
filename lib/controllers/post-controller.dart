import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:get/get.dart';

class PostController extends GetxController 
{
  RxList likedCommentList = [].obs;
  RxList likedProducts = [].obs;
  RxMap<String, int> postCount = <String, int>{}.obs;
  RxMap<String, int> postCommentCount = <String, int>{}.obs;
  RxMap<String, int> supportCount = <String, int>{}.obs;
  RxMap<String, bool> postData = <String, bool>{}.obs;
  RxList<PostModel> trandingPostList = <PostModel>[].obs;
  RxList<PostModel> feedPostList = <PostModel>[].obs;
  RxInt currentPageTranding = 1.obs;
  RxInt currentPageFeed = 1.obs;
  RxBool isPostloading = false.obs;
  RxBool hasMorePostTranding = false.obs;
  RxBool hasMorePostFeed = false.obs;
  late PostModel uniquePostDeatils;
  RxList likedList = [].obs;
  RxList historyExploriaListData = [].obs;
  RxList getExploriaTrendingData = [].obs;
  RxMap<String, int> postExploriaCount = <String, int>{}.obs;
  RxMap<String, int> postExploriaCommentCount = <String, int>{}.obs;
  RxMap<String, int> supportExploriaCount = <String, int>{}.obs;
  RxBool postDis = false.obs;
  RxBool posting = false.obs;
  RxBool getPosted = false.obs;
  RxBool getPostedTranding = false.obs;
  RxBool postInter = false.obs;
  RxBool reloadUniquePost = false.obs;
  RxBool isPost = false.obs;
  RxBool isPostTranding = false.obs;
  RxBool isTrending = false.obs;
  
}
