import 'dart:html';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/activity_detail.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Screens/register_screen.dart';
import 'package:spotfinder/Screens/settingsScreen.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Espera la inicialización de GetStorage

  // Inicializa GoogleSignIn
  final UserService userService = UserService();
  String? token = await userService.getToken();  

token=null;
  setUrlStrategy(PathUrlStrategy());

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;


  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {

  
    final box = GetStorage();
    String? font = box.read('font');

    String? theme = box.read('theme');
    if (theme == null) {
      box.write('theme', "Light");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (token != null) {
        if (!Get.currentRoute.contains('activity')) {
          Get.offAllNamed('/home');
        }
      }
    });

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpotFinder',
      theme: getTheme(theme, font),
      getPages: [
        GetPage(name: '/', page: () => TitleScreen()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
        GetPage(
          name: '/activity/:id',
          page: () => ActivityDetail(),
          transition: Transition.fade,
        ),
      ],
      initialRoute: '/',
    );
  }

  TextTheme? getFontTextTheme(String? font) {
    switch (font) {
      case 'Dyslexia':
        return GoogleFonts.comicNeueTextTheme().copyWith();
      case 'Default':
        return null;
    }
    return null;
  }

  ThemeData? getTheme(String? theme, String? font) {
    ThemeData themeData;

    if (theme == "Dark") {
      Pallete.setDarkTheme();
      themeData = ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.backgroundColor,
        textTheme: getFontTextTheme(font),
      );
    } else if (theme == "Custom") {
      Pallete.setCustomTheme();
      themeData = ThemeData.light().copyWith(
        scaffoldBackgroundColor: Pallete.backgroundColor,
        textTheme: getFontTextTheme(font),
      );
    } else {
      Pallete.setLightTheme();
      themeData = ThemeData.light().copyWith(
        scaffoldBackgroundColor: Pallete.backgroundColor,
        textTheme: getFontTextTheme(font),
      );
    }
    return themeData;
  }
}
