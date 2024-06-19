// ignore: file_names
import 'dart:async';
import 'dart:convert' show base64Url, json, jsonDecode;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:spotfinder/Resources/jwt.dart' as jwt;
import 'dart:math';
import 'package:google_identity_services_web/oauth2.dart';

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

String generateState() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  return base64Url.encode(values);
}

String? storedState;

class SignInService {
  final GoogleSignIn _googleSignIn;
  late final IdConfiguration idConfiguration;
  final Dio dio = Dio();
  final String baseUrl = 'http://127.0.0.1:3000';

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _contactText = '';
  String _token = '';
  bool _isRegistered = false;
  String idClient =
      '257534938006-c7hvo16718jppmasvep1oscbb5sa6398.apps.googleusercontent.com';


  SignInService({required String clientId})
      : _googleSignIn = GoogleSignIn(
          clientId: clientId,
          scopes: scopes,
        ) {
    idConfiguration = IdConfiguration(
      client_id: clientId,
      callback: (onCredentialResponse),
      use_fedcm_for_prompt: false,
    );
  }

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isAuthorized => _isAuthorized;
  String get contactText => _contactText;
  String get token => _token;
  bool get isRegistered => _isRegistered;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<void> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();

      if (_currentUser != null) {
        _isAuthorized = true;
      }
    } catch (e) {
      print("Error in signInSilently: $e");
    }
  }

  Future<void> onError(GoogleIdentityServicesError? error) async {
    print('Error! ${error?.type} (${error?.message})');
  }

  Future<void> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        _isAuthorized = true;
      }
    } catch (e) {
      print("Error in signIn: $e");
    }
  }

  Future<void> handleSignIn() async {
    try {
      if (kIsWeb) {
        id.setLogLevel('debug');
        id.initialize(idConfiguration);    

        id.prompt(onPromptMoment);

        final state = generateState();
        storedState = state;
      } else {
        await signIn();
      }
    } catch (error) {
      print("Error in handleSignIn: $error");
    }
  }

  void onPromptMoment(PromptMomentNotification o) {
    final MomentType type = o.getMomentType();
    print("Prompt moment: ${type}");
  }

  Future<void> handleSignOut() async => await _googleSignIn.disconnect();

  void onCredentialResponse(CredentialResponse response) {
    final Map<String, dynamic>? payload =
        jwt.decodePayload(response.credential);
    if (payload != null) {
    } else {
      print('Could not decode ${response.credential}');
    }
  }

  Future<bool> checkIfRegistered(String email) async {
    try {
      final response = await Dio().get('$baseUrl/user/check-email/$email');

      if (response.statusCode == 200) {
        // Parsea la respuesta como un objeto JSON
        final dynamic responseData = response.data;

        if (responseData is Map<String, dynamic>) {

          if (responseData.containsKey('isEmailRegistered')) {
            final bool isRegistered = responseData['isEmailRegistered'];
            return isRegistered;
          } else {
            throw Exception(
                'Datos de respuesta inválidos: falta "isEmailRegistered"');
          }
        } else {
          throw Exception('Datos de respuesta inválidos');
        }
      } else {
        throw Exception(
            'No se pudo verificar el estado de registro: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al verificar el estado de registro: $e');
      throw e;
    }
  }

  void saveId(String id) {
    final box = GetStorage();
    box.write('id', id);
  }


  void saveToken(String token, String refreshToken) {
    final box = GetStorage();
    box.write('token', token);
    box.write('refresh_token', refreshToken);
  }

  String? getId() {
    final box = GetStorage();
    return box.read('id');
  }

  String? getToken() {
    final box = GetStorage();
    return box.read('token');
  }

  Future<int> logIn(String email) async {

    try {
      Response response =
          await dio.post('$baseUrl/signin/google', data: {'email': email});

      var data = response.data;
      var statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 201) {

        // Verifica si response.data es un Map y contiene el campo 'id'
        if (data is Map<String, dynamic> && data.containsKey('id')) {
          var token = response.data['token'];
          var refresh_token = response.data['refreshToken'];
          var id = response.data['id'];
          saveToken(token, refresh_token);
          saveId(id);
        }
        if (statusCode == 201) {
          return 201;
        }
        return 200;
      }
      if (statusCode == 400) {
        // Si hay campos faltantes, retornamos el código 400
        print('400');

        return 400;
      } else if (statusCode == 500) {
        // Si hay un error interno del servidor, retornamos el código 500
        print('500');

        return 500;
      } else {
        // En caso de otros códigos de estado no manejados explícitamente, puedes lanzar una excepción o devolver un valor adecuado.
        return -1; // O cualquier otro valor que refleje un estado no manejado
      }
      // ignore: deprecated_member_use
    } on DioError catch (e) {
      if (e.response != null) {
        print('Error en la solicitud: ${e.response?.statusCode}');
        print('Datos de respuesta: ${e.response?.data}');
        print('Encabezados de respuesta: ${e.response?.headers}');
        return e.response?.statusCode ?? -2;
      } else {
        print('Error enviando la solicitud: ${e.message}');
        return -3;
      }
    }
  }
}
