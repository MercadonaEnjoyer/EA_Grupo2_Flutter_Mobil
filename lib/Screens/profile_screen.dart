import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/detalles_user.dart';
import 'package:spotfinder/Screens/history.dart';
import 'package:spotfinder/Screens/my_comments_screen.dart';
import 'package:spotfinder/Screens/my_activities.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

late UserService userService;
User? user;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  bool isLoading = true;

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
    getData();
  }

  Future<void> getData() async {
    await userService.getUser().then((retrievedUser) {
      setState(() {
        user = retrievedUser;
        isLoading = false;
      });
    }).catchError((error) {
      // Handle error
      print("Error fetching user data: $error");
    });
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/dgwbrwvux/image/upload');
      final String filename =
          'upload_${DateTime.now().millisecondsSinceEpoch}.png';
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'byxhgftn'
        ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: filename));

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await http.Response.fromStream(response);
          final jsonData = jsonDecode(responseData.body);
          final imageUrl = jsonData['secure_url'];

          user?.image = imageUrl;

          userService.updateUser(user!).then((_) {
            getData();
          }).catchError((error) {
            Get.snackbar(
              'Error',
              'Error sending user to backend: $error',
              snackPosition: SnackPosition.BOTTOM,
            );
          });
        } else {
          Get.snackbar(
            'Error',
            'Error uploading image',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Pallete.textColor,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Error unexpected: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Pallete.textColor,
        );
      }
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }


  Future<void> deleteImageFromUrl(String imageUrl) async {
    final String cloudName = 'dgwbrwvux';
    final String apiKey = '388645541249985';
    final String apiSecret = 'MTRqeAf4459Akl-4NwIbzYP0jCM';
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final Uri uri = Uri.parse(imageUrl);
    final segments = uri.pathSegments;
    final String publicId = segments.last.split('.').first;

    // Create the signature
    final String signatureBase =
        'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final String signature =
        sha1.convert(utf8.encode(signatureBase)).toString();

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

    final response = await http.post(
      url,
      body: {
        'public_id': publicId,
        'api_key': apiKey,
        'timestamp': timestamp,
        'signature': signature,
      },
    );

    if (response.statusCode == 200) {
      user?.image = null;
      userService.updateUser(user!).then((_) {
        getData();
      }).catchError((error) {
        Get.snackbar(
          'Error',
          'Error removing image',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
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
                  _pickImage();
                },
              ),
              if (user?.image != null)
                ListTile(
                  leading: const Icon(Icons.remove_circle),
                  title: const Text('Remove image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    deleteImageFromUrl(user!.image!);
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
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        backgroundColor: Pallete.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de información del usuario
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Avatar y botón de edición
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Pallete.primaryColor,
                          child: user?.image == null
                              ? Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Pallete.paleBlueColor,
                                )
                              : ClipOval(
                                  child: Image.network(
                                    user!.image!,
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: -10,
                          left: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Pallete.paleBlueColor,
                              padding: EdgeInsets.all(8),
                            ),
                            onPressed: () {
                              _showImageSourceActionSheet(context);
                            },
                            child: Icon(
                              Icons.edit,
                              color: Pallete.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                        // Texto del nombre del usuario
                        Positioned(
                          left: 140,
                          top: 27,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              user!.name,
                              style: TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.bold,
                                color: Pallete.accentColor,
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
                            Get.to(() =>
                                UserDetailsPage(user!, onUpdate: getData));
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'My profile',
                              style: TextStyle(color: Pallete.accentColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Get.to(() => MyActivities());
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'My activities',
                              style: TextStyle(color: Pallete.accentColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Get.to(() =>
                                MyCommentsScreen(user!, onUpdate: getData));
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'My reviews',
                              style: TextStyle(color: Pallete.accentColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Get.to(() => HistoryPage(user!));
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'History',
                              style: TextStyle(color: Pallete.accentColor),
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
                            foregroundColor:
                                Pallete.salmonColor, // Color del texto
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.exit_to_app, // Icono de log out
                                  color: Pallete.salmonColor, // Color del icono
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Log out',
                                  style: TextStyle(color: Pallete.salmonColor),
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

              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                child: TextButton(
                  onPressed: () async {
                    final result = await Get.toNamed('/settings');

                    if (result == true) {
                      setState(() {});
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(12.0), // Padding del botón
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings, // Icono de configuración
                        color: Pallete.textColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: TextStyle(color: Pallete.textColor),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
