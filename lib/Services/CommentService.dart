import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/Models/CommentModel.dart';
import 'package:spotfinder/Services/TokenService.dart';

class CommentService {
  final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend
  final Dio dio = DioSingleton.instance;
  var statusCode;
  var data;
  final TokenRefreshService tokenRefreshService = TokenRefreshService(); 

  CommentService() {
    dio.interceptors.add(tokenRefreshService.dio.interceptors.first);
  }
  
  String? getToken(){
    final box = GetStorage();
    return box.read('token');
  }

 Future<void> deleteComment(String id) async {

    try {
      await dio.delete('$baseUrl/comment/$id');
      return;
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }

Future<int> updateComment(Comment comment) async {
    

    Response response =await dio.put('$baseUrl/comment/${comment.id}', data: comment.toJson());

    data = response.data.toString();
    statusCode = response.statusCode;

    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500

      return 500;
    } else {
      // Otro caso no manejado

      return -1;
    }
  }

 Future<Comment> getComment(String id) async {

   
    try {
      Response res = await dio.get('$baseUrl/comment/$id');
      Comment comment = Comment.fromJson(res.data['data']);
      return comment;
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }

  Future<Comment?> createComment (Comment newComment) async {

    try {      
      Response response = await dio.post('$baseUrl/comment', data: newComment.toJson());
      Comment comment = Comment.fromJson(response.data['comment']);
      return comment;
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }
}