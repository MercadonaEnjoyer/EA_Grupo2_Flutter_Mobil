import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotfinder/Resources/pallete.dart';

class ParamTextBox extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final TextInputType keyboardType;
  final bool? editable;
  final List<TextInputFormatter>? inputFormatters;

  const ParamTextBox({
    required this.controller,
    required this.text,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.editable,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: editable!,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: TextStyle(
          color: Pallete.paleBlueColor, // Color del texto del label
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                Pallete.paleBlueColor, // Color del borde cuando está enfocado
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Pallete.accentColor.withOpacity(0.8), // Color del borde cuando deshabilitado
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Pallete.accentColor.withOpacity(0.3), // Color del borde cuando deshabilitado
          ),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: Pallete.textColor),
    );
  }
}
