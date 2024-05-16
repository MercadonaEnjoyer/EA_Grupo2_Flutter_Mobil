import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';

late UserService userService;

class UserDetailsPage extends StatefulWidget {
  final User user;
  final VoidCallback onUpdate;

  const UserDetailsPage(this.user, {Key? key, required this.onUpdate})
      : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final UpdateScreenController controller = Get.put(UpdateScreenController());

  @override
  void initState() {
    super.initState();
    userService = UserService();
    controller.nombreController.text = widget.user.name;
    controller.generoController.text = widget.user.gender;
    controller.contrasenaController.text = widget.user.password;
    controller.mailController.text = widget.user.email;
    controller.telController.text = widget.user.phone_number;
    controller.date = widget.user.birthday!;
    if (widget.user.birthday != null) {
      final DateTime birthdayDateTime = DateTime.parse(widget.user.birthday!);
      final localBirthdayDateTime = birthdayDateTime.toLocal();
      final formattedBirthday =
          "${localBirthdayDateTime.day}/${localBirthdayDateTime.month}/${localBirthdayDateTime.year}";
      controller.cumpleController.text = formattedBirthday;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ParamTextBox(
              controller: controller.nombreController,
              text: 'Nombre',
            ),
            SizedBox(height: 15),
            ParamTextBox(
              controller: controller.mailController,
              text: 'E-Mail',
            ),
            Visibility(
              visible: controller.invalid,
              child: Text(
                'Invalid',
                style: TextStyle(
                  color: Pallete.salmonColor,
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(height: 15),
            ParamTextBox(
              controller: controller.telController,
              text: 'Teléfono',
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ParamTextBox(
                    controller: controller.cumpleController,
                    text: 'Cumpleaños',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => controller.selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 15),
            ParamTextBox(
              controller: controller.generoController,
              text: 'Género',
            ),
            // SizedBox(height: 15),
            // ParamTextBox(
            //   controller: controller.contrasenaController,
            //   text: 'Contraseña',
            // ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                controller.updateUser(widget.user);
                widget.onUpdate();
              },
              child: const Text ('Update'),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _confirmDeleteAccount(context),
              child: const Text('Eliminar Cuenta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de querer eliminar tu cuenta?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                userService.deleteUser();
                Get.to(TitleScreen());
              },
              child: Text('Eliminar cuenta'),
            ),
          ],
        );
      },
    );
  }
}

class ParamTextBox extends StatelessWidget {
  final TextEditingController controller;
  final String text;

  const ParamTextBox({required this.controller, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: text),
    );
  }
}

class UpdateScreenController extends GetxController {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController generoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController cumpleController = TextEditingController();
  late String date;

  bool invalid = false;
  bool parameters = false;

  void selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final utcDate = pickedDate.toUtc();
      String formattedDate =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      cumpleController.text = formattedDate;

      date = utcDate.toIso8601String();
    }
  }

  void updateUser(User updatedUser) {
    if (nombreController.text.isEmpty ||
        generoController.text.isEmpty ||
        contrasenaController.text.isEmpty ||
        mailController.text.isEmpty ||
        telController.text.isEmpty ||
        cumpleController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Campos vacíos',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (GetUtils.isEmail(mailController.text) == true) {
        User user = User(
          id: updatedUser.id,
          name: nombreController.text,
          gender: generoController.text,
          password: contrasenaController.text,
          email: mailController.text,
          phone_number: telController.text,
          birthday: date,
        );
        userService.updateUser(user).then((statusCode) {
          print('Usuario editado exitosamente');
          Get.snackbar(
            '¡Usuario editado!',
            'Usuario editado correctamente',
            snackPosition: SnackPosition.BOTTOM,
          );
        }).catchError((error) {
          Get.snackbar(
            'Error',
            'Error al enviar usuario al backend: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      } else {
        Get.snackbar(
          'Error',
          'E-mail no válido',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
