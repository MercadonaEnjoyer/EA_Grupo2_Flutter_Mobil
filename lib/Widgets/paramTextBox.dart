import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';

class ParamTextBox extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  const ParamTextBox({super.key, required this.controller, required this.text});

  @override 
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 50,
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Cambia el color del texto a negro
        decoration: InputDecoration(
          filled: true, // Habilita el relleno del campo de texto
        fillColor: Colors.white, // Establece el color de fondo blanco
          enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Pallete.backgroundColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
            color: Pallete.salmonColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(50),
          ),
          hintText: text,
          hintStyle: const TextStyle(
            color: Color.fromARGB(255, 122, 122, 122),
          ),
        ),
        
      ),
    );
  }
}