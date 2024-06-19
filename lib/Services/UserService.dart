import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:dio/dio.dart'; // Usa un prefijo 'Dio' para importar la clase Response desde Dio
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:spotfinder/Services/SignInService.dart';
import 'package:spotfinder/Services/TokenService.dart';

class UserService {
  final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend
  final Dio dio = DioSingleton.instance;
  var statusCode;
  var data;
  final TokenRefreshService tokenRefreshService = TokenRefreshService();
  String idClient =
      '257534938006-c7hvo16718jppmasvep1oscbb5sa6398.apps.googleusercontent.com'; 
  late SignInService signInService = SignInService(clientId: idClient);

  UserService(){
        dio.interceptors.add(tokenRefreshService.dio.interceptors.first);
  }


  void saveToken(String token, String refreshToken) {
    final box = GetStorage();
    box.write('token', token);
    box.write('refresh_token', refreshToken);
  }

  String? getToken() {
    final box = GetStorage();
    return box.read('token');
  }

  void saveId(String id) {
    final box = GetStorage();
    box.write('id', id);
  }

  String? getId() {
    final box = GetStorage();
    return box.read('id');
  }

  void logout() {
    signInService.handleSignOut();
    final box = GetStorage();
    box.remove('token');
    box.remove('refresh_token');
    box.remove('id');
  }

  //Función createUser
  Future<int> createUser(User newUser) async {
    print('createUser');
    print('try');
    // Utilizar Dio para enviar la solicitud POST a http://127.0.0.1:3000/users
    Response response = await dio.post('$baseUrl/user', data: newUser.toJson());
    //En response guardamos lo que recibimos como respuesta

    data = response.data.toString();
    print('Data: $data');
    //Printeamos el status code recibido por el backend

    statusCode = response.statusCode;
    print('Status code: $statusCode');

    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      print('201');
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    } else {
      // Otro caso no manejado
      print('-1');

      return -1;
    }
  }

  Future<int> updateUser(User user) async {
    
    Response response =await dio.put('$baseUrl/user/${user.id}', data: user.toJson());

    data = response.data.toString();
    statusCode = response.statusCode;

    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      print('201');
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    } else {
      // Otro caso no manejado
      print('-1');

      return -1;
    }
  }

  Future<int> updateLocation(Position? location) async {
   

    final json ={
      'location': {
        'type': 'Point',
        'coordinates': [location!.longitude, location.latitude],
      }
    };
    Response response =await dio.put('$baseUrl/user/${getId()}', data: json);
    data = response.data.toString();
    statusCode = response.statusCode;
    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      print('201');
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    } else {
      // Otro caso no manejado
      print('-1');

      return -1;
    }
  }

  Future<User> getUser() async {
    final id = getId();
    try {
      Response res = await dio.get('$baseUrl/user/$id');
      User user = User.fromJson(res.data['data']);
      return user;
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }
  Future<User> getAnotherUser(String? id) async {

    
    try {
      Response res = await dio.get('$baseUrl/user/$id');
      User user = User.fromJson(res.data['data']);
      return user;
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }

  Future<List<Activity>> getData() async {
   
    try {
      var res = await dio.get('$baseUrl/place');
      List<dynamic> responseData =
          res.data; // Obtener los datos de la respuesta

      // Convertir los datos en una lista de objetos Place
      List<Activity> activities =
          responseData.map((data) => Activity.fromJson(data)).toList();

      return activities; // Devolver la lista de actividadess
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }

  Future<int> logIn(logIn) async {
    print('LogIn');

    Response response = await dio.post('$baseUrl/signin', data: logInToJson(logIn));

    data = response.data.toString();
    print('Data: $data');

    statusCode = response.statusCode;
    print('Status code: $statusCode');

    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      var token = response.data['token'];
      var refresh_token = response.data['refreshToken'];
      var id = response.data['id'];
      saveToken(token, refresh_token);
      saveId(id);
      print('200');
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    } else {
      // Otro caso no manejado
      print('-1');

      return -1;
    }
  }

  Map<String, dynamic> logInToJson(logIn) {
    return {'email': logIn.email, 'password': logIn.password};
  }

  Future<void> deleteUser() async {

    final id = getId();
    try {
      Response response = await dio.put('$baseUrl/user/delete/$id');
        statusCode = response.statusCode;
      logout();
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }

  Future<int> updateUserLocation(String userId, double latitude, double longitude) async {
  

  final data = {
    'latitude': latitude,
    'longitude': longitude,
  };

  try {
    Response response = await dio.put('$baseUrl/user/location/$userId', data: data);
    statusCode = response.statusCode;
    return statusCode;
  } catch (e) {
    print('Error updating user location: $e');
    return -1;
  }
}

Future<User> getCurrentUser() async {
  

  final id = getId();
  try {
    Response res = await dio.get('$baseUrl/user/$id');
    User user = User.fromJson(res.data['data']);
    return user;
  } catch (e) {
    print('Error fetching user data: $e');
    throw e;
  }
}

}
