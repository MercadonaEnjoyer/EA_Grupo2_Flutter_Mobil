import 'package:flutter/material.dart';
import 'package:spotfinder/Controller/chat_controller.dart';
import 'package:spotfinder/Models/ChatModel.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color purple = const Color(0xFF6c5ce7);
  Color black = const Color(0xFF191919);
  TextEditingController msgInputController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    socket = IO.io(
        "http://127.0.0.1:3000",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    setUpsocketListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Column(
        children: [
          Expanded(
              child: Obx(() => Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Connected User ${chatController.connectedUser}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                  ))),
          Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                    itemCount: chatController.chatMessages.length,
                    itemBuilder: (context, index) {
                      var currentItem = chatController.chatMessages[index];
                      return MessageItem(
                        sentByMe: currentItem.sentByMe == socket.id,
                        message: currentItem.message,
                      );
                    }),
              )),
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.red,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: purple,
              controller: msgInputController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: purple,
                    ),
                    child: IconButton(
                        onPressed: () {
                          sendMessage(msgInputController.text);
                          msgInputController.text = "";
                        },
                        icon: const Icon(Icons.send)),
                  )),
            ),
          )),
        ],
      ),
    );
  }

  void sendMessage(String text) {
    var messageJSON = {"message": text, "sentByMe": socket.id};
    socket.emit('message', messageJSON);
    chatController.chatMessages.add(Message.fromJson(messageJSON));
  }

  void setUpsocketListener() {
    socket.on('message-receive', (data) {
      print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data) {
      print(data);
      chatController.connectedUser.value = data;
    });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({super.key, required this.sentByMe, required this.message});
  final bool sentByMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    Color purple = const Color(0xFF6c5ce7);
    Color black = Color(0xFF191919);
    Color white = Colors.white;
    return Align(
        alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
            color: sentByMe ? purple : white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  message,
                  style:
                      TextStyle(color: sentByMe ? white : purple, fontSize: 18),
                ),
                const SizedBox(width: 5),
                Text(
                  "1:10AM",
                  style: TextStyle(
                      color: (sentByMe ? white : purple).withOpacity(0.7),
                      fontSize: 10),
                ),
              ],
            )));
  }
}
