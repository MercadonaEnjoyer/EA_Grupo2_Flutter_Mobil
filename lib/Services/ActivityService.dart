import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:spotfinder/Services/TokenService.dart';
import 'package:spotfinder/Services/UserService.dart';


class ActivityService {
  final String baseUrl = "http://127.0.0.1:3000";
  final Dio dio = DioSingleton.instance;
  var statusCode;
  var data;
  final TokenRefreshService tokenRefreshService = TokenRefreshService(); 
  final UserService user_service = UserService(); 

  ActivityService() {
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

  Future<List<Activity>> getData(double selectedDistance, int page, int limit, String sort) async {
    print('getData');
    String? id = user_service.getId();
    try {
      var res = await dio.get('$baseUrl/activity/$page/$limit/$id/$selectedDistance/$sort');
      final List<dynamic> responseData = res.data['activities'];
      List<Activity> activities = responseData.map((data) => Activity.fromJson(data)).toList();
      return activities;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<List<Activity>> getDataByName(double selectedDistance, int page, int limit, String search) async {
    print('getData');
    String? id = user_service.getId();
    try {
      var res = await dio.get('$baseUrl/activityByName/$page/$limit/$id/$selectedDistance/$search');
      final List<dynamic> responseData = res.data['activities'];
      List<Activity> activities = responseData.map((data) => Activity.fromJson(data)).toList();
      return activities;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<int> joinActivity(String? aId) async {
    try {
      final id = getId();
      var res = await dio.put('$baseUrl/activity/$id/$aId');
      data = res.data.toString();
      print('Data: $data');
      statusCode = res.statusCode;
      print('Status code: $statusCode');
      return statusCode;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<int> leaveActivity(String? aId) async {
    try {
      final id = getId();
      var res = await dio.put('$baseUrl/activity/leave/$id/$aId');
      data = res.data.toString();
      print('Data: $data');
      statusCode = res.statusCode;
      print('Status code: $statusCode');
      return statusCode;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<Activity> getActivity(String id) async {
    try {
      Response res = await dio.get('$baseUrl/activity/$id');
      Activity activity = Activity.fromJson(res.data['data']);
      return activity;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<List<Activity>> getUserActivities() async {
    
    try {
      final id = getId();
      Response res = await dio.get('$baseUrl/activities/$id');
      final List<dynamic> responseData = res.data['data'];
      List<Activity> activities = responseData.map((data) => Activity.fromJson(data)).toList();
      return activities;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<void> addActivity(Activity activity) async {
   
    try {
      print (activity.toJson());
      var res = await dio.post('$baseUrl/activity', data: activity.toJson());
      statusCode = res.statusCode;
      print('Status code: $statusCode');
    } catch (e) {
      print('Error adding activity: $e');
      throw e;
    }
  }

  Future<void> editActivity(Activity activity, String? id) async {
    try {
      var res = await dio.put('$baseUrl/activity/$id', data: activity.toJson());
      data = res.data.toString();
      statusCode = res.statusCode;
      print('Status code: $statusCode');
    } catch (e) {
      print('Error adding activity: $e');
      throw e;
    }
  }

  Future<int> updateLocation(Position? location) async {
    final json ={
      'location': {
        'type': 'Point',
        'coordinates': [location!.longitude, location.latitude],
      }
    };
    Response response =await dio.put('$baseUrl/activity/${getId()}', data: json);
    data = response.data.toString();
    statusCode = response.statusCode;
    if (statusCode == 201) {
      // Si la actividad se crea correctamente, retornamos el código 201
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

  Future<void> deleteActivity(String? id) async {
  
    try {
      print("deleting activity");
      var res = await dio.put('$baseUrl/activity/delete/$id');
      statusCode = res.statusCode;
      print('Status code: $statusCode');
    } catch (e) {
      print('Error adding activity: $e');
      throw e;
    }
  }
}
