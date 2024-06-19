import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/Screens/title_screen.dart';

class TokenRefreshService {
  final Dio dio = DioSingleton.instance;
  final GetStorage box = GetStorage();
  late String? _token;

  TokenRefreshService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {

        options.headers['x-access-token'] = await _getToken();
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 400 &&
            !_shouldSkipRetry(e.requestOptions)) {
          await _refreshToken();
          final options = e.response!.requestOptions;
          options.extra['retried'] = true;
          options.headers['x-access-token'] = _getToken();
          try {
            final response = await dio.request(
              options.path,
              options: Options(
                method: options.method,
                headers: options.headers,
                responseType: options.responseType,
                contentType: options.contentType,
                extra: options.extra,
                followRedirects: options.followRedirects,
                receiveDataWhenStatusError: options.receiveDataWhenStatusError,
                validateStatus: options.validateStatus,
                receiveTimeout: options.receiveTimeout,
                sendTimeout: options.sendTimeout,
                requestEncoder: options.requestEncoder,
                responseDecoder: options.responseDecoder,
              ),
              data: options.data,
              queryParameters: options.queryParameters,
            );
            return handler.resolve(response);
          } catch (err) {
            return handler.reject(err as DioException);
          }
        }
        return handler.next(e);
      },
    ));
  }

  bool _shouldSkipRetry(RequestOptions options) {
    return options.extra.containsKey('retried');
  }

  Future<String?> _getToken() async {
    _token = box.read('token');
    return _token;
  }

  Future<void> _updateToken(String newToken, String newRefreshToken) async {
    _token = newToken;
    await box.write('token', newToken);
    await box.write('refresh_token', newRefreshToken);
  }

  Future<void> _refreshToken() async {
    try {
      final refreshToken = box.read('refresh_token');
      if (refreshToken != null) {
        final response = await dio.post('http://127.0.0.1:3000/refresh_token',
            data: {'refresh_token': refreshToken});
        var token = response.data['token'];
        var refresh_token = response.data['refreshToken'];
        if (token != null) {
          await _updateToken(token, refresh_token);
        }
      }
    } catch (e) {
      print('Error refreshing token: $e');
      box.remove('token');
      box.remove('refresh_token');
      Get.to(TitleScreen());
    }
  }
}

class DioSingleton {
  static final Dio _dio = Dio();

  DioSingleton._();

  static Dio get instance => _dio;
}
