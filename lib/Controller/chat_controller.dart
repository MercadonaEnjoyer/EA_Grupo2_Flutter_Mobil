import 'package:spotfinder/Models/ChatModel.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var chatMessages = <Message>[].obs;
  var connectedUser = 0.obs;
  var userMessage = "".obs;
  //var hourMessage =  <DateTime>[].obs;
}
