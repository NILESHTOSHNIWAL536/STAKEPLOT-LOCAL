import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../routes/index_route.dart'; // API.urlWithLocallHost

late IO.Socket socket;

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String myId;        // 🔥 current user id
  final String myName;      // 🔥 current user name

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.myId,
    required this.myName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController controller = TextEditingController();

  /// messages list
  final List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();

    /// 1️⃣ Create socket
    socket = IO.io(
      API.urlWithLocallHost,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    /// 2️⃣ Connect socket
    socket.connect();

    /// 3️⃣ On connect → join group room
    socket.onConnect((_) {
      debugPrint("✅ Connected to socket");
      debugPrint("📌 Joining group: ${widget.groupId}");

      socket.emit("joinRoom", widget.groupId);
    });

    /// 4️⃣ Listen for incoming group messages
    socket.on("message", (data) {
      if (!mounted) return;

      // ignore other rooms
      if (data['roomId'] != widget.groupId) return;

      // ignore own message (already added locally)
      if (data['sender'] == widget.myId) return;

      setState(() {
        messages.insert(0, {
          "sender": data['senderName'] ?? "Member",
          "message": data['message'] ?? "",
        });
      });
    });
  }

  /// 5️⃣ Send message to backend
  void sendMessage(String text) {
    final payload = {
      "roomId": widget.groupId,
      "sender": widget.myId,
      "senderName": widget.myName,
      "message": text,
      "messageType": "message",
      "isGroup": true,
    };

    /// send to backend
    socket.emit("message", payload);

    /// show instantly in UI
    setState(() {
      messages.insert(0, {
        "sender": "You",
        "message": text,
      });
    });

    controller.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          /// messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text(
                    msg['sender']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(msg['message']!),
                );
              },
            ),
          ),

          /// input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Type message",
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        sendMessage(value.trim());
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      sendMessage(controller.text.trim());
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
