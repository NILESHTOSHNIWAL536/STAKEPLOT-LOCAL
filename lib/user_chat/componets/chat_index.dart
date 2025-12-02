import 'package:flutter/material.dart';
import '../message.dart';
import 'chat_image.dart';
import 'chat_polled.dart';
import 'chat_post.dart';
import 'chat_split.dart';
import 'chat_text.dart';

Widget buildMessage(Message message, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      mainAxisAlignment:
          message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: !message.isMe
              ? EdgeInsets.only(left: 14)
              : EdgeInsets.only(right: 14),
          child: getDataWidget(message, context),
        ),
      ],
    ),
  );
}

Widget getDataWidget(Message message, BuildContext context) {
  if (message.type == "message") {
    return text(message.text, message.isMe, context);
  } else if (message.type == "poll") {
    return polled(message.isMe, message.poll, context);
  } else if (message.type == "image") {
    return imageDisplay(message.text, message.isMe, message.image, context);
  } else if (message.type == "post") {
    return postDisplay(
        message.text, message.isMe, message.image, message, context);
  } else if (message.type == "split") {
    return spliDisplay(
        message.text, message.isMe, message.image, message, context);
  }

  return Text("polled");
}

String generateRoomId({
  required String userName,
  required String maskedName,
  required String otherName,
  required bool isMasked,
}) {
  // Pick which names to use based on masking
  final String nameA = isMasked ? maskedName + otherName : userName + otherName;
  final String nameB = isMasked ? otherName + maskedName : otherName + userName;

  // Compare and return in lexicographical order
  return "NILESH"; //nameA.compareTo(nameB) <= 0 ? nameA : nameB;
}
