import 'package:flutter/material.dart';
import 'package:spotfinder/Widgets/button_sign_in.dart';
import 'package:spotfinder/Widgets/paramTextBox.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';

late UserService userService;
late String? id;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final Controller controller = Get.put(Controller());
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    id = Get.arguments?['id'];
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotFinder'),
      ),
      body: Stack(
        children: [
          // Fondo de pantalla
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido de la pantalla
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo de la empresa
              Image.asset(
                'assets/spotfinder.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(20), // Ajusta el margen del cuadro negro aquí
                padding: const EdgeInsets.all(20), // Ajusta el padding del cuadro negro aquí
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7), // Color del cuadro negro con opacidad
                  borderRadius: BorderRadius.circular(20), // Bordes redondeados del cuadro
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ParamTextBox(
                        controller: controller.mailController,
                        text: 'e-mail',
                        prefixIcon: Icon(Icons.email)
                    ),
                    const SizedBox(height: 10),
                    ParamTextBox(
                      controller: controller.contrasenaController,
                      text: 'Password',
                      obscureText: _obscureText,
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SignInButton(
                        onPressed: () => controller.logIn(), text: 'Sign in'),
                    const SizedBox(height: 10),
                    // Nuevo texto para olvidar la contraseña
                    GestureDetector(
                      onTap: () {
                        // Aquí puedes agregar la acción para olvidar la contraseña
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Controller extends GetxController {
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController mailController = TextEditingController();

  bool invalid = false;
  bool parameters = false;

  void logIn() {
    if (contrasenaController.text.isEmpty || mailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Campos vacios',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (GetUtils.isEmail(mailController.text) == true) {
        final logIn = (
          email: mailController.text,
          password: contrasenaController.text,
        );

        userService.logIn(logIn).then((statusCode) {
          print('Usuario logeado exitosamente');
          if (id != null) {
            Get.toNamed('/activity/$id');
          } else {
            Get.toNamed('/home');
          }
          contrasenaController.text = '';
        }).catchError((error) {
          // Manejar errores de solicitud HTTP
          Get.snackbar(
            'Error',
            'Los datos introducidos son incorrectos. Prueba otra vez.',
            snackPosition: SnackPosition.BOTTOM,
          );
          print('Error al enviar log in al backend: $error');
        });
      } else {
        Get.snackbar(
          'Error',
          'e-mail no valido',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
