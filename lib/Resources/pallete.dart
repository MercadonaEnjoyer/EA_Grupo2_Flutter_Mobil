import 'package:flutter/material.dart';

class Pallete {
  static Color backgroundColor = Color.fromRGBO(4, 9, 11, 1);
  static Color primaryColor = Color.fromRGBO(0, 28, 42, 1);
  static Color accentColor = Color.fromRGBO(38, 166, 231, 1);
  static Color textColor = Color.fromRGBO(229, 239, 245, 1);
  static Color salmonColor = Color.fromRGBO(254, 95, 85, 1);
  static Color paleBlueColor = Color.fromRGBO(173, 215, 246, 1);


  static void setLightTheme() {
    backgroundColor = Color.fromRGBO(229, 239, 245, 1);
    primaryColor = Color.fromRGBO(173, 215, 246, 1);
    accentColor = Color.fromRGBO(0, 28, 42, 1);
    textColor = Color.fromRGBO(4, 9, 11, 1);
    salmonColor = Color.fromRGBO(254, 95, 85, 1);
    paleBlueColor = Color.fromRGBO(38, 166, 231, 1);
  }

  static void setDarkTheme() {
    backgroundColor = Color.fromRGBO(4, 9, 11, 1);
    primaryColor = Color.fromRGBO(0, 28, 42, 1);
    accentColor = Color.fromRGBO(38, 166, 231, 1);
    textColor = Color.fromRGBO(229, 239, 245, 1);
    salmonColor = Color.fromRGBO(254, 95, 85, 1);
    paleBlueColor = Color.fromRGBO(173, 215, 246, 1);
  }

  static void setCustomTheme() {
    textColor = Color(0xFFF97306); 
    accentColor = Color(0xFFF97306);
    primaryColor = Color(0xFF7E1E9C); 
    backgroundColor = Color(0xFF7E1E9C);
    salmonColor = Color(0xFFF97306); 
    paleBlueColor = Color(0xFFF97306);
   
  }
}
