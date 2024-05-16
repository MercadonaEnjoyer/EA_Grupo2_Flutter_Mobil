import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Screens/detalles_user.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'dart:io';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';

late UserService userService;
User? user;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final GetStorage _storage = GetStorage();
  String? _imagePath;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    user = User(
        name: '',
        email: '',
        phone_number: '',
        gender: '',
        password: ''); // Provide an initial value
    _imagePath = _storage.read<String>('profile_image');
    if (kIsWeb && _imagePath != null && _imagePath!.startsWith('data:image')) {
      _webImage = base64Decode(_imagePath!.split(',').last);
    }
    userService.getUser().then((retrievedUser) {
      setState(() {
        user = retrievedUser;
      });
    }).catchError((error) {
      // Handle error
      print("Error fetching user data: $error");
    });
  }

  void updateProfile() {
    setState(() {
      // Actualiza la información del usuario
      userService.getUser().then((retrievedUser) {
        setState(() {
          user = retrievedUser;
        });
      }).catchError((error) {
        // Maneja el error
        print("Error fetching user data: $error");
      });
    });
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        final imagePath = 'data:image/png;base64,' + base64Encode(bytes);
        _saveImage(imagePath);
      } else {
        _saveImage(pickedImage.path);
      }
    }
  }

  Future<void> _takePicture() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        final imagePath = 'data:image/png;base64,' + base64Encode(bytes);
        _saveImage(imagePath);
      } else {
        _saveImage(pickedImage.path);
      }
    }
  }

  void _saveImage(String path) {
    setState(() {
      _imagePath = path;
      if (kIsWeb) {
        _webImage = base64Decode(_imagePath!.split(',').last);
      }
    });
    _storage.write('profile_image', path);
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? imageProvider;
    if (_imagePath != null) {
      if (kIsWeb) {
        imageProvider = MemoryImage(_webImage!);
      } else {
        imageProvider = FileImage(File(_imagePath!));
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección de información del usuario
          Container(
            padding: EdgeInsets.all(20.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar y botón de edición
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imageProvider,
                  backgroundColor: Colors.blue,
                  child: _imagePath == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        )
                      : null,
                ),
                Positioned(
                  bottom: -10,
                  left: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(8),
                    ),
                    onPressed: () {
                      _showImageSourceActionSheet(context);
                    },
                    child: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ),
                // Texto del nombre del usuario
                Positioned(
                  left: 140, // Ajusta la posición horizontal del nombre
                  top: 27, // Alinea el texto con la parte superior del avatar
                  child: Align(
                    alignment: Alignment
                        .centerLeft, // Alinea el texto alineado a la izquierda
                    child: Text(
                      user!.name,
                      style: TextStyle(
                        fontSize: 26.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botones de navegación
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () {
                    Get.to(() => UserDetailsPage(user!, onUpdate: updateProfile));
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My profile',
                      style: TextStyle(color: Colors.black), // Texto en negro
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    // Navegar a otra pantalla (puedes reemplazar esta función)
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My activities',
                      style: TextStyle(color: Colors.black), // Texto en negro
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    // Navegar a otra pantalla (puedes reemplazar esta función)
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My reviews',
                      style: TextStyle(color: Colors.black), // Texto en negro
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    // Navegar a otra pantalla (puedes reemplazar esta función)
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Preferences',
                      style: TextStyle(color: Colors.black), // Texto en negro
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    userService.logout();
                    Get.to(() => TitleScreen());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red, // Color del texto
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.exit_to_app, // Icono de log out
                          color: Colors.red, // Color del icono
                        ),
                        SizedBox(
                            width: 8), // Espaciado entre el icono y el texto
                        Text(
                          'Log out',
                          style:
                              TextStyle(color: Colors.red), // Color del texto
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
