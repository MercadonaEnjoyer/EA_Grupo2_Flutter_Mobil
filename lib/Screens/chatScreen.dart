// ignore: file_names
import 'package:flutter/material.dart';
import 'package:spotfinder/Controller/chat_controller.dart';
import 'package:spotfinder/Models/ChatModel.dart';
import 'package:get/get.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:spotfinder/Models/UserModel.dart';
import 'home_page.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:intl/intl.dart';

User? user;

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
  UserService user = UserService();

  @override
  void initState() {
    socket = IO.io(
        "http://127.0.0.1:3000",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': "${user.getToken()}"})
            .build());
    socket.connect();
    setUpsocketListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        title: const Text('SpotFinder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            manualDisconnect();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Obx(
                () => Text(
                  "Connected User: ${chatController.connectedUser}",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 11, 37, 167),
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index) {
                    //var currentUser = chatController.userMessage;
                    var currentItem = chatController.chatMessages[index];
                    //var currenteHour = chatController.hourMessage;
                    return MessageItem(
                      sentByMe: currentItem.sentByMe == socket.id,
                      message: currentItem.message,
                      userName: currentItem.userName,
                      hora: currentItem.hora,
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.red,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: purple,
                controller: msgInputController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void sendMessage(String text) {
    var messageJSON = {
      "message": text,
      "sentByMe": socket.id,
      "userName": '',
      "hora": DateTime.now().toIso8601String(),
      "id": user.getId()
    };

    socket.emit('message', messageJSON);
    chatController.chatMessages.add(Message.fromJson(messageJSON));
  }

  void setUpsocketListener() {
    socket.on('message-receive', (data) {
      // ignore: avoid_print
      print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data) {
      // ignore: avoid_print
      print(data);
      chatController.connectedUser.value = data;
    });
  }

// ignore: non_constant_identifier_names


  void manualDisconnect() {
    socket.emit('manual-disconnect');
    socket.disconnect();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem(
      {super.key,
      required this.sentByMe,
      required this.message,
      required this.userName,
      required this.hora});
  final bool sentByMe;
  final String message;
  final String userName;
  final DateTime hora;

  

  @override
  Widget build(BuildContext context) {
    Color purple = const Color(0xFF6c5ce7);
    Color black = const Color(0xFF191919);
    Color white = Colors.white;
    var newDate = DateFormat.jm().format(hora);

    return Align(
        alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: sentByMe ? purple : white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  // ignore: unnecessary_brace_in_string_interps
                  "${userName}:",
                  style:
                      TextStyle(color: sentByMe ? white : black, fontSize: 18),
                ),
                Text(
                  message,
                  style:
                      TextStyle(color: sentByMe ? white : purple, fontSize: 18),
                ),
                const SizedBox(width: 5),
                Text(
                  newDate,
                  style: TextStyle(
                    color: (sentByMe ? white : purple).withOpacity(0.7),
                    fontSize: 10,
                  ),
                )
              ],
            )));
  }
}
