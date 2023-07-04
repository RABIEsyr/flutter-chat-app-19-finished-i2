import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  final String message;
  const CustomSnackBar({ Key? key, required this.message }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }

  void displaySnackBar(BuildContext context, {required String error}) {
    final snackBar = SnackBar(content: Text(error));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}