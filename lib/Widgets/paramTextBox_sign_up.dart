import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para usar inputFormatters
import 'package:spotfinder/Resources/pallete.dart';

class ParamTextBox extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final IconButton? suffixIcon;
  final bool editable;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixWidget;
  final TextInputType? keyboardType;
  final bool obscureText;

  const ParamTextBox({
    Key? key,
    required this.controller,
    required this.text,
    this.suffixIcon,
    this.editable = true,
    this.inputFormatters,
    this.prefixWidget,
    this.keyboardType, this.obscureText=false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 200,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TextFormField(
            controller: controller,
            readOnly: !editable,
            obscureText: obscureText,
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Pallete.backgroundColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Pallete.salmonColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              hintText: text,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              prefixIcon: prefixWidget != null
                  ? SizedBox(
                      width: constraints.maxWidth * 0.39, 
                      child: Padding(
                       padding: const EdgeInsets.only(left: 6.0),
                       child: prefixWidget!,
                      ),
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: suffixIcon!,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
