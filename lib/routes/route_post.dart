import 'index_route.dart';

class PostRoutes {
  static final String _urlPath =  API.mainBackendUrl  + "/post";
  static String post = "$_urlPath/";
  static String allPost = "$_urlPath/all/";
  static String save = "$_urlPath/save/";
  static String saved = "$_urlPath/saved/";
  static String userDiscussions = "$_urlPath/userDiscussions";
  static String myDiscussions = "$_urlPath/myDiscussions/";
  static String trending = "$_urlPath/trending/";
  static String feed = "$_urlPath/feed/";
}

class PostRoute {
  static final String _urlPath = "${API.mainBackendUrl}/post";

  // Create a new post
  static String createPost = "$_urlPath/";

  // Toggle save/unsave post
  static String toggleSavePost({required String postId}) =>
      "$_urlPath/save/$postId";

  // My discussions
  static String myDiscussions = "$_urlPath/myDiscussions";

  // Saved posts
  static String getSavedPosts = "$_urlPath/saved";

  // Trending posts (paginated)
  static String getTrendingPosts({required int page}) =>
      "$_urlPath/trending/$page";

  // Feed posts (For You)
  static String getFeedPosts({required int page}) => "$_urlPath/feed/$page";

  // Get specific post
  static String getSpecificPost({required String postId}) =>
      "$_urlPath/$postId";

  // User discussions
  static String userDiscussions({required String uid}) =>
      "$_urlPath/userDiscussions/$uid";

  // Edit post
  static String editPost({required String postId}) => "$_urlPath/$postId";

  // Delete post
  static String deletePost({required String postId}) => "$_urlPath/$postId";
}

class CommentRoute {
  static final String _basePath = "${API.mainBackendUrl}/comment";

  // POST → Add comment
  static String addComment = "$_basePath/";

  // GET → Get all comments for a post
  static String getComments({required String postId}) => "$_basePath/$postId";

  // PATCH → Edit a comment
  static String editComment({required String id}) => "$_basePath/$id";

  // DELETE → Delete a comment
  static String deleteComment({required String postId, required String id}) =>
      "$_basePath/$postId/$id";
}

class ReplyRoute {
  static final String _basePath = "${API.mainBackendUrl}/reply";

  // POST → Add reply
  static String postReply = "$_basePath/";

  // GET → Get replies of a comment
  static String getReplies({required String commentId}) =>
      "$_basePath/$commentId";

  // PATCH → Edit a reply
  static String editReply({required String id}) => "$_basePath/$id";

  // DELETE → Delete a reply
  static String deleteReply({required String id}) => "$_basePath/$id";
}

class SplitRoutes
{
  static final String _basePath = "${API.mainBackendUrl}/split";
  static final String _basePathbill = "${API.mainBackendUrl}/bill";
  static String split = "$_basePath";
  static String bill = "$_basePathbill";
  static String splitpending = "${_basePath}/pending-user";
}


class pollRoute {
  static final String _basePath = "${API.mainBackendUrl}/poll";

  // POST → Upvote model (post/comment/reply)
  static String poll = "$_basePath/";
  static String pollAdd = "$_basePath/add";
   static String votePollInPost({required String postId}) => "$_basePath/votePollInPost/$postId";

}

class UpvoteRoute {
  static final String _basePath = "${API.mainBackendUrl}/upvote";

  // POST → Upvote model (post/comment/reply)
  static String upvote = "$_basePath/";

  // GET → Get upvotes of a model
  static String getUpvotes({required String modelId}) => "$_basePath/$modelId";
}

class DownvoteRoute {
  static final String _basePath = "${API.mainBackendUrl}/downvote";

  // POST → Downvote model (post/comment/reply)
  static String downvote = "$_basePath/";

  // GET → Get downvotes of a model
  static String getDownvotes({required String modelId}) =>
      "$_basePath/$modelId";
}
