import 'dart:io';

class Message {
  Message(
      {this.text,
      required this.isMe,
      this.url,
      required this.type,
      this.question,
      this.image = "",
      this.poll = "",
      this.post = "",
      this.split = ""});

  String image;
  final bool isMe;
  var poll;
  var post;
  var question;
  var split;
  String? text;
  String type; //["image","text","Poll",'post']
  File? url;
  
}