// import 'dart:async';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:stakeplot/backed_connections/apis_connect.dart';
// import 'package:stakeplot/thridScreen/chat.dart';

// //  late IO.Socket socket;

  
//   void socketConnection2(){
//     socket=IO.io("http://localhost:5000",IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());
//     // socket=IO.io(urlWithLocallHost,IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());
//     setUpSocketListener2();
//   
//   }


//    setUpSocketL  istener2(){
//      socket.on("newMessage", (data) => {
      
//        messages.insert(0,Message(
//                     text: data['message'], 
//                     isMe: userId==data['sender']??true,
//                     type: data['messageType']??"message",
//                     image:data['image']?? "https://res.cloudinary.com/deus5rcgl/image/upload/v1715447062/public/xb3koplsy9fvoeetup02.jpg", 
//                     poll: "",
//        ))
 
//      });
//   }