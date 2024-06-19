import 'package:flutter/gestures.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Resources/sign_in_button.dart';
import 'package:spotfinder/Services/SignInService.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/id.dart' as gis_id;
import 'package:spotfinder/Screens/register_screen_google.dart';

late SignInService _signInService;

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

class TitleScreen extends StatefulWidget {
  @override
  _TitleScreenState createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  // late SignInService signInService;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String email = '';
  late TokenClient tokenClient;
  late TokenClientConfig config;

  String idClient =
      '257534938006-c7hvo16718jppmasvep1oscbb5sa6398.apps.googleusercontent.com';

  @override
  void initState() {
    super.initState();

   
    _signInService = SignInService(
      clientId: idClient,
    );

    _signInService.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        gis_id.id.setLogLevel('debug');
        gis_id.id.initialize(_signInService.idConfiguration);
    
        gis_id.id.prompt(_signInService.onPromptMoment);

        _handleSignIn();
        _currentUser = account;
        
      });
    });

    _signInService.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _signInService.handleSignIn();

      email = _currentUser?.email ?? '';

      final isRegistered = await _signInService.checkIfRegistered(email);

      if (!isRegistered) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return RegisterGoogleScreen(
              onRegistrationComplete: () async {
                setState(() {
                  _isAuthorized = true;
                });
                Navigator.of(context).pop();
              },
              currentUser: _currentUser,
            );
          },
        );
      } else {
        await _signInService.logIn(email);
        Get.offAllNamed("/home");
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> _handleSignOut() async {
    await _signInService.handleSignOut();
    // Get.toNamed('/');
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text(
          'Google sign in.',
          style: TextStyle(color: Colors.white),
        ),
        buildSignInButton(
          onPressed: _handleSignIn,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? id = Get.arguments?['id'];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Fondo de pantalla
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ),
          // Contenido de la pantalla
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo de SpotFinder
              Image.asset(
                'assets/spotfinder.png',
                height: 200,
                width: 200,
              ),
              Container(
                margin: const EdgeInsets.all(
                  20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón
                    Get.toNamed('/login', arguments: {'id': id});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete
                        .salmonColor, // Cambia el color del botón a salmón
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 26, // Ajusta el tamaño del texto aquí
                      color: Colors.white, // Cambia el color del texto a blanco
                    ),
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(
                      text: "Don't have an account? ",
                    ),
                    TextSpan(
                      text: "Sign up",
                      style: TextStyle(
                        color: Pallete.salmonColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration
                            .underline, // Subraya el texto "Sign up"
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed('/register', arguments: {'id': id});
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildBody(),
            ],
          ),
        ],
      ),
    );
  }
}
