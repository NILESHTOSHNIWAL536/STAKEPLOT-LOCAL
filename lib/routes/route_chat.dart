import 'index_route.dart';

class ChatRoutes {
  static final String _urlPath = "${API.mainBackendUrl}/chat";

  static String sendMessage = "$_urlPath/";

  static String updateUnseenMessages({
    required String friendId,
    required bool isMasked,
  }) => "$_urlPath/$friendId/${isMasked}";

  static String chatsOrder({required bool isMasked}) =>"$_urlPath/order/${isMasked}";

  static String retrieveChatMessages({
    required String Id,
    required bool isMasked,
  }) => "$_urlPath/$Id/${isMasked}";
  
}
