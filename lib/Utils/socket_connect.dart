import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../components/shared_utils.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? _socket;

  void initSocket(String url) {
    if (_socket != null) {
      if (!_socket!.connected) {
        _socket!.connect();
      }
      return;
    }

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      consolelog("Socket Connected");
    });
    _socket!.onConnectError((data) {
      consolelog("Socket Connect Error: $data");
    });
    _socket!.onDisconnect((_) {
      consolelog("Socket Disconnected");
    });
    _socket!.connect();
  }

  bool get isInitialized => _socket != null;

  IO.Socket getSocket() {
    final activeSocket = _socket;
    if (activeSocket == null) {
      throw StateError("Socket is not initialized");
    }
    return activeSocket;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
