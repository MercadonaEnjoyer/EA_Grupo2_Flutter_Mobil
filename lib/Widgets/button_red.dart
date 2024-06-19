import 'package:flutter/material.dart';

class RedButton extends StatelessWidget {
  final String text; 
  final VoidCallback onPressed;
  const RedButton({Key? key, required this.onPressed, required this.text}) : super(key: key);

  @override 
  Widget build(BuildContext context){
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 55),
        backgroundColor: const Color.fromARGB(255, 245, 54, 41),
        foregroundColor: Colors.white,
      ),
      child: Text(text, style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 27,
      ),),
    );
  }
}