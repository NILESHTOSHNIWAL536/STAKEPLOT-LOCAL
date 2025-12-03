import '../backed_connections/apis_connect.dart';

class ChatRoutes {
  static final String _urlPath = "$url/chat";

  /// 💬 Send a new message
  /// POST /chat/
  static String sendMessage = "$_urlPath/";

  /// 🔄 Update unseen messages when user opens chat
  /// PATCH /chat/:friendId/:isMasked
  static String updateUnseenMessages({
    required String friendId,
    required bool isMasked,
  }) =>
      "$_urlPath/$friendId/${isMasked}";

  /// 📑 Get ordered chat list
  /// GET /chat/order/:isMasked
  static String chatsOrder({required bool isMasked}) =>
      "$_urlPath/order/${isMasked}";

  /// 📥 Get chat messages with someone
  /// GET /chat/:friendId/:isMasked
  static String retrieveChatMessages({
    required String Id,
    required bool isMasked,
  }) =>
      "$_urlPath/$Id/${isMasked}";
}
