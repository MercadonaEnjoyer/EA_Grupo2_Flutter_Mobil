import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';

class SignUpButton extends StatelessWidget {
  final String text; 
  final VoidCallback onPressed;
  const SignUpButton({super.key, required this.onPressed, required this.text});

  @override 
  Widget build(BuildContext context){
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 55),
        backgroundColor: Pallete.salmonColor,
        foregroundColor: Colors.white,
      ),
      child: Text(text, style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 27,
      ),),
    );
  }
}