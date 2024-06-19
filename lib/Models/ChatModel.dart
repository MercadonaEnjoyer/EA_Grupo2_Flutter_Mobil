class Message {
  String message;
  String sentByMe;
  String userName;
  DateTime hora;

  Message(
      {required this.message, required this.sentByMe, required this.userName, required this.hora});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        message: json["message"],
        sentByMe: json["sentByMe"],
        userName: json["userName"],
        hora: DateTime.parse(json["hora"]),
  );
  }
}
