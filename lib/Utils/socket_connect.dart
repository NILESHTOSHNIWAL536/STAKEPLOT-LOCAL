import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  late IO.Socket socket;

  void initSocket(String url) {
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket.connect();
    socket.onDisconnect((_) {
      print("❌ Socket Disconnected");
    });
    
  }

  IO.Socket getSocket() => socket;

  void disconnect() {
    socket.disconnect();
    socket.dispose();
  }
}